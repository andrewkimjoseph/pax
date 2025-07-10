import { beforeUserCreated } from "firebase-functions/v2/identity";
import { logger } from "firebase-functions/v2";
import { TELEGRAM_CHAT_ID } from "../../utils/config";
import { sendTelegramMessage } from "../../utils/helpers/sendTelegramMessage";
import { checkIfParticipantExistsInAuth } from "../../utils/helpers/checkIfParticipantExistsInAuth";

interface TelegramMessage {
  chat_id: string;
  text: string;
  parse_mode?: string;
}

export const notifyPaxTotifierAboutNewUser = beforeUserCreated(async (event) => {
  try {
    logger.info("notifyPaxTotifierAboutNewUser triggered for new user creation", {
      eventId: event.eventId,
      eventType: event.eventType,
    });

    const user = event.data;
    
    if (!user) {
      logger.warn("No user data in event", {
        eventId: event.eventId,
        eventType: event.eventType,
      });
      return;
    }

    // Check if user already exists in Firestore
    const userExists = await checkIfParticipantExistsInAuth(user.uid);
    if (userExists) {
      logger.info("User already exists in Firestore, skipping notification", {
        userId: user.uid,
      });
      return;
    }

    logger.info("Processing new user notification", {
      userId: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      providerCount: user.providerData?.length || 0,
    });
    
    // Create notification message
    const message: TelegramMessage = {
      chat_id: TELEGRAM_CHAT_ID,
      text: `🎉 *New Pax Participant Registered!*\n\n` +
            `*User ID:* \`${user.uid}\`\n` +
            `*Email:* ${user.email || 'Not provided'}\n` +
            `*Display Name:* ${user.displayName || 'Not provided'}\n` +
            `*Phone:* ${user.phoneNumber || 'Not provided'}\n` +
            `*Created At:* ${new Date().toLocaleString()}\n` +
            `*Provider:* ${user.providerData?.map((p: any) => p.providerId).join(', ') || 'Unknown'}`,
      parse_mode: 'Markdown'
    };

    // Send notification to Telegram
    await sendTelegramMessage(message);

    logger.info("Successfully notified about new user", {
      userId: user.uid,
      telegramChatId: TELEGRAM_CHAT_ID,
    });
  } catch (error) {
    logger.error("Error in notifyPaxTotifierAboutNewUser", {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
      eventId: event.eventId,
    });
  }
});