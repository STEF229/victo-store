TICKET 101d — /boutique rejoint les autres pages de liste

Écris `src/app/boutique/page.tsx` en entier, à partir de zéro. La page n'utilise
plus l'ancien panneau de filtres : elle affiche toute la sélection avec
`VueCatalogue`, comme les pages Femme, Homme, Chaussures et Soldes.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut `PageBoutique`.** Aucun export nommé.
- Composant serveur : **pas** de `'use client'`.

## Fichier
Taille attendue : ~15 lignes.
```tsx
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { listerProduits } from '@/lib/donnees';

export default function PageBoutique() {
  return (
    <VueCatalogue
      titre="Boutique"
      description="Toute la sélection, toutes marques confondues, au bon prix."
      produits={listerProduits()}
    />
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
