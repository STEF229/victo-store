TICKET 021 — page vitrine du design system

Crée `src/app/design/page.tsx`, export nommé `DesignPage`, plus un
`export default DesignPage;` en fin de fichier (Next.js exige un export par
défaut pour une route ; c'est la **seule** exception à la règle des exports
nommés).

Le fichier commence par la directive `'use client';` car la page gère de l'état.

## But
Une page unique qui montre tous les composants du design system, pour valider le
rendu visuel d'un coup d'œil. C'est l'écran de contrôle de la marque.

## Règles absolues
- TypeScript strict. Aucune dépendance nouvelle.
- **Ne modifie aucun fichier de test.**
- Ne crée et ne modifie aucun autre fichier.
- Couleurs uniquement via les tokens `var(--vs-*)`.

## Contenu imposé
La page importe et utilise **tous** les composants existants :
`Container`, `Section`, `Heading`, `Text`, `Button`, `Badge`, `Price`, `Field`,
`SizeSelector`, `QuantityStepper`, `ProductCard`, `SiteHeader`.

Structure attendue :
- `<SiteHeader>` en haut, avec trois entrées (« Femme », « Homme », « Soldes ») et
  `cartCount={2}`.
- Un `<Heading level={1}>` dont le texte est exactement `Design system`.
- Une section par famille de composants, chacune introduite par un
  `<Heading level={2}>` : `Boutons`, `Badges`, `Prix`, `Formulaire`,
  `Sélection`, `Produits`.
- Boutons : les trois variantes et les trois tailles, plus un bouton `loading`.
- Badges : les quatre variantes.
- Prix : un prix simple et un prix en promotion.
- Formulaire : un `Field` normal, un avec aide, un en erreur.
- Sélection : un `SizeSelector` et un `QuantityStepper` **fonctionnels**, reliés
  à un `useState`, de sorte que cliquer change réellement l'affichage.
- Produits : une grille de trois `ProductCard` construits à partir de données
  fictives typées `Produit` de `src/lib/catalogue`, dont au moins un en
  promotion et un avec un `badge`.

## Critère de fin
`npm run typecheck` et `npm test` passent.
