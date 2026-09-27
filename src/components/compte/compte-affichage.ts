import type { StatutCommande } from '@/lib/compte';

export const TITRE_PAGE = 'text-[40px] font-black leading-none tracking-tight text-[var(--vs-noir)] lg:text-[52px]';
export const SOUS_TITRE = 'text-base text-[var(--vs-gris)]';
export const CHAMP = 'flex flex-col gap-2';
export const CHAMP_LIBELLE = 'text-sm font-bold text-[var(--vs-noir)]';
export const CHAMP_SAISIE = 'h-[54px] w-full rounded-[14px] border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-[18px] text-base text-[var(--vs-noir)]';
export const CHAMP_SAISIE_ERREUR = 'h-[54px] w-full rounded-[14px] border-[1.5px] border-[var(--vs-promo)] bg-[var(--vs-blanc)] px-[18px] text-base text-[var(--vs-noir)]';
export const CHAMP_AIDE = 'text-[13px] text-[var(--vs-gris)]';
export const CHAMP_ERREUR = 'text-[13px] font-bold text-[var(--vs-promo)]';
export const BOUTON_PRINCIPAL = 'flex h-14 w-full items-center justify-center rounded-full bg-[var(--vs-accent)] px-7 text-base font-extrabold text-[var(--vs-blanc)]';
export const BOUTON_SECONDAIRE = 'flex h-14 w-full items-center justify-center rounded-full border-[1.5px] border-[var(--vs-noir)] bg-[var(--vs-blanc)] px-7 text-base font-extrabold text-[var(--vs-noir)]';
export const LIEN = 'text-sm font-bold text-[var(--vs-noir)] underline';
export const CARTE = 'flex flex-col gap-3.5 rounded-3xl border-[1.5px] border-[var(--vs-ligne)] p-[26px]';
export const MENU_LIEN = 'flex h-[50px] items-center gap-3 rounded-full px-[18px] text-[15px] font-semibold text-[var(--vs-noir)]';
export const MENU_LIEN_ACTIF = 'flex h-[50px] items-center gap-3 rounded-full bg-[var(--vs-noir)] px-[18px] text-[15px] font-bold text-[var(--vs-blanc)]';

export const CLASSES_STATUT: Record<StatutCommande, string> = {
  preparation: 'whitespace-nowrap rounded-full bg-[#E9E4DA] px-3 py-1.5 text-[13px] font-extrabold text-[var(--vs-noir)]',
  expediee: 'whitespace-nowrap rounded-full bg-[#EEF1F8] px-3 py-1.5 text-[13px] font-extrabold text-[var(--vs-accent)]',
  livree: 'whitespace-nowrap rounded-full bg-[#F0F0EE] px-3 py-1.5 text-[13px] font-extrabold text-[var(--vs-noir)]',
  annulee: 'whitespace-nowrap rounded-full bg-[#FFD3DB] px-3 py-1.5 text-[13px] font-extrabold text-[#C70026]',
};
export const LIBELLES_STATUT: Record<StatutCommande, string> = {
  preparation: 'En préparation',
  expediee: 'Expédiée',
  livree: 'Livrée',
  annulee: 'Annulée',
};
