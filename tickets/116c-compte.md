TICKET 116c — une commande peut porter son adresse de livraison

Modifie `src/lib/compte.ts`. Le type `Commande` gagne un champ facultatif `adresse` : une commande Medusa porte sa propre adresse de livraison.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre. Chaque « avant » est recopié tel qu'il est
  dans le fichier ; quand un « après » a plus de lignes que son « avant », **écris toutes ses lignes**.

## Remplacement 1 — le champ facultatif `adresse` s'ajoute entre `adresseId` et `paiement`, qui restent
Avant :
```tsx
  adresseId: string;
  paiement: string;
```
Après :
```tsx
  adresseId: string;
  /** Adresse de livraison, quand la commande vient de Medusa. */
  adresse?: Adresse;
  paiement: string;
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les anciens tests de la session et des pages du compte.
