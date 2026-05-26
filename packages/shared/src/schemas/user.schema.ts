import { z } from 'zod';

export const goalSchema = z.enum([
  'strength',
  'muscle_gain',
  'fat_loss',
  'fitness',
  'cardio',
  'power',
  'mobility',
  'general_health',
]);

export const ageBandSchema = z.enum(['16-24', '25-34', '35-44', '45-54', '55+']);

export const experienceLevelSchema = z.enum(['beginner', 'intermediate', 'advanced']);

export const leaderboardPrivacySchema = z.enum([
  'public',
  'gym_visible',
  'anonymous',
  'private',
]);

export const avatarConfigSchema = z
  .object({
    background: z.string().optional(),
    body: z.string().optional(),
    skin: z.string().optional(),
    bottom: z.string().optional(),
    shoes: z.string().optional(),
    top: z.string().optional(),
    hair_back: z.string().optional(),
    face: z.string().optional(),
    hair_front: z.string().optional(),
    accessory: z.string().optional(),
    equipment: z.string().optional(),
  })
  .strict();

export const updateProfileSchema = z.object({
  displayName: z.string().min(1).max(50).optional(),
  goal: goalSchema.optional(),
  ageBand: ageBandSchema.optional(),
  experienceLevel: experienceLevelSchema.optional(),
  avatarConfig: avatarConfigSchema.optional(),
  leaderboardPrivacy: leaderboardPrivacySchema.optional(),
});

export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
