TICKET 074 — Reassurance : icônes lucide

Modifie `src/components/accueil/Reassurance.tsx`.

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
import { Lock, RotateCcw, Truck } from 'lucide-react';
```

## Changement
Les trois icônes deviennent, dans l'ordre des engagements :
`<Truck aria-hidden size={24} />`, `<RotateCcw aria-hidden size={24} />`,
`<Lock aria-hidden size={24} />`. Le carré arrondi qui les entoure est inchangé.
Supprime la logique qui choisissait un tracé selon `e.icone` si elle n'est plus
utile ; garde la constante `ENGAGEMENTS`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
