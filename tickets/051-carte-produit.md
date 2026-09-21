TICKET 051 — ProductCard : style de la maquette

Modifie `src/components/ui/ProductCard.tsx`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée ni ne modifie aucun autre fichier
  que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres dans une chaîne littérale.
  Tailwind ne génère que les classes qu'il lit dans le code ; une classe construite
  par interpolation n'existera jamais. Les tests vérifient leur présence. Tu peux en
  ajouter, jamais en retirer.
- Couleurs : tokens `var(--vs-*)` en priorité (`--vs-noir`, `--vs-blanc`,
  `--vs-surface`, `--vs-ligne`, `--vs-gris`, `--vs-accent` cobalt, `--vs-promo`
  rouge). Seules ces teintes décoratives sont autorisées en valeur directe :
  `#1E1E26` `#C70026` `#E9E4DA` `#D9D2C4` `#EEF1F8` `#B5B5BA` `#FFD3DB`.
- Toute icône `<svg>` porte `aria-hidden="true"`. Toute image purement décorative
  porte `alt=""`.
- Accès aux tableaux : `t[0]` a le type `T | undefined`. Pas de `!`, pas de `as` ;
  utilise `.map`, `.filter`, `.slice` ou des constantes nommées.
- `'use client'` en première ligne **seulement** si le composant a un état ou un effet.
## Contrats existants à conserver absolument
`tests/ProductCard.test.tsx` doit continuer à passer. En particulier :
`article` avec `data-testid="carte-produit"` et `data-produit-id` ; **un seul**
`<a>` (vers `hrefProduit(produit)`) ; **une seule** image accessible, `<img>` avec
un `alt` contenant la marque et le nom ; `carte-marque` ; `carte-nom` ; le
composant `Badge` (qui porte `data-testid="badge"`) **uniquement** si
`produit.badge` est fourni.

## Nouveautés
1. Ajoute `'use client';` en première ligne : la carte gagne un état.
2. Le visuel est enveloppé dans `<div data-testid="carte-visuel">` aux classes
   imposées `relative overflow-hidden rounded-[20px] bg-[var(--vs-surface)]`.
   L'`<img>` porte les classes imposées `h-full w-full object-cover` et le
   conteneur a un ratio 4/5 (`aspect-[4/5]`).
3. **Pastille de remise**, seulement si le produit est en promotion
   (`estEnPromotion`) : un `<span data-testid="prix-remise">` en haut à gauche du
   visuel, fond `var(--vs-promo)`, texte blanc, forme pilule. Son texte est
   **exactement** `−N %` : signe moins U+2212 (`'\u2212'`), la valeur de
   `remisePourcent(produit)`, espace insécable U+00A0 (`'\u00A0'`), puis `%`.
   Ce n'est **pas** le composant `Badge` : un simple `<span>`.
4. Rends le prix avec `<Price amount={produit.prixCents} compareAt={produit.prixCompareCents} afficherRemise={false} />`,
   pour qu'il n'y ait qu'**un seul** `prix-remise` dans la carte.
5. **Bouton favori** en haut à droite du visuel :
   `<button type="button" aria-label="Ajouter aux favoris" aria-pressed={favori}>`,
   rond, fond blanc, 44 px, contenant un cœur en `<svg aria-hidden="true">`. Un clic
   bascule `favori` (`useState(false)`). Il est **hors** du lien.
6. Le `Badge` de `produit.badge`, s'il existe, se place sous la pastille de remise.

## Bloc d'imports exact
```tsx
'use client';

import { useState } from 'react';
import { Badge } from '@/components/ui/Badge';
import { Price } from '@/components/ui/Price';
import { estEnPromotion, hrefProduit, remisePourcent, type Produit } from '@/lib/catalogue';
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
