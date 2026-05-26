export type AvatarSlot =
  | 'background'
  | 'body'
  | 'skin'
  | 'bottom'
  | 'shoes'
  | 'top'
  | 'hair_back'
  | 'face'
  | 'hair_front'
  | 'accessory'
  | 'equipment';

export type AvatarConfig = Partial<Record<AvatarSlot, string>>;

export const AVATAR_SLOT_ORDER: AvatarSlot[] = [
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

export function getDefaultAvatarConfig(): AvatarConfig {
  return {
    background: 'background/gym_01',
    body: 'body/athletic_01',
    skin: 'skin/medium_01',
    bottom: 'bottom/shorts_01',
    shoes: 'shoes/trainers_01',
    top: 'top/tank_01',
    face: 'face/neutral_01',
    hair_front: 'hair_front/short_01',
  };
}
