import { z } from 'zod';
import { avatarConfigSchema } from './avatar.schema';
import { ageBandSchema, experienceLevelSchema, goalSchema } from './base.schema';

/** Step 1 — goal + experience selection */
export const onboardingGoalSchema = z.object({
  goal: goalSchema,
  experienceLevel: experienceLevelSchema,
  ageBand: ageBandSchema,
});

/** Step 2 — optional baseline metrics for progress leaderboard */
export const onboardingBaselineSchema = z
  .object({
    bodyWeightKg: z.number().positive().max(500).optional(),
    bench1RMkg: z.number().min(0).max(500).optional(),
    squat1RMkg: z.number().min(0).max(600).optional(),
    deadlift1RMkg: z.number().min(0).max(700).optional(),
    run5kSeconds: z.number().int().min(600).max(7200).optional(), // 10min–2hr
    pushupsMax: z.number().int().min(0).max(500).optional(),
  })
  .refine(
    (data) => Object.values(data).some((v) => v !== undefined),
    { message: 'At least one baseline metric is required' }
  );

/** Step 3 — initial avatar setup */
export const onboardingAvatarSchema = z.object({
  avatarConfig: avatarConfigSchema,
});

/** Full onboarding payload sent on completion */
export const completeOnboardingSchema = z.object({
  goal: goalSchema,
  experienceLevel: experienceLevelSchema,
  ageBand: ageBandSchema,
  avatarConfig: avatarConfigSchema,
  baseline: onboardingBaselineSchema.optional(),
});

export type OnboardingGoalInput = z.infer<typeof onboardingGoalSchema>;
export type OnboardingBaselineInput = z.infer<typeof onboardingBaselineSchema>;
export type OnboardingAvatarInput = z.infer<typeof onboardingAvatarSchema>;
export type CompleteOnboardingInput = z.infer<typeof completeOnboardingSchema>;
