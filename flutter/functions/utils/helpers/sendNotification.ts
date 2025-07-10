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
    
    // Get the most recent token
    const tokens = tokensSnapshot.docs
      .map(doc => doc.data().token)
      .filter((token): token is string => !!token);
    
    if (tokens.length === 0) {
      logger.info("No valid tokens found for participant", { participantId });
      return;
    }

    // Use the most recent token
    const token = tokens[0];
    
    // Prepare the notification message with proper format for both platforms
    const message = {
      android: {
        priority: 'high' as const,
        notification: {
          channelId: 'high_importance_channel',
          priority: 'high' as const,
          defaultSound: true,
          defaultVibrateTimings: true,
          defaultLightSettings: true,
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
      notification: {
        title,
        body,
      },
      data: {
        ...data,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      token
    };
    
    // Send the notification
    const response = await MESSAGING.send(message);
    
    logger.info("Notification sent", {
      participantId,
      messageId: response
    });
    
  } catch (error) {
    logger.error("Error sending notification", { error, participantId });
    // We don't throw the error to prevent the main function from failing
    // if notification sending fails
  }
}