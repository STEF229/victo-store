TICKET 092 — grille : quatre colonnes possibles

Modifie `src/components/catalogue/GrilleProduits.tsx`. Les pages de liste passent
à quatre colonnes en grand écran ; l'accueil reste à trois.

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
## Changement unique
Ajoute la prop `colonnes?: 3 | 4`, **par défaut `3`**, et applique la classe
correspondante. Écris la correspondance en clair, jamais par interpolation :
```ts
const COLONNES = { 3: 'lg:grid-cols-3', 4: 'lg:grid-cols-4' } as const;
```
Les classes de base restent imposées : `grid grid-cols-1 gap-6 sm:grid-cols-2`,
suivies de la classe de colonnes puis de la `className` reçue.

Le reste est inchangé : `data-testid="grille"`, un `<li>` par produit avec
`key={produit.id}`, et le message `Aucun produit ne correspond à ces filtres.`
dans `<p data-testid="grille-vide">` quand la liste est vide.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
