// src/addNonPrimaryWithdrawalMethodToPaxAccountV1Proxy/index.ts
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { Address, http, encodeFunctionData } from "viem";
import { entryPoint07Address } from "viem/account-abstraction";
import { celo } from "viem/chains";
import { createViemAccount } from "@privy-io/server-auth/viem";
import {
  FUNCTION_RUNTIME_OPTS,
  PRIVY_CLIENT,
  PUBLIC_CLIENT,
  PIMLICO_URL,
  AUTH,
} from "../../utils/config";
import { paxAccountV1ABI } from "../../utils/abis/paxAccountV1ABI";
import { getReferralTagFromSmartAccount } from "../../utils/helpers/getReferralTagFromSmartAccount";

// Initialize clients

/**
 * Cloud function to add a non-primary payment method to an existing PaxAccount proxy contract
 */
export const addNonPrimaryWithdrawalMethodToPaxAccountV1Proxy = onCall(
  FUNCTION_RUNTIME_OPTS,
  async (request) => {
    try {
      const { createSmartAccountClient } = await import("permissionless");
      const { toSimpleSmartAccount } = await import("permissionless/accounts");
      const { createPimlicoClient } = await import(
        "permissionless/clients/pimlico"
      );

      const PIMLICO_CLIENT = createPimlicoClient({
        transport: http(PIMLICO_URL),
        entryPoint: {
          address: entryPoint07Address,
          version: "0.7",
        },
      });

      // Ensure the user is authenticated
      if (!request.auth) {
        logger.error(
          "Unauthenticated request to addNonPrimaryWithdrawalMethodToPaxAccountV1Proxy",
          {
            requestAuth: request.auth,
          }
        );
        throw new HttpsError(
          "unauthenticated",
          "The function must be called by an authenticated user."
        );
      }

      const userId = request.auth.uid;

      // Check if the user is disabled
      const userRecord = await AUTH.getUser(userId);
      if (userRecord.disabled) {
        throw new HttpsError("permission-denied", "This user is disabled.");
      }

      const {
        walletAddress,
        _paymentMethodId,
        serverWalletId,
        contractAddress,
      } = request.data as {
        walletAddress: string;
        _paymentMethodId: number;
        serverWalletId: string;
        contractAddress: string;
      };

      if (!_paymentMethodId || _paymentMethodId === 0) {
        logger.error(
          "Invalid payment method ID in addNonPrimaryWithdrawalMethodToPaxAccountV1Proxy",
          { _paymentMethodId }
        );
        throw new HttpsError(
          "invalid-argument",
          "Payment method ID must be provided and cannot be 0 (reserved for primary)"
        );
      }

      if (!walletAddress) {
        logger.error(
          "Missing required parameter: paymentMethodAddress in addNonPrimaryWithdrawalMethodToPaxAccountV1Proxy",
          { walletAddress }
        );
        throw new HttpsError(
          "invalid-argument",
          "Missing required parameter: paymentMethodAddress"
        );
      }

      if (!serverWalletId) {
        logger.error(
          "Missing required parameter: serverWalletId in addNonPrimaryWithdrawalMethodToPaxAccountV1Proxy",
          { serverWalletId }
        );
        throw new HttpsError(
          "invalid-argument",
          "Missing required parameter: serverWalletId"
        );
      }

      if (!contractAddress) {
        logger.error(
          "Missing required parameter: contractAddress in addNonPrimaryWithdrawalMethodToPaxAccountV1Proxy",
          { contractAddress }
        );
        throw new HttpsError(
          "invalid-argument",
          "Missing required parameter: contractAddress"
        );
      }

      logger.info("Adding non-primary payment method to PaxAccount", {
        userId,
        _paymentMethodId,
        walletAddress,
        serverWalletId,
        contractAddress,
      });

      // Get the server wallet from Privy
      const wallet = await PRIVY_CLIENT.walletApi.getWallet({
        id: serverWalletId,
      });

      if (!wallet) {
        logger.error(
          "Server wallet not found with the provided ID in addNonPrimaryWithdrawalMethodToPaxAccountV1Proxy",
          { serverWalletId }
        );
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

      const addNonPrimaryPaymentMethodData = encodeFunctionData({
        abi: paxAccountV1ABI,
        functionName: "addNonPrimaryPaymentMethod",
        args: [BigInt(_paymentMethodId), walletAddress as Address],
      });

      const referralTag = getReferralTagFromSmartAccount(smartAccountClient);

      // Prepare the transaction data
      const transactionData = {
        to: contractAddress as Address,
        data: (addNonPrimaryPaymentMethodData + referralTag) as Address,
      };

      // Send the transaction via account abstraction
      const userOpTxnHash = await smartAccountClient.sendUserOperation({
        calls: [transactionData],
      });

      logger.info("User operation submitted for adding payment method", {
        userOpTxnHash,
      });

      // Wait for user operation receipt
      const userOpReceipt =
        await smartAccountClient.waitForUserOperationReceipt({
          hash: userOpTxnHash,
        });

      if (!userOpReceipt.success) {
        logger.error(
          "User operation failed in addNonPrimaryWithdrawalMethodToPaxAccountV1Proxy",
          {
            userOpReceipt,
          }
        );
        throw new HttpsError(
          "internal",
          `User operation failed: ${JSON.stringify(userOpReceipt)}`
        );
      }

      const txnHash = userOpReceipt.receipt.transactionHash;
      logger.info("Payment method addition transaction confirmed", { txnHash });

      return {
        txnHash,
      };
    } catch (error) {
      logger.error("Error adding non-primary payment method to PaxAccount", {
        error,
      });

      let errorMessage = "Unknown error occurred";
      if (error instanceof Error) {
        errorMessage = error.message;
      }

      throw new HttpsError(
        "internal",
        `Failed to add payment method: ${errorMessage}`
      );
    }
  }
);
