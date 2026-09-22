TICKET 091 — page d'accueil : retirer la barre d'annonce

Modifie `src/app/page.tsx`. Le composant `BarreAnnonce` n'existe plus : son
contenu est passé dans le filet de `SiteHeader`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  `page.tsx` qui n'a **qu'un export par défaut**.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** Les déclarations de types des modules utilisés
  te sont fournies en lecture seule.
- Icônes : **`lucide-react` uniquement**, chacune avec `aria-hidden`.
- Classes imposées en toutes lettres, jamais construites par interpolation.
- Couleurs : tokens `var(--vs-*)`. Teintes décoratives autorisées telles quelles :
  `#1E1E26` `#2A2A30` `#FF5A74` `#F0F0EE` `#E9E4DA` `#EEF1F8`.
- **Aucun `<h1>`** sauf dans un composant qui porte explicitement le titre de page.
- Accès aux tableaux : pas de `!`, pas de `as` ; `.map`, `.filter`, constantes nommées.
- Les tests existants du fichier modifié doivent rester verts.
## Changements, et rien d'autre
1. Retire la ligne `import { BarreAnnonce } from '@/components/accueil/BarreAnnonce';`.
2. Retire `<BarreAnnonce />` du rendu. La page commence donc par `<SiteHeader …>`.

Tout le reste du fichier est inchangé : mêmes constantes `NAV` et `COLONNES_PIED`,
même sélection `listerProduits().filter(estEnPromotion).slice(0, 4)`, mêmes
sections dans le même ordre, mêmes classes d'enveloppe, un seul export par défaut.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
