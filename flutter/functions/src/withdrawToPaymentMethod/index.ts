// src/withdrawToPaymentMethod/index.ts
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
import { createViemAccount } from "@privy-io/server-auth/viem";

import { paxAccountV1ABI } from "../../shared/abis/paxAccountV1ABI";
import {
  FUNCTION_RUNTIME_OPTS,
  PRIVY_CLIENT,
  PUBLIC_CLIENT,
  PIMLICO_CLIENT,
  PIMLICO_URL,
} from "../../shared/config";
import { createWithdrawalRecord } from "../../shared/utils/createWithdrawal";

/**
 * Cloud function to withdraw tokens to a payment method
 */
export const withdrawToPaymentMethod = onCall(FUNCTION_RUNTIME_OPTS, async (request) => {
  try {
    // Ensure the user is authenticated
    const { createSmartAccountClient } = await import("permissionless");
    const { toSimpleSmartAccount } = await import("permissionless/accounts");
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called by an authenticated user."
      );
    }

    const userId = request.auth.uid;
    const { 
      serverWalletId, 
      paxAccountAddress, 
      paymentMethodId, // This is now the contract payment method ID (predefinedId - 1)
      withdrawalPaymentMethodId, // This is the string ID for the withdrawal record
      amountRequested,
      currency,
      decimals = 18, // Default to 18 decimals (standard for most ERC20 tokens)
      tokenId, // Add tokenId to the request data
    } = request.data as {
      serverWalletId: string;
      paxAccountAddress: string;
      paymentMethodId: number; // Changed to number for contract
      withdrawalPaymentMethodId: string; // Added for withdrawal record
      amountRequested: string; // Human-readable amount (e.g., "0.5")
      currency: string; // ERC20 token address
      decimals?: number; // Token decimals
      tokenId: number; // Add tokenId to the type
    };

    // Validate required parameters
    if (!serverWalletId) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required parameter: serverWalletId"
      );
    }

    if (!paxAccountAddress) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required parameter: paxAccountAddress"
      );
    }

    if (!amountRequested) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required parameter: amountRequested"
      );
    }

    if (!currency) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required parameter: currency"
      );
    }

    if (tokenId === undefined) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required parameter: tokenId"
      );
    }

    if (!withdrawalPaymentMethodId) {
      throw new HttpsError(
        "invalid-argument",
        "Missing required parameter: withdrawalPaymentMethodId"
      );
    }
    
    // Convert the decimal amount to wei (smallest unit)
    // Example: 0.5 tokens with 18 decimals = 0.5 * 10^18 = 500000000000000000 wei
    let amountInWei: bigint;
    try {
      // Parse the amount as a floating point number
      const amountFloat = parseFloat(amountRequested);
      
      // Convert to wei by multiplying by 10^decimals
      const multiplier = BigInt(10) ** BigInt(decimals);
      amountInWei = BigInt(Math.floor(amountFloat * Number(multiplier)));
      
      // For high precision, we could use a library like bignumber.js instead
      // This approach may have precision limitations for very small numbers
    } catch (error) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid amountRequested format. Please provide a valid number."
      );
    }

    logger.info("Withdrawing tokens to payment method", {
      userId,
      paxAccountAddress,
      paymentMethodId,
      amountRequested,
      amountInWei: amountInWei.toString(),
      currency,
      serverWalletId,
      tokenId,
    });

    // Get the server wallet from Privy
    const wallet = await PRIVY_CLIENT.walletApi.getWallet({
      id: serverWalletId,
    });

    if (!wallet) {
      throw new HttpsError(
        "not-found",
        "Server wallet not found with the provided ID"
      );
    }

    // Create viem account from Privy wallet
    const serverWalletAccount = await createViemAccount({
      walletId: wallet.id,
      address: wallet.address as Address,
      privy: PRIVY_CLIENT,
    });

    // Create the Simple smart account
    const smartAccount = await toSimpleSmartAccount({
      client: PUBLIC_CLIENT,
      owner: serverWalletAccount,
      entryPoint: {
        address: entryPoint07Address,
        version: "0.7",
      },
    });

    logger.info("Using Smart Account", {
      address: smartAccount.address,
    });

    // Create the smart account client
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

    // Encode the function call to withdrawToPaymentMethod
    const withdrawData = encodeFunctionData({
      abi: paxAccountV1ABI,
      functionName: "withdrawToPaymentMethod",
      args: [
        BigInt(paymentMethodId),
        amountInWei,
        currency as Address,
      ],
    });

    // Send user operation to call withdrawToPaymentMethod
    const userOpTxnHash = await smartAccountClient.sendUserOperation({
      calls: [
        {
          to: paxAccountAddress as Address,
          value: BigInt(0),
          data: withdrawData,
        },
      ],
    });

    logger.info("User operation submitted", { userOpTxnHash });

    // Wait for user operation receipt
    const userOpReceipt = await smartAccountClient.waitForUserOperationReceipt({
      hash: userOpTxnHash,
    });

    const txnHash = userOpReceipt.receipt.transactionHash;
    logger.info("Transaction confirmed", { txnHash });

    // Create withdrawal record
    const withdrawalId = await createWithdrawalRecord({
      participantId: userId,
      paymentMethodId: withdrawalPaymentMethodId, // Use the string ID for the withdrawal record
      amountRequested: parseFloat(amountRequested),
      rewardCurrencyId: tokenId,
      txnHash,
    });

    // Return the transaction hash and details
    return {
      success: true,
      txnHash,
      withdrawalId,
      details: {
        paxAccountAddress,
        paymentMethodId,
        amountRequested,
        amountInWei: amountInWei.toString(),
        currency,
        tokenId,
      },
    };
  } catch (error) {
    logger.error("Error withdrawing tokens", { error });

    let errorMessage = "Unknown error occurred";
    if (error instanceof Error) {
      errorMessage = error.message;
    }

    throw new HttpsError(
      "internal",
      `Failed to withdraw tokens: ${errorMessage}`
    );
  }
});