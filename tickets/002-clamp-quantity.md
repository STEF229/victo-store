TICKET 002 — `clampQuantity`

Crée le fichier `src/lib/clampQuantity.ts` et implémente la fonction `clampQuantity`.

## Règles absolues
- TypeScript strict. Export **nommé**, pas d'export par défaut.
- **Aucune dépendance externe**, aucun import.
- Ne modifie **aucun** fichier de test. Les tests font foi.
- Ne crée aucun autre fichier. Ne touche pas à `src/lib/formatPrice.ts`.

## Signature
```ts
export function clampQuantity(value: number, min?: number, max?: number): number
```
Valeurs par défaut : `min = 1`, `max = 99`.

## Comportement, dans cet ordre exact
1. **Valider les bornes d'abord.** Si `min` ou `max` n'est pas un entier fini, lève
   `new TypeError('clampQuantity: min et max doivent être des entiers finis')`.
2. Si `min > max`, lève `new RangeError('clampQuantity: min ne peut pas dépasser max')`.
3. Si `value` n'est pas de type `number`, ou vaut `NaN`, retourne `min`.
4. Sinon, appliquer `Math.floor(value)` (arrondi vers le bas, y compris pour les négatifs).
5. Puis borner dans `[min, max]` : en dessous → `min`, au-dessus → `max`.
6. `Infinity` donne donc `max`, `-Infinity` donne `min`.
7. La fonction est pure : pas d'effet de bord, pas de mutation, pas de `console.log`.

## Exemples
| appel | résultat |
|---|---|
| `clampQuantity(5)` | `5` |
| `clampQuantity(1)` | `1` |
| `clampQuantity(0)` | `1` |
| `clampQuantity(-3)` | `1` |
| `clampQuantity(99)` | `99` |
| `clampQuantity(100)` | `99` |
| `clampQuantity(3.7)` | `3` |
| `clampQuantity(0.5)` | `1` |
| `clampQuantity(99.9)` | `99` |
| `clampQuantity(NaN)` | `1` |
| `clampQuantity(Infinity)` | `99` |
| `clampQuantity(5, 2, 4)` | `4` |
| `clampQuantity(1, 2, 4)` | `2` |
| `clampQuantity(3, 2, 4)` | `3` |
| `clampQuantity(0, 0, 10)` | `0` |

## Critère de fin
`npm run typecheck` et `npm test` passent tous les deux, sans modification des tests.
