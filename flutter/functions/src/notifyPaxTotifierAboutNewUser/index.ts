import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";
import { TELEGRAM_CHAT_ID } from "../../utils/config";
import { sendTelegramMessage } from "../../utils/helpers/sendTelegramMessage";
import { escapeMarkdown } from "../../utils/helpers/escapeMarkdown";

interface TelegramMessage {
  chat_id: string;
  text: string;
  parse_mode?: string;
}

export const notifyPaxTotifierAboutNewUser = onDocumentCreated(
  "participants/{participantId}",
  async (event) => {
    try {
      logger.info(
        "notifyPaxTotifierAboutNewUser triggered for new participant creation",
        {
          timestamp: new Date().toISOString(),
        }
      );

      const participant = event.data?.data();
      const participantId = event.params?.participantId;

      if (!participant) {
        logger.warn("No participant data in event", {
          participantId,
        });
        return;
      }

      const userEmail = participant.emailAddress;

      if (!userEmail) {
        logger.warn("No email provided for participant, cannot process", {
          participantId,
        });
        return;
      }

      logger.info("Processing new participant notification", {
        email: participant.emailAddress,
        displayName: participant.displayName,
        photoURL: participant.profilePictureURI,
        userEmail,
        participantId,
      });

      // Create notification message
      const message: TelegramMessage = {
        chat_id: TELEGRAM_CHAT_ID,
        text:
          `🎉 *New Pax Participant Registered!*\n\n` +
          `*Email:* ${escapeMarkdown(participant.emailAddress || "Not provided")}\n` +
          `*Display Name:* ${escapeMarkdown(participant.displayName || "Not provided")}\n` +
          `*Photo URL:* ${escapeMarkdown(participant.profilePictureURI || "Not provided")}\n` +
          `*Participant ID:* \`${participantId || "Not provided"}\`\n` +
          `*Created At (Kenya):* ${new Date().toLocaleString("en-US", {
            timeZone: "Africa/Nairobi",
          })}`,
        parse_mode: "Markdown",
      };

      logger.info("Sending Telegram notification", {
        userEmail,
        participantId,
        telegramChatId: TELEGRAM_CHAT_ID,
        messageLength: message.text.length,
      });

      // Send notification to Telegram
      await sendTelegramMessage(message);

      logger.info("Successfully notified about new participant", {
        userEmail,
        participantId,
        telegramChatId: TELEGRAM_CHAT_ID,
      });

    } catch (error) {
      logger.error("Error in notifyPaxTotifierAboutNewUser", {
        error: error instanceof Error ? error.message : "Unknown error",
        stack: error instanceof Error ? error.stack : undefined,
        participantId: event.params?.participantId,
      });
    }
  }
);
