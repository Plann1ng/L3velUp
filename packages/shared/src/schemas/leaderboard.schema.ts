import { z } from 'zod';
import {
  ageBandSchema,
  boardPeriodSchema,
  boardScopeSchema,
  boardTypeSchema,
  experienceLevelSchema,
  goalSchema,
} from './base.schema';

export const leaderboardFiltersSchema = z.object({
  boardType: boardTypeSchema,
  scope: boardScopeSchema.default('gym'),
  period: boardPeriodSchema,
  goalFilter: goalSchema.optional(),
  ageBandFilter: ageBandSchema.optional(),
  expFilter: experienceLevelSchema.optional(),
});

export type LeaderboardFiltersInput = z.infer<typeof leaderboardFiltersSchema>;
