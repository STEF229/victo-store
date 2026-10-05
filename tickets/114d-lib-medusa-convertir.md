TICKET 114d — les photos de Medusa passent par la boutique

Modifie `src/lib/medusa/convertir.ts`. Les adresses des photos de Medusa sont réécrites vers `/medusa-images/…` (fonction `imageLocale`, exportée).

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
const enCents = (montant: number) => Math.round(montant * 100);
```
Après :
```tsx
/**
 * Les photos téléversées dans Medusa (adresse finissant par /static/fichier.jpg) sont servies par la
 * boutique elle-même, à /medusa-images/fichier.jpg, relayées vers Medusa (next.config.ts) : elles s'affichent partout,
 * tunnel compris. Les autres adresses ne changent pas.
 */
export function imageLocale(url: string): string {
  return url.includes('/static/') ? url.replace(/^.*?\/static\//, '/medusa-images/') : url;
}

const enCents = (montant: number) => Math.round(montant * 100);
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
const images = (p.images ?? []).map((i) => i.url);
```
Après :
```tsx
const images = (p.images ?? []).map((i) => imageLocale(i.url));
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
imageUrl: p.thumbnail ?? images.find(() => true) ?? IMAGE_ABSENTE,
```
Après :
```tsx
imageUrl: (p.thumbnail ? imageLocale(p.thumbnail) : undefined) ?? images.find(() => true) ?? IMAGE_ABSENTE,
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
