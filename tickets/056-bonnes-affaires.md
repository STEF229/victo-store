TICKET 056 — section des bonnes affaires

Crée `src/components/accueil/SectionBonnesAffaires.tsx`, export `SectionBonnesAffaires`.

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
import { ProductCard } from '@/components/ui/ProductCard';
import type { Produit } from '@/lib/catalogue';
```

## Props
```ts
{ produits: Produit[] }
```

## Contrat
- Racine `<section data-testid="bonnes-affaires">`.
- En-tête aux classes imposées `flex items-end justify-between gap-4`, contenant :
  - un bloc avec `<span>` au texte exact `Prix cassés`, en petites capitales, couleur
    `var(--vs-promo)`, puis `<h2>` au texte exact
    `Les bonnes affaires du moment`, 48 px, graisse 900 ;
  - `<a href="/soldes">Tout voir</a>` en pilule bordée de `var(--vs-noir)`.
- Rail `<ul data-testid="rail">` aux classes imposées
  `flex gap-4 overflow-x-auto snap-x snap-mandatory md:grid md:grid-cols-4 md:gap-5 md:overflow-visible`.
  Sur téléphone, les cartes défilent au doigt ; en grand écran, quatre colonnes.
- Un `<li>` par produit, `key={p.id}`, aux classes imposées
  `w-[250px] shrink-0 snap-start md:w-auto`, contenant `<ProductCard produit={p} />`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
