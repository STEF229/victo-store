TICKET 112b — l'accueil affiche les pastilles des rubriques

Modifie `src/app/page.tsx`. Les pastilles des rubriques (ticket 112a) s'affichent juste avant les bonnes affaires, dans le même bloc ; elles sont masquées sur grand écran.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { MosaiqueCategories } from '@/components/accueil/MosaiqueCategories';
```
Après :
```tsx
import { MosaiqueCategories } from '@/components/accueil/MosaiqueCategories';
import { RubriquesRapides } from '@/components/accueil/RubriquesRapides';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
          <SectionBonnesAffaires produits={bonnesAffaires} />
```
Après :
```tsx
          <RubriquesRapides items={NAV} />
          <SectionBonnesAffaires produits={bonnesAffaires} />
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
