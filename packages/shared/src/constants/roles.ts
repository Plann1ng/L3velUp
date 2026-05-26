import type { UserRole } from '../types/user';

export const USER_ROLES: UserRole[] = ['gym_owner', 'gym_staff', 'member'];

export const USER_ROLE_LABELS: Record<UserRole, string> = {
  gym_owner: 'Gym Owner',
  gym_staff: 'Gym Staff',
  member: 'Member',
};

export const USER_ROLE_PERMISSIONS: Record<UserRole, string[]> = {
  gym_owner: ['manage_gym', 'manage_staff', 'manage_members', 'manage_programs', 'view_analytics'],
  gym_staff: ['manage_members', 'manage_programs', 'view_analytics'],
  member: ['log_workouts', 'view_leaderboard', 'view_programs', 'customize_avatar'],
};
