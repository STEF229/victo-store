TICKET 059 — bloc de réassurance

Crée `src/components/accueil/Reassurance.tsx`, export `Reassurance`.

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
const ENGAGEMENTS = [
  { titre: 'Livraison offerte au Canada', texte: 'Expédiée du Québec sous 48 heures.', icone: 'camion' },
  { titre: 'Retours gratuits 30 jours', texte: 'Une taille qui ne va pas ? On l’échange.', icone: 'retour' },
  { titre: 'Paiement sécurisé', texte: 'Vos données de carte ne transitent jamais par nos serveurs.', icone: 'cadenas' },
] as const;
```

## Contrat
- Racine `<section data-testid="reassurance">` avec une bordure haute
  `var(--vs-ligne)`, contenant une `<ul>` aux classes imposées
  `grid grid-cols-1 gap-8 sm:grid-cols-3 lg:gap-12`.
- Un `<li>` par engagement (`.map`, `key={e.titre}`), en ligne : un carré arrondi
  de 52 px fond `var(--vs-surface)` contenant l'icône, puis `<h3>` au texte
  `e.titre` et `<p>` au texte `e.texte` en `var(--vs-gris)`.
- Icônes : trois `<svg aria-hidden="true">` en trait (`fill="none"`,
  `stroke="currentColor"`), choisies selon `e.icone` avec des `if` ou une
  table de correspondance : un camion, une flèche circulaire de retour, un cadenas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
