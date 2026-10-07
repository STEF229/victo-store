TICKET 116i — la liste des commandes montre les vraies commandes

Modifie `src/app/compte/commandes/page.tsx`. En mode Medusa, la liste montre les commandes de Medusa ; en démonstration, celles d'avant.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre. Chaque « avant » est recopié tel qu'il est
  dans le fichier ; quand un « après » a plus de lignes que son « avant », **écris toutes ses lignes**.

## Remplacement 1 — **une ligne s'ajoute** sous la signature de `Liste`
Avant :
```tsx
function Liste({ client }: { client: Client }) {
```
Après :
```tsx
function Liste({ client }: { client: Client }) {
  const session = useSession();
```

## Remplacement 2 — les commandes viennent de la session en mode Medusa
Avant :
```tsx
filtrerCommandes(commandesDe(client), filtre)
```
Après :
```tsx
filtrerCommandes(session.commandes ?? commandesDe(client), filtre)
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les anciens tests de la session et des pages du compte.
