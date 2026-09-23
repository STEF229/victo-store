TICKET 095a — constantes d'affichage des filtres

Crée `src/components/catalogue/filtres-affichage.ts` avec **exactement** le
contenu ci-dessous, sans rien ajouter ni retirer. Ces chaînes viennent de la
maquette validée ; elles seront importées par la barre de filtres et par les
tiroirs mobiles.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Recopie chaque chaîne telle quelle : ne la découpe pas, ne la reformate pas.

## Contenu du fichier
Taille attendue : ~40 lignes.
```ts
import type { Tri } from '@/lib/filtres';

export const PILULE = 'flex h-[46px] items-center gap-2 rounded-full border-[1.5px] px-[18px] text-[15px] font-semibold';
export const PILULE_OFF = 'border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]';
export const PILULE_ON = 'border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]';
export const PANNEAU = 'absolute left-0 top-[54px] z-20 rounded-[20px] border border-[var(--vs-ligne)] bg-[var(--vs-blanc)] p-3.5 shadow-[0_18px_40px_rgba(16,16,20,0.12)]';
export const PANNEAU_MARQUES = 'flex w-[300px] flex-wrap gap-2';
export const PANNEAU_TAILLES = 'grid w-[320px] grid-cols-5 gap-2';
export const OPTION_MARQUE = 'h-[38px] rounded-full border-[1.5px] px-3.5 text-sm font-semibold';
export const OPTION_TAILLE = 'h-11 rounded-xl border-[1.5px] text-sm font-bold';
export const OPTION_TRI = 'h-[52px] w-full rounded-[14px] border-[1.5px] px-[18px] text-left text-base font-semibold';
export const TRI_LIBELLE = 'text-[15px] text-[var(--vs-gris)]';
export const TRI_SELECT = 'h-[46px] rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-4 text-[15px] font-semibold text-[var(--vs-noir)]';
export const PASTILLES = 'mt-4 flex flex-wrap items-center gap-2';
export const PASTILLE = 'flex h-[34px] items-center gap-1.5 rounded-full bg-[#F0F0EE] pl-3.5 pr-2 text-sm font-semibold text-[var(--vs-noir)]';
export const PASTILLE_CROIX = 'text-[var(--vs-gris)]';
export const TOUT_EFFACER = 'h-[34px] px-3 text-sm font-semibold text-[var(--vs-gris)] underline';
export const MOBILE_FILTRER = 'flex h-[46px] flex-1 items-center justify-center gap-2 rounded-full border-[1.5px] border-[var(--vs-noir)] bg-[var(--vs-blanc)] text-[15px] font-bold text-[var(--vs-noir)]';
export const MOBILE_TRIER = 'h-[46px] flex-1 rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[15px] font-semibold text-[var(--vs-noir)]';
export const TIROIR_FOND = 'fixed inset-0 z-40 bg-[rgba(16,16,20,0.45)] lg:hidden';
export const TIROIR = 'fixed inset-x-0 bottom-0 z-50 max-h-[85vh] overflow-y-auto rounded-t-[28px] bg-[var(--vs-blanc)] px-5 pb-7 pt-6 lg:hidden';
export const TIROIR_ENTETE = 'mb-5 flex items-center justify-between';
export const TIROIR_TITRE = 'text-[22px] font-black text-[var(--vs-noir)]';
export const TIROIR_SECTION = 'mb-2.5 text-[13px] font-bold uppercase tracking-[0.14em] text-[var(--vs-gris)]';
export const FERMER = 'flex h-11 w-11 items-center justify-center rounded-full bg-[#F0F0EE] text-[var(--vs-noir)]';
export const VALIDER = 'h-[54px] w-full rounded-full bg-[var(--vs-accent)] text-base font-extrabold text-[var(--vs-blanc)]';

export const OPTIONS_TRI: { valeur: Tri; libelle: string }[] = [
  { valeur: 'nouveautes', libelle: 'Nouveautés' },
  { valeur: 'prix-croissant', libelle: 'Prix croissant' },
  { valeur: 'prix-decroissant', libelle: 'Prix décroissant' },
  { valeur: 'remise', libelle: 'Meilleures remises' },
];
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
