export type SubscriptionTier = 'starter' | 'pro' | 'enterprise';

export interface GymThemeConfig {
  primaryColor: string;
  accentColor: string;
  appName: string;
  logoUrl?: string;
  timezone?: string;
}

export interface Gym {
  id: string;
  name: string;
  slug: string;
  logoUrl: string | null;
  themeConfig: GymThemeConfig;
  subscriptionTier: SubscriptionTier;
  ownerId: string;
  isActive: boolean;
  createdAt: string;
}
