// src/rewardParticipant/index.ts
import * as functions from "firebase-functions/v2";
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

/**
 * Firebase function that triggers when a task_completion document is updated
 * and the timeCompleted field changes from null to a timestamp.
 * This function automatically rewards the participant who completed the task.
 */
export const rewardParticipantProxy = functions.firestore
  .onDocumentUpdated("task_completions/{taskCompletionId}", async (event) => {
    try {
      // Get before and after states
      const beforeData = event.data?.before.data();
      const afterData = event.data?.after.data();
      const taskCompletionId = event.params.taskCompletionId;

      // Check if data exists
      if (!beforeData || !afterData) {
        logger.info("No data found in the event", { taskCompletionId });
        return { success: false, reason: "No data found in the event" };
      }

      // Check if this is the specific update we're looking for:
      // timeCompleted changed from null to a value
      const hadTimeCompletedBefore = beforeData.timeCompleted !== null;
      const hasTimeCompletedAfter = afterData.timeCompleted !== null;

      if (hadTimeCompletedBefore || !hasTimeCompletedAfter) {
        // Not the update we're looking for
        logger.info("Not a null→timestamp timeCompleted update", {
          taskCompletionId,
          hadTimeCompletedBefore,
          hasTimeCompletedAfter
        });
        return { success: false, reason: "Not a completion event" };
      }

      // Extract required data from the task completion
      const { taskId, participantId } = afterData;
      if (!taskId || !participantId) {
        logger.error("Missing required data in task completion", {
          taskCompletionId,
          hasTaskId: !!taskId,
          hasParticipantId: !!participantId
        });
        return { success: false, reason: "Missing required data" };
      }

      logger.info("Starting participant reward process for completed task", {
        taskCompletionId,
        taskId,
        participantId
      });

      // Step 1: Get required data from related collections
      const firestore = DB();
      
      // Get task data for reward details
      const taskDoc = await firestore.collection('tasks').doc(taskId).get();
      if (!taskDoc.exists) {
        logger.error("Task not found", { taskId });
        return { success: false, reason: "Task not found" };
      }
      
      const taskData = taskDoc.data();
      if (!taskData || !taskData.rewardAmount || !taskData.rewardCurrency || 
          !taskData.taskManagerContractAddress || !taskData.taskMasterId) {
        logger.error("Task missing required reward data", { taskId });
        return { success: false, reason: "Task missing reward data" };
      }
      
      const rewardAmount = taskData.rewardAmount;
      const rewardCurrency = taskData.rewardCurrency;
      const taskManagerContractAddress = taskData.taskManagerContractAddress as Address;
      const taskMasterId = taskData.taskMasterId;
      
      // Get the participant's PaxAccount
      const participantPaxAccountDoc = await firestore.collection('pax_accounts').doc(participantId).get();
      if (!participantPaxAccountDoc.exists) {
        logger.error("PaxAccount record not found for participant", { participantId });
        return { success: false, reason: "Participant PaxAccount not found" };
      }
      
      const participantPaxAccountData = participantPaxAccountDoc.data();
      if (!participantPaxAccountData || !participantPaxAccountData.contractAddress || 
          !participantPaxAccountData.serverWalletId) {
        logger.error("Participant PaxAccount missing required data", { participantId });
        return { success: false, reason: "Participant PaxAccount missing data" };
      }
      
      const paxAccountContractAddress = participantPaxAccountData.contractAddress as Address;
      const serverWalletId = participantPaxAccountData.serverWalletId;
      
      // Get the task master's PaxAccount for the serverWalletId
      const taskMasterPaxAccountDoc = await firestore.collection('pax_accounts').doc(taskMasterId).get();
      if (!taskMasterPaxAccountDoc.exists) {
        logger.error("PaxAccount record not found for task master", { taskMasterId });
        return { success: false, reason: "Task master PaxAccount not found" };
      }
      
      const taskMasterPaxAccountData = taskMasterPaxAccountDoc.data();
      if (!taskMasterPaxAccountData || !taskMasterPaxAccountData.serverWalletId) {
        logger.error("Task master PaxAccount missing serverWalletId", { taskMasterId });
        return { success: false, reason: "Task master PaxAccount missing serverWalletId" };
      }
      
      const taskMasterServerWalletId = taskMasterPaxAccountData.serverWalletId;

      // Step 2: Get wallet information and create accounts
      const [serverWallet, taskMasterWallet] = await Promise.all([
        PRIVY_CLIENT.walletApi.getWallet({ id: serverWalletId }),
        PRIVY_CLIENT.walletApi.getWallet({ id: taskMasterServerWalletId })
      ]);

      if (!serverWallet) {
        logger.error("Server wallet not found", { serverWalletId });
        return { success: false, reason: "Server wallet not found" };
      }

      if (!taskMasterWallet) {
        logger.error("Task master wallet not found", { taskMasterServerWalletId });
        return { success: false, reason: "Task master wallet not found" };
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
      const rewardId = `reward-${taskId}-${participantId}-${Date.now()}`;
      
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
        logger.error("Signature validation failed", { participantProxy, rewardId });
        return { success: false, reason: "Signature validation failed" };
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
        amount: rewardAmount,
        currency: rewardCurrency
        // Not providing txnHash here to create a pending record
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
        `You've received ${rewardAmount} ${rewardCurrency} for completing a task.`,
        {
          type: "reward",
          rewardId: rewardRecordId,
          taskId,
          taskCompletionId,
          amount: rewardAmount,
          currency: rewardCurrency
        }
      );

      // Return complete response with all relevant data
      return {
        success: true,
        participantProxy,
        paxAccountContractAddress,
        rewardId,
        taskId,
        participantId,
        taskCompletionId,
        signature,
        nonce: nonceString,
        txnHash,
        rewardRecordId,
        amount: rewardAmount,
        currency: rewardCurrency
      };
    } catch (error) {
      logger.error("Reward process failed", { error });
      
      // Don't throw the error since this is a trigger function
      // Throwing would cause retries which might lead to duplicate rewards
      return { 
        success: false, 
        error: error instanceof Error ? error.message : "Unknown error"
      };
    }
  });