// src/screenParticipant/index.ts
import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import {
  Address,
  encodeFunctionData,
  http,
} from "viem";
import { entryPoint07Address } from "viem/account-abstraction";
import { celo } from "viem/chains";
import { createSmartAccountClient } from "permissionless";
import { toSimpleSmartAccount } from "permissionless/accounts";
import { createViemAccount } from "@privy-io/server-auth/viem";

import { taskManagerV1ABI } from "../../shared/abis/taskManagerV1ABI";
import {
  FUNCTION_RUNTIME_OPTS,
  PRIVY_CLIENT,
  PUBLIC_CLIENT,
  PIMLICO_CLIENT,
  PIMLICO_URL,
} from "../../shared/config";
import { 
  createScreeningSignaturePackage, 
  generateRandomNonce 
} from "../../shared/utils/screeningSignature";
import { createScreeningRecord } from "../../shared/utils/createScreening";

/**
 * Comprehensive cloud function to screen a participant
 * This function handles the complete process:
 * 1. Generates a signature for screening
 * 2. Submits the transaction to the blockchain
 * 3. Creates a screening record with the transaction hash
 * 
 * Returns all relevant data including the participant proxy address, 
 * signature, nonce, transaction hash, and screening record ID.
 */
export const screenParticipantProxy = onCall(FUNCTION_RUNTIME_OPTS, async (request) => {
  try {
    // Ensure the user is authenticated
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called by an authenticated user."
      );
    }

    const userId = request.auth.uid;
    const { 
      serverWalletId,
      taskId,
      participantId,
      taskManagerContractAddress,
      taskMasterServerWalletId
    } = request.data as {
      serverWalletId: string;
      taskId: string;
      participantId: string;
      taskManagerContractAddress: Address;
      taskMasterServerWalletId: string;
    };

    // Validate required parameters
    if (!serverWalletId || !taskId || !participantId || 
        !taskManagerContractAddress || !taskMasterServerWalletId) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required parameters. Please provide serverWalletId, taskId, participantId, taskManagerContractAddress, and taskMasterServerWalletId."
      );
    }

    logger.info("Starting comprehensive participant screening process", {
      userId,
      taskId,
      participantId,
    });

    // Get wallet information in parallel
    const [serverWallet, taskMasterWallet] = await Promise.all([
      PRIVY_CLIENT.walletApi.getWallet({ id: serverWalletId }),
      PRIVY_CLIENT.walletApi.getWallet({ id: taskMasterServerWalletId })
    ]);

    if (!serverWallet) {
      throw new HttpsError("not-found", "Server wallet not found");
    }

    if (!taskMasterWallet) {
      throw new HttpsError("not-found", "Task master wallet not found");
    }

    // Step 1: Create server wallet account and smart account
    const serverWalletAccount = await createViemAccount({
      walletId: serverWallet.id,
      address: serverWallet.address as Address,
      privy: PRIVY_CLIENT,
    });

    const smartAccount = await toSimpleSmartAccount({
      client: PUBLIC_CLIENT,
      owner: serverWalletAccount,
      entryPoint: {
        address: entryPoint07Address,
        version: "0.7",
      },
    });

    const participantProxy = smartAccount.address;
    logger.info("Smart account created", { participantProxy });

    // Step 2: Generate screening signature
    const nonce = generateRandomNonce();
    
    logger.info("Generating screening signature", {
      participantProxy,
      taskId,
      nonce: nonce.toString()
    });

    const signaturePackage = await createScreeningSignaturePackage(
      taskManagerContractAddress,
      taskMasterWallet.id,
      taskMasterWallet.address as Address,
      participantProxy,
      taskId,
      nonce
    );

    if (!signaturePackage.isValid) {
      throw new HttpsError("internal", "Generated signature failed verification");
    }

    const signature = signaturePackage.signature;
    const nonceString = signaturePackage.nonce;

    // Step 3: Submit screening transaction
    const smartAccountClient = createSmartAccountClient({
      account: smartAccount,
      chain: celo,
      bundlerTransport: http(PIMLICO_URL),
      paymaster: PIMLICO_CLIENT,
      userOperation: {
        estimateFeesPerGas: async () => {
          return (await PIMLICO_CLIENT.getUserOperationGasPrice()).fast;
        },
      },
    });

    const screeningData = encodeFunctionData({
      abi: taskManagerV1ABI,
      functionName: "screenParticipantProxy",
      args: [
        participantProxy,
        taskId,
        nonce,
        signature
      ],
    });

    logger.info("Submitting screening transaction");
    
    const userOpTxnHash = await smartAccountClient.sendUserOperation({
      calls: [
        {
          to: taskManagerContractAddress,
          value: BigInt(0),
          data: screeningData,
        },
      ],
    });

    logger.info("Transaction submitted", { userOpTxnHash });

    const userOpReceipt = await smartAccountClient.waitForUserOperationReceipt({
      hash: userOpTxnHash,
    });

    const txnHash = userOpReceipt.receipt.transactionHash;
    logger.info("Transaction confirmed", { txnHash });

    // Step 4: Create screening record using the utility function
    const screeningId = await createScreeningRecord({
      taskId,
      participantId,
      signature,
      nonce: nonceString,
      txnHash,
    });
    
    logger.info("Screening record created", { screeningId });

    // Return complete response with all relevant data
    return {
      success: true,
      participantProxy,
      taskId,
      signature,
      nonce: nonceString,
      txnHash,
      screeningId,
    };
  } catch (error) {
    logger.error("Comprehensive screening process failed", { error });
    
    throw new HttpsError(
      "internal",
      `Failed to screen participant: ${error instanceof Error ? error.message : "Unknown error"}`
    );
  }
});