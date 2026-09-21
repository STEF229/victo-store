TICKET 070 — SiteHeader : icônes lucide

Modifie `src/components/ui/SiteHeader.tsx`.

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
import { Menu, Search, ShoppingBag, User } from 'lucide-react';
```

## Changement
Remplace chaque icône dessinée à la main :
- bouton `Ouvrir le menu` → `<Menu aria-hidden size={22} />`
- bouton `Rechercher` → `<Search aria-hidden size={21} />`
- bouton `Mon compte` → `<User aria-hidden size={21} />`
- lien panier → `<ShoppingBag aria-hidden size={21} />`

Rien d'autre ne change : disposition, pastille, libellés, attributs.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
