#!/usr/bin/env bash
# VICTO STORE — lot liste v3 : la barre de filtres en trois tickets tenant dans le contexte.
#   095a  filtres-affichage.ts : constantes de classes (maquette) et options de tri
#   095b  TiroirsFiltres.tsx   : tiroirs mobiles, sans état
#   095c  FiltresBarre.tsx     : réécrit à partir d'un fichier vide (mode neuf)
# Harnais : budget de contexte (TROP_GROS), mode neuf, lint d'Aider coupé.
# Nettoyage : ancien ticket 095 retiré, tsbuildinfo n'est plus suivi par git.
# Usage :  cd ~/victo-store && bash lot-liste-v3.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }
annuler(){ git reset -q --hard HEAD; git clean -fdq -- tests tickets run.sh; mort "$*  — rien n'a été modifié"; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
# Un tsbuildinfo encore suivi est réécrit à chaque porte : on annule ce bruit avant
# de juger l'arbre, puis on le retire du suivi plus bas.
modifies="$(git ls-files -m -- '*.tsbuildinfo')"
[ -z "$modifies" ] || { git checkout -q -- $modifies; ok "tsbuildinfo remis en l'état ($modifies)"; }
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
ok "main à jour ($(git rev-parse --short HEAD))"

JETONS=src/styles/tokens.css
[ -f "$JETONS" ] || mort "$JETONS introuvable (npm run tokens)"
for j in noir blanc ligne gris accent; do
  grep -qE -- "--vs-$j\s*:" "$JETONS" || mort "le jeton --vs-$j n'est pas défini dans $JETONS"
done
[ -f src/components/catalogue/FiltresBarre.tsx ] || mort "FiltresBarre.tsx absent"
[ -f tests/FiltresBarre.test.tsx ] || mort "tests/FiltresBarre.test.tsx absent : le comportement ne serait plus vérifié"
ok "jetons, cible et test de comportement présents"

mkdir -p tickets/tests
cat > tickets/095a-filtres-affichage.md <<'__VICTO_FIN_0__'
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
__VICTO_FIN_0__
cat > tickets/095b-tiroirs-filtres.md <<'__VICTO_FIN_1__'
TICKET 095b — tiroirs mobiles des filtres et du tri

Crée `src/components/catalogue/TiroirsFiltres.tsx`, export nommé `TiroirsFiltres`.
C'est un composant **sans état** : il affiche le tiroir demandé et remonte chaque
action par une prop. La barre de filtres l'utilisera au ticket suivant.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Aucun fichier baril n'existe.** Les déclarations des modules de `components/`
  te sont fournies en lecture seule ; les types de `lib/` sont donnés plus bas.
- **Toutes les classes de couleur et de forme viennent des constantes importées.**
  N'écris aucun `var(--vs-…)` dans ce fichier. Seules classes écrites à la main
  autorisées : celles des trois conteneurs donnés plus bas.
- Icône : `X` de `lucide-react`, avec `aria-hidden`. **Aucun `<h1>`, `<h2>`, `<h3>`.**

## Bloc d'imports exact
```tsx
import { X } from 'lucide-react';
import {
  FERMER, OPTION_MARQUE, OPTION_TAILLE, OPTION_TRI, OPTIONS_TRI, PILULE, PILULE_OFF, PILULE_ON,
  TIROIR, TIROIR_ENTETE, TIROIR_FOND, TIROIR_SECTION, TIROIR_TITRE, VALIDER,
} from '@/components/catalogue/filtres-affichage';
import type { Marque } from '@/lib/catalogue';
import type { Criteres, Tri } from '@/lib/filtres';
```

## Types importés
Leurs déclarations ne te sont pas fournies ; voici ce dont tu as besoin :
```ts
// '@/lib/catalogue' — d'autres champs peuvent exister
interface Marque { id: string; nom: string; slug: string }
// '@/lib/filtres' — d'autres champs optionnels peuvent exister
interface Criteres { marques?: string[]; tailles?: string[]; promotionSeulement?: boolean; enStockSeulement?: boolean }
type Tri = 'nouveautes' | 'prix-croissant' | 'prix-decroissant' | 'remise';
```

## Props
```ts
export type VueTiroir = 'filtres' | 'tri' | null;

interface TiroirsFiltresProps {
  vue: VueTiroir;
  marques: Marque[];
  tailles: string[];
  criteres: Criteres;
  tri: Tri;
  onMarque: (slug: string) => void;
  onTaille: (taille: string) => void;
  onPromo: () => void;
  onStock: () => void;
  onTri: (tri: Tri) => void;
  onFermer: () => void;
}
```
`VueTiroir` est exporté.

## Rendu
Taille attendue : ~130 lignes.

Si `vue` vaut `null`, le composant renvoie `null`. Sinon il renvoie un fragment :
1. `<div data-testid="tiroir-fond" aria-hidden="true" className={TIROIR_FOND} onClick={onFermer} />`
2. puis le tiroir correspondant à `vue`.

**Règle d'état** — un bouton qui a un état reçoit sa constante de forme suivie de
`PILULE_ON` s'il est actif, `PILULE_OFF` sinon, et `aria-pressed` égal à ce même
booléen : `` className={`${FORME} ${actif ? PILULE_ON : PILULE_OFF}`} ``.

**Rangée de titre**, en tête de chaque tiroir :
`<div className={TIROIR_ENTETE}>` contenant `<p className={TIROIR_TITRE}>` (texte
`Filtrer` ou `Trier par`) puis
`<button type="button" aria-label="Fermer" className={FERMER} onClick={onFermer}>`
contenant `<X aria-hidden size={18} />`.

### `vue === 'filtres'`
`<div data-testid="tiroir-filtres" role="dialog" aria-label="Filtrer" className={TIROIR}>`
contenant, dans l'ordre :
- la rangée de titre `Filtrer` ;
- `<p className={TIROIR_SECTION}>Marques</p>` puis `<div className="mb-6 flex flex-wrap gap-2">` :
  un bouton par marque, `` data-testid={`filtre-marque-${marque.slug}`} ``, texte
  `marque.nom`, forme `OPTION_MARQUE`, actif si `criteres.marques` contient
  `marque.slug`, clic → `onMarque(marque.slug)` ;
- `<p className={TIROIR_SECTION}>Tailles</p>` puis `<div className="mb-6 grid grid-cols-5 gap-2">` :
  un bouton par taille, `` data-testid={`filtre-taille-${taille}`} ``, texte `taille`,
  forme `OPTION_TAILLE`, actif si `criteres.tailles` contient `taille`, clic →
  `onTaille(taille)` ;
- `<div className="mb-6 flex gap-2">` : deux boutons de forme
  `` `${PILULE} flex-1 justify-center` `` — `data-testid="filtre-promo"`, texte
  `Promotions`, actif si `criteres.promotionSeulement === true`, clic → `onPromo()` ;
  puis `data-testid="filtre-stock"`, texte `En stock`, actif si
  `criteres.enStockSeulement === true`, clic → `onStock()` ;
- `<button type="button" className={VALIDER} onClick={onFermer}>Appliquer les filtres</button>`.

### `vue === 'tri'`
`<div data-testid="tiroir-tri" role="dialog" aria-label="Trier" className={TIROIR}>`
contenant la rangée de titre `Trier par`, puis `<div className="flex flex-col gap-2.5">` :
un bouton par élément de `OPTIONS_TRI`, texte `option.libelle`, forme `OPTION_TRI`,
actif si `tri === option.valeur`. Au clic : `onTri(option.valeur)` puis `onFermer()`.

Tous les boutons ont `type="button"`. Les listes utilisent `.map` avec une `key`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > tickets/095c-filtres-barre-v3.md <<'__VICTO_FIN_2__'
TICKET 095c — barre de filtres, réécriture complète

Écris `src/components/catalogue/FiltresBarre.tsx` en entier, export nommé
`FiltresBarre`, à partir de zéro. Il assemble `TiroirsFiltres` et les classes de
`filtres-affichage`, et porte la logique.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Aucun fichier baril n'existe.** Les déclarations des modules de `components/`
  te sont fournies en lecture seule ; les types de `lib/` sont donnés plus bas.
- **Toutes les classes de couleur et de forme viennent des constantes importées.**
  N'écris aucun `var(--vs-…)` dans ce fichier. Seules classes écrites à la main
  autorisées : celles des conteneurs donnés plus bas, sans couleur.
- Icônes `lucide-react` avec `aria-hidden`. **Aucun `<h1>`.**
- Ne mute jamais `criteres` : chaque changement appelle `onChange` avec un **nouvel**
  objet complet `{ ...criteres, … }`.

## Bloc d'imports exact
```tsx
'use client';

import { ChevronDown, SlidersHorizontal, X } from 'lucide-react';
import { useState } from 'react';
import {
  MOBILE_FILTRER, MOBILE_TRIER, OPTION_MARQUE, OPTION_TAILLE, OPTIONS_TRI, PANNEAU, PANNEAU_MARQUES,
  PANNEAU_TAILLES, PASTILLE, PASTILLE_CROIX, PASTILLES, PILULE, PILULE_OFF, PILULE_ON, TOUT_EFFACER, TRI_LIBELLE, TRI_SELECT,
} from '@/components/catalogue/filtres-affichage';
import { TiroirsFiltres } from '@/components/catalogue/TiroirsFiltres';
import type { Marque } from '@/lib/catalogue';
import type { Criteres, Tri } from '@/lib/filtres';
```

## Types importés
Leurs déclarations ne te sont pas fournies ; voici ce dont tu as besoin :
```ts
// '@/lib/catalogue' — d'autres champs peuvent exister
interface Marque { id: string; nom: string; slug: string }
// '@/lib/filtres' — d'autres champs optionnels peuvent exister
interface Criteres { marques?: string[]; tailles?: string[]; promotionSeulement?: boolean; enStockSeulement?: boolean }
type Tri = 'nouveautes' | 'prix-croissant' | 'prix-decroissant' | 'remise';
```

## Props et état
```ts
interface FiltresBarreProps {
  marques: Marque[];
  tailles: string[];
  criteres: Criteres;
  onChange: (criteres: Criteres) => void;
  tri: Tri;
  onTriChange: (tri: Tri) => void;
}
```
Seul état interne : `const [ouvert, setOuvert] = useState<null | 'marques' | 'tailles' | 'filtres' | 'tri'>(null);`
Cliquer le bouton d'une vue l'ouvre ; recliquer le bouton de la vue ouverte la
ferme ; ouvrir une vue ferme l'autre.

## Logique
- **Basculer une marque ou une taille** : si la valeur est déjà dans la liste
  (`criteres.marques ?? []`, idem `tailles`), la retirer avec `.filter` en gardant
  l'ordre des autres ; sinon l'ajouter à la fin. Appeler `onChange` avec la
  nouvelle liste, même vide.
- **Basculer Promotions** : `onChange({ ...criteres, promotionSeulement: !criteres.promotionSeulement })`.
  **En stock** de même avec `enStockSeulement`.
- **Retirer depuis une pastille** : une marque ou une taille se bascule comme
  ci-dessus ; Promotions et En stock passent à `false`.
- **Tout effacer** : `onChange({})`.
- **Nombre de filtres actifs** : marques choisies + tailles choisies + 1 si
  `promotionSeulement` + 1 si `enStockSeulement`.

## Rendu
Taille attendue : ~200 lignes.

**Règle d'état** — un bouton qui a un état reçoit sa constante de forme suivie de
`PILULE_ON` s'il est actif, `PILULE_OFF` sinon :
`` className={`${FORME} ${actif ? PILULE_ON : PILULE_OFF}`} ``. Tous les boutons
ont `type="button"`.

Racine `<div data-testid="filtres-barre">`, qui contient dans l'ordre :

**1. Barre, grand écran** — `<div data-testid="barre-bureau" className="hidden flex-wrap items-center gap-3 lg:flex">` :
- `<div className="relative">` avec le bouton `data-testid="bouton-marques"`,
  `aria-expanded={ouvert === 'marques'}`, forme `PILULE`, actif si
  `ouvert === 'marques' || criteres.marques` non vide. Contenu :
  `<span>` de texte `Marque` sans sélection, `Marque (N)` avec N marques choisies,
  puis `<ChevronDown aria-hidden size={16} />`. Quand `ouvert === 'marques'`, suivi de
  `` <div data-testid="panneau-marques" className={`${PANNEAU} ${PANNEAU_MARQUES}`}> `` :
  un bouton par marque, `` data-testid={`filtre-marque-${marque.slug}`} ``, texte
  `marque.nom`, forme `OPTION_MARQUE`, `aria-pressed` et actif si la marque est choisie.
- même chose pour les tailles : `bouton-tailles`, texte `Taille` ou `Taille (N)`,
  `panneau-tailles` avec `PANNEAU_TAILLES`, boutons
  `` data-testid={`filtre-taille-${taille}`} `` de forme `OPTION_TAILLE`, `aria-pressed`.
- `data-testid="filtre-promo"`, texte `Promotions`, forme `PILULE`,
  `aria-pressed` et actif si `criteres.promotionSeulement === true`.
- `data-testid="filtre-stock"`, texte `En stock`, idem avec `enStockSeulement`.
- `<div className="ml-auto flex items-center gap-2">` contenant
  `<label htmlFor="tri" className={TRI_LIBELLE}>Trier par</label>` et
  `<select id="tri" data-testid="tri" className={TRI_SELECT} value={tri}>` avec une
  `<option value={o.valeur}>{o.libelle}</option>` par élément de `OPTIONS_TRI`. Au
  changement : `onTriChange(e.target.value as Tri)`.

**2. Pastilles**, seulement s'il y a au moins un filtre actif —
`<div data-testid="pastilles" className={PASTILLES}>` : une pastille par filtre
actif, dans l'ordre marques, tailles, Promotions, En stock. Chaque pastille est un
`<button className={PASTILLE}>` avec `aria-label` `Retirer le filtre <texte>`,
contenant `<span>` du texte puis `<X aria-hidden size={14} className={PASTILLE_CROIX} />`.
Textes : le nom de la marque (retrouvé dans `marques` par son slug ; une marque
introuvable n'a pas de pastille), `Taille <valeur>`, `Promotions`, `En stock`.
Puis `<button data-testid="filtres-reinitialiser" className={TOUT_EFFACER}>Tout effacer</button>`.

**3. Barre, téléphone** — `<div data-testid="barre-mobile" className="flex items-center gap-3 lg:hidden">` :
- `data-testid="ouvrir-filtres"`, `className={MOBILE_FILTRER}`, contenant
  `<SlidersHorizontal aria-hidden size={17} />` puis `<span>` de texte `Filtrer` ou
  `Filtrer (N)`, N = nombre de filtres actifs. Ouvre ou ferme la vue `'filtres'`.
- `data-testid="ouvrir-tri"`, `className={MOBILE_TRIER}`, texte `Trier` seul.
  Ouvre ou ferme la vue `'tri'`.

**4. Tiroirs** — `<TiroirsFiltres>` avec
`vue={ouvert === 'filtres' || ouvert === 'tri' ? ouvert : null}`, les props
`marques`, `tailles`, `criteres`, `tri`, et : `onMarque` et `onTaille` basculent la
valeur, `onPromo` et `onStock` basculent l'interrupteur, `onTri` appelle
`onTriChange`, `onFermer` remet `ouvert` à `null`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont
`tests/FiltresBarre.test.tsx`, qui vérifie le comportement.
__VICTO_FIN_2__
cat > tickets/manifest-liste-v3.tsv <<'__VICTO_FIN_3__'
095a	src/components/catalogue/filtres-affichage.ts	tests/filtres-affichage.test.ts	tickets/095a-filtres-affichage.md	src/lib/filtres.ts		
095b	src/components/catalogue/TiroirsFiltres.tsx	tests/TiroirsFiltres.test.tsx	tickets/095b-tiroirs-filtres.md	src/components/catalogue/filtres-affichage.ts	095a	
095c	src/components/catalogue/FiltresBarre.tsx	tests/FiltresBarre-v3.test.tsx	tickets/095c-filtres-barre-v3.md	src/components/catalogue/filtres-affichage.ts,src/components/catalogue/TiroirsFiltres.tsx	095a,095b	neuf
__VICTO_FIN_3__
cat > tickets/tests/filtres-affichage.test.ts <<'__VICTO_FIN_4__'
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
__VICTO_FIN_4__
cat > tickets/tests/TiroirsFiltres.test.tsx <<'__VICTO_FIN_5__'
import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import {
  FERMER, OPTION_MARQUE, OPTION_TAILLE, OPTION_TRI, PILULE, PILULE_OFF, PILULE_ON,
  TIROIR, TIROIR_ENTETE, TIROIR_FOND, TIROIR_SECTION, TIROIR_TITRE, VALIDER,
} from '../src/components/catalogue/filtres-affichage';
import { TiroirsFiltres, type VueTiroir } from '../src/components/catalogue/TiroirsFiltres';
import type { Marque } from '../src/lib/catalogue';
import type { Criteres } from '../src/lib/filtres';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
function porte(el: Element, ...attendues: string[]) {
  const reelles = classes(el);
  for (const chaine of attendues) for (const k of chaine.split(' ')) expect(reelles, `classe ${k}`).toContain(k);
}
const MARQUES: Marque[] = [
  { id: 'm1', nom: 'Nike', slug: 'nike' },
  { id: 'm2', nom: 'Lacoste', slug: 'lacoste' },
];

function poser(vue: VueTiroir, criteres: Criteres = {}) {
  const f = {
    onMarque: vi.fn(), onTaille: vi.fn(), onPromo: vi.fn(), onStock: vi.fn(), onTri: vi.fn(), onFermer: vi.fn(),
  };
  const rendu = render(
    <TiroirsFiltres vue={vue} marques={MARQUES} tailles={['40', '41']} criteres={criteres} tri="nouveautes" {...f} />,
  );
  return { ...f, container: rendu.container };
}

describe('TiroirsFiltres — fermé', () => {
  it('ne rend rien quand vue vaut null', () => {
    const { container } = poser(null);
    expect(container.innerHTML).toBe('');
  });
});

describe('TiroirsFiltres — filtres', () => {
  it('rend le fond puis le tiroir, avec leurs classes', () => {
    poser('filtres');
    const fond = screen.getByTestId('tiroir-fond');
    const tiroir = screen.getByTestId('tiroir-filtres');
    porte(fond, TIROIR_FOND);
    expect(fond).toHaveAttribute('aria-hidden', 'true');
    porte(tiroir, TIROIR);
    expect(tiroir).toHaveAttribute('role', 'dialog');
    expect(tiroir).toHaveAttribute('aria-label', 'Filtrer');
    expect(fond.compareDocumentPosition(tiroir) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(screen.queryByTestId('tiroir-tri')).toBeNull();
  });

  it('titre le tiroir et ses sections', () => {
    poser('filtres');
    const tiroir = screen.getByTestId('tiroir-filtres');
    porte(within(tiroir).getByText('Filtrer', { selector: 'p' }), TIROIR_TITRE);
    porte(within(tiroir).getByText('Marques'), TIROIR_SECTION);
    porte(within(tiroir).getByText('Tailles'), TIROIR_SECTION);
    const fermer = within(tiroir).getByRole('button', { name: 'Fermer' });
    porte(fermer, FERMER);
    expect(fermer.querySelector('svg.lucide-x')).not.toBeNull();
    expect(tiroir.querySelector(`.${TIROIR_ENTETE.split(' ').join('.')}`)).not.toBeNull();
    expect(tiroir.querySelector('h1, h2, h3')).toBeNull();
  });

  it('marque les choix actifs et les autres', () => {
    poser('filtres', { marques: ['nike'], tailles: ['41'], promotionSeulement: true });
    const nike = screen.getByTestId('filtre-marque-nike');
    porte(nike, OPTION_MARQUE, PILULE_ON);
    expect(nike).toHaveAttribute('aria-pressed', 'true');
    porte(screen.getByTestId('filtre-marque-lacoste'), OPTION_MARQUE, PILULE_OFF);
    expect(screen.getByTestId('filtre-marque-lacoste')).toHaveAttribute('aria-pressed', 'false');
    porte(screen.getByTestId('filtre-taille-41'), OPTION_TAILLE, PILULE_ON);
    porte(screen.getByTestId('filtre-taille-40'), OPTION_TAILLE, PILULE_OFF);
    porte(screen.getByTestId('filtre-promo'), PILULE, 'flex-1 justify-center', PILULE_ON);
    porte(screen.getByTestId('filtre-stock'), PILULE, 'flex-1 justify-center', PILULE_OFF);
    expect(screen.getByTestId('filtre-stock')).toHaveAttribute('aria-pressed', 'false');
  });

  it('remonte chaque action', () => {
    const f = poser('filtres');
    fireEvent.click(screen.getByTestId('filtre-marque-lacoste'));
    expect(f.onMarque).toHaveBeenCalledWith('lacoste');
    fireEvent.click(screen.getByTestId('filtre-taille-40'));
    expect(f.onTaille).toHaveBeenCalledWith('40');
    fireEvent.click(screen.getByTestId('filtre-promo'));
    expect(f.onPromo).toHaveBeenCalledTimes(1);
    fireEvent.click(screen.getByTestId('filtre-stock'));
    expect(f.onStock).toHaveBeenCalledTimes(1);
    expect(f.onFermer).not.toHaveBeenCalled();
  });

  it('ferme par la croix, le bouton de validation et le fond', () => {
    const f = poser('filtres');
    const valider = screen.getByRole('button', { name: 'Appliquer les filtres' });
    porte(valider, VALIDER);
    fireEvent.click(screen.getByRole('button', { name: 'Fermer' }));
    fireEvent.click(valider);
    fireEvent.click(screen.getByTestId('tiroir-fond'));
    expect(f.onFermer).toHaveBeenCalledTimes(3);
  });
});

describe('TiroirsFiltres — tri', () => {
  it('rend le tiroir de tri et marque le tri courant', () => {
    poser('tri');
    const tiroir = screen.getByTestId('tiroir-tri');
    porte(tiroir, TIROIR);
    expect(tiroir).toHaveAttribute('aria-label', 'Trier');
    porte(within(tiroir).getByText('Trier par', { selector: 'p' }), TIROIR_TITRE);
    expect(within(tiroir).getAllByRole('button').map((b: HTMLElement) => b.textContent)).toEqual([
      '', 'Nouveautés', 'Prix croissant', 'Prix décroissant', 'Meilleures remises',
    ]);
    const courant = within(tiroir).getByRole('button', { name: 'Nouveautés' });
    porte(courant, OPTION_TRI, PILULE_ON);
    expect(courant).toHaveAttribute('aria-pressed', 'true');
    porte(within(tiroir).getByRole('button', { name: 'Prix croissant' }), OPTION_TRI, PILULE_OFF);
    expect(screen.queryByTestId('tiroir-filtres')).toBeNull();
  });

  it('choisit un tri puis ferme', () => {
    const f = poser('tri');
    fireEvent.click(screen.getByRole('button', { name: 'Meilleures remises' }));
    expect(f.onTri).toHaveBeenCalledWith('remise');
    expect(f.onFermer).toHaveBeenCalledTimes(1);
  });
});

describe('TiroirsFiltres — source', () => {
  it("ne code aucune couleur à la main : tout vient des constantes", () => {
    const source = readFileSync('src/components/catalogue/TiroirsFiltres.tsx', 'utf8');
    expect(source).not.toContain('var(--vs-');
    expect(source).toContain("from '@/components/catalogue/filtres-affichage'");
  });
});
__VICTO_FIN_5__
cat > tickets/tests/FiltresBarre-v3.test.tsx <<'__VICTO_FIN_6__'
import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { FiltresBarre } from '../src/components/catalogue/FiltresBarre';
import {
  MOBILE_FILTRER, MOBILE_TRIER, OPTION_MARQUE, OPTION_TAILLE, PANNEAU, PANNEAU_MARQUES, PANNEAU_TAILLES,
  PASTILLE, PASTILLE_CROIX, PASTILLES, PILULE, PILULE_OFF, PILULE_ON, TOUT_EFFACER, TRI_LIBELLE, TRI_SELECT,
} from '../src/components/catalogue/filtres-affichage';
// Dépendance déclarée pour le harnais : sans les tiroirs, ce ticket est BLOQUÉ.
import { TiroirsFiltres as _dependance } from '../src/components/catalogue/TiroirsFiltres';
import type { Marque } from '../src/lib/catalogue';
import type { Criteres } from '../src/lib/filtres';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
function porte(el: Element, ...attendues: string[]) {
  const reelles = classes(el);
  for (const chaine of attendues) for (const k of chaine.split(' ')) expect(reelles, `classe ${k}`).toContain(k);
}
const MARQUES: Marque[] = [
  { id: 'm1', nom: 'Nike', slug: 'nike' },
  { id: 'm2', nom: 'Lacoste', slug: 'lacoste' },
];

function poser(criteres: Criteres = {}) {
  const onChange = vi.fn();
  const onTriChange = vi.fn();
  render(
    <FiltresBarre marques={MARQUES} tailles={['40', '41']} criteres={criteres}
      onChange={onChange} tri="nouveautes" onTriChange={onTriChange} />,
  );
  return { onChange, onTriChange };
}

describe('FiltresBarre v3 — pilules', () => {
  it('rend les quatre pilules inactives sans filtre', () => {
    poser();
    for (const id of ['bouton-marques', 'bouton-tailles', 'filtre-promo', 'filtre-stock']) {
      porte(screen.getByTestId(id), PILULE, PILULE_OFF);
    }
  });

  it('noircit chaque pilule active', () => {
    poser({ marques: ['nike'], tailles: ['41'], promotionSeulement: true, enStockSeulement: true });
    for (const id of ['bouton-marques', 'bouton-tailles', 'filtre-promo', 'filtre-stock']) {
      porte(screen.getByTestId(id), PILULE, PILULE_ON);
    }
    expect(screen.getByTestId('filtre-promo')).toHaveAttribute('aria-pressed', 'true');
  });

  it('noircit Marque tant que son panneau est ouvert', () => {
    poser();
    fireEvent.click(screen.getByTestId('bouton-marques'));
    porte(screen.getByTestId('bouton-marques'), PILULE_ON);
    porte(screen.getByTestId('bouton-tailles'), PILULE_OFF);
  });
});

describe('FiltresBarre v3 — panneaux et tri', () => {
  it('habille le panneau des marques', () => {
    poser({ marques: ['nike'] });
    fireEvent.click(screen.getByTestId('bouton-marques'));
    porte(screen.getByTestId('panneau-marques'), PANNEAU, PANNEAU_MARQUES);
    porte(screen.getByTestId('filtre-marque-nike'), OPTION_MARQUE, PILULE_ON);
    porte(screen.getByTestId('filtre-marque-lacoste'), OPTION_MARQUE, PILULE_OFF);
  });

  it('habille le panneau des tailles et le tri', () => {
    poser({ tailles: ['41'] });
    porte(screen.getByText('Trier par', { selector: 'label' }), TRI_LIBELLE);
    porte(screen.getByTestId('tri'), TRI_SELECT);
    fireEvent.click(screen.getByTestId('bouton-tailles'));
    porte(screen.getByTestId('panneau-tailles'), PANNEAU, PANNEAU_TAILLES);
    porte(screen.getByTestId('filtre-taille-41'), OPTION_TAILLE, PILULE_ON);
    expect(screen.getByTestId('filtre-taille-41')).toHaveAttribute('aria-pressed', 'true');
    expect(screen.getByTestId('filtre-taille-40')).toHaveAttribute('aria-pressed', 'false');
  });
});

describe('FiltresBarre v3 — pastilles', () => {
  it('rend des pastilles visibles avec une croix grise', () => {
    poser({ marques: ['nike'], tailles: ['41'], promotionSeulement: true, enStockSeulement: true });
    const zone = screen.getByTestId('pastilles');
    porte(zone, PASTILLES);
    const noms = within(zone).getAllByRole('button').map((b: HTMLElement) => b.getAttribute('aria-label') ?? b.textContent);
    expect(noms).toEqual([
      'Retirer le filtre Nike', 'Retirer le filtre Taille 41', 'Retirer le filtre Promotions',
      'Retirer le filtre En stock', 'Tout effacer',
    ]);
    for (const nom of ['Nike', 'Taille 41', 'Promotions', 'En stock']) {
      const p = within(zone).getByRole('button', { name: `Retirer le filtre ${nom}` });
      porte(p, PASTILLE);
      const croix = p.querySelector('svg.lucide-x');
      expect(croix).not.toBeNull();
      porte(croix as Element, PASTILLE_CROIX);
    }
    porte(screen.getByTestId('filtres-reinitialiser'), TOUT_EFFACER);
  });

  it('remet un interrupteur à false depuis sa pastille', () => {
    const { onChange } = poser({ promotionSeulement: true, marques: ['nike'] });
    fireEvent.click(screen.getByRole('button', { name: 'Retirer le filtre Promotions' }));
    expect(onChange).toHaveBeenCalledWith({ promotionSeulement: false, marques: ['nike'] });
  });
});

describe('FiltresBarre v3 — téléphone', () => {
  it('délègue les tiroirs à TiroirsFiltres et relaie ses actions', () => {
    const { onChange, onTriChange } = poser({ marques: ['lacoste'] });
    porte(screen.getByTestId('ouvrir-filtres'), MOBILE_FILTRER);
    porte(screen.getByTestId('ouvrir-tri'), MOBILE_TRIER);
    fireEvent.click(screen.getByTestId('ouvrir-filtres'));
    const tiroir = screen.getByTestId('tiroir-filtres');
    fireEvent.click(within(tiroir).getByTestId('filtre-marque-nike'));
    expect(onChange).toHaveBeenCalledWith({ marques: ['lacoste', 'nike'] });
    fireEvent.click(within(tiroir).getByTestId('filtre-stock'));
    expect(onChange).toHaveBeenLastCalledWith({ marques: ['lacoste'], enStockSeulement: true });
    fireEvent.click(screen.getByTestId('tiroir-fond'));
    expect(screen.queryByTestId('tiroir-filtres')).toBeNull();
    fireEvent.click(screen.getByTestId('ouvrir-tri'));
    fireEvent.click(within(screen.getByTestId('tiroir-tri')).getByRole('button', { name: 'Prix croissant' }));
    expect(onTriChange).toHaveBeenCalledWith('prix-croissant');
    expect(screen.queryByTestId('tiroir-tri')).toBeNull();
  });
});

describe('FiltresBarre v3 — source', () => {
  const source = readFileSync('src/components/catalogue/FiltresBarre.tsx', 'utf8');

  it('ne code aucune couleur à la main', () => {
    expect(source).not.toContain('var(--vs-');
    for (const k of ['rounded-md', 'shadow-sm', 'shadow-lg', 'ring-1']) expect(source).not.toContain(k);
  });

  it('ne réimplémente pas les tiroirs', () => {
    expect(source).toContain('<TiroirsFiltres');
    expect(source).not.toContain('tiroir-filtres');
    expect(source).not.toContain('tiroir-tri');
  });
});
__VICTO_FIN_6__
cat > run.sh <<'__VICTO_FIN_7__'
#!/usr/bin/env bash
# =============================================================================
# VICTO STORE — harnais autonome
# Aucune action humaine entre les tickets.
#
# Par ticket :
#   1. branche auto/<id> partant de main
#   2. appel Aider non interactif (timeout dur)
#   3. porte de qualité : tsc --noEmit ET npm test
#   4. rouge -> on renvoie la sortie brute au modèle (max 3 tentatives)
#   5. vert  -> merge --no-ff dans main.  calé -> la branche reste isolée.
#
# Manifeste TSV : id  cible  tests  spec  [contexte]  [dépend_de]  [mode]
#   contexte  : fichiers en lecture seule, séparés par des virgules
#   dépend_de : ids de tickets, séparés par des virgules. Si l'un d'eux n'a pas
#               été fusionné dans main par le harnais, le ticket est BLOQUÉ sans
#               appel au modèle — et, n'étant pas fusionné, bloque à son tour
#               ceux qui dépendent de lui (cascade).
#   mode      : « neuf » = la cible est vidée sur la branche avant le premier
#               appel. Le modèle l'écrit d'après la spec seule, sans relire
#               l'ancienne version : sur CPU, lire un jeton coûte autant
#               qu'en écrire un.
#
# Budget : avant d'appeler le modèle, le harnais estime entrée + sortie en
# jetons. Au-delà de 90 % de num_ctx, le ticket est TROP_GROS, en quelques
# secondes au lieu de 40 minutes de TIMEOUT (ticket 095 : 14 062 jetons en
# entrée, fenêtre saturée, moitié du prompt jetée).
#
# Sortie : VERT / CALÉ / TIMEOUT / TRICHE / BLOQUÉ / TEST_SUSPECT / TROP_GROS.
# =============================================================================
set -uo pipefail

# ------------------------------------------------------------------- réglages
REPO="${REPO:-$PWD}"
MODEL="${MODEL:-ollama_chat/qwen3-coder-ctx}"
MANIFEST="${MANIFEST:-tickets/manifest.tsv}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"     # plafond de réflexions, en dur
AIDER_TIMEOUT="${AIDER_TIMEOUT:-2400}" # 40 min par appel (CPU : ~14 tok/s)
GIT_REMOTE="${GIT_REMOTE:-origin}"    # vide ("") = aucun push
RUN_BUILD="${RUN_BUILD:-1}"           # 0 = sauter npm run build dans la porte


export OLLAMA_API_BASE="${OLLAMA_API_BASE:-http://192.168.40.30:11434}"
export AIDER_NO_ANALYTICS=1

cd "$REPO" || { echo "Dépôt introuvable : $REPO"; exit 2; }

# Aider coupe par défaut un appel au modèle après 600 s puis le relance depuis
# zéro : un gros fichier généré sur CPU n'aboutit alors jamais. On aligne son
# délai sur celui du harnais, seulement si cette version d'Aider connaît l'option.
AIDER_DELAI=()
if aider --help 2>/dev/null | grep -q -- '--timeout'; then
  AIDER_DELAI=(--timeout "$((AIDER_TIMEOUT - 120))")
fi
# Le lint automatique d'Aider relance le modèle avec tout le contexte dès qu'un
# fichier ne se lit pas : un deuxième prompt complet, à ~12 jetons/s. La porte du
# harnais fait déjà ce travail, avec la spec. On le coupe si l'option existe.
if aider --help 2>/dev/null | grep -q -- '--auto-lint'; then
  AIDER_DELAI+=(--no-auto-lint)
fi

# Budget de contexte. CAR_PAR_JETON et SURCOUT_AIDER sont calibrés sur le 095 :
# 36 000 caractères de fichiers → 14 062 jetons observés dans le journal d'Ollama.
NUM_CTX="$(grep -oE 'num_ctx["]?:[[:space:]]*[0-9]+' .aider.model.settings.yml 2>/dev/null | grep -oE '[0-9]+$' | head -1)"
NUM_CTX="${NUM_CTX:-16384}"
CAR_PAR_JETON=3
SURCOUT_AIDER=2000
BUDGET_MAX=$((NUM_CTX * 90 / 100))

RUN_ID="$(date +%Y%m%d-%H%M%S)"
LOGDIR=".logs/$RUN_ID"
mkdir -p "$LOGDIR"

log()  { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" | tee -a "$LOGDIR/run.log"; }
fail() { log "FATAL: $*"; exit 2; }

# ------------------------------------------------------------ pré-vérifications
command -v aider >/dev/null || fail "aider absent du PATH (pipx ensurepath + ~/.bashrc)"
command -v git   >/dev/null || fail "git absent"
[ -f "$MANIFEST" ] || fail "manifeste introuvable : $MANIFEST"
[ -f ".aider.model.settings.yml" ] || fail ".aider.model.settings.yml manquant (num_ctx → reload à froid)"

if ! git diff --quiet || ! git diff --cached --quiet; then
  fail "arbre de travail sale — commit ou stash avant de lancer le harnais"
fi

if ! curl -sf --max-time 5 "$OLLAMA_API_BASE/api/tags" >/dev/null; then
  fail "Ollama injoignable sur $OLLAMA_API_BASE"
fi
log "Ollama OK sur $OLLAMA_API_BASE — modèle : $MODEL"

# Le push doit être non interactif (clé SSH sans passphrase ou credential store),
# sinon le harnais resterait bloqué sur une demande de mot de passe.
if [ -n "$GIT_REMOTE" ]; then
  if ! git remote get-url "$GIT_REMOTE" >/dev/null 2>&1; then
    log "AVERTISSEMENT : remote '$GIT_REMOTE' inexistant — push désactivé"
    GIT_REMOTE=""
  elif ! GIT_TERMINAL_PROMPT=0 git ls-remote --exit-code "$GIT_REMOTE" >/dev/null 2>&1; then
    fail "remote '$GIT_REMOTE' injoignable ou demande une authentification interactive"
  else
    log "Remote OK : $(git remote get-url "$GIT_REMOTE")"
  fi
else
  log "Push distant désactivé (GIT_REMOTE vide)"
fi

git checkout -q main || fail "branche main introuvable"

# ------------------------------------------------------ porte de qualité
# 0 = vert. Toute la sortie va dans le log passé en $1.
run_gate() {
  local log="$1"
  : > "$log"
  echo "===== tsc --noEmit =====" >> "$log"
  if ! npm run --silent typecheck >> "$log" 2>&1; then return 1; fi
  printf '\n===== vitest run =====\n' >> "$log"
  if ! npm run --silent test >> "$log" 2>&1; then return 1; fi
  # Troisième barreau : l'application doit CONSTRUIRE. Sans lui, un projet peut
  # être vert partout et ne rien afficher (config PostCSS absente, import mort,
  # composant serveur invalide). C'est le seul contrôle qui voit la vraie appli.
  if [ "$RUN_BUILD" = "1" ] && grep -q '"build"' package.json; then
    printf '\n===== npm run build =====\n' >> "$log"
    if ! npm run --silent build >> "$log" 2>&1; then return 1; fi
  fi
  return 0
}

# Une erreur tsc qui pointe un fichier de tests/ SANS jamais nommer le fichier
# cible est impossible à corriger par le modèle : il n'a pas le droit d'y toucher.
# Inutile de brûler trois tentatives, on nomme le coupable tout de suite.
# Imports du fichier cible qui ne pointent vers aucun fichier réel.
# Le modèle n'a le droit de créer que sa cible : un module qu'il importe sans
# qu'il existe n'existera jamais. C'est la cause des échecs d'assemblage 021 et 061.
imports_inventes() {
  local f="$1" spec base ext
  [ -f "$f" ] || return 0
  grep -oE "from ['\"][^'\"]+['\"]" "$f" | sed -E "s/^from ['\"]//; s/['\"]$//" | sort -u |
  while read -r spec; do
    case "$spec" in
      @/*)       base="src/${spec#@/}" ;;
      ./*|../*)  base="$(dirname "$f")/$spec" ;;
      *)         continue ;;
    esac
    for ext in "" .ts .tsx /index.ts /index.tsx; do
      [ -f "$base$ext" ] && continue 2
    done
    echo "$spec"
  done
}

modules_existants() {
  find src -type f \( -name '*.ts' -o -name '*.tsx' \) ! -name '*.d.ts' ! -path 'src/app/*' |
    sed -E 's#^src/#@/#; s#\.(tsx|ts)$##' | sort
}

# Déclarations de types de tout le projet : un résumé exact des exports et des
# props, sans le code. Compact et toujours conforme à ce que le modèle a écrit.
DECL=".logs/decl"
generer_declarations() {
  rm -rf "$DECL"
  npx --no-install tsc -p tsconfig.json --noEmit false --declaration \
    --emitDeclarationOnly --outDir "$DECL" >/dev/null 2>&1 || true
}

# Ne renvoie au modèle que ce qui échoue : les erreurs TypeScript, sinon les
# assertions vitest en échec, sinon la fin du journal (erreur de build).
erreurs_utiles() {
  local log="$1" r
  r="$(grep -E 'error TS[0-9]+' "$log" | head -40)"
  if [ -n "$r" ]; then printf '%s\n' "$r"; return; fi
  r="$(grep -E '×|FAIL |AssertionError|Expected|Received|^[[:space:]]*[-+] |→ ' "$log" | grep -v '✓' | head -60)"
  if [ -n "$r" ]; then printf '%s\n' "$r"; return; fi
  tail -n 60 "$log"
}

gate_accuse_les_tests() {
  local log="$1" cible="$2"
  grep -qE '^tests/[^ ]+\([0-9]+,[0-9]+\): error' "$log" || return 1
  grep -q "$cible" "$log" && return 1
  return 0
}

# Première dépendance déclarée (6ᵉ colonne) qui n'a pas été fusionnée dans main.
# Critère unique : le commit de fusion que le harnais écrit au vert. Il vaut
# d'un run à l'autre, sans état à conserver.
dependance_absente() {
  local deps="$1" d IFS=','
  [ -n "$deps" ] || return 1
  for d in $deps; do
    d="${d//[[:space:]]/}"
    [ -n "$d" ] || continue
    if [ -z "$(git log main -1 --format=%h --fixed-strings --grep="feat($d): fusionné")" ]; then
      echo "$d"; return 0
    fi
  done
  return 1
}

# Estimation « entree sortie » en jetons. Entrée : spec + fichiers en lecture
# seule + cible actuelle. Sortie : « Taille attendue : ~N lignes » si la spec le
# dit (40 caractères par ligne), sinon la taille actuelle de la cible + 10 %.
budget_ticket() {
  local spec="$1" cible="$2"; shift 2
  local car=0 f n sortie=0
  for f in "$spec" "$@" "$cible"; do
    [ -f "$f" ] && car=$((car + $(wc -m < "$f")))
  done
  n="$(grep -oE 'Taille attendue : ~?[0-9]+ lignes' "$spec" | grep -oE '[0-9]+' | head -1)"
  if [ -n "$n" ]; then sortie=$((n * 40 / CAR_PAR_JETON))
  elif [ -f "$cible" ]; then sortie=$(( $(wc -m < "$cible") * 11 / 10 / CAR_PAR_JETON ))
  fi
  echo "$((car / CAR_PAR_JETON + SURCOUT_AIDER)) $sortie"
}

# Empreinte d'un échec : les lignes renvoyées au modèle, sans couleurs ni durées.
# Deux empreintes égales d'affilée = la tentative suivante n'y changera rien.
empreinte_echec() {
  local esc=$'\x1b'
  erreurs_utiles "$1" |
    sed -E -e "s/${esc}\[[0-9;]*m//g" -e 's/[0-9]+([.,][0-9]+)? ?ms\b//g' -e 's/[[:space:]]+$//' |
    sort -u | md5sum | cut -d' ' -f1
}

# Un ticket dont les tests importent un module absent de main et différent de sa
# propre cible dépend d'un ticket qui a calé : il échouera à coup sûr.
ticket_bloque() {
  local test_src="$1" cible="$2" imp chemin
  [ -f "$test_src" ] || return 1
  while read -r imp; do
    [ -n "$imp" ] || continue   # test sans import relatif : rien à vérifier
    chemin="$(printf '%s' "$imp" | sed -E "s|.*from '\.\./||; s|'.*||")"
    case "$chemin" in
      "${cible%.*}"|"$cible") continue ;;
    esac
    if [ ! -e "$chemin.ts" ] && [ ! -e "$chemin.tsx" ] && [ ! -e "$chemin" ]; then
      echo "$chemin"; return 0
    fi
  done <<EOF
$(grep -oE "from '\.\./[^']+'" "$test_src" | sort -u)
EOF
  return 1
}

# ------------------------------------------------------------------ exécution
declare -a IDS=() STATUSES=() ATTEMPTS=()

while IFS= read -r LIGNE || [ -n "${LIGNE:-}" ]; do
  # Découpage sur un séparateur non blanc : avec IFS=tabulation, bash fusionne
  # deux tabulations consécutives et une colonne vide décalerait les suivantes.
  LIGNE="${LIGNE%$'\r'}"
  ID="" TARGET="" TESTFILE="" SPEC="" EXTRA="" DEPS="" MODE=""
  IFS=$'\x1f' read -r ID TARGET TESTFILE SPEC EXTRA DEPS MODE <<< "${LIGNE//$'\t'/$'\x1f'}"
  MODE="${MODE//[[:space:]]/}"
  [ -z "${ID:-}" ] && continue
  case "$ID" in \#*) continue ;; esac

  BRANCH="auto/$ID"
  log "──────────────────────────────────────────────────────────────"
  log "TICKET $ID  →  $TARGET   (tests : $TESTFILE)"

  PENDING="tickets/tests/$(basename "$TESTFILE")"

  [ -f "$SPEC" ] || { log "spec introuvable : $SPEC"; IDS+=("$ID"); STATUSES+=("CALÉ"); ATTEMPTS+=(0); continue; }
  if [ ! -f "$PENDING" ] && [ ! -f "$TESTFILE" ]; then
    log "tests introuvables : ni $PENDING ni $TESTFILE"
    IDS+=("$ID"); STATUSES+=("CALÉ"); ATTEMPTS+=(0); continue
  fi

  # Dépendance déclarée non fusionnée : on saute avant même de créer la branche.
  if manque="$(dependance_absente "$DEPS")"; then
    log "  BLOQUÉ : dépend du ticket $manque, qui n'est pas fusionné dans main"
    IDS+=("$ID"); STATUSES+=("BLOQUÉ"); ATTEMPTS+=(0)
    continue
  fi
  [ -n "$DEPS" ] && log "  dépendances fusionnées : $DEPS"

  git checkout -q main
  git branch -q -D "$BRANCH" 2>/dev/null
  git checkout -q -b "$BRANCH"

  # Activation des tests du ticket : ils quittent la zone d'attente pour entrer
  # dans le périmètre de la porte. Un ticket ne voit donc que ses propres tests
  # et ceux des tickets déjà fusionnés — jamais ceux des tickets à venir.
  if [ -f "$PENDING" ]; then
    mkdir -p "$(dirname "$TESTFILE")"
    cp "$PENDING" "$TESTFILE"
    git add "$TESTFILE"
    git diff --cached --quiet || git commit -q -m "test($ID): activation des tests par le harnais"
    log "  tests activés : $PENDING → $TESTFILE"
  fi
  # Mode « neuf » : la cible est vidée sur la branche, main n'est pas touché.
  if [ "$MODE" = "neuf" ]; then
    mkdir -p "$(dirname "$TARGET")"
    : > "$TARGET"
    git add "$TARGET"
    git diff --cached --quiet || git commit -q -m "chore($ID): cible vidée pour une réécriture complète"
    log "  mode neuf : $TARGET vidé sur la branche"
  fi
  TEST_BASE="$(git rev-parse HEAD)"   # référence anti-triche

  # Dépendance manquante : on saute sans appeler le modèle.
  if manque="$(ticket_bloque "$PENDING" "$TARGET")"; then
    log "  BLOQUÉ : $manque est absent de main (ticket amont calé)"
    git checkout -q --force main
    IDS+=("$ID"); STATUSES+=("BLOQUÉ"); ATTEMPTS+=(0)
    continue
  fi

  # Contexte en lecture seule : les types et composants que le ticket consomme.
  # Sans ça le modèle devine les noms de champs — c'est l'origine des deux seules
  # erreurs réelles du modèle lors du premier build (image/imageUrl, badge en prop).
  READS=(--read "$TESTFILE")
  if [ -n "$EXTRA" ]; then
    generer_declarations
    OLDIFS="$IFS"; IFS=','
    for ctx in $EXTRA; do
      decl="$DECL/${ctx%.*}.d.ts"
      if [ -f "$decl" ]; then READS+=(--read "$decl")
      elif [ -f "$ctx" ]; then READS+=(--read "$ctx")
      fi
    done
    IFS="$OLDIFS"
    log "  contexte (déclarations de types) : $EXTRA"
  fi

  # Budget : la cible (vidée en mode neuf) et tout ce qu'Aider lira.
  LUS=()
  for ((k = 1; k < ${#READS[@]}; k += 2)); do LUS+=("${READS[$k]}"); done
  read -r B_ENTREE B_SORTIE <<< "$(budget_ticket "$SPEC" "$TARGET" "${LUS[@]}")"
  log "  budget : ≈ $B_ENTREE jetons lus + $B_SORTIE écrits = $((B_ENTREE + B_SORTIE)) / $NUM_CTX (plafond $BUDGET_MAX)"
  if [ $((B_ENTREE + B_SORTIE)) -gt "$BUDGET_MAX" ]; then
    log "  TROP_GROS : le ticket saturerait la fenêtre du modèle — découper la spec ou passer en mode neuf"
    git checkout -q --force main
    IDS+=("$ID"); STATUSES+=("TROP_GROS"); ATTEMPTS+=(0)
    continue
  fi

  MSG="$(cat "$SPEC")"
  STATUS="CALÉ"
  attempt=1
  used=0
  EMPREINTE_PREC=""

  while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
    # Une relance relit la spec, les échecs ET la cible déjà écrite : on refait le compte.
    if [ "$attempt" -gt 1 ]; then
      printf '%s\n' "$MSG" > "$LOGDIR/$ID.message.$attempt.txt"
      read -r B_ENTREE B_SORTIE <<< "$(budget_ticket "$LOGDIR/$ID.message.$attempt.txt" "$TARGET" "${LUS[@]}")"
      log "  budget de la relance : ≈ $((B_ENTREE + B_SORTIE)) / $NUM_CTX"
      if [ $((B_ENTREE + B_SORTIE)) -gt "$BUDGET_MAX" ]; then
        log "  TROP_GROS : la relance saturerait la fenêtre — arrêt"
        STATUS="TROP_GROS"; break
      fi
    fi
    log "  tentative $attempt/$MAX_ATTEMPTS — appel du modèle…"
    timeout --signal=TERM --kill-after=60 "$AIDER_TIMEOUT" \
      aider \
        --model "$MODEL" \
        --edit-format whole \
        --yes-always \
        --no-auto-test \
        --no-stream \
        --no-check-update \
        --no-show-model-warnings \
        "${AIDER_DELAI[@]}" \
        "${READS[@]}" \
        --file "$TARGET" \
        --message "$MSG" \
        >> "$LOGDIR/$ID.aider.log" 2>&1 < /dev/null
    rc=$?
    used="$attempt"

    if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
      log "  TIMEOUT après ${AIDER_TIMEOUT}s"
      STATUS="TIMEOUT"; break
    fi

    # Garde-fou anti-triche : les tests sont passés en --read. On compare au
    # commit d'activation, pas à main, puisque c'est le harnais qui les a posés.
    if ! git diff --quiet "$TEST_BASE" HEAD -- "$TESTFILE"; then
      log "  TRICHE : le fichier de test a été modifié sur la branche"
      STATUS="TRICHE"; break
    fi

    INVENTES="$(imports_inventes "$TARGET")"
    if [ -n "$INVENTES" ]; then
      log "  IMPORTS INVENTÉS : $(printf '%s ' $INVENTES)"
      MSG="$(cat "$SPEC")

════════════════════════════════════════════════════════════
TENTATIVE PRÉCÉDENTE : IMPORTS INVENTÉS
Ton fichier $TARGET importe des modules qui N'EXISTENT PAS :
$INVENTES

Tu n'as le droit de créer AUCUN autre fichier que $TARGET : ces modules
n'existeront donc jamais. Retire ces imports. Tout ce qui n'est pas importé d'un
module réel doit être écrit dans $TARGET lui-même.

Voici la liste COMPLÈTE des modules qui existent. N'importe que parmi eux :
$(modules_existants)

Réécris $TARGET en entier."
      attempt=$((attempt + 1))
      continue
    fi

    GATELOG="$LOGDIR/$ID.gate.$attempt.log"
    if run_gate "$GATELOG"; then
      log "  porte VERTE"
      STATUS="VERT"; break
    fi

    if gate_accuse_les_tests "$GATELOG" "$TARGET"; then
      log "  TEST_SUSPECT : tsc n'accuse que des fichiers de tests, le modèle ne peut rien corriger"
      STATUS="TEST_SUSPECT"; break
    fi

    # Diagnostic d'un coup d'œil dans run.log : premières lignes utiles de l'échec.
    grep -E 'error TS|×|→' "$GATELOG" | sed -E "s/$(printf '\033')\[[0-9;]*m//g" | head -3 |
      while IFS= read -r l; do log "    | $l"; done

    EMPREINTE="$(empreinte_echec "$GATELOG")"
    if [ "$EMPREINTE" = "$EMPREINTE_PREC" ]; then
      log "  MÊME ÉCHEC qu'à la tentative précédente — arrêt, une relance n'y changera rien"
      STATUS="CALÉ"; break
    fi
    EMPREINTE_PREC="$EMPREINTE"

    [ "$attempt" -lt "$MAX_ATTEMPTS" ] && log "  porte ROUGE — relance avec la spec et les seuls échecs"
    MSG="$(cat "$SPEC")

════════════════════════════════════════════════════════════
TENTATIVE PRÉCÉDENTE : ROUGE
$TARGET contient ta dernière version. Garde tout ce qui fonctionne et corrige
UNIQUEMENT les échecs ci-dessous. Respecte à la lettre les imports et les exports
imposés par la spécification ci-dessus. Ne modifie aucun test.

Échecs :
$(erreurs_utiles "$GATELOG")"
    attempt=$((attempt + 1))
  done

  if [ "$STATUS" = "VERT" ]; then
    npm run --silent lint:fix >/dev/null 2>&1   # optionnel, après le vert
    git add -A
    git diff --cached --quiet || git commit -q -m "chore($ID): formatage post-porte"
    git checkout -q main
    git merge --no-ff -q "$BRANCH" -m "feat($ID): fusionné au vert par le harnais"
    log "  fusionné dans main"
    if [ -n "$GIT_REMOTE" ]; then
      if GIT_TERMINAL_PROMPT=0 git push -q "$GIT_REMOTE" main 2>>"$LOGDIR/$ID.git.log"; then
        log "  poussé sur $GIT_REMOTE/main"
      else
        log "  AVERTISSEMENT : push de main échoué (voir $LOGDIR/$ID.git.log)"
      fi
    fi
  else
    git checkout -q --force main
    log "  laissé isolé sur $BRANCH — main est intact"
    # On pousse quand même la branche calée : elle est relisible depuis le laptop.
    if [ -n "$GIT_REMOTE" ]; then
      GIT_TERMINAL_PROMPT=0 git push -q --force "$GIT_REMOTE" "$BRANCH" \
        2>>"$LOGDIR/$ID.git.log" && log "  branche calée poussée sur $GIT_REMOTE/$BRANCH"
    fi
  fi

  IDS+=("$ID"); STATUSES+=("$STATUS"); ATTEMPTS+=("$used")
done < "$MANIFEST"

# -------------------------------------------------------------------- rapport
echo | tee -a "$LOGDIR/run.log"
log "═══════════════ RAPPORT  ($RUN_ID) ═══════════════"
exit_code=0
i=0
while [ "$i" -lt "${#IDS[@]}" ]; do
  printf '  %-12s %-8s (tentatives : %s)\n' "${IDS[$i]}" "${STATUSES[$i]}" "${ATTEMPTS[$i]}" \
    | tee -a "$LOGDIR/run.log"
  [ "${STATUSES[$i]}" = "VERT" ] || exit_code=1
  i=$((i + 1))
done
log "logs : $LOGDIR"
log "main : $(git rev-parse --short HEAD) — $(git log -1 --pretty=%s)"

# Porte finale : l'état fusionné de main doit tenir debout dans son ensemble.
git checkout -q main
if run_gate "$LOGDIR/final.gate.log"; then
  log "PORTE FINALE VERTE sur main"
else
  log "PORTE FINALE ROUGE sur main — voir $LOGDIR/final.gate.log"
  exit_code=1
fi
exit "$exit_code"
__VICTO_FIN_7__
chmod +x run.sh
for t in tests/filtres-affichage.test.ts tests/TiroirsFiltres.test.tsx tests/FiltresBarre-v3.test.tsx; do
  # activés par le harnais ; jamais retirés une fois suivis (relance après fusion)
  git ls-files --error-unmatch "$t" >/dev/null 2>&1 || rm -f "$t"
done
ok "specs, tests, manifeste et harnais écrits"

# ------------------------------------------------------------ nettoyage
for f in tickets/095-filtres-barre-v2.md tickets/tests/FiltresBarre-v2.test.tsx tickets/manifest-liste-v2.tsv; do
  if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then git rm -q -- "$f"; fi
  rm -f -- "$f"
done
ok "ancien ticket 095 retiré (spec, test en attente, manifeste)"
for f in $(git ls-files -- '*.tsbuildinfo'); do git rm -q --cached -- "$f"; done
if ! grep -qxF '*.tsbuildinfo' .gitignore 2>/dev/null; then
  [ -s .gitignore ] && [ -n "$(tail -c1 .gitignore)" ] && echo >> .gitignore
  echo '*.tsbuildinfo' >> .gitignore
fi
ok "tsbuildinfo hors du suivi git"

# ------------------------------------------------------------ contrôle et budget
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/095a-filtres-affichage.md tickets/095b-tiroirs-filtres.md tickets/095c-filtres-barre-v3.md "$CTL/"
cp tickets/tests/filtres-affichage.test.ts tickets/tests/TiroirsFiltres.test.tsx tickets/tests/FiltresBarre-v3.test.tsx "$CTL/tests/"
python3 outils/controle-lot.py "$CTL" "$JETONS" || annuler "le contrôle du lot a levé une alerte"
rm -rf "$CTL"
ok "contrôle du lot : 0 alerte, jetons vérifiés sur $JETONS"

# Même formule que le harnais. Les contextes pas encore écrits comptent 3 000
# caractères ; les sources existantes sont plus longues que leurs déclarations.
python3 - tickets/manifest-liste-v3.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
import os, re, sys
ctx = 16384
try:
    m = re.search(r'num_ctx"?:\s*(\d+)', open('.aider.model.settings.yml').read()); ctx = int(m.group(1)) if m else ctx
except OSError: pass
plafond, ko = ctx * 90 // 100, False
for ligne in open(sys.argv[1]):
    c = (ligne.rstrip('\n').split('\t') + [''] * 7)[:7]
    if not c[0]: continue
    tid, cible, test, spec, contexte, _, mode = c
    car = len(open(spec).read()) + len(open('tickets/tests/' + os.path.basename(test)).read())
    for f in filter(None, contexte.split(',')):
        car += len(open(f).read()) if os.path.isfile(f) else 3000
    if mode != 'neuf' and os.path.isfile(cible): car += len(open(cible).read())
    n = re.search(r'Taille attendue : ~?(\d+) lignes', open(spec).read())
    sortie = int(n.group(1)) * 40 // 3 if n else 0
    total = car // 3 + 2000 + sortie
    ko |= total > plafond
    print(f"  {'✓' if total <= plafond else '✗'} budget {tid} : ≈ {total} jetons / plafond {plafond}")
sys.exit(1 if ko else 0)
PYB

# ------------------------------------------------------------ base verte
bash -n run.sh || annuler "run.sh : erreur de syntaxe"
npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head -10; annuler "tsc rouge"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head -12; annuler "tests rouges"; }
ok "base verte"

# ------------------------------------------------------------ commit et vérification
git add -A -- tests tickets run.sh .gitignore
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "chore(lot): liste v3 — filtres en trois tickets, budget de contexte, mode neuf"
  ok "commit $(git rev-parse --short HEAD)"
}
restes="$(git ls-files -- tickets/095-filtres-barre-v2.md tickets/tests/FiltresBarre-v2.test.tsx tickets/manifest-liste-v2.tsv '*.tsbuildinfo')"
[ -z "$restes" ] || mort "encore suivis par git après le commit : $restes"
ok "retraits vérifiés dans HEAD"

git branch -q -D auto/095 2>/dev/null && ok "branche locale auto/095 supprimée" || true
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else printf '  \033[33m!\033[0m push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert\n'; fi
GIT_TERMINAL_PROMPT=0 git push -q origin --delete auto/095 2>/dev/null && ok "branche auto/095 supprimée sur GitHub" || true

cat <<'TXT'

Prêt :

    MANIFEST=tickets/manifest-liste-v3.tsv ./run.sh

Trois tickets enchaînés : 095b attend 095a, 095c attend les deux.
Compte 45 à 75 minutes, lecture des prompts comprise.
TXT
