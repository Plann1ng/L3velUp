export type ExerciseCategory =
  | 'barbell'
  | 'dumbbell'
  | 'machine'
  | 'cable'
  | 'bodyweight'
  | 'cardio'
  | 'stretch'
  | 'other';

export interface Exercise {
  id: string;
  gymId: string | null;
  name: string;
  category: ExerciseCategory;
  muscleGroups: string[];
  equipment: string[];
  instructions: string | null;
  videoUrl: string | null;
  isArchived: boolean;
  createdAt: string;
}

export interface WorkoutSession {
  id: string;
  userId: string;
  gymId: string;
  programId: string | null;
  programDayId: string | null;
  title: string | null;
  notes: string | null;
  startedAt: string;
  endedAt: string | null;
  durationSeconds: number | null;
  xpEarned: number;
  createdAt: string;
}

export interface WorkoutSet {
  id: string;
  sessionId: string;
  exerciseId: string;
  setNumber: number;
  reps: number | null;
  weightKg: number | null;
  durationSeconds: number | null;
  distanceMeters: number | null;
  rpe: number | null;
  isPersonalRecord: boolean;
  completedAt: string;
}
