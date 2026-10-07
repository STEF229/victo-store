TICKET 116a — un résultat immédiat ou asynchrone

Crée `src/lib/quand.ts`. Petite fonction qui exécute une suite tout de suite si le résultat est déjà là, ou à son arrivée si c'est une promesse.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index, le fichier utilise
  `.find`, `.map`, `.filter`, `.some` et la déstructuration, jamais `t[i]`. Recopie-le tel quel.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~10 lignes.
```ts
/**
 * Exécute la suite tout de suite si le résultat est déjà là (mode démonstration), ou à son arrivée
 * (mode Medusa). En démonstration, le déroulement reste donc exactement synchrone.
 */
export function quand<T>(resultat: T | Promise<T>, suite: (valeur: T) => void): void {
  if (resultat instanceof Promise) void resultat.then(suite);
  else suite(resultat);
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
