// src/utils/updateRewardRecord.ts
import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";

import { DB } from "../../shared/config";

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