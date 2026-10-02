TICKET 109h — le cœur des cartes produit garde le favori

Modifie `src/components/ui/ProductCard.tsx`. Avec le fournisseur de favoris (le cas du
site), le cœur lit et bascule les favoris gardés ; sans fournisseur, il garde son état
local comme aujourd'hui. Aucune classe, aucun texte ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- `useState` reste importé (il sert encore à l'état local).

## Les trois changements
1. Ajoute, à la suite des imports existants :
   `import { useFavoris } from '@/components/favoris/FavorisProvider';`
2. Remplace exactement `const [favori, setFavori] = useState(false);` par :
   ```tsx
   const favoris = useFavoris();
   const [favoriLocal, setFavoriLocal] = useState(false);
   const favori = favoris.present ? favoris.estFavori(produit.slug) : favoriLocal;
   const basculerFavori = () => (favoris.present ? favoris.basculer(produit.slug) : setFavoriLocal(!favoriLocal));
   ```
3. Sur le bouton « Ajouter aux favoris », remplace exactement
   `onClick={() => setFavori(!favori)}` par `onClick={basculerFavori}`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/accueil2-ProductCard.test.tsx`
et `tests/finitions-ProductCard.test.tsx` (comportement sans fournisseur).
