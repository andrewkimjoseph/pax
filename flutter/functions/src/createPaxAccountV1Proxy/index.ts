// src/createPaxAccountProxy/index.ts
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { Address, http } from "viem";
import { entryPoint07Address } from "viem/account-abstraction";
import { celo } from "viem/chains";
import { createViemAccount } from "@privy-io/server-auth/viem";
import {
  PAXACCOUNT_V1_IMPLEMENTATION_ADDRESS,
  FUNCTION_RUNTIME_OPTS,
  CREATE2_FACTORY,
  PRIVY_CLIENT,
  PUBLIC_CLIENT,
  PIMLICO_URL,
  DB,
  AUTH,
} from "../../utils/config";
import { getDeployedProxyContractAddress } from "../../utils/helpers/getDeployedProxyContractAddress";
import { getProxyDeployDataAndSalt } from "../../utils/helpers/getProxyDeployDataAndSalt";
import { getReferralTagFromSmartAccount } from "../../utils/helpers/getReferralTagFromSmartAccount";

// Initialize clients

/**
 * Cloud function to create a PaxAccount proxy contract
 */
export const createPaxAccountV1Proxy = onCall(
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
        logger.error("Unauthenticated request to createPaxAccountV1Proxy", {
          requestAuth: request.auth,
        });
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

      const { _primaryPaymentMethod, serverWalletId } = request.data as {
        _primaryPaymentMethod: string;
        serverWalletId: string;
      };

      if (!_primaryPaymentMethod) {
        logger.error(
          "Missing required parameter: walletAddress in createPaxAccountV1Proxy",
          { _primaryPaymentMethod }
        );
        throw new HttpsError(
          "invalid-argument",
          "Missing required parameter: walletAddress"
        );
      }

      if (!serverWalletId) {
        logger.error(
          "Missing required parameter: serverWalletId in createPaxAccountV1Proxy",
          { serverWalletId }
        );
        throw new HttpsError(
          "invalid-argument",
          "Missing required parameter: serverWalletId"
        );
      }

      logger.info("Deploying PaxAccount proxy", {
        userId,
        _primaryPaymentMethod,
        serverWalletId,
      });

      // Check if PaxAccount already exists for this user
      const firestore = DB();
      const paxAccountDoc = await firestore
        .collection("pax_accounts")
        .doc(userId)
        .get();
      if (paxAccountDoc.exists) {
        const paxAccountData = paxAccountDoc.data();
        if (
          paxAccountData?.contractAddress &&
          paxAccountData?.contractCreationTxnHash
        ) {
          logger.info("PaxAccountContract already exists for user", {
            contractAddress: paxAccountData.contractAddress,
            txnHash: paxAccountData.contractCreationTxnHash,
          });
          return {
            contractAddress: paxAccountData.contractAddress,
            txnHash: paxAccountData.contractCreationTxnHash,
          };
        }
      } else {
        logger.info("No PaxAccount contract found for user, creating new one", {
          userId,
        });
      }

      // Get the server wallet from Privy
      const wallet = await PRIVY_CLIENT.walletApi.getWallet({
        id: serverWalletId,
      });

      if (!wallet) {
        logger.error(
          "Server wallet not found with the provided ID in createPaxAccountV1Proxy",
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
        // version: "1.4.1",
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

      const _owner = smartAccount.address;

      // Get deployment data with salt for CREATE2
      const { deployData } = getProxyDeployDataAndSalt(
        PAXACCOUNT_V1_IMPLEMENTATION_ADDRESS,
        _owner,
        _primaryPaymentMethod as Address // Use the provided wallet address as primary payment method
      );

      const referralTag = getReferralTagFromSmartAccount(smartAccountClient);

      // Deploy using CREATE2 factory via account abstraction
      const userOpTxnHash = await smartAccountClient.sendUserOperation({
        calls: [
          {
            to: CREATE2_FACTORY,
            value: BigInt(0),
            data: (deployData + referralTag) as Address,
          },
        ],
      });

      logger.info("User operation submitted", { userOpTxnHash });

      // Wait for user operation receipt
      const userOpReceipt =
        await smartAccountClient.waitForUserOperationReceipt({
          hash: userOpTxnHash,
        });

      if (!userOpReceipt.success) {
        logger.error("User operation failed in createPaxAccountV1Proxy", {
          userOpReceipt,
        });
        throw new HttpsError(
          "internal",
          `User operation failed: ${JSON.stringify(userOpReceipt)}`
        );
      }

      const txnHash = userOpReceipt.receipt.transactionHash;
      logger.info("Transaction confirmed", { txnHash });

      // Retrieve proxy address from logs
      const proxyAddress = await getDeployedProxyContractAddress(txnHash);

      if (!proxyAddress) {
        logger.error(
          "Failed to retrieve proxy contract address from transaction logs in createPaxAccountV1Proxy",
          { txnHash }
        );
        throw new HttpsError(
          "internal",
          "Failed to retrieve proxy contract address from transaction logs"
        );
      }

      logger.info("PaxAccount proxy deployed successfully", {
        proxyAddress,
        implementationAddress: PAXACCOUNT_V1_IMPLEMENTATION_ADDRESS,
      });

      // Return the contract address and transaction hash
      return {
        contractAddress: proxyAddress,
        txnHash,
      };
    } catch (error) {
      logger.error("Error deploying PaxAccount proxy", { error });

      let errorMessage = "Unknown error occurred";
      if (error instanceof Error) {
        errorMessage = error.message;
      }

      throw new HttpsError(
        "internal",
        `Failed to deploy PaxAccount proxy: ${errorMessage}`
      );
    }
  }
);
