TICKET 095 — barre de filtres conforme à la maquette

Modifie `src/components/catalogue/FiltresBarre.tsx`. Ce ticket ne change **que
l'apparence**. Le comportement actuel est correct et reste vérifié par
`tests/FiltresBarre.test.tsx`, qui doit rester vert : ne change ni les props, ni
l'état `ouvert`, ni les fonctions de critères, ni un seul `data-testid`, ni un
seul libellé, ni un seul `aria-label`.

## Pourquoi
Le fichier utilise `--vs-principal` et `--vs-fond`. **Ces jetons n'existent pas.**
Un jeton qui n'existe pas donne une couleur vide : le fond des pastilles est
transparent, leur texte blanc sur blanc, et elles ne se voient pas.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Export nommé `FiltresBarre`.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.**
- Icônes : **`lucide-react` uniquement**, chacune avec `aria-hidden`.
- **Jetons de couleur — liste fermée.** Les seuls `var(--vs-…)` autorisés dans ce
  fichier sont : `--vs-noir` `--vs-blanc` `--vs-ligne` `--vs-gris` `--vs-accent`.
  Aucun autre n'existe. Seule teinte fixe autorisée : `#F0F0EE`.
- **Supprime** toute classe `rounded-md`, `shadow-sm`, `shadow-lg`, `ring-*`,
  `hover:*` et `focus:*`. Aucune n'est remplacée.
- **Aucun `<h1>`.**

## Bloc d'imports exact (inchangé)
```tsx
'use client';

import { ChevronDown, SlidersHorizontal, X } from 'lucide-react';
import { useState } from 'react';
import type { Marque } from '@/lib/catalogue';
import type { Criteres, Tri } from '@/lib/filtres';
```

## Classes — à recopier telles quelles, juste après les imports
Ces constantes sont la seule source des classes visuelles du fichier. Elles sont
écrites en toutes lettres : ne les découpe pas, ne les reconstruis pas.
```ts
const PILULE = 'flex h-[46px] items-center gap-2 rounded-full border-[1.5px] px-[18px] text-[15px] font-semibold';
const PILULE_OFF = 'border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]';
const PILULE_ON = 'border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]';
const PANNEAU = 'absolute left-0 top-[54px] z-20 rounded-[20px] border border-[var(--vs-ligne)] bg-[var(--vs-blanc)] p-3.5 shadow-[0_18px_40px_rgba(16,16,20,0.12)]';
const PANNEAU_MARQUES = 'flex w-[300px] flex-wrap gap-2';
const PANNEAU_TAILLES = 'grid w-[320px] grid-cols-5 gap-2';
const OPTION_MARQUE = 'h-[38px] rounded-full border-[1.5px] px-3.5 text-sm font-semibold';
const OPTION_TAILLE = 'h-11 rounded-xl border-[1.5px] text-sm font-bold';
const TRI_LIBELLE = 'text-[15px] text-[var(--vs-gris)]';
const TRI_SELECT = 'h-[46px] rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-4 text-[15px] font-semibold text-[var(--vs-noir)]';
const PASTILLES = 'mt-4 flex flex-wrap items-center gap-2';
const PASTILLE = 'flex h-[34px] items-center gap-1.5 rounded-full bg-[#F0F0EE] pl-3.5 pr-2 text-sm font-semibold text-[var(--vs-noir)]';
const TOUT_EFFACER = 'h-[34px] px-3 text-sm font-semibold text-[var(--vs-gris)] underline';
const MOBILE_FILTRER = 'flex h-[46px] flex-1 items-center justify-center gap-2 rounded-full border-[1.5px] border-[var(--vs-noir)] bg-[var(--vs-blanc)] text-[15px] font-bold text-[var(--vs-noir)]';
const MOBILE_TRIER = 'h-[46px] flex-1 rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[15px] font-semibold text-[var(--vs-noir)]';
const TIROIR_FOND = 'fixed inset-0 z-40 bg-[rgba(16,16,20,0.45)] lg:hidden';
const TIROIR = 'fixed inset-x-0 bottom-0 z-50 max-h-[85vh] overflow-y-auto rounded-t-[28px] bg-[var(--vs-blanc)] px-5 pb-7 pt-6 lg:hidden';
const TIROIR_ENTETE = 'mb-5 flex items-center justify-between';
const TIROIR_TITRE = 'text-[22px] font-black text-[var(--vs-noir)]';
const TIROIR_SECTION = 'mb-2.5 text-[13px] font-bold uppercase tracking-[0.14em] text-[var(--vs-gris)]';
const FERMER = 'flex h-11 w-11 items-center justify-center rounded-full bg-[#F0F0EE] text-[var(--vs-noir)]';
const VALIDER = 'h-[54px] w-full rounded-full bg-[var(--vs-accent)] text-base font-extrabold text-[var(--vs-blanc)]';
const OPTION_TRI = 'h-[52px] w-full rounded-[14px] border-[1.5px] px-[18px] text-left text-base font-semibold';
```

## Où va chaque classe
Un élément qui a un état actif reçoit **une constante de forme** suivie de
`PILULE_ON` ou `PILULE_OFF`, exactement ainsi :
`` className={`${PILULE} ${actif ? PILULE_ON : PILULE_OFF}`} ``

**Éléments avec un état actif** — la condition est donnée en code exact :
- `bouton-marques` : `PILULE`, actif si `ouvert === 'marques' || marquesSelectionnees.length > 0`.
- `bouton-tailles` : `PILULE`, actif si `ouvert === 'tailles' || taillesSelectionnees.length > 0`.
- `filtre-promo` dans la barre : `PILULE`, actif si `criteres.promotionSeulement === true`.
- `filtre-stock` dans la barre : `PILULE`, actif si `criteres.enStockSeulement === true`.
- `filtre-promo` et `filtre-stock` dans le tiroir : même condition, forme
  `` `${PILULE} flex-1 justify-center` ``, soit
  `` className={`${PILULE} flex-1 justify-center ${actif ? PILULE_ON : PILULE_OFF}`} ``.
- chaque `filtre-marque-<slug>`, panneau et tiroir : `OPTION_MARQUE`, actif si
  `marquesSelectionnees.includes(marque.slug)`.
- chaque `filtre-taille-<t>`, panneau et tiroir : `OPTION_TAILLE`, actif si
  `taillesSelectionnees.includes(taille)`.
- chaque option du tiroir de tri : `OPTION_TRI`, actif si `tri === option.value`.

**Éléments sans état** — `className={CONSTANTE}` :
- `panneau-marques` : `` `${PANNEAU} ${PANNEAU_MARQUES}` `` ; `panneau-tailles` :
  `` `${PANNEAU} ${PANNEAU_TAILLES}` ``.
- `<label htmlFor="tri">` : `TRI_LIBELLE` ; `<select data-testid="tri">` : `TRI_SELECT`.
- `<div data-testid="pastilles">` : `PASTILLES` ; chaque bouton de pastille : `PASTILLE` ;
  `filtres-reinitialiser` : `TOUT_EFFACER`.
- `ouvrir-filtres` : `MOBILE_FILTRER` ; `ouvrir-tri` : `MOBILE_TRIER`.
- `tiroir-filtres` et `tiroir-tri` : `TIROIR`.
- dans chaque tiroir, la rangée qui contient le titre et le bouton Fermer :
  `TIROIR_ENTETE` ; le titre (`Filtrer` ou `Trier par`) : `TIROIR_TITRE` ; les
  intertitres `Marques`, `Tailles`, `Filtres` : `TIROIR_SECTION`.
- chaque bouton `aria-label="Fermer"` : `FERMER` ; le bouton `Appliquer les filtres` : `VALIDER`.

Dans le tiroir, les boutons de marque sont dans `<div className="mb-6 flex flex-wrap gap-2">`,
ceux de taille dans `<div className="mb-6 grid grid-cols-5 gap-2">`, et les deux
interrupteurs côte à côte dans `<div className="mb-6 flex gap-2">`. Les options du
tiroir de tri sont dans `<div className="flex flex-col gap-2.5">`.

## Trois ajouts, et seulement trois
1. Chaque `filtre-taille-<t>`, dans le panneau et dans le tiroir, reçoit
   `aria-pressed={taillesSelectionnees.includes(t)}`, comme les marques.
2. Chaque option du tiroir de tri reçoit `aria-pressed={tri === option.value}`.
3. Quand `ouvert` vaut `'tiroir'` ou `'tri'`, rendre **juste avant** le tiroir un
   fond cliquable qui ferme :
   `<div data-testid="tiroir-fond" aria-hidden="true" className={TIROIR_FOND} onClick={fermerPanneaux} />`.

Dans le tiroir de filtres, les interrupteurs Promotions et En stock ne contiennent
plus que leur texte : **supprime** les deux `<div>` qui dessinaient un curseur.
Les icônes : `<X aria-hidden size={14} className="text-[var(--vs-gris)]" />` dans
les pastilles, `<X aria-hidden size={18} />` dans les boutons Fermer ; les autres
icônes ne changent pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent. Les deux fichiers
`tests/FiltresBarre.test.tsx` et `tests/FiltresBarre-v2.test.tsx` sont verts.
