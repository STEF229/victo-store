TICKET 055 — bande des marques qui défile

Crée `src/components/accueil/BandeMarques.tsx`, export `BandeMarques`.

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
import { hrefMarque, type Marque } from '@/lib/catalogue';
```

## Props
```ts
{ marques: Marque[] }
```

## Principe
Une bande infinie : la liste des marques est rendue **deux fois** côte à côte, et
l'ensemble glisse de la moitié de sa largeur en boucle. Quand la première copie est
sortie, la seconde est exactement à sa place, d'où l'illusion d'un défilement sans fin.

## Contrat
- Racine `<section data-testid="bande-marques" aria-label="Nos marques">` aux
  classes imposées `overflow-hidden border-b border-[var(--vs-ligne)]`, hauteur 96 px.
- **En tout début de la section**, l'animation, exactement :
  ```tsx
  <style>{'@keyframes vs-defile{from{transform:translateX(0)}to{transform:translateX(-50%)}}'}</style>
  ```
- Piste `<div data-testid="bande-piste">` aux classes imposées
  `flex w-max items-center animate-[vs-defile_38s_linear_infinite] motion-reduce:animate-none`.
- Dans la piste, deux `<ul>` identiques, classes `flex items-center gap-16 pr-16` :
  - la **première** est normale ;
  - la **seconde** porte `aria-hidden="true"`, et chacun de ses liens
    `tabIndex={-1}` : c'est une copie visuelle, ni lue ni atteignable au clavier.
- Chaque `<li>` contient `<a href={hrefMarque(m)}>` au texte `m.nom` en
  capitales (`uppercase`), 26 px, graisse 900, suivi d'une étoile décorative
  `<span aria-hidden="true">✦</span>` en `var(--vs-promo)`.
- Itère avec `.map` et `key={m.id}` ; pour la copie, `key={\`copie-${m.id}\`}`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
