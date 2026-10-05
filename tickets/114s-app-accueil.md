TICKET 114s — l’accueil lit le catalogue du site

Modifie `src/app/page.tsx`. La page devient asynchrone et lit `chargerCatalogue()`.

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
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
export function AccueilPage() {
  const bonnesAffaires = listerProduits().filter(estEnPromotion).slice(0, 4);
```
Après :
```tsx
export async function AccueilPage() {
  const catalogue = await chargerCatalogue();
  const bonnesAffaires = catalogue.produits.filter(estEnPromotion).slice(0, 4);
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
<BandeMarques marques={listerMarques()} />
```
Après :
```tsx
<BandeMarques marques={catalogue.marques} />
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
