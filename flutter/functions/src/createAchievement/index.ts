import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

interface CreateAchievementRequest {
  participantId: string;
  name: string;
  tasksCompleted: number;
  tasksNeededForCompletion: number;
}

export const createAchievement = functions.https.onCall(
  async (request: functions.https.CallableRequest<CreateAchievementRequest>) => {
    // Check if user is authenticated
    if (!request.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'The function must be called while authenticated.'
      );
    }

    const {
      participantId,
      name,
      tasksCompleted,
      tasksNeededForCompletion,
    } = request.data;

    // Validate required fields
    if (!participantId || !name || tasksCompleted === undefined || tasksNeededForCompletion === undefined) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Missing required fields'
      );
    }

    try {
      // Create a new document reference to get auto-generated ID
      const achievementRef = admin.firestore().collection('achievements').doc();

      // Create achievement data
      const achievementData = {
        id: achievementRef.id,
        participantId,
        name,
        tasksCompleted,
        tasksNeededForCompletion,
        timeCreated: admin.firestore.Timestamp.now(),
        amountEarned: null,
        txnHash: null,
        timeCompleted: tasksCompleted >= tasksNeededForCompletion 
          ? admin.firestore.Timestamp.now() 
          : null,
      };

      // Create the achievement document
      await achievementRef.set(achievementData);

      return {
        success: true,
        achievementId: achievementRef.id,
        participantId: achievementData.participantId,
        name: achievementData.name,
        tasksCompleted: achievementData.tasksCompleted,
        tasksNeededForCompletion: achievementData.tasksNeededForCompletion,
        timeCreated: achievementData.timeCreated,
        amountEarned: achievementData.amountEarned,
        txnHash: achievementData.txnHash,
        timeCompleted: achievementData.timeCompleted
      };
    } catch (error) {
      console.error('Error creating achievement:', error);
      throw new functions.https.HttpsError(
        'internal',
        'Error creating achievement'
      );
    }
  }
); 