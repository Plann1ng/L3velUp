import type { AgeBand, ExperienceLevel, Goal } from '../types/user';

export const GOALS: Goal[] = [
  'strength',
  'muscle_gain',
  'fat_loss',
  'fitness',
  'cardio',
  'power',
  'mobility',
  'general_health',
];

export const GOAL_LABELS: Record<Goal, string> = {
  strength: 'Strength',
  muscle_gain: 'Muscle Gain',
  fat_loss: 'Fat Loss',
  fitness: 'General Fitness',
  cardio: 'Cardio',
  power: 'Power',
  mobility: 'Mobility',
  general_health: 'General Health',
};

export const GOAL_DESCRIPTIONS: Record<Goal, string> = {
  strength: 'Build maximal strength in compound lifts',
  muscle_gain: 'Increase muscle size and definition',
  fat_loss: 'Reduce body fat while preserving muscle',
  fitness: 'Improve overall fitness and athleticism',
  cardio: 'Boost cardiovascular endurance',
  power: 'Develop explosive strength and speed',
  mobility: 'Enhance flexibility and joint range of motion',
  general_health: 'Maintain a healthy, active lifestyle',
};

export const AGE_BANDS: AgeBand[] = ['16-24', '25-34', '35-44', '45-54', '55+'];

export const EXPERIENCE_LEVELS: ExperienceLevel[] = ['beginner', 'intermediate', 'advanced'];

export const EXPERIENCE_LEVEL_LABELS: Record<ExperienceLevel, string> = {
  beginner: 'Beginner (< 6 months)',
  intermediate: 'Intermediate (6 months – 2 years)',
  advanced: 'Advanced (2+ years)',
};
