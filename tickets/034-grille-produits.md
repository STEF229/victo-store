TICKET 034 — grille de produits

Crée `src/components/catalogue/GrilleProduits.tsx`, export `GrilleProduits`.

## Règles absolues
- TypeScript strict. Exports **nommés**. Ne modifie aucun test, ne crée aucun
  autre fichier.
- Couleurs via les tokens `var(--vs-*)` uniquement. Cobalt `--vs-accent` pour les
  actions, rouge `--vs-promo` réservé aux remises.
- **Aucun fichier baril nexiste** : nimporte jamais depuis un dossier.
- Les `data-testid` sont un contrat testé ; les classes Tailwind sont libres.

## Bloc d'imports exact
```tsx
import type { Produit } from '@/lib/catalogue';
import { ProductCard } from '@/components/ui/ProductCard';
```

## Props
```ts
{ produits: Produit[]; className?: string }
```

## Contrat
- Liste non vide : `<ul data-testid="grille">` contenant un `<li>` par produit,
  avec l'attribut `key` sur `produit.id`, et un `<ProductCard produit={p} />`
  à l'intérieur. N'ajoute **aucun** autre `data-testid`.
- Liste vide : pas de `<ul>` du tout, mais
  `<p data-testid="grille-vide">Aucun produit ne correspond à ces filtres.</p>`.

## Style
Grille responsive : une colonne sur mobile, deux sur tablette, trois à quatre sur
grand écran. Espacement généreux, la photo doit primer.

## Critère de fin
`npm run typecheck` et `npm test` passent.
