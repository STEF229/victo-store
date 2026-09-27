import { describe, expect, it } from 'vitest';
import * as A from '../src/components/compte/compte-affichage';

const ATTENDU: Record<string, string> = {
  TITRE_PAGE: 'text-[40px] font-black leading-none tracking-tight text-[var(--vs-noir)] lg:text-[52px]',
  SOUS_TITRE: 'text-base text-[var(--vs-gris)]',
  CHAMP: 'flex flex-col gap-2',
  CHAMP_LIBELLE: 'text-sm font-bold text-[var(--vs-noir)]',
  CHAMP_SAISIE: 'h-[54px] w-full rounded-[14px] border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-[18px] text-base text-[var(--vs-noir)]',
  CHAMP_SAISIE_ERREUR: 'h-[54px] w-full rounded-[14px] border-[1.5px] border-[var(--vs-promo)] bg-[var(--vs-blanc)] px-[18px] text-base text-[var(--vs-noir)]',
  CHAMP_AIDE: 'text-[13px] text-[var(--vs-gris)]',
  CHAMP_ERREUR: 'text-[13px] font-bold text-[var(--vs-promo)]',
  BOUTON_PRINCIPAL: 'flex h-14 w-full items-center justify-center rounded-full bg-[var(--vs-accent)] px-7 text-base font-extrabold text-[var(--vs-blanc)]',
  BOUTON_SECONDAIRE: 'flex h-14 w-full items-center justify-center rounded-full border-[1.5px] border-[var(--vs-noir)] bg-[var(--vs-blanc)] px-7 text-base font-extrabold text-[var(--vs-noir)]',
  LIEN: 'text-sm font-bold text-[var(--vs-noir)] underline',
  CARTE: 'flex flex-col gap-3.5 rounded-3xl border-[1.5px] border-[var(--vs-ligne)] p-[26px]',
  MENU_LIEN: 'flex h-[50px] items-center gap-3 rounded-full px-[18px] text-[15px] font-semibold text-[var(--vs-noir)]',
  MENU_LIEN_ACTIF: 'flex h-[50px] items-center gap-3 rounded-full bg-[var(--vs-noir)] px-[18px] text-[15px] font-bold text-[var(--vs-blanc)]',
};

describe('compte-affichage', () => {
  it("n'exporte que les constantes prévues", () => {
    expect(Object.keys(A).sort()).toEqual([
      'BOUTON_PRINCIPAL', 'BOUTON_SECONDAIRE', 'CARTE', 'CHAMP', 'CHAMP_AIDE', 'CHAMP_ERREUR', 'CHAMP_LIBELLE', 'CHAMP_SAISIE', 'CHAMP_SAISIE_ERREUR', 'CLASSES_STATUT', 'LIBELLES_STATUT', 'LIEN', 'MENU_LIEN', 'MENU_LIEN_ACTIF', 'SOUS_TITRE', 'TITRE_PAGE',
    ]);
  });

  it('recopie chaque classe à l\'identique', () => {
    const reel: Record<string, unknown> = { ...A };
    for (const [nom, valeur] of Object.entries(ATTENDU)) expect(reel[nom], nom).toBe(valeur);
  });

  it('donne une pastille et un libellé à chaque statut', () => {
    expect(Object.keys(A.CLASSES_STATUT).sort()).toEqual(['annulee', 'expediee', 'livree', 'preparation']);
    expect(A.LIBELLES_STATUT).toEqual({ preparation: 'En préparation', expediee: 'Expédiée', livree: 'Livrée', annulee: 'Annulée' });
    expect(A.CLASSES_STATUT.annulee).toContain('bg-[#FFD3DB]');
    expect(A.CLASSES_STATUT.expediee).toContain('text-[var(--vs-accent)]');
  });
});
