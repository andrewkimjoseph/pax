import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import * as admin from 'firebase-admin';

import {
  FUNCTION_RUNTIME_OPTS,
  DB
} from "../../shared/config";
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
      throw new HttpsError(
        "unauthenticated",
        "The function must be called by an authenticated user."
      );
    }

    const participantId = request.auth.uid;
    const db = DB();
    const batch = db.batch();

    logger.info("Starting participant data deletion", { participantId });

    // Get payment method to save wallet address
    const paymentMethodSnapshot = await db
      .collection('payment_methods')
      .where('participantId', '==', participantId)
      .get();
    const walletAddress = paymentMethodSnapshot.docs[0]?.data()?.walletAddress;

    // Create record in former_participants collection
    const formerParticipantRef = db.collection('former_participants').doc(participantId);
    
    batch.set(formerParticipantRef, { 
      id: participantId,
      miniPayWalletAddress: walletAddress || null,
      timeDeleted: Timestamp.now()
    });

    // 1. Delete participant record
    const participantRef = db.collection('participants').doc(participantId);
    batch.delete(participantRef);

    // 2. Delete pax accounts
    const paxAccountsSnapshot = await db
      .collection('pax_accounts')
      .where('id', '==', participantId)
      .get();
    paxAccountsSnapshot.docs.forEach((doc) => batch.delete(doc.ref));

    // 3. Delete task completions
    const taskCompletionsSnapshot = await db
      .collection('task_completions')
      .where('participantId', '==', participantId)
      .get();
    taskCompletionsSnapshot.docs.forEach((doc) => batch.delete(doc.ref));

    // 4. Delete rewards
    const rewardsSnapshot = await db
      .collection('rewards')
      .where('participantId', '==', participantId)
      .get();
    rewardsSnapshot.docs.forEach((doc) => batch.delete(doc.ref));

    // 5 Delete achievements
    const achievementsSnapshot = await db
      .collection('achievements')
      .where('participantId', '==', participantId)
      .get();
    achievementsSnapshot.docs.forEach((doc) => batch.delete(doc.ref));

    // 6. Delete withdrawals
    const withdrawalsSnapshot = await db
      .collection('withdrawals')
      .where('participantId', '==', participantId)
      .get();
    withdrawalsSnapshot.docs.forEach((doc) => batch.delete(doc.ref));

    // 7. Delete FCM tokens
    const fcmTokensSnapshot = await db
      .collection('fcm_tokens')
      .where('participantId', '==', participantId)
      .get();
    fcmTokensSnapshot.docs.forEach((doc) => batch.delete(doc.ref));

    // Commit all deletions
    await batch.commit();

    // Delete the user's authentication record
    await admin.auth().deleteUser(participantId);

    logger.info("Successfully deleted all participant data", { participantId });

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