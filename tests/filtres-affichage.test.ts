import { describe, expect, it } from 'vitest';
import * as A from '../src/components/catalogue/filtres-affichage';

const ATTENDU: Record<string, string> = {
  PILULE: 'flex h-[46px] items-center gap-2 rounded-full border-[1.5px] px-[18px] text-[15px] font-semibold',
  PILULE_OFF: 'border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]',
  PILULE_ON: 'border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]',
  PANNEAU: 'absolute left-0 top-[54px] z-20 rounded-[20px] border border-[var(--vs-ligne)] bg-[var(--vs-blanc)] p-3.5 shadow-[0_18px_40px_rgba(16,16,20,0.12)]',
  PANNEAU_MARQUES: 'flex w-[300px] flex-wrap gap-2',
  PANNEAU_TAILLES: 'grid w-[320px] grid-cols-5 gap-2',
  OPTION_MARQUE: 'h-[38px] rounded-full border-[1.5px] px-3.5 text-sm font-semibold',
  OPTION_TAILLE: 'h-11 rounded-xl border-[1.5px] text-sm font-bold',
  OPTION_TRI: 'h-[52px] w-full rounded-[14px] border-[1.5px] px-[18px] text-left text-base font-semibold',
  TRI_LIBELLE: 'text-[15px] text-[var(--vs-gris)]',
  TRI_SELECT: 'h-[46px] rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-4 text-[15px] font-semibold text-[var(--vs-noir)]',
  PASTILLES: 'mt-4 flex flex-wrap items-center gap-2',
  PASTILLE: 'flex h-[34px] items-center gap-1.5 rounded-full bg-[#F0F0EE] pl-3.5 pr-2 text-sm font-semibold text-[var(--vs-noir)]',
  PASTILLE_CROIX: 'text-[var(--vs-gris)]',
  TOUT_EFFACER: 'h-[34px] px-3 text-sm font-semibold text-[var(--vs-gris)] underline',
  MOBILE_FILTRER: 'flex h-[46px] flex-1 items-center justify-center gap-2 rounded-full border-[1.5px] border-[var(--vs-noir)] bg-[var(--vs-blanc)] text-[15px] font-bold text-[var(--vs-noir)]',
  MOBILE_TRIER: 'h-[46px] flex-1 rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[15px] font-semibold text-[var(--vs-noir)]',
  TIROIR_FOND: 'fixed inset-0 z-40 bg-[rgba(16,16,20,0.45)] lg:hidden',
  TIROIR: 'fixed inset-x-0 bottom-0 z-50 max-h-[85vh] overflow-y-auto rounded-t-[28px] bg-[var(--vs-blanc)] px-5 pb-7 pt-6 lg:hidden',
  TIROIR_ENTETE: 'mb-5 flex items-center justify-between',
  TIROIR_TITRE: 'text-[22px] font-black text-[var(--vs-noir)]',
  TIROIR_SECTION: 'mb-2.5 text-[13px] font-bold uppercase tracking-[0.14em] text-[var(--vs-gris)]',
  FERMER: 'flex h-11 w-11 items-center justify-center rounded-full bg-[#F0F0EE] text-[var(--vs-noir)]',
  VALIDER: 'h-[54px] w-full rounded-full bg-[var(--vs-accent)] text-base font-extrabold text-[var(--vs-blanc)]',
};

describe('filtres-affichage', () => {
  it("n'exporte que les constantes prévues", () => {
    expect(Object.keys(A).sort()).toEqual([
      'FERMER', 'MOBILE_FILTRER', 'MOBILE_TRIER', 'OPTIONS_TRI', 'OPTION_MARQUE', 'OPTION_TAILLE', 'OPTION_TRI', 'PANNEAU', 'PANNEAU_MARQUES', 'PANNEAU_TAILLES', 'PASTILLE', 'PASTILLES', 'PASTILLE_CROIX', 'PILULE', 'PILULE_OFF', 'PILULE_ON', 'TIROIR', 'TIROIR_ENTETE', 'TIROIR_FOND', 'TIROIR_SECTION', 'TIROIR_TITRE', 'TOUT_EFFACER', 'TRI_LIBELLE', 'TRI_SELECT', 'VALIDER',
    ]);
  });

  it('recopie chaque classe à l\'identique', () => {
    const reel: Record<string, unknown> = { ...A };
    for (const [nom, valeur] of Object.entries(ATTENDU)) expect(reel[nom], nom).toBe(valeur);
  });

  it('liste les quatre tris dans l\'ordre', () => {
    expect(A.OPTIONS_TRI).toEqual([
      { valeur: 'nouveautes', libelle: 'Nouveautés' },
      { valeur: 'prix-croissant', libelle: 'Prix croissant' },
      { valeur: 'prix-decroissant', libelle: 'Prix décroissant' },
      { valeur: 'remise', libelle: 'Meilleures remises' },
    ]);
  });
});
