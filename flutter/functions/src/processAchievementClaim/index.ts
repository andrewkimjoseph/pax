import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { Address, encodeFunctionData, http } from "viem";
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

      const { 
        achievementId, 
        paxAccountContractAddress, 
        amountEarned, 
        tasksCompleted 
      } = request.data as {
        achievementId: string;
        paxAccountContractAddress: string;
        amountEarned: number;
        timeCompleted?: number;
        tasksNeededForCompletion: number;
        tasksCompleted: number;
      };

      if (!achievementId || !paxAccountContractAddress || !amountEarned === undefined || tasksCompleted === undefined) {
        throw new HttpsError(
          "invalid-argument",
          "Missing required parameters: achievementId, paxAccountContractAddress, amountEarned, tasksNeededForCompletion, and tasksCompleted."
        );
      }


      const recipientAddress = paxAccountContractAddress as Address;

      const PAX_MASTER_ACCOUNT = privateKeyToAccount(PAX_MASTER);

      const smartAccount = await toSimpleSmartAccount({
        client: PUBLIC_CLIENT,
        owner: PAX_MASTER_ACCOUNT,
        entryPoint: {
          address: entryPoint07Address,
          version: "0.7",
        },
      });

      const data = encodeFunctionData({
        abi: erc20ABI,
        functionName: "transfer",
        args: [recipientAddress, BigInt(amountEarned)],
      });

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

      return { success: true, txnHash: hash };
    } catch (error) {
      logger.error("Error processing achievement claim:", error);
      throw new HttpsError("internal", "Error processing achievement claim.");
    }
  }
);
