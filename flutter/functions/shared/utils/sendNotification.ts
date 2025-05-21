// src/utils/sendNotification.ts
import { logger } from "firebase-functions/v2";
import { MESSAGING, DB } from "../../shared/config";

/**
 * Send an FCM notification to a participant
 * @param participantId The ID of the participant to notify
 * @param title The notification title
 * @param body The notification body
 * @param data Additional data to include in the notification
 */
export async function sendParticipantNotification(
  participantId: string,
  title: string,
  body: string,
  data: Record<string, string> = {}
): Promise<void> {
  try {
    logger.info("Preparing to send notification to participant", {
      participantId,
      title
    });
    
    // Get the participant's FCM tokens
    const firestore = DB();
    const tokensSnapshot = await firestore
      .collection('fcm_tokens')
      .where('participantId', '==', participantId)
      .get();
    
    if (tokensSnapshot.empty) {
      logger.info("No FCM tokens found for participant", { participantId });
      return;
    }
    
    const tokens: string[] = [];
    tokensSnapshot.forEach(doc => {
      const token = doc.data().token;
      if (token) tokens.push(token);
    });
    
    if (tokens.length === 0) {
      logger.info("No valid tokens found for participant", { participantId });
      return;
    }
    
    // Prepare the notification message
    const message = {
      notification: {
        title,
        body,
      },
      data,
      tokens
    };
    
    // Send the notification
    const response = await MESSAGING.sendEachForMulticast(message);
    
    logger.info("Notification sent", {
      participantId,
      success: response.successCount,
      failure: response.failureCount
    });
    
    // Handle failed tokens if any
    if (response.failureCount > 0) {
      const failedTokens: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(tokens[idx]);
        }
      });
      
      logger.warn("Failed to send notifications to some tokens", {
        participantId,
        failedTokens
      });
      
      // Optionally: remove invalid tokens from the database
      // This could be implemented if needed
    }
  } catch (error) {
    logger.error("Error sending notification", { error, participantId });
    // We don't throw the error to prevent the main function from failing
    // if notification sending fails
  }
}