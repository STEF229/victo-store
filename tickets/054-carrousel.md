TICKET 054 — carrousel d'accueil

Crée `src/components/accueil/Carrousel.tsx`, export `Carrousel`.

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
## Bloc d'imports exact
```tsx
'use client';

import { useEffect, useState } from 'react';
```

## Props
```ts
{ intervalleMs?: number; auto?: boolean }
```
Défauts : `intervalleMs = 5000`, `auto = true`.

## Données — à recopier telles quelles en tête de fichier
```ts
const DIAPOS = [
  {
    surTitre: 'Nouvelle saison',
    titre: 'Des grandes marques, au bon prix.',
    texte: 'Les marques que vous aimez, à moitié prix. Neuf, authentique, expédié du Québec.',
    image: '/img/accueil/photo-1.svg',
    fond: 'bg-[var(--vs-noir)] text-[var(--vs-blanc)]',
    actions: [
      { label: 'Découvrir la boutique', href: '/boutique', principale: true },
      { label: 'Voir les soldes', href: '/soldes', principale: false },
    ],
  },
  {
    surTitre: 'Soldes d’automne',
    titre: 'Jusqu’à −50 % sur les sneakers.',
    texte: 'Nike, Adidas, New Balance, Converse. Stocks limités, pointures qui partent vite.',
    image: '/img/accueil/photo-2.svg',
    fond: 'bg-[var(--vs-promo)] text-[var(--vs-blanc)]',
    actions: [{ label: 'Profiter des soldes', href: '/soldes', principale: true }],
  },
  {
    surTitre: 'Arrivages',
    titre: 'Le denim et le polo, réinventés.',
    texte: 'Levi’s et Lacoste rejoignent la sélection. Les classiques, sans le prix des classiques.',
    image: '/img/accueil/photo-3.svg',
    fond: 'bg-[#E9E4DA] text-[var(--vs-noir)]',
    actions: [{ label: 'Voir les nouveautés', href: '/nouveautes', principale: true }],
  },
] as const;
```
Les classes de `fond` sont écrites en toutes lettres ici justement pour que Tailwind
les voie : applique-les telles quelles avec `className={diapo.fond}`.

## État et défilement
- `const [index, setIndex] = useState(0);`
- Si `auto` vaut `true`, un `useEffect` installe
  `setInterval(() => setIndex((i) => (i + 1) % DIAPOS.length), intervalleMs)` et le
  nettoie avec `clearInterval` dans sa fonction de retour. Ses dépendances sont
  `[auto, intervalleMs]`.
- Suivante : `(i + 1) % 3`. Précédente : `(i + 2) % 3` (on boucle).

## Structure et contrat
- Racine `<section data-testid="carrousel" aria-label="À la une" aria-roledescription="carrousel">`
  aux classes imposées `relative overflow-hidden`.
- Piste `<div data-testid="carrousel-piste">` aux classes imposées
  `flex transition-transform duration-700 ease-in-out`, avec
  `style={{ transform: \`translateX(-${index * 100}%)\` }}`.
- Une diapositive par entrée : `<div data-testid={\`diapo-${n}\`}>` aux classes
  imposées `w-full shrink-0`, plus `diapo.fond`. Elle porte
  `aria-hidden={n !== index}` et `inert={n !== index}`.
- Contenu d'une diapositive, sur deux colonnes en grand écran (conteneur aux
  classes imposées `grid grid-cols-1 items-center gap-10 lg:grid-cols-2`) :
  - le sur-titre dans un `<span>` en petites capitales espacées ;
  - le titre : **`<h1>` pour la diapositive 0 uniquement**, `<h2>` pour les
    autres. Classes imposées sur les deux : `text-5xl font-black tracking-tight lg:text-7xl` ;
  - le texte dans un `<p>` ;
  - les actions dans un conteneur aux classes imposées `flex flex-wrap gap-4`, chacune
    `<a href>` en pilule (`rounded-full`), hauteur 54 px. Une action `principale`
    a un fond contrasté (blanc sur fond sombre ou rouge, cobalt sur fond sable) ; une
    action secondaire a une simple bordure ;
  - l'image : `<img src={diapo.image} alt="">` aux classes imposées
    `h-[520px] w-full rounded-[28px] object-cover`.
- **Commandes**, hors de la piste :
  - `<button type="button" aria-label="Diapositive précédente">` et
    `<button type="button" aria-label="Diapositive suivante">`, ronds, 48 px, avec
    une flèche `<svg aria-hidden="true">` ;
  - trois points : `<button type="button" aria-label="Aller à la diapositive 1">`
    (puis 2, 3), qui appellent `setIndex(n)`. Le point actif porte
    `aria-current="true"` et une largeur de 36 px ; les autres n'ont **pas du tout**
    l'attribut et font 8 px. Écris-le exactement ainsi, sinon React rendrait
    `aria-current="false"` sur les points inactifs :
    `aria-current={n === index ? 'true' : undefined}`. Hauteur 8 px, forme pilule.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
