import { beforeUserCreated } from "firebase-functions/v2/identity";
import { logger } from "firebase-functions/v2";
import { TELEGRAM_CHAT_ID } from "../../utils/config";
import { sendTelegramMessage } from "../../utils/helpers/sendTelegramMessage";
import { escapeMarkdown } from "../../utils/helpers/escapeMarkdown";

interface TelegramMessage {
  chat_id: string;
  text: string;
  parse_mode?: string;
}

export const notifyPaxTotifierAboutNewUser = beforeUserCreated(
  async (event) => {
    try {
      logger.info(
        "notifyPaxTotifierAboutNewUser triggered for new user creation",
        {
          eventId: event.eventId,
          eventType: event.eventType,
          timestamp: new Date().toISOString(),
        }
      );

      const user = event.data;

      if (!user) {
        logger.warn("No user data in event", {
          eventId: event.eventId,
          eventType: event.eventType,
        });
        return;
      }

      const userEmail = user.email;

      if (!userEmail) {
        logger.warn("No email provided for user, cannot process", {
          eventId: event.eventId,
        });
        return;
      }

      logger.info("Processing new user notification", {
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
        userEmail,
        eventId: event.eventId,
      });

      // Create notification message
      const message: TelegramMessage = {
        chat_id: TELEGRAM_CHAT_ID,
        text:
          `🎉 *New Pax Participant Registered!*\n\n` +
          `*Email:* ${escapeMarkdown(user.email || "Not provided")}\n` +
          `*Display Name:* ${escapeMarkdown(user.displayName || "Not provided")}\n` +
          `*Photo URL:* ${escapeMarkdown(user.photoURL || "Not provided")}\n` +
          `*Created At (Kenya):* ${new Date().toLocaleString("en-US", {
            timeZone: "Africa/Nairobi",
          })}`,
        parse_mode: "Markdown",
      };

      logger.info("Sending Telegram notification", {
        userEmail,
        telegramChatId: TELEGRAM_CHAT_ID,
        messageLength: message.text.length,
        eventId: event.eventId,
      });

      // Send notification to Telegram
      await sendTelegramMessage(message);

      logger.info("Successfully notified about new user", {
        userEmail,
        telegramChatId: TELEGRAM_CHAT_ID,
        eventId: event.eventId,
      });

    } catch (error) {
      logger.error("Error in notifyPaxTotifierAboutNewUser", {
        error: error instanceof Error ? error.message : "Unknown error",
        stack: error instanceof Error ? error.stack : undefined,
        eventId: event.eventId,
      });
    }
  }
);
