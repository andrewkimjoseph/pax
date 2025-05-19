// src/utils/createRewardRecord.ts
import { logger } from "firebase-functions/v2";
import { Hex } from "viem";
import { FieldValue } from "firebase-admin/firestore";

import { DB } from "../../shared/config";

// Create reward record interface
interface RewardParams {
  taskId: string;
  participantId: string;
  taskCompletionId: string;
  signature: Hex;
  nonce: string;
  txnHash?: string | null;
  amount: string;
  currency: string;
}

/**
 * Function to create a reward record in the database
 */
export async function createRewardRecord(params: RewardParams): Promise<string> {
  try {
    const { 
      taskId, 
      participantId, 
      taskCompletionId,
      signature, 
      nonce, 
      txnHash = null,
      amount,
      currency
    } = params;
    
    logger.info("Creating reward record", {
      taskId,
      participantId,
      taskCompletionId
    });
    
    // Get Firestore reference
    const firestore = DB();
    const rewardsCollection = firestore.collection('rewards');
    
    // Generate a unique ID for the reward record
    const rewardDocRef = rewardsCollection.doc();
    const rewardId = rewardDocRef.id;
    
    // Save to Firestore with all fields and server timestamps
    await rewardDocRef.set({
      id: rewardId,
      taskId,
      participantId,
      taskCompletionId,
      signature,
      nonce,
      txnHash,
      amount,
      currency,
      timeCreated: FieldValue.serverTimestamp(),
      timeUpdated: FieldValue.serverTimestamp(),
      status: txnHash ? 'completed' : 'pending'
    });
    
    logger.info("Reward record created successfully", {
      rewardId,
      taskId,
      participantId,
      taskCompletionId
    });
    
    return rewardId;
  } catch (error) {
    logger.error("Error creating reward record", { error });
    throw error;
  }
}

/**
 * Function to update a reward record with a transaction hash
 */
export async function updateRewardWithTxnHash(
  rewardId: string,
  txnHash: string
): Promise<void> {
  try {
    logger.info("Updating reward record with transaction hash", {
      rewardId,
      txnHash
    });
    
    // Get Firestore reference
    const firestore = DB();
    const rewardDocRef = firestore.collection('rewards').doc(rewardId);
    
    // Update the document with server timestamp
    await rewardDocRef.update({
      txnHash,
      status: 'completed',
      timeUpdated: FieldValue.serverTimestamp()
    });
    
    logger.info("Reward record updated successfully with transaction hash", {
      rewardId,
      txnHash
    });
  } catch (error) {
    logger.error("Error updating reward record with transaction hash", { 
      error,
      rewardId,
      txnHash
    });
    throw error;
  }
}