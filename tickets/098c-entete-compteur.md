TICKET 098c — compteur de l'en-tête branché sur le panier

Modifie `src/components/ui/SiteHeader.tsx`. Le fichier actuel est correct et
testé : tu ne changes que ce qui est décrit ici.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index
  (`tableau[i]`) ; utilise `.find`, `.map`, `.filter`.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Ne change aucune classe, aucun texte, aucun `data-testid`, aucun `aria-*`, aucun
  autre import, aucune autre prop.

## Les cinq changements
1. **Première ligne** du fichier : `'use client';`. Si elle y est déjà, ne la
   double pas.
2. **Ajoute** cet import, à la suite des imports existants :
   ```tsx
   import { usePanier } from '@/components/panier/PanierProvider';
   ```
3. **Type des props : ne le touche pas.** La ligne `cartCount?: number;` reste
   **exactement** ainsi, point d'interrogation compris : la prop reste
   **facultative**. Beaucoup de pages et de tests affichent l'en-tête sans elle ;
   la rendre obligatoire casserait tout le projet.
   **Paramètres de la fonction** : si la déstructuration donne une valeur par
   défaut à `cartCount` (par exemple `cartCount = 0`), écris seulement `cartCount`,
   sans `= 0`. Rien d'autre ne change dans la signature.
4. **Au début du corps** de `SiteHeader`, avant tout autre code, ajoute exactement :
   ```tsx
   const { nombre } = usePanier();
   const compte = cartCount ?? nombre;
   ```
   puis, **dans tout le reste du composant**, remplace chaque utilisation de
   `cartCount` par `compte`. Après ce changement, `cartCount` n'apparaît plus que
   dans la signature et dans la ligne `const compte = cartCount ?? nombre;`.
5. L'élément `data-testid="entete-panier-compte"` n'est rendu **que si
   `compte > 0`** : `{compte > 0 && ( … )}` autour de lui. Un panier vide
   n'affiche pas de pastille « 0 ».

Ainsi une valeur passée explicitement l'emporte (les tests existants passent
`cartCount={2}`), et sans elle l'en-tête affiche le nombre d'articles du panier.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont
`tests/entete-v3.test.tsx` (comportement existant) et `tests/entete-compteur.test.tsx`.
