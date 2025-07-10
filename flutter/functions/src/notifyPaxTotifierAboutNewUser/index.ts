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

    // Check if user already exists in Auth
    const userExists = await checkIfParticipantExistsInAuth(user.uid);
    if (userExists) {
      logger.info("User already exists in Auth, skipping notification", {
        userId: user.uid,
      });
      return;
    }

    logger.info("Processing new user notification", {
      userId: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoURL: user.photoURL,
    });
    
    // Create notification message
    const message: TelegramMessage = {
      chat_id: TELEGRAM_CHAT_ID,
      text: `🎉 *New Pax Participant Registered!*\n\n` +
            `*User ID:* \`${user.uid}\`\n` +
            `*Email:* ${user.email || 'Not provided'}\n` +
            `*Display Name:* ${user.displayName || 'Not provided'}\n` +
            `*Photo URL:* ${user.photoURL || 'Not provided'}\n` +
            `*Created At (Kenya):* ${new Date().toLocaleString('en-US', { timeZone: 'Africa/Nairobi' })}\n` +
            `*Created At (Server):* ${new Date().toLocaleString()}`,
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