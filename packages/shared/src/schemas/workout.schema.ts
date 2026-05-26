import { z } from 'zod';

export const workoutSetSchema = z.object({
  exerciseId: z.string().uuid(),
  setNumber: z.number().int().min(1),
  reps: z.number().int().min(0).max(9999).nullable(),
  weightKg: z.number().min(0).max(9999.99).nullable(),
  durationSeconds: z.number().int().min(0).nullable(),
  distanceMeters: z.number().min(0).nullable(),
  rpe: z.number().int().min(1).max(10).nullable(),
});

export const finishWorkoutSchema = z.object({
  title: z.string().max(100).optional(),
  notes: z.string().max(2000).optional(),
  startedAt: z.string().datetime(),
  endedAt: z.string().datetime(),
  sets: z.array(workoutSetSchema).min(1),
});

export type WorkoutSetInput = z.infer<typeof workoutSetSchema>;
export type FinishWorkoutInput = z.infer<typeof finishWorkoutSchema>;
