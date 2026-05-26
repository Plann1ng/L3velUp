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

export const userRoleSchema = z.enum(['gym_owner', 'gym_staff', 'member']);

export const leaderboardVisibilitySchema = z.enum(['public_name', 'nickname', 'private']);

export const boardTypeSchema = z.enum(['progress', 'consistency', 'performance']);

export const boardScopeSchema = z.enum(['gym', 'city', 'country']);

export const boardPeriodSchema = z.enum(['weekly', 'monthly', 'all_time']);
