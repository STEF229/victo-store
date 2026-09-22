TICKET 093 — barre de filtres

Crée `src/components/catalogue/FiltresBarre.tsx`, export `FiltresBarre`. Elle
remplace la colonne de cases à cocher par une barre horizontale : deux menus
déroulants, deux interrupteurs, le tri, et les filtres actifs en pastilles
retirables. Sur téléphone, un tiroir qui monte du bas.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  `page.tsx` qui n'a **qu'un export par défaut**.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** Les déclarations de types des modules utilisés
  te sont fournies en lecture seule.
- Icônes : **`lucide-react` uniquement**, chacune avec `aria-hidden`.
- Classes imposées en toutes lettres, jamais construites par interpolation.
- Couleurs : tokens `var(--vs-*)`. Teintes décoratives autorisées telles quelles :
  `#1E1E26` `#2A2A30` `#FF5A74` `#F0F0EE` `#E9E4DA` `#EEF1F8`.
- **Aucun `<h1>`** sauf dans un composant qui porte explicitement le titre de page.
- Accès aux tableaux : pas de `!`, pas de `as` ; `.map`, `.filter`, constantes nommées.
- Les tests existants du fichier modifié doivent rester verts.
## Bloc d'imports exact
```tsx
'use client';

import { ChevronDown, SlidersHorizontal, X } from 'lucide-react';
import { useState } from 'react';
import type { Marque } from '@/lib/catalogue';
import type { Criteres, Tri } from '@/lib/filtres';
```

## Props
```ts
{ marques: Marque[]; tailles: string[]; criteres: Criteres;
  onChange: (criteres: Criteres) => void; tri: Tri; onTriChange: (tri: Tri) => void }
```
Composant **contrôlé** pour les critères et le tri ; il ne garde en état interne que
l'ouverture des panneaux :
```ts
const [ouvert, setOuvert] = useState<null | 'marques' | 'tailles' | 'tiroir' | 'tri'>(null);
```

## Contrat
Racine `<div data-testid="filtres-barre">`.

### Barre, en grand écran
Conteneur `<div data-testid="barre-bureau">` aux classes imposées
`hidden flex-wrap items-center gap-3 lg:flex`. Chaque bouton à panneau est dans son
propre conteneur `relative`, pour que le panneau se positionne dessous.
- `<button type="button" data-testid="bouton-marques" aria-expanded={…}>` dont le
  texte est `Marque` sans sélection, et `Marque (N)` avec N marques choisies, suivi
  de `<ChevronDown aria-hidden size={16} />`.
  Ouvert, il affiche `<div data-testid="panneau-marques">` contenant un
  `<button type="button" data-testid={\`filtre-marque-${m.slug}\`} aria-pressed={…}>`
  par marque, texte = `m.nom`.
- `<button type="button" data-testid="bouton-tailles">` de la même façon : `Taille`
  ou `Taille (N)`, panneau `data-testid="panneau-tailles"` avec un
  `data-testid={\`filtre-taille-${t}\`}` par taille.
- `<button type="button" data-testid="filtre-promo" aria-pressed={…}>Promotions</button>`
  et `<button type="button" data-testid="filtre-stock" aria-pressed={…}>En stock</button>`.
- Tri : `<label htmlFor="tri">Trier par</label>` et
  `<select id="tri" data-testid="tri">` avec exactement, dans cet ordre, les valeurs
  `nouveautes` `prix-croissant` `prix-decroissant` `remise` et les libellés
  `Nouveautés` `Prix croissant` `Prix décroissant` `Meilleures remises`.
  Son conteneur porte les classes imposées `ml-auto flex items-center gap-2`.

Un seul panneau ouvert à la fois : ouvrir l'un ferme l'autre. Recliquer sur le
bouton d'un panneau ouvert le ferme.

### Pastilles des filtres actifs
Rendues **seulement** s'il y a au moins un filtre actif, dans
`<div data-testid="pastilles">` : un `<button type="button">` par filtre, avec
`aria-label` `Retirer le filtre <texte>` et `<X aria-hidden size={14} />`. Textes :
le nom de la marque, `Taille <valeur>`, `Promotions`, `En stock`. Puis
`<button type="button" data-testid="filtres-reinitialiser">Tout effacer</button>`,
qui appelle `onChange({})`.

### Téléphone
Conteneur `<div data-testid="barre-mobile">` aux classes imposées
`flex items-center gap-3 lg:hidden` contenant :
- `<button type="button" data-testid="ouvrir-filtres">` avec
  `<SlidersHorizontal aria-hidden size={17} />` et le texte `Filtrer` ou
  `Filtrer (N)`, N étant le nombre total de filtres actifs ;
- `<button type="button" data-testid="ouvrir-tri">Trier</button>`.

Quand `ouvert` vaut `'tiroir'`, rendre `<div data-testid="tiroir-filtres" role="dialog" aria-label="Filtrer">`
contenant les **mêmes** boutons de marque et de taille (mêmes `data-testid`), les
deux interrupteurs, un bouton `aria-label="Fermer"` et un bouton de validation.
Quand `ouvert` vaut `'tri'`, rendre `<div data-testid="tiroir-tri" role="dialog" aria-label="Trier">`
avec un bouton par option de tri.

**Attention** : les `data-testid` des boutons de marque et de taille doivent rester
uniques dans le DOM. Le tiroir n'est rendu que lorsqu'il est ouvert, et la barre du
haut est masquée par CSS, pas retirée : n'ouvre donc jamais le tiroir et un panneau
en même temps, et ne rends le tiroir que pour la valeur d'état correspondante.

## Comportement des critères
Cocher ajoute, décocher retire, dans un **nouvel** objet `Criteres` complet, sans
muter celui reçu. Un tableau vidé est transmis vide. Les interrupteurs basculent
`promotionSeulement` et `enStockSeulement`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
