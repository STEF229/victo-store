TICKET 060 — SiteFooter : style de la maquette

Modifie `src/components/ui/SiteFooter.tsx`.

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
`tests/SiteFooter.test.tsx` doit continuer à passer : `<footer data-testid="pied">`
de premier niveau ; un `<h2>` et une liste de liens par colonne ;
`pied-mentions` exactement `© <annee> VICTO STORE` ; `pied-slogan` exactement
`Des grandes marques, au bon prix.`.

## Nouveautés
1. Le `<footer>` porte les classes imposées `bg-[var(--vs-noir)] text-[var(--vs-blanc)]`.
2. En haut : la marque `VICTO STORE` (26 px, 900) et le slogan à gauche, les
   colonnes à droite, titres de colonnes en petites capitales `#B5B5BA`, liens blancs.
3. Au-dessus des mentions, un filigrane décoratif :
   `<p aria-hidden="true" data-testid="pied-filigrane">VICTO</p>` aux classes
   imposées `select-none text-[200px] font-black leading-none text-[#1E1E26]`.
4. Les mentions, séparées par une bordure haute fine, en `#B5B5BA`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
