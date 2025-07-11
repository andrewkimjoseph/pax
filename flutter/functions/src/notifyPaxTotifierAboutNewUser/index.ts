import { beforeUserCreated } from "firebase-functions/v2/identity";
import { logger } from "firebase-functions/v2";
import { TELEGRAM_CHAT_ID } from "../../utils/config";
import { sendTelegramMessage } from "../../utils/helpers/sendTelegramMessage";
import { checkIfParticipantExistsInAuthByEmail } from "../../utils/helpers/checkIfParticipantExistsInAuthByEmail";
import { checkIfParticipantExistsInFirestore } from "../../utils/helpers/checkIfParticipantExistsInFirestore";
import { escapeMarkdown } from "../../utils/helpers/escapeMarkdown";

interface TelegramMessage {
  chat_id: string;
  text: string;
  parse_mode?: string;
}

// Use a simple in-memory cache to track processed emails within this function instance
const processedEmails = new Set<string>();

export const notifyPaxTotifierAboutNewUser = beforeUserCreated(
  async (event) => {
    
    try {
      logger.info(
        "notifyPaxTotifierAboutNewUser triggered for new user creation",
        {
          eventId: event.eventId,
          eventType: event.eventType,
          timestamp: new Date().toISOString(),
          processedEmailsCount: processedEmails.size,
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

      // Use only email as the unique identifier
      const userEmail = user.email;

      if (!userEmail) {
        logger.warn("No email provided for user, cannot process", {
          userId: user.uid,
          eventId: event.eventId,
        });
        return;
      }

      logger.info("User data received", {
        userId: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
        userEmail,
        eventId: event.eventId,
      });

      // Check if we've already processed this email in this function instance
      if (processedEmails.has(userEmail)) {
        logger.warn("Email already processed in this function instance, skipping", {
          userEmail,
          eventId: event.eventId,
          processedEmailsCount: processedEmails.size,
          allProcessedEmails: Array.from(processedEmails),
        });
        return;
      }

      logger.info("Checking if user exists in Auth by email", {
        userId: user.uid,
        userEmail,
        eventId: event.eventId,
      });

      // Check if user already exists in Auth by email
      const userExistsInAuth = await checkIfParticipantExistsInAuthByEmail(userEmail);
      
      logger.info("Auth check completed", {
        userId: user.uid,
        userEmail,
        userExistsInAuth,
        eventId: event.eventId,
      });

      if (userExistsInAuth) {
        logger.info("User already exists in Auth, skipping notification", {
          userId: user.uid,
          userEmail,
          eventId: event.eventId,
        });
        return;
      }

      // Check if user already exists in Firestore by userId
      const userExistsInFirestore = await checkIfParticipantExistsInFirestore(user.uid);

      logger.info("Firestore check completed", {
        userId: user.uid,
        userEmail,
        userExistsInFirestore,
        eventId: event.eventId,
      });

      if (userExistsInFirestore) {
        logger.info("User already exists in Firestore, skipping notification", {
          userId: user.uid,
          userEmail,
          eventId: event.eventId,
        });
        return;
      }

      // Mark email as processed BEFORE sending notification to prevent duplicates
      processedEmails.add(userEmail);

      logger.info("Email marked as processed, proceeding with notification", {
        userId: user.uid,
        userEmail,
        eventId: event.eventId,
        processedEmailsCount: processedEmails.size,
      });

      logger.info("Processing new user notification", {
        userId: user.uid,
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
          `*User ID:* \`${escapeMarkdown(user.uid)}\`\n` +
          `*Email:* ${escapeMarkdown(user.email || "Not provided")}\n` +
          `*Display Name:* ${escapeMarkdown(user.displayName || "Not provided")}\n` +
          `*Photo URL:* ${escapeMarkdown(user.photoURL || "Not provided")}\n` +
          `*Event ID:* \`${escapeMarkdown(event.eventId)}\`\n` +
          `*Created At (Kenya):* ${escapeMarkdown(new Date().toLocaleString("en-US", {
            timeZone: "Africa/Nairobi",
          }))}`,
        parse_mode: "Markdown",
      };

      logger.info("Sending Telegram notification", {
        userId: user.uid,
        userEmail,
        telegramChatId: TELEGRAM_CHAT_ID,
        messageLength: message.text.length,
        eventId: event.eventId,
      });

      // Send notification to Telegram
      await sendTelegramMessage(message);

      logger.info("Successfully notified about new user", {
        userId: user.uid,
        userEmail,
        telegramChatId: TELEGRAM_CHAT_ID,
        eventId: event.eventId,
        processedEmailsCount: processedEmails.size,
      });

      // Clean up old entries to prevent memory leaks
      // Keep only the last 100 processed emails
      if (processedEmails.size > 100) {
        const entries = Array.from(processedEmails);
        processedEmails.clear();
        entries.slice(-50).forEach(entry => processedEmails.add(entry));
        
        logger.info("Cleaned up processed emails cache", {
          previousSize: entries.length,
          newSize: processedEmails.size,
          eventId: event.eventId,
        });
      }

    } catch (error) {
      logger.error("Error in notifyPaxTotifierAboutNewUser", {
        error: error instanceof Error ? error.message : "Unknown error",
        stack: error instanceof Error ? error.stack : undefined,
        eventId: event.eventId,
        processedEmailsCount: processedEmails.size,
      });
      
      // Don't rethrow to prevent retries that could cause duplicates
    }
  }
);