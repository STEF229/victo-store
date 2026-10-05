TICKET 114a — le catalogue transmis aux composants du navigateur

Crée `src/components/catalogue/CatalogueProvider.tsx` : un fournisseur (`CatalogueProvider`) et son
crochet (`useCatalogue`). Le serveur charge le catalogue (ticket 114k) et le transmet ; sans
fournisseur, `useCatalogue()` renvoie les données de démonstration.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier. Recopie le fichier tel quel.

## Fichier complet
Taille attendue : ~20 lignes.
```tsx
'use client';

import { createContext, useContext, type ReactNode } from 'react';
import type { Catalogue } from '@/lib/catalogue-source';
import { listerMarques, listerProduits } from '@/lib/donnees';

// Sans fournisseur (tests, aperçus), les données de démonstration : les composants marchent toujours.
const Contexte = createContext<Catalogue>({ produits: listerProduits(), marques: listerMarques(), source: 'demo' });

/** Transmet aux composants du navigateur le catalogue chargé par le serveur (layout.tsx). */
export function CatalogueProvider({ valeur, children }: { valeur: Catalogue; children: ReactNode }) {
  return <Contexte.Provider value={valeur}>{children}</Contexte.Provider>;
}

/** Le catalogue du site : Medusa ou démonstration, selon CATALOGUE_SOURCE. */
export function useCatalogue(): Catalogue {
  return useContext(Contexte);
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
