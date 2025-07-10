import { logger } from "firebase-functions/v2";
import { getAuth } from "firebase-admin/auth";

/**
 * Checks if a user exists in the participants collection in Firestore
 * @param userId - The user ID to check
 * @returns Promise<boolean> - true if user exists, false otherwise
 */
export async function checkIfParticipantExistsInAuth(userId: string): Promise<boolean> {
    try {

        const participantInAuth = await getAuth().getUser(userId);

        if (!participantInAuth) {
            return false;
        }
        return true;
    } catch (error) {
        logger.error('Error checking if user exists', {
            userId,
            error: error instanceof Error ? error.message : 'Unknown error',
        });
        // If we can't check, assume user doesn't exist to be safe
        return false;
    }
} 