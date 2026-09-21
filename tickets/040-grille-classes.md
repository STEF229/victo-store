TICKET 040 — grille de produits : colonnes responsives

Modifie `src/components/catalogue/GrilleProduits.tsx`. La grille actuelle n'a
**aucune** classe de colonnes : elle s'affiche sur une seule colonne et chaque
carte occupe toute la largeur. C'est le seul défaut à corriger.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée aucun autre fichier.
- Couleurs via les tokens `var(--vs-*)` uniquement. Cobalt `--vs-accent` pour les
  actions, rouge `--vs-promo` réservé aux remises.
- **Aucun fichier baril nexiste** : nimporte jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres, dans une chaîne littérale.
  Tailwind ne génère que les classes quil lit dans le code source ; une classe
  construite dynamiquement (`grid-cols-${n}`) ne sera jamais produite. Les tests
  vérifient la présence des classes imposées. Tu peux en **ajouter** d autres,
  jamais en retirer.
- Accès aux tableaux : `tableau[0]` a le type `T | undefined`. Nutilise ni `!`
  ni `as` ; préfère `.map`, `.filter`, `.slice` ou une constante nommée.
- Les `data-testid` sont un contrat testé.

## Classes imposées sur le `<ul data-testid="grille">`
```
grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3
```
Suivies de la `className` reçue en prop. Exemple exact :
```tsx
<ul data-testid="grille" className={`grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 ${className}`}>
```

## Ne change rien d'autre
Le comportement existant est déjà testé par `tests/GrilleProduits.test.tsx`, qui
doit continuer à passer : même `data-testid`, même message quand la liste est
vide, un `<li>` par produit avec `key={produit.id}`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
