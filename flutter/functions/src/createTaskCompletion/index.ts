// src/createTaskCompletion/index.ts
import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";

import { DB } from "../../shared/config";
import { onDocumentCreated } from "firebase-functions/firestore";

/**
 * Firestore onCreate trigger function that creates a task completion record
 * when a new screening record is created.
 * 
 * The task completion will have the following fields:
 * - id: Auto-generated UUID
 * - taskId: From the screening record
 * - screeningId: The ID of the screening record that triggered this function
 * - participantId: From the screening record
 * - timeCompleted: null (because the task is not yet completed)
 * - timeCreated: Server timestamp
 * - timeUpdated: Server timestamp
 */
export const createTaskCompletion = 
  onDocumentCreated("screenings/{screeningId}", async (event) => {
    try {
      // Get the screening data
      const screeningData = event.data?.data();
      const screeningId = event.params.screeningId;

      if (!screeningData) {
        logger.error("No screening data found", { screeningId });
        return;
      }

      const { taskId, participantId } = screeningData;

      if (!taskId || !participantId) {
        logger.error("Missing required fields in screening data", { 
          screeningId,
          hasTaskId: !!taskId,
          hasParticipantId: !!participantId
        });
        return;
      }

      logger.info("Creating task completion from screening", {
        screeningId,
        taskId,
        participantId
      });

      // Get Firestore reference
      const firestore = DB();
      const taskCompletionsCollection = firestore.collection('task_completions');
      
      // Generate a unique ID for the task completion
      const taskCompletionDocRef = taskCompletionsCollection.doc();
      const taskCompletionId = taskCompletionDocRef.id;
      
      // Create the task completion record
      await taskCompletionDocRef.set({
        id: taskCompletionId,
        taskId,
        screeningId,
        participantId,
        timeCompleted: null, // Task is not yet completed
        timeCreated: FieldValue.serverTimestamp(),
        timeUpdated: FieldValue.serverTimestamp()
      });
      
      logger.info("Task completion created successfully", {
        taskCompletionId,
        screeningId,
        taskId,
        participantId
      });
      
      return { success: true, taskCompletionId };
    } catch (error) {
      logger.error("Error creating task completion", { error });
      throw error;
    }
  });