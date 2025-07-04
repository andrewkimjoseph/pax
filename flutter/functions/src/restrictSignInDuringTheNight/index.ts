import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { FUNCTION_RUNTIME_OPTS } from "../../shared/config";

/**
 * Cloud function to restrict account creation during the night (11 PM to 8 AM)
 * Runs before account creation (beforeCreate)
 *
 * @param request - Firebase callable function request
 * @returns {Promise<{ allowed: boolean, reason?: string }>}
 */
export const restrictSignInDuringTheNight = onCall( FUNCTION_RUNTIME_OPTS, async (request) => {
  try {
    // Get current server time
    const now = new Date();
    const hour = now.getHours();

    // Block if between 11 PM (23) and 8 AM (8)
    if (hour >= 8 || hour < 8) {
      logger.info("Blocked account creation during restricted hours", { hour });
      return {
        allowed: false,
        reason: "Account creation is not allowed between 11 PM and 8 AM. Please try again during the day.",
      };
    }

    // Otherwise, allow
    return { allowed: true };
  } catch (error) {
    logger.error("Error in restrictSignInDuringTheNight", { error });
    throw new HttpsError("internal", "Error in restrictSignInDuringTheNight");
  }
}); 