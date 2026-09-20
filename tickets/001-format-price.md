TICKET 001 — `formatPrice`

Crée le fichier `src/lib/formatPrice.ts` et implémente la fonction `formatPrice`.

## Règles absolues
- TypeScript strict (`strict: true`, `noUncheckedIndexedAccess: true`).
- Export **nommé** : `export function formatPrice(...)`. Pas d'export par défaut.
- **Aucune dépendance externe**, aucun import.
- **N'utilise PAS `Intl.NumberFormat` ni `toLocaleString`** : le résultat dépend de la version d'ICU et casserait les tests. Construis la chaîne caractère par caractère.
- Ne modifie **aucun** fichier de test. Les tests font foi.
- Ne crée aucun autre fichier.

## Signature
```ts
export function formatPrice(cents: number): string
```

## Comportement
1. `cents` est un **entier** représentant un montant en cents CAD (ex. `1250` = 12,50 $).
2. Si `cents` n'est pas un nombre entier fini (float, `NaN`, `Infinity`, `-Infinity`, ou tout type autre que `number`), lève `new TypeError('formatPrice: cents doit être un entier fini')`.
3. Format de sortie, dans cet ordre :
   - signe `-` en tête si le montant est négatif ;
   - partie entière, groupée par milliers avec l'**espace insécable** `U+00A0` (`'\u00A0'`) comme séparateur ;
   - virgule `,` comme séparateur décimal ;
   - **toujours exactement 2 décimales** ;
   - une **espace insécable** `U+00A0` puis le symbole `$`.
4. N'utilise **jamais** l'espace ASCII ordinaire (`' '`, U+0020) dans le résultat.
5. `-0` doit produire le même résultat que `0`.

## Exemples (`·` note l'espace insécable U+00A0)
| entrée | sortie |
|---|---|
| `0` | `0,00·$` |
| `5` | `0,05·$` |
| `99` | `0,99·$` |
| `1250` | `12,50·$` |
| `99900` | `999,00·$` |
| `123456` | `1·234,56·$` |
| `100000000` | `1·000·000,00·$` |
| `-1250` | `-12,50·$` |
| `-123456` | `-1·234,56·$` |

## Critère de fin
`npm run typecheck` et `npm test` passent tous les deux, sans modification des tests.
