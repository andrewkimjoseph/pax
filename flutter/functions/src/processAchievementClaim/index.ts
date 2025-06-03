import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { Address, encodeFunctionData, http, parseEther } from "viem";
import { celo } from "viem/chains";
import { erc20ABI } from "../../shared/abis/erc20";
import {
  FUNCTION_RUNTIME_OPTS,
  PUBLIC_CLIENT,
  PIMLICO_URL,
  PAX_MASTER,
  REWARD_TOKEN_ADDRESS,
} from "../../shared/config";
import { entryPoint07Address } from "viem/account-abstraction";
import { privateKeyToAccount } from "viem/accounts";


export const processAchievementClaim = onCall(
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
        throw new HttpsError(
          "unauthenticated",
          "The function must be called by an authenticated user."
        );
      }

      logger.info("Processing achievement claim for user:", { 
        userId: request.auth.uid,
        achievementId: request.data.achievementId 
      });

      const { 
        achievementId, 
        paxAccountContractAddress, 
        amountEarned, 
        tasksCompleted 
      } = request.data as {
        achievementId: string;
        paxAccountContractAddress: string;
        amountEarned: number;
        tasksCompleted: number;
      };

      logger.info("Claim parameters:", {
        achievementId,
        paxAccountContractAddress,
        amountEarned,
        tasksCompleted
      });

      if (!achievementId || !paxAccountContractAddress || !amountEarned === undefined || tasksCompleted === undefined) {
        throw new HttpsError(
          "invalid-argument",
          "Missing required parameters: achievementId, paxAccountContractAddress, amountEarned, tasksNeededForCompletion, and tasksCompleted."
        );
      }


      const recipientAddress = paxAccountContractAddress as Address;

      logger.info("Preparing transaction:", {
        recipientAddress,
        amountEarned: amountEarned.toString(),
        rewardTokenAddress: REWARD_TOKEN_ADDRESS
      });

      const PAX_MASTER_ACCOUNT = privateKeyToAccount(PAX_MASTER);

      const smartAccount = await toSimpleSmartAccount({
        client: PUBLIC_CLIENT,
        owner: PAX_MASTER_ACCOUNT,
        entryPoint: {
          address: entryPoint07Address,
          version: "0.7",
        },
      });

      logger.info("Smart Account Address:", { address: smartAccount.address });

      // Check balance before transfer
      const balanceBefore = await PUBLIC_CLIENT.readContract({
        address: REWARD_TOKEN_ADDRESS,
        abi: erc20ABI,
        functionName: 'balanceOf',
        args: [recipientAddress],
      }) as bigint;

      logger.info("G$ Balance before transfer:", { 
        address: recipientAddress,
        balance: balanceBefore.toString()
      });

      const data = encodeFunctionData({
        abi: erc20ABI,
        functionName: "transfer",
        args: [recipientAddress, parseEther(amountEarned.toString())],
      });

      logger.info("Encoded transaction data:", { data });

      // Create a smart account client
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

      // Send the transaction
      const hash = await smartAccountClient.sendTransaction({
        to: REWARD_TOKEN_ADDRESS,
        data,
      });

      logger.info("Transaction sent successfully:", { 
        transactionHash: hash,
        achievementId,
        recipientAddress
      });

      // Check balance after transfer
      const balanceAfter = await PUBLIC_CLIENT.readContract({
        address: REWARD_TOKEN_ADDRESS,
        abi: erc20ABI,
        functionName: 'balanceOf',
        args: [recipientAddress],
      }) as bigint;

      logger.info("G$ Balance after transfer:", { 
        address: recipientAddress,
        balance: balanceAfter.toString()
      });

      return { success: true, txnHash: hash };
    } catch (error) {
      logger.error("Error processing achievement claim:", {
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
        achievementId: request.data?.achievementId
      });
      throw new HttpsError("internal", "Error processing achievement claim.");
    }
  }
);
