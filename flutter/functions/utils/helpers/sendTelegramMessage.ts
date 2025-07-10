import { logger } from "firebase-functions/v2";
import { TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID } from "../config";

interface TelegramMessage {
  chat_id: string;
  text: string;
  parse_mode?: string;
}

/**
 * Sends a message to Telegram using the configured bot token and chat ID
 * @param message - The Telegram message object
 * @returns Promise<void>
 */
export async function sendTelegramMessage(message: TelegramMessage): Promise<void> {
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