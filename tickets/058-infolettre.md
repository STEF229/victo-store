TICKET 058 — bandeau d'inscription à l'infolettre

Crée `src/components/accueil/Infolettre.tsx`, export `Infolettre`.

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

import { useState, type FormEvent } from 'react';
```

## Contrat
- Racine `<section data-testid="infolettre">` ; à l'intérieur, un bloc aux classes
  imposées `grid grid-cols-1 items-center gap-8 rounded-[28px] bg-[var(--vs-accent)] text-[var(--vs-blanc)] lg:grid-cols-2`,
  avec un grand espacement intérieur.
- Colonne de gauche : `<h2>−10 % sur votre première commande.</h2>`, 40 px,
  graisse 900 ; puis `<p>Les arrivages et les ventes privées, avant tout le monde.</p>`.
- Colonne de droite, tant que l'inscription n'est pas faite :
  `<form data-testid="infolettre-formulaire" noValidate onSubmit={envoyer}>` aux classes
  imposées `flex flex-col gap-3 sm:flex-row`, contenant :
  - `<label htmlFor="infolettre-courriel" className="sr-only">Votre courriel</label>`
  - `<input id="infolettre-courriel" type="email" placeholder="Votre courriel">`
    contrôlé par `useState('')`, en pilule, fond blanc, hauteur 56 px ;
  - `<button type="submit">Recevoir le code</button>` en pilule, fond
    `var(--vs-noir)`, texte blanc.
- `envoyer(e: FormEvent<HTMLFormElement>)` commence **toujours** par
  `e.preventDefault()`. Puis :
  - si la valeur ne contient pas `@` : afficher sous le formulaire
    `<p role="alert">Entrez une adresse courriel valide.</p>` ;
  - sinon : remplacer le formulaire par
    `<p data-testid="infolettre-merci">Merci, votre code arrive par courriel.</p>`.
- Aucun envoi réseau : c'est une maquette fonctionnelle, le branchement viendra plus tard.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
