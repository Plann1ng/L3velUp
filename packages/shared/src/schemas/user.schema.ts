import { z } from 'zod';
import { avatarConfigSchema } from './avatar.schema';
import {
  ageBandSchema,
  experienceLevelSchema,
  goalSchema,
  leaderboardVisibilitySchema,
} from './base.schema';

export const updateProfileSchema = z.object({
  displayName: z.string().min(1).max(50).optional(),
  goal: goalSchema.optional(),
  ageBand: ageBandSchema.optional(),
  experienceLevel: experienceLevelSchema.optional(),
  avatarConfig: avatarConfigSchema.optional(),
  leaderboardVisibility: leaderboardVisibilitySchema.optional(),
  cityLeaderboardOptIn: z.boolean().optional(),
  countryLeaderboardOptIn: z.boolean().optional(),
});

export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;

// Re-export base schemas for convenience
export {
  ageBandSchema,
  boardPeriodSchema,
  boardScopeSchema,
  boardTypeSchema,
  experienceLevelSchema,
  goalSchema,
  leaderboardVisibilitySchema,
  userRoleSchema,
} from './base.schema';
export { avatarConfigSchema } from './avatar.schema';
