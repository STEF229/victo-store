TICKET 114b — les tailles se calculent sur n’importe quelle liste de produits

Modifie `src/lib/donnees.ts`. `taillesDe(produits)` fait le calcul de `taillesCatalogue()` sur la liste reçue (celle de Medusa ou de la démonstration) ; `taillesCatalogue()` l'appelle, son résultat ne change pas.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
export function taillesCatalogue(): string[] {
  const vues = new Set<string>();
  for (const p of PRODUITS) for (const v of p.variantes) vues.add(v.taille);
```
Après :
```tsx
export function taillesCatalogue(): string[] {
  return taillesDe(PRODUITS);
}

/** Les tailles présentes dans une liste de produits : pointures croissantes, puis S, M, L, XL. */
export function taillesDe(produits: Produit[]): string[] {
  const vues = new Set<string>();
  for (const p of produits) for (const v of p.variantes) vues.add(v.taille);
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
