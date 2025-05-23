import { onCall } from "firebase-functions/v2/https";
import { getMessaging } from "firebase-admin/messaging";
import { FUNCTION_RUNTIME_OPTS } from "../../shared/config";

interface SendNotificationParams {
  title: string;
  body: string;
  token: string;
  data?: Record<string, string>;
}

export const sendNotification = onCall(FUNCTION_RUNTIME_OPTS, async (request) => {
  try {
    const { title, body, token, data } = request.data as SendNotificationParams;

    if (!title || !body || !token) {
      throw new Error("Missing required parameters: title, body, and token are required");
    }

    const message = {
      notification: {
        title,
        body,
      },
      token,
      data: data || {},
    };

    const response = await getMessaging().send(message);
    
    return {
      success: true,
      messageId: response,
    };
  } catch (error) {
    console.error("Error sending notification:", error);
    throw new Error(`Failed to send notification: ${error instanceof Error ? error.message : "Unknown error"}`);
  }
}); 