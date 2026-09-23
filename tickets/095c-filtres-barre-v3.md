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

**Les quatre pilules de la barre** ont exactement ces `className`, où
`marquesChoisies = criteres.marques ?? []` et `taillesChoisies = criteres.tailles ?? []` :
```tsx
// bouton-marques
className={`${PILULE} ${ouvert === 'marques' || marquesChoisies.length > 0 ? PILULE_ON : PILULE_OFF}`}
// bouton-tailles
className={`${PILULE} ${ouvert === 'tailles' || taillesChoisies.length > 0 ? PILULE_ON : PILULE_OFF}`}
// filtre-promo, avec aria-pressed={criteres.promotionSeulement === true}
className={`${PILULE} ${criteres.promotionSeulement === true ? PILULE_ON : PILULE_OFF}`}
// filtre-stock, avec aria-pressed={criteres.enStockSeulement === true}
className={`${PILULE} ${criteres.enStockSeulement === true ? PILULE_ON : PILULE_OFF}`}
```

**1. Barre, grand écran** — `<div data-testid="barre-bureau" className="hidden flex-wrap items-center gap-3 lg:flex">` :
- `<div className="relative">` avec le bouton `data-testid="bouton-marques"`,
  `aria-expanded={ouvert === 'marques'}`, `className` ci-dessus. Contenu :
  `<span>` de texte `Marque` sans sélection, `Marque (N)` avec N marques choisies,
  puis `<ChevronDown aria-hidden size={16} />`. Quand `ouvert === 'marques'`, suivi de
  `` <div data-testid="panneau-marques" className={`${PANNEAU} ${PANNEAU_MARQUES}`}> `` :
  un bouton par marque, `` data-testid={`filtre-marque-${marque.slug}`} ``, texte
  `marque.nom`, forme `OPTION_MARQUE`, `aria-pressed` et actif si la marque est choisie.
- même chose pour les tailles : `bouton-tailles`, texte `Taille` ou `Taille (N)`,
  `panneau-tailles` avec `PANNEAU_TAILLES`, boutons
  `` data-testid={`filtre-taille-${taille}`} `` de forme `OPTION_TAILLE`, `aria-pressed`.
- `data-testid="filtre-promo"`, texte `Promotions`, `className` et `aria-pressed` ci-dessus.
- `data-testid="filtre-stock"`, texte `En stock`, idem.
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
