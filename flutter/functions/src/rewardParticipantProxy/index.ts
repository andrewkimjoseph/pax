// src/rewardParticipant/index.ts (corrected)
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
  DB
} from "../../shared/config";
import { 
  createRewardClaimSignaturePackage, 
  generateRandomNonce 
} from "../../shared/utils/rewardingSignature";
import { createRewardRecord, updateRewardWithTxnHash } from "../../shared/utils/createReward";
import { sendParticipantNotification } from "../../shared/utils/sendNotification";
import { getCurrencySymbol } from "../../shared/utils/currencyUtils";

/**
 * Firebase onCall function to reward a participant after task completion.
 * This function replaces the Firestore trigger for more reliability.
 */
export const rewardParticipantProxy = onCall(FUNCTION_RUNTIME_OPTS, async (request) => {
  try {
    // Ensure the user is authenticated
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called by an authenticated user."
      );
    }

    const { taskCompletionId } = request.data as {
      taskCompletionId: string;
    };

    if (!taskCompletionId) {
      throw new HttpsError(
        "invalid-argument",
        "Missing taskCompletionId parameter."
      );
    }

    // Get task completion data
    const firestore = DB();
    const taskCompletionDoc = await firestore.collection('task_completions').doc(taskCompletionId).get();
    
    if (!taskCompletionDoc.exists) {
      throw new HttpsError("not-found", "Task completion not found");
    }
    
    const taskCompletionData = taskCompletionDoc.data();
    if (!taskCompletionData) {
      throw new HttpsError("not-found", "Task completion data is empty");
    }

    // Extract required data from the task completion
    const { taskId, participantId } = taskCompletionData;
    if (!taskId || !participantId) {
      throw new HttpsError(
        "invalid-argument", 
        "Task completion missing required fields"
      );
    }

    logger.info("Starting participant reward process", {
      taskCompletionId,
      taskId,
      participantId
    });

    // Step 1: Get required data from related collections
    // Get task data for reward details
    const taskDoc = await firestore.collection('tasks').doc(taskId).get();
    if (!taskDoc.exists) {
      throw new HttpsError("not-found", "Task not found");
    }
    
    const taskData = taskDoc.data();
    if (!taskData || !taskData.rewardAmountPerParticipant || !taskData.rewardCurrencyId || 
        !taskData.managerContractAddress || !taskData.taskMasterId) {
      throw new HttpsError("invalid-argument", "Task missing required reward data");
    }
    
    const rewardAmountPerParticipant = taskData.rewardAmountPerParticipant;
    const rewardCurrencyId = taskData.rewardCurrencyId;
    const taskManagerContractAddress = taskData.managerContractAddress as Address;
    const taskMasterId = taskData.taskMasterId;
    
    // Get the participant's PaxAccount
    const participantPaxAccountDoc = await firestore.collection('pax_accounts').doc(participantId).get();
    if (!participantPaxAccountDoc.exists) {
      throw new HttpsError("not-found", "PaxAccount record not found for participant");
    }
    
    const participantPaxAccountData = participantPaxAccountDoc.data();
    if (!participantPaxAccountData || !participantPaxAccountData.contractAddress || 
        !participantPaxAccountData.serverWalletId) {
      throw new HttpsError("invalid-argument", "Participant PaxAccount missing required data");
    }
    
    const paxAccountContractAddress = participantPaxAccountData.contractAddress as Address;
    const serverWalletId = participantPaxAccountData.serverWalletId;
    
    // Get the task master's PaxAccount for the serverWalletId
    const taskMasterPaxAccountDoc = await firestore.collection('pax_accounts').doc(taskMasterId).get();
    if (!taskMasterPaxAccountDoc.exists) {
      throw new HttpsError("not-found", "PaxAccount record not found for task master");
    }
    
    const taskMasterPaxAccountData = taskMasterPaxAccountDoc.data();
    if (!taskMasterPaxAccountData || !taskMasterPaxAccountData.serverWalletId) {
      throw new HttpsError("invalid-argument", "Task master PaxAccount missing serverWalletId");
    }
    
    const taskMasterServerWalletId = taskMasterPaxAccountData.serverWalletId;

    // Step 2: Get wallet information and create accounts
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

    // Create server wallet account and smart account
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

    // Step 3: Generate reward claim signature
    const nonce = generateRandomNonce();
    // Use taskCompletionId as the rewardId for consistency
    const rewardId = taskCompletionId;
    
    logger.info("Generating reward claim signature", {
      participantProxy,
      rewardId,
      nonce: nonce.toString()
    });

    const signaturePackage = await createRewardClaimSignaturePackage(
      taskManagerContractAddress,
      taskMasterWallet.id,
      taskMasterWallet.address as Address,
      participantProxy,
      rewardId,
      nonce
    );

    if (!signaturePackage.isValid) {
      throw new HttpsError("internal", "Signature validation failed");
    }

    const signature = signaturePackage.signature;
    const nonceString = signaturePackage.nonce;

    // Step 4: Submit reward claim transaction
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

    // First, create a pending reward record
    const rewardRecordId = await createRewardRecord({
      taskId,
      participantId,
      taskCompletionId,
      signature,
      nonce: nonceString,
      amount: rewardAmountPerParticipant,
      rewardCurrencyId
    });

    // Encode the function call to processRewardClaimByParticipantProxy
    const rewardClaimData = encodeFunctionData({
      abi: taskManagerV1ABI,
      functionName: "processRewardClaimByParticipantProxy",
      args: [
        participantProxy,
        paxAccountContractAddress,
        rewardId,
        nonce,
        signature
      ],
    });

    logger.info("Submitting reward claim transaction");
    
    const userOpTxnHash = await smartAccountClient.sendUserOperation({
      calls: [
        {
          to: taskManagerContractAddress,
          value: BigInt(0),
          data: rewardClaimData,
        },
      ],
    });

    logger.info("Transaction submitted", { userOpTxnHash });

    const userOpReceipt = await smartAccountClient.waitForUserOperationReceipt({
      hash: userOpTxnHash,
    });

    const txnHash = userOpReceipt.receipt.transactionHash;
    logger.info("Transaction confirmed", { txnHash });

    // Step 5: Update the reward record with the transaction hash
    await updateRewardWithTxnHash(rewardRecordId, txnHash);
    
    logger.info("Reward record updated with transaction hash", { rewardRecordId, txnHash });

    // Step 6: Send notification to the participant
    await sendParticipantNotification(
      participantId,
      "Reward Received! 🎉",
      `You've received ${getCurrencySymbol(rewardCurrencyId)} ${rewardAmountPerParticipant} for completing a task.`,
      {
        type: "reward",
        rewardId: rewardRecordId,
        taskId,
        taskCompletionId,
        amount: rewardAmountPerParticipant,
        currency: rewardAmountPerParticipant
      }
    );

    // Return complete response with all relevant data
    return {
      success: true,
      participantProxy,
      paxAccountContractAddress,
      rewardId, // This is the taskCompletionId
      taskId,
      participantId,
      taskCompletionId,
      signature,
      nonce: nonceString,
      txnHash,
      rewardRecordId,
      amount: rewardAmountPerParticipant,
      rewardCurrencyId
    };
  } catch (error) {
    logger.error("Reward process failed", { error });
    
    throw new HttpsError(
      "internal",
      `Failed to reward participant: ${error instanceof Error ? error.message : "Unknown error"}`
    );
  }
});