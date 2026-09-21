TICKET 057 — mosaïque des catégories

Crée `src/components/accueil/MosaiqueCategories.tsx`, export `MosaiqueCategories`.

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
Aucun import.

## Données — à recopier telles quelles
```ts
const TUILES = [
  { titre: 'Femme', href: '/femme', image: '/img/accueil/photo-8.svg',
    classes: 'col-span-2 lg:col-span-1 lg:row-span-2 bg-[#1E1E26] text-[var(--vs-blanc)]' },
  { titre: 'Homme', href: '/homme', image: '/img/accueil/photo-9.svg',
    classes: 'bg-[#E9E4DA] text-[var(--vs-noir)]' },
  { titre: 'Chaussures', href: '/chaussures', image: '/img/accueil/photo-10.svg',
    classes: 'bg-[#EEF1F8] text-[var(--vs-noir)]' },
] as const;
```

## Contrat
- Racine `<section data-testid="categories">` contenant `<h2>` au texte exact
  `Par catégorie`, 48 px, graisse 900, puis une `<ul>`.
- `<ul>` aux classes imposées
  `grid grid-cols-2 gap-4 lg:h-[640px] lg:grid-cols-3 lg:grid-rows-2`.
- Trois `<li>` générés depuis `TUILES` avec `.map` et `key={t.href}`. Chaque
  `<li>` porte `className={t.classes}` **plus** les classes imposées
  `relative overflow-hidden rounded-[28px]`, et contient un unique
  `<a href={t.href}>` qui remplit la tuile et renferme :
  - `<img src={t.image} alt="">` aux classes imposées
    `absolute inset-0 h-full w-full object-cover` ;
  - le titre dans un `<span>`, 36 px, graisse 900, en bas à gauche ;
  - un rond de 48 px avec une flèche `<svg aria-hidden="true">`, en bas à droite.
  Le texte accessible du lien est donc **uniquement** le titre.
- Empilement : le `<a>` porte `relative flex h-full min-h-[190px] flex-col justify-end p-7`.
  L'image étant en position absolue, le titre et le rond fléché doivent porter la
  classe `relative` pour passer **au-dessus** de la photo ; sinon elle les masque.
- Un quatrième `<li>`, écrit à la main après les trois autres, aux classes imposées
  `col-span-2 relative overflow-hidden rounded-[28px] bg-[var(--vs-promo)] text-[var(--vs-blanc)]`,
  contenant `<a href="/soldes">` avec `<span>Soldes</span>` en petites capitales,
  puis `<span>Jusqu’à −50 %</span>` en 44 px graisse 900, et le rond fléché blanc.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
