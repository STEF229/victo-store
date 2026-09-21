TICKET 072 — Carrousel : flèches lucide

Modifie `src/components/accueil/Carrousel.tsx`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Icônes : uniquement `lucide-react`.** Plus aucun `<svg>` dessiné à la main dans
  ce composant. Chaque icône reçoit `aria-hidden` et une taille explicite
  (`size={20}` par exemple). Importe **exactement** les noms indiqués, ils ont été
  vérifiés sur ta version installée.
- **Aucun `<h1>`** dans un composant, sauf le carrousel qui porte le titre de la page.
- Classes imposées en toutes lettres ; les tests les vérifient. Tu peux en
  ajouter, jamais en retirer.
- **Les tests existants de ce composant doivent rester verts** : tu modifies un
  composant déjà en production, tu ne le réécris pas de zéro.
## Import à ajouter
```tsx
import { ChevronLeft, ChevronRight } from 'lucide-react';
```

## Changement
- bouton `Diapositive précédente` → `<ChevronLeft aria-hidden size={20} />`
- bouton `Diapositive suivante` → `<ChevronRight aria-hidden size={20} />`

Rien d'autre ne change. Le `<h1>` de la première diapositive reste en place :
c'est le seul composant qui a le droit d'en avoir un.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
