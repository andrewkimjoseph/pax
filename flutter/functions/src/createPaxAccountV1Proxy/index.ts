// src/createPaxAccountProxy/index.ts
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import {
  Address,
  Hex,
  concat,
  encodeFunctionData,
  encodeDeployData,
  http,
  toHex,
} from "viem";
import { entryPoint07Address } from "viem/account-abstraction";
import { celo } from "viem/chains";
import { createViemAccount } from "@privy-io/server-auth/viem";
import { randomBytes } from "crypto";

import { paxAccountV1ABI } from "../../shared/abis/paxAccountV1ABI";
import { erc1967ProxyABI } from "../../shared/abis/erc1967Proxy";
import { erc1967ByteCode } from "../../shared/bytecode/erc1967";
import { calculateEventSignature } from "../../shared/utils/calculateEventSignature";
import {
  PAXACCOUNT_IMPLEMENTATION_ADDRESS,
  FUNCTION_RUNTIME_OPTS,
  CREATE2_FACTORY,
  PRIVY_CLIENT,
  PUBLIC_CLIENT,
  PIMLICO_URL,
} from "../../shared/config";

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
        logger.error("Unauthenticated request to createPaxAccountV1Proxy", { requestAuth: request.auth });
        throw new HttpsError(
          "unauthenticated",
          "The function must be called by an authenticated user."
        );
      }

      const userId = request.auth.uid;
      const { _primaryPaymentMethod, serverWalletId } = request.data as {
        _primaryPaymentMethod: string;
        serverWalletId: string;
      };

      if (!_primaryPaymentMethod) {
        logger.error("Missing required parameter: walletAddress in createPaxAccountV1Proxy", { _primaryPaymentMethod });
        throw new HttpsError(
          "invalid-argument",
          "Missing required parameter: walletAddress"
        );
      }

      if (!serverWalletId) {
        logger.error("Missing required parameter: serverWalletId in createPaxAccountV1Proxy", { serverWalletId });
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

      // Get the server wallet from Privy
      const wallet = await PRIVY_CLIENT.walletApi.getWallet({
        id: serverWalletId,
      });

      if (!wallet) {
        logger.error("Server wallet not found with the provided ID in createPaxAccountV1Proxy", { serverWalletId });
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
        PAXACCOUNT_IMPLEMENTATION_ADDRESS,
        _owner,
        _primaryPaymentMethod as Address // Use the provided wallet address as primary payment method
      );

      // Deploy using CREATE2 factory via account abstraction
      const userOpTxnHash = await smartAccountClient.sendUserOperation({
        calls: [
          {
            to: CREATE2_FACTORY,
            value: BigInt(0),
            data: deployData,
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
        logger.error("User operation failed in createPaxAccountV1Proxy", { userOpReceipt });
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
        logger.error("Failed to retrieve proxy contract address from transaction logs in createPaxAccountV1Proxy", { txnHash });
        throw new HttpsError(
          "internal",
          "Failed to retrieve proxy contract address from transaction logs"
        );
      }

      logger.info("PaxAccount proxy deployed successfully", {
        proxyAddress,
        implementationAddress: PAXACCOUNT_IMPLEMENTATION_ADDRESS,
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

// Function to generate deterministic deployment data with salt
function getProxyDeployDataAndSalt(
  implementationAddress: Address,
  ownerAddress: Address,
  primaryPaymentMethod: Address
): { deployData: Hex; salt: Hex } {
  // Generate a random salt for CREATE2
  const salt = toHex(randomBytes(32), { size: 32 });

  const initData = encodeFunctionData({
    abi: paxAccountV1ABI,
    functionName: "initialize",
    args: [ownerAddress, primaryPaymentMethod],
  });

  const proxyData = encodeDeployData({
    abi: erc1967ProxyABI,
    bytecode: erc1967ByteCode,
    args: [implementationAddress, initData],
  });

  // Combine the salt with the deployment data
  const deployData = concat([salt, proxyData]);

  return { deployData, salt };
}

// Helper function to extract the proxy address from transaction logs
async function getDeployedProxyContractAddress(
  txHash: Address
): Promise<Address | undefined> {
  try {
    // Wait for the transaction receipt
    const receipt = await PUBLIC_CLIENT.getTransactionReceipt({
      hash: txHash,
    });

    // The specific event signature for PaxAccountCreated(address)
    const paxAccountEventSignature = calculateEventSignature(
      "PaxAccountCreated(address)"
    );

    // Look through all logs for our specific event
    for (const log of receipt.logs) {
      if (
        log.topics[0]?.toLowerCase() === paxAccountEventSignature.toLowerCase()
      ) {
        // The contract address is in log.address
        const contractAddress = log.address as Address;

        logger.info(`Found PaxAccount contract at address: ${contractAddress}`);

        // Additional verification: the contract address should also be in the indexed parameter
        if (log.topics[1]) {
          const indexedAddress = `0x${log.topics[1].slice(
            -40
          )}`.toLowerCase() as Address;

          if (contractAddress.toLowerCase() === indexedAddress.toLowerCase()) {
            logger.info(
              `Verified: The indexed parameter matches the contract address`
            );
          } else {
            logger.warn(
              `Warning: Contract address ${contractAddress} doesn't match indexed parameter ${indexedAddress}`
            );
          }
        }

        return contractAddress;
      }
    }

    return undefined;
  } catch (error) {
    logger.error("Error retrieving contract address from logs", {
      error,
      txHash,
    });
    throw error;
  }
}
