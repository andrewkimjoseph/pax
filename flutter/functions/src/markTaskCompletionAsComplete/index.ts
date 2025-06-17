// src/markTaskCompletionAsComplete/index.ts
import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";

import {
  FUNCTION_RUNTIME_OPTS,
  DB
} from "../../shared/config";

/**
 * Cloud function to mark a task completion as complete
 * Updates the timeCompleted field with the current timestamp
 * 
 * @param screeningId - ID of the screening record
 * @param taskId - ID of the task
 * @returns The updated task completion data
 */
export const markTaskCompletionAsComplete = onCall(FUNCTION_RUNTIME_OPTS, async (request) => {
  try {
    // Ensure the user is authenticated
    if (!request.auth) {
      logger.error("Unauthenticated request to markTaskCompletionAsComplete", { requestAuth: request.auth });
      throw new HttpsError(
        "unauthenticated",
        "The function must be called by an authenticated user."
      );
    }

    const userId = request.auth.uid;
    const { 
      screeningId, 
      taskId
    } = request.data as {
      screeningId: string;
      taskId: string;
    };

    // Validate required parameters
    if (!screeningId || !taskId) {
      logger.error("Missing required parameters in markTaskCompletionAsComplete", { screeningId, taskId });
      throw new HttpsError(
        "invalid-argument",
        "Missing required parameters. Please provide screeningId and taskId."
      );
    }

    logger.info("Marking task completion as complete", {
      userId,
      screeningId,
      taskId
    });

    // Get Firestore reference
    const firestore = DB();
    
    // Find the task completion document that matches both screeningId and taskId
    const taskCompletionsRef = firestore.collection('task_completions');
    const querySnapshot = await taskCompletionsRef
      .where('screeningId', '==', screeningId)
      .where('taskId', '==', taskId)
      .limit(1)
      .get();
      
    if (querySnapshot.empty) {
      logger.error("No task completion found with the provided screeningId and taskId in markTaskCompletionAsComplete", { screeningId, taskId });
      throw new HttpsError(
        "not-found",
        "No task completion found with the provided screeningId and taskId."
      );
    }
    
    // Get the first (and should be only) matching document
    const taskCompletionDoc = querySnapshot.docs[0];
    const taskCompletionId = taskCompletionDoc.id;
    
    // Update the document with timeCompleted and timeUpdated
    await taskCompletionDoc.ref.update({
      timeCompleted: FieldValue.serverTimestamp(),
      timeUpdated: FieldValue.serverTimestamp()
    });
    
    logger.info("Task completion marked as complete", {
      taskCompletionId,
      screeningId,
      taskId
    });
    
    return {
      success: true,
      taskCompletionId,
    };
  } catch (error) {
    logger.error("Error marking task completion as complete", { error });

    throw error;
  }
});