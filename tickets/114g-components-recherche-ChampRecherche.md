TICKET 114g — les suggestions de recherche lisent le catalogue du site

Modifie `src/components/recherche/ChampRecherche.tsx`. Les suggestions cherchent dans `useCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerMarques, listerProduits } from '@/lib/donnees';
```
Après :
```tsx
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const [terme, setTerme] = useState('');
```
Après :
```tsx
  const catalogue = useCatalogue();
  const [terme, setTerme] = useState('');
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
rechercherProduits(listerProduits(), terme)
```
Après :
```tsx
rechercherProduits(catalogue.produits, terme)
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
marquesCorrespondantes(listerMarques(), terme)
```
Après :
```tsx
marquesCorrespondantes(catalogue.marques, terme)
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
