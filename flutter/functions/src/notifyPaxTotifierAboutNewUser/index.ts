import { beforeUserSignedIn } from "firebase-functions/v2/identity";
import { logger } from "firebase-functions/v2";
import { TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID } from "../../shared/config";

interface TelegramMessage {
  chat_id: string;
  text: string;
  parse_mode?: string;
}

async function sendTelegramMessage(message: TelegramMessage): Promise<void> {
  if (!TELEGRAM_BOT_TOKEN || !TELEGRAM_CHAT_ID) {
    logger.warn("Telegram bot token or chat ID not configured", {
      hasBotToken: !!TELEGRAM_BOT_TOKEN,
      hasChatId: !!TELEGRAM_CHAT_ID,
    });
    return;
  }

  try {
    logger.info("Sending Telegram message", {
      chatId: TELEGRAM_CHAT_ID,
      messageLength: message.text.length,
    });

    const response = await fetch(`https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(message),
    });

    if (!response.ok) {
      const errorData = await response.json();
      logger.error('Telegram API error', {
        status: response.status,
        statusText: response.statusText,
        errorData,
      });
      throw new Error(`Telegram API error: ${response.status} ${response.statusText}`);
    }

    const result = await response.json();
    logger.info('Telegram message sent successfully', {
      messageId: result.result?.message_id,
      chatId: result.result?.chat?.id,
    });
  } catch (error) {
    logger.error('Failed to send Telegram message', {
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
    });
    throw error;
  }
}

export const notifyPaxTotifierAboutNewUser = beforeUserSignedIn(async (event) => {
  try {
    logger.info("notifyPaxTotifierAboutNewUser triggered", {
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