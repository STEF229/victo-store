TICKET 114w — les sous-catégories de Femme lisent le catalogue du site

Modifie `src/app/femme/[...chemin]/page.tsx`. La route charge le catalogue et le passe à la page de sous-catégorie.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';
```
Après :
```tsx
import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  return <PageSousCategorie rubrique="femme" chemin={chemin} />;
```
Après :
```tsx
  const { produits } = await chargerCatalogue();
  return <PageSousCategorie rubrique="femme" chemin={chemin} produits={produits} />;
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
