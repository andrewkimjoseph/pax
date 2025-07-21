import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getMessaging } from "firebase-admin/messaging";
import { AUTH, FUNCTION_RUNTIME_OPTS } from "../../utils/config";

interface SendNotificationParams {
  title: string;
  body: string;
  token: string;
  data?: Record<string, string>;
}

export const sendNotification = onCall(
  FUNCTION_RUNTIME_OPTS,
  async (request) => {
    try {
      // Ensure the user is authenticated
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Unauthenticated request");
      }
      const userId = request.auth.uid;
      // Check if the user is disabled
      const userRecord = await AUTH.getUser(userId);
      if (userRecord.disabled) {
        throw new HttpsError("permission-denied", "This user is disabled.");
      }

      const { title, body, token, data } =
        request.data as SendNotificationParams;

      if (!title || !body || !token) {
        throw new HttpsError(
          "invalid-argument",
          "Missing required parameters: title, body, and token are required"
        );
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
      throw new HttpsError(
        "internal",
        `Failed to send notification: ${
          error instanceof Error ? error.message : "Unknown error"
        }`
      );
    }
  }
);
