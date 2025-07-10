import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";

import { DB } from "../../shared/config";

// Create withdrawal record interface
interface WithdrawalParams {
  participantId: string;
  paymentMethodId: string;
  amountRequested: number;
  rewardCurrencyId: number;
  txnHash: string;
}

/**
 * Function to create a withdrawal record in the database
 */
export async function createWithdrawalRecord(params: WithdrawalParams): Promise<string> {
  try {
    const { 
      participantId, 
      paymentMethodId,
      amountRequested,
      rewardCurrencyId,
      txnHash
    } = params;
    
    logger.info("Creating withdrawal record", {
      participantId,
      paymentMethodId,
      amountRequested
    });
    
    // Get Firestore reference
    const firestore = DB();
    const withdrawalsCollection = firestore.collection('withdrawals');
    
    // Generate a unique ID for the withdrawal record
    const withdrawalDocRef = withdrawalsCollection.doc();
    const withdrawalId = withdrawalDocRef.id;
    
    // Save to Firestore with all fields and server timestamps
    await withdrawalDocRef.set({
      id: withdrawalId,
      participantId,
      paymentMethodId,
      amountRequested,
      rewardCurrencyId,
      txnHash,
      timeCreated: FieldValue.serverTimestamp(),
      timeRequested: FieldValue.serverTimestamp(),
      timeUpdated: FieldValue.serverTimestamp(),
    });
    
    logger.info("Withdrawal record created successfully", {
      withdrawalId,
      participantId,
      paymentMethodId
    });
    
    return withdrawalId;
  } catch (error) {
    logger.error("Error creating withdrawal record", { error });
    throw error;
  }
} 