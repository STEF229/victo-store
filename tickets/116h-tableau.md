TICKET 116h — le tableau de bord montre les vraies commandes

Modifie `src/app/compte/page.tsx`. En mode Medusa, les commandes affichées sont celles de Medusa (`session.commandes`) ; en démonstration, celles d'avant.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre. Chaque « avant » est recopié tel qu'il est
  dans le fichier ; quand un « après » a plus de lignes que son « avant », **écris toutes ses lignes**.

## Remplacement 1 — **une ligne s'ajoute** sous la signature de `Tableau`
Avant :
```tsx
function Tableau({ client }: { client: Client }) {
```
Après :
```tsx
function Tableau({ client }: { client: Client }) {
  const session = useSession();
```

## Remplacement 2 — les commandes viennent de la session en mode Medusa
Avant :
```tsx
  const commandes = commandesDe(client);
```
Après :
```tsx
  const commandes = session.commandes ?? commandesDe(client);
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les anciens tests de la session et des pages du compte.
