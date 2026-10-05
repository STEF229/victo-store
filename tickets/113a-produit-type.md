TICKET 113a — un produit peut porter son type

Modifie `src/lib/catalogue.ts`. L'interface `Produit` gagne un champ facultatif `type` (le
troisième niveau de l'arbre : `course`, `polos`…), fourni par les catégories de Medusa.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier. Rien d'autre ne change.

## Le remplacement (l'occurrence unique)
Avant :
```ts
  composition?: string;
  images?: string[];
}
```
Après :
```ts
  composition?: string;
  images?: string[];
  type?: string;
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
