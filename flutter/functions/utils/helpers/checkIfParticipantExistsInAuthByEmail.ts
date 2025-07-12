import { logger } from "firebase-functions/v2";
import { getAuth } from "firebase-admin/auth";

/**
 * Checks if a user exists in Auth by email address
 * @param email - The email address to check
 * @returns Promise<boolean> - true if user exists, false otherwise
 */
export async function checkIfParticipantExistsInAuthByEmail(email: string): Promise<boolean> {
    try {
        const participantsInAuth = await getAuth().listUsers();

        const participantInAuth = participantsInAuth.users.find((user: any) => user.email === email);

        if (!participantInAuth) {
            return false;
        }
        return true;
    } catch (error) {
        logger.error('Error checking if user exists in Auth by email', {
            email,
            error: error instanceof Error ? error.message : 'Unknown error',
        });
        // If we can't check, assume user doesn't exist to be safe
        return false;
    }
} 