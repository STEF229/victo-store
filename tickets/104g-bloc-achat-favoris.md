TICKET 104g — le cœur de la fiche produit garde le favori

Modifie `src/components/produit/BlocAchat.tsx`. Le fichier actuel est correct et
testé : le favori, aujourd'hui un simple état local, passe par les favoris gardés.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Aucune classe, aucun texte, aucun autre comportement ne change. `useState` reste
  importé : il sert encore à la taille, à la quantité, à l'erreur et à la confirmation.

## Les trois changements
1. Ajoute, à la suite des imports existants :
   `import { useFavoris } from '@/components/favoris/FavorisProvider';`
2. Remplace exactement la ligne `const [favori, setFavori] = useState(false);` par :
   ```tsx
   const favoris = useFavoris();
   const favori = favoris.estFavori(produit.slug);
   ```
3. Sur le bouton `aria-label="Ajouter aux favoris"`, remplace
   `onClick={() => setFavori(!favori)}` par `onClick={() => favoris.basculer(produit.slug)}`.
   Ses autres attributs et son icône ne changent pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/BlocAchat.test.tsx`.
