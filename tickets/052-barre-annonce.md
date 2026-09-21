TICKET 052 — barre d'annonce

Crée `src/components/accueil/BarreAnnonce.tsx`, export `BarreAnnonce`.

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
## Contrat
- Racine `<div data-testid="barre-annonce">` aux classes imposées
  `bg-[var(--vs-noir)] text-[var(--vs-blanc)]`, hauteur 40 px, texte 13 px gras.
- Une `<ul>` aux classes imposées `flex items-center justify-center gap-7`,
  contenant trois `<li>` dont le texte est **exactement**, dans l'ordre :
  `Livraison offerte au Canada`, `Retours gratuits 30 jours`,
  `Authenticité garantie`.
- Le 2e et le 3e `<li>` portent les classes imposées `hidden sm:flex` : sur
  téléphone, seul le premier message reste.
- **Aucun séparateur** : ni point, ni barre, ni caractère décoratif. L'espacement
  `gap-7` suffit. Le texte de chaque `<li>` doit être exactement le message, rien d'autre.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
