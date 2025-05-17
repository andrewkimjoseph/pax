// src/withdrawToPaymentMethod/index.ts
import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import {
  Address,
  createPublicClient,
  encodeFunctionData,
  http,
} from "viem";
import { entryPoint07Address } from "viem/account-abstraction";
import { celo } from "viem/chains";
import { createPimlicoClient } from "permissionless/clients/pimlico";
import { createSmartAccountClient } from "permissionless";
import { toSimpleSmartAccount } from "permissionless/accounts";
import { PrivyClient } from "@privy-io/server-auth";
import { createViemAccount } from "@privy-io/server-auth/viem";

import { paxAccountV1ABI } from "../../shared/abis/paxAccountV1ABI";
import {
  PIMLICO_API_KEY,
  PRIVY_APP_ID,
  PRIVY_APP_SECRET,
  PRIVY_WALLET_AUTH_PRIVATE_KEY,
  FUNCTION_RUNTIME_OPTS,
} from "../../shared/config";

// Initialize clients
const publicClient = createPublicClient({
  chain: celo,
  transport: http(),
});

const pimlicoUrl = `https://api.pimlico.io/v2/42220/rpc?apikey=${PIMLICO_API_KEY}`;

const pimlicoClient = createPimlicoClient({
  transport: http(pimlicoUrl),
  entryPoint: {
    address: entryPoint07Address,
    version: "0.7",
  },
});

const privy = new PrivyClient(PRIVY_APP_ID, PRIVY_APP_SECRET, {
  walletApi: {
    authorizationPrivateKey: PRIVY_WALLET_AUTH_PRIVATE_KEY,
  },
});

/**
 * Cloud function to withdraw tokens to a payment method
 */
export const withdrawToPaymentMethod = onCall(FUNCTION_RUNTIME_OPTS, async (request) => {
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
      paxAccountAddress, 
      paymentMethodId = 0,
      amountRequested,
      currency,
      decimals = 18 // Default to 18 decimals (standard for most ERC20 tokens)
    } = request.data as {
      serverWalletId: string;
      paxAccountAddress: string;
      paymentMethodId?: number;
      amountRequested: string; // Human-readable amount (e.g., "0.5")
      currency: string; // ERC20 token address
      decimals?: number; // Token decimals
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
    });

    // Get the server wallet from Privy
    const wallet = await privy.walletApi.getWallet({
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
      privy,
    });

    // Create the Simple smart account
    const smartAccount = await toSimpleSmartAccount({
      client: publicClient,
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
      bundlerTransport: http(pimlicoUrl),
      paymaster: pimlicoClient,
      userOperation: {
        estimateFeesPerGas: async () => {
          return (await pimlicoClient.getUserOperationGasPrice()).fast;
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

    // Return the transaction hash and details
    return {
      success: true,
      txnHash,
      details: {
        paxAccountAddress,
        paymentMethodId,
        amountRequested,
        amountInWei: amountInWei.toString(),
        currency,
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