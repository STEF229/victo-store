TICKET 117d — le bouton « Passer la commande » mène au tunnel en mode Medusa

Modifie `src/components/panier/RecapPanier.tsx`. En mode Medusa, « Passer la commande » est un lien vers le tunnel (`/commande`). En démonstration, et sans fournisseur de catalogue (les tests), le bouton désactivé et son message restent identiques.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre. Chaque « avant » est recopié tel qu'il est
  dans le fichier ; quand un « après » a plus de lignes que son « avant », **écris toutes ses lignes**.

## Remplacement 1 — la ligne d'import de `formatPrice` reste, et **deux lignes d'import s'ajoutent juste dessous**
Avant :
```tsx
import { formatPrice } from '@/lib/formatPrice';
```
Après :
```tsx
import { formatPrice } from '@/lib/formatPrice';
import Link from 'next/link';
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
```

## Remplacement 2 — **une ligne s'ajoute** sous la signature, qui reste
Avant :
```tsx
export function RecapPanier({ recap }: { recap: Recap }) {
```
Après :
```tsx
export function RecapPanier({ recap }: { recap: Recap }) {
  const enLigne = useCatalogue().source === 'medusa';
```

## Remplacement 3 — en mode Medusa, un lien vers `/commande` ; en démonstration, le bouton désactivé d'avant
Avant :
```tsx
      <button type="button" disabled className="h-[58px] cursor-not-allowed rounded-full bg-[var(--vs-accent)] text-[17px] font-extrabold text-[var(--vs-blanc)] opacity-60">
        Passer la commande
      </button>
      <p className="text-center text-[13px] text-[var(--vs-gris)]">Le paiement en ligne arrive bientôt.</p>
```
Après :
```tsx
      {enLigne ? (
        <Link href="/commande" className="flex h-[58px] items-center justify-center rounded-full bg-[var(--vs-accent)] text-[17px] font-extrabold text-[var(--vs-blanc)]">
          Passer la commande
        </Link>
      ) : (
        <>
          <button type="button" disabled className="h-[58px] cursor-not-allowed rounded-full bg-[var(--vs-accent)] text-[17px] font-extrabold text-[var(--vs-blanc)] opacity-60">
            Passer la commande
          </button>
          <p className="text-center text-[13px] text-[var(--vs-gris)]">Le paiement en ligne arrive bientôt.</p>
        </>
      )}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/RecapPanier.test.tsx`.
