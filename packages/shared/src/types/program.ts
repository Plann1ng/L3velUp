import type { ExperienceLevel, Goal } from './user';

export interface WorkoutProgram {
  id: string;
  gymId: string;
  creatorId: string | null;
  name: string;
  description: string | null;
  goal: Goal | null;
  difficulty: ExperienceLevel | null;
  durationWeeks: number;
  isPublic: boolean;
  isGymTemplate: boolean;
  isArchived: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface ProgramDay {
  id: string;
  programId: string;
  weekNumber: number;
  dayNumber: number;
  /** e.g. "Push Day", "Rest" */
  name: string | null;
}

export interface ProgramExercise {
  id: string;
  dayId: string;
  exerciseId: string;
  orderIndex: number;
  targetSets: number | null;
  /** e.g. "8-12" or "AMRAP" */
  targetReps: string | null;
  /** e.g. "70% 1RM" (instructional only) */
  targetWeight: string | null;
  restSeconds: number | null;
  notes: string | null;
}

export interface MemberProgram {
  id: string;
  profileId: string;
  programId: string;
  startedAt: string;
  currentWeek: number;
  currentDay: number;
  completedAt: string | null;
  isActive: boolean;
  createdAt: string;
}
