TICKET 108i — les sous-catégories de Homme ont leur adresse

Crée `src/app/homme/[...chemin]/page.tsx` (le dossier s'appelle exactement `[...chemin]`).
Export par défaut seulement ; composant serveur, pas de `'use client'`.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~10 lignes.
```tsx
import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';

export default async function PageSousCategorieHomme({ params }: { params: Promise<{ chemin: string[] }> }) {
  const { chemin } = await params;
  return <PageSousCategorie rubrique="homme" chemin={chemin} />;
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
