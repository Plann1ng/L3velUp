import { z } from 'zod';
import { experienceLevelSchema, goalSchema } from './base.schema';

export const programExerciseSchema = z.object({
  exerciseId: z.string().uuid(),
  orderIndex: z.number().int().min(0),
  targetSets: z.number().int().min(1).max(20).nullable(),
  targetReps: z.string().max(20).nullable(), // e.g. "8-12" or "AMRAP"
  targetWeight: z.string().max(50).nullable(), // e.g. "70% 1RM"
  restSeconds: z.number().int().min(0).max(600).nullable(),
  notes: z.string().max(500).nullable(),
});

export const programDaySchema = z.object({
  weekNumber: z.number().int().min(1).max(52),
  dayNumber: z.number().int().min(1).max(7),
  name: z.string().max(50).nullable(),
  exercises: z.array(programExerciseSchema),
});

export const createProgramSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().max(2000).optional(),
  goal: goalSchema.optional(),
  difficulty: experienceLevelSchema.optional(),
  durationWeeks: z.number().int().min(1).max(52),
  isPublic: z.boolean().default(false),
  isGymTemplate: z.boolean().default(false),
  days: z.array(programDaySchema).min(1, 'At least one day is required'),
});

export const updateProgramSchema = createProgramSchema.partial().omit({ days: true });

export type ProgramExerciseInput = z.infer<typeof programExerciseSchema>;
export type ProgramDayInput = z.infer<typeof programDaySchema>;
export type CreateProgramInput = z.infer<typeof createProgramSchema>;
export type UpdateProgramInput = z.infer<typeof updateProgramSchema>;
