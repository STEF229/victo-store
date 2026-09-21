TICKET 085 — page Homme

Crée `src/app/homme/page.tsx`. **Un seul export, par défaut.** Aucun état, pas de `'use client'`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  les fichiers `page.tsx` qui n'ont **qu'un export par défaut**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** N'importe que des modules réels ; leurs
  déclarations de types exactes te sont fournies en lecture seule.
- Icônes : uniquement `lucide-react`, avec `aria-hidden`.
- Classes imposées en toutes lettres ; les tests les vérifient.
- Accès aux tableaux : `t[0]` est `T | undefined` ; pas de `!` ni de `as`.
- **Les tests existants qui touchent ce fichier doivent rester verts.**
## Contenu exact du fichier

```tsx
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { correspondAuGenre } from '@/lib/catalogue';
import { listerProduits } from '@/lib/donnees';

export default function PageHomme() {
  return (
    <VueCatalogue
      titre="Homme"
      description="Sneakers, vêtements et accessoires des grandes marques, au bon prix."
      produits={listerProduits().filter((p) => correspondAuGenre(p, 'homme'))}
    />
  );
}
```

Recopie ce fichier tel quel. C'est volontairement court : toute la logique vit dans
`VueCatalogue`, déjà testé.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
