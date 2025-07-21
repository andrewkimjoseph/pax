import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import * as admin from 'firebase-admin';

import {
  FUNCTION_RUNTIME_OPTS,
  DB,
  AUTH,
} from "../../utils/config";
import { Timestamp } from "firebase-admin/firestore";

/**
 * Cloud function to delete all participant data
 * This function removes all data associated with a participant including:
 * - Participant record
 * - Task completions
 * - Rewards
 * - Withdrawals
 * - FCM tokens
 * - Screenings
 * - Authentication record
 */
export const deleteParticipantOnRequest = onCall(FUNCTION_RUNTIME_OPTS, async (request) => {
  try {
    // Ensure the user is authenticated
    if (!request.auth) {
      logger.error("Unauthenticated request to deleteParticipantOnRequest", { requestAuth: request.auth });
      throw new HttpsError(
        "unauthenticated",
        "The function must be called by an authenticated user."
      );
    }

    const userId = request.auth.uid;
    // Check if the user is disabled
    const userRecord = await AUTH.getUser(userId);
    if (userRecord.disabled) {  
      throw new HttpsError(
        "permission-denied",
        "This user is disabled."
      );
    }

    const db = DB();
    const batch = db.batch();

    logger.info("Starting participant data deletion", { participantId: userId });

    // Get payment method to save wallet address
    const paymentMethodSnapshot = await db
      .collection('payment_methods')
      .where('participantId', '==', userId)
      .get();
    const walletAddress = paymentMethodSnapshot.docs[0]?.data()?.walletAddress;

    // Create record in former_participants collection
    const formerParticipantRef = db.collection('former_participants').doc(userId);
    
    batch.set(formerParticipantRef, { 
      id: userId,
      miniPayWalletAddress: walletAddress || null,
      timeDeleted: Timestamp.now()
    });

    // 1. Delete participant record
    const participantRef = db.collection('participants').doc(userId);
    batch.delete(participantRef);

    // 2. Delete pax accounts
    const paxAccountsSnapshot = await db
      .collection('pax_accounts')
      .where('id', '==', userId)
      .get();
    paxAccountsSnapshot.docs.forEach((doc) => batch.delete(doc.ref));

    // 3. Delete task completions
    const taskCompletionsSnapshot = await db
      .collection('task_completions')
      .where('participantId', '==', userId)
      .get();
    taskCompletionsSnapshot.docs.forEach((doc) => batch.delete(doc.ref));

    // 4. Delete rewards
    const rewardsSnapshot = await db
      .collection('rewards')
      .where('participantId', '==', userId)
      .get();
    rewardsSnapshot.docs.forEach((doc) => batch.delete(doc.ref));

    // 5 Delete achievements
    const achievementsSnapshot = await db
      .collection('achievements')
      .where('participantId', '==', userId)
      .get();
    achievementsSnapshot.docs.forEach((doc) => batch.delete(doc.ref));

    // 6. Delete withdrawals
    const withdrawalsSnapshot = await db
      .collection('withdrawals')
      .where('participantId', '==', userId)
      .get();
    withdrawalsSnapshot.docs.forEach((doc) => batch.delete(doc.ref));

    // 7. Delete FCM tokens
    const fcmTokensSnapshot = await db
      .collection('fcm_tokens')
      .where('participantId', '==', userId)
      .get();
    fcmTokensSnapshot.docs.forEach((doc) => batch.delete(doc.ref));

    // Commit all deletions
    await batch.commit();

    // Delete the user's authentication record
    await admin.auth().deleteUser(userId);

    logger.info("Successfully deleted all participant data", { participantId: userId });

    return {
      success: true,
      message: 'All participant data has been successfully deleted'
    };
  } catch (error) {
    logger.error("Error deleting participant data", { error });

    let errorMessage = "Unknown error occurred";
    if (error instanceof Error) {
      errorMessage = error.message;
    }

    throw new HttpsError(
      "internal",
      `Failed to delete participant data: ${errorMessage}`
    );
  }
}); 