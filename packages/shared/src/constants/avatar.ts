import type { AvatarSlot } from '../types/avatar';

export const AVATAR_SLOTS: AvatarSlot[] = [
  'background',
  'body',
  'skin',
  'bottom',
  'shoes',
  'top',
  'hair_back',
  'face',
  'hair_front',
  'accessory',
  'equipment',
];

export const AVATAR_SLOT_LABELS: Record<AvatarSlot, string> = {
  background: 'Background',
  body: 'Body',
  skin: 'Skin Tone',
  bottom: 'Bottoms',
  shoes: 'Shoes',
  top: 'Top',
  hair_back: 'Hair (back)',
  face: 'Face',
  hair_front: 'Hair (front)',
  accessory: 'Accessory',
  equipment: 'Equipment',
};

/** Minimum XP level required to unlock assets not listed in avatar_assets DB. */
export const DEFAULT_ASSET_LEVEL_REQUIREMENT = 1;

/** Minimum number of slots that should be set for a "complete" avatar. */
export const AVATAR_MIN_SLOTS_COMPLETE = 5;
