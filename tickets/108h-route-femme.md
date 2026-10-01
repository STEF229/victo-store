TICKET 108h — les sous-catégories de Femme ont leur adresse

Crée `src/app/femme/[...chemin]/page.tsx` (le dossier s'appelle exactement `[...chemin]`).
Export par défaut seulement ; composant serveur, pas de `'use client'`.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~10 lignes.
```tsx
import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';

export default async function PageSousCategorieFemme({ params }: { params: Promise<{ chemin: string[] }> }) {
  const { chemin } = await params;
  return <PageSousCategorie rubrique="femme" chemin={chemin} />;
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
