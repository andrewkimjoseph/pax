import { logger } from "firebase-functions/v2";
import { DB } from "../config";

/**
 * Checks if a user exists in the participants collection in Firestore
 * @param userId - The user ID to check
 * @returns Promise<boolean> - true if user exists, false otherwise
 */
export async function checkIfParticipantExistsInFirestore(userId: string): Promise<boolean> {
    try {

        const participantInFirestore = await DB().collection('participants').doc(userId).get();

        return participantInFirestore.exists;
    } catch (error) {
        logger.error('Error checking if user exists in Firestore', {
            userId,
            error: error instanceof Error ? error.message : 'Unknown error',
        });
        return false;
    }
} 