import { z } from 'zod';

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

export type AvatarConfigInput = z.infer<typeof avatarConfigSchema>;
