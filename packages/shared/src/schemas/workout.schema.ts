import { z } from 'zod';

export const workoutSetSchema = z.object({
  exerciseId: z.string().uuid(),
  setNumber: z.number().int().min(1).max(99),
  reps: z.number().int().min(0).max(9999).nullable(),
  weightKg: z.number().min(0).max(9999.99).nullable(),
  durationSeconds: z.number().int().min(0).nullable(),
  distanceMeters: z.number().min(0).nullable(),
  rpe: z.number().int().min(1).max(10).nullable(),
});

/** Sent when the user taps "Finish Workout". */
export const createWorkoutSessionSchema = z.object({
  title: z.string().max(100).optional(),
  notes: z.string().max(2000).optional(),
  startedAt: z.string().datetime(),
  endedAt: z.string().datetime(),
  programId: z.string().uuid().optional(),
  programDayId: z.string().uuid().optional(),
  sets: z.array(workoutSetSchema).min(1, 'At least one set is required'),
});

/** Single-set logging during an active session (optimistic UI). */
export const logWorkoutSetSchema = workoutSetSchema.extend({
  sessionId: z.string().uuid(),
});

export type WorkoutSetInput = z.infer<typeof workoutSetSchema>;
export type CreateWorkoutSessionInput = z.infer<typeof createWorkoutSessionSchema>;
export type LogWorkoutSetInput = z.infer<typeof logWorkoutSetSchema>;

// Keep the old name for backwards compat during the transition
export const finishWorkoutSchema = createWorkoutSessionSchema;
export type FinishWorkoutInput = CreateWorkoutSessionInput;
