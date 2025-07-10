import { logger } from "firebase-functions/v2";
import { Hex } from "viem";
import { FieldValue } from "firebase-admin/firestore";

import {
  DB
} from "../../shared/config";

// Create screening record interface
interface ScreeningParams {
  taskId: string;
  participantId: string;
  signature: Hex;
  nonce: string;
  txnHash?: string | null;
}

/**
 * Internal function to create a screening record
 * This can be called directly from other cloud functions
 */
export async function createScreeningRecord(params: ScreeningParams): Promise<string> {
  try {
    const { taskId, participantId, signature, nonce, txnHash = null } = params;
    
    logger.info("Creating screening record", {
      taskId,
      participantId
    });
    
    // Get Firestore reference
    const firestore = DB();
    const screeningsCollection = firestore.collection('screenings');
    
    // Generate a unique ID for the screening record
    const screeningDocRef = screeningsCollection.doc();
    const screeningId = screeningDocRef.id;
    
    // Save to Firestore with all fields and server timestamps
    await screeningDocRef.set({
      id: screeningId,
      taskId,
      participantId,
      signature,
      nonce,
      txnHash,
      timeCreated: FieldValue.serverTimestamp(),
      timeUpdated: FieldValue.serverTimestamp()
    });
    
    logger.info("Screening record created successfully", {
      screeningId,
      taskId,
      participantId
    });
    
    return screeningId;
  } catch (error) {
    logger.error("Error creating screening record", { error });
    throw error;
  }
}
