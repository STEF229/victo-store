TICKET 114j — les filtres proposent les tailles du catalogue du site

Modifie `src/components/catalogue/VueCatalogue.tsx`. Les tailles proposées par le filtre viennent de `useCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { taillesCatalogue } from '@/lib/donnees';
```
Après :
```tsx
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
import { taillesDe } from '@/lib/donnees';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const [criteres, setCriteres] = useState<Criteres>({});
```
Après :
```tsx
  const catalogue = useCatalogue();
  const [criteres, setCriteres] = useState<Criteres>({});
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
tailles={taillesCatalogue()}
```
Après :
```tsx
tailles={taillesDe(catalogue.produits)}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
