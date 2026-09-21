TICKET 050 — Price : option pour masquer le pourcentage de remise

Modifie `src/components/ui/Price.tsx`. La carte produit de la maquette affiche la
remise dans une pastille sur la photo ; elle doit pouvoir demander à `Price` de ne
pas la répéter à côté du prix.

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
## Changement unique
Ajoute la prop optionnelle `afficherRemise?: boolean`, **par défaut `true`**.
Quand elle vaut `false`, l'élément `data-testid="prix-remise"` n'est **pas rendu**.
Tout le reste est inchangé : prix courant, prix barré, `data-promo`, formats.

Les tests existants de `tests/Price.test.tsx` doivent continuer à passer.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
