TICKET 116j — le détail d’une commande montre la vraie commande

Modifie `src/app/compte/commandes/[numero]/page.tsx`. En mode Medusa, le détail montre la commande de Medusa et son adresse de livraison ; en démonstration, comme avant.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre. Chaque « avant » est recopié tel qu'il est
  dans le fichier ; quand un « après » a plus de lignes que son « avant », **écris toutes ses lignes**.

## Remplacement 1 — **une ligne s'ajoute** sous la signature de `Detail`
Avant :
```tsx
function Detail({ client, numero }: { client: Client; numero: string }) {
```
Après :
```tsx
function Detail({ client, numero }: { client: Client; numero: string }) {
  const session = useSession();
```

## Remplacement 2 — la commande vient de la session en mode Medusa
Avant :
```tsx
  const commande = commandesDe(client).find((c) => c.numero === numero);
```
Après :
```tsx
  const commande = (session.commandes ?? commandesDe(client)).find((c) => c.numero === numero);
```

## Remplacement 3 — l'adresse de la commande Medusa d'abord
Avant :
```tsx
  const adresse = client.adresses.find((a) => a.id === commande.adresseId);
```
Après :
```tsx
  const adresse = commande.adresse ?? client.adresses.find((a) => a.id === commande.adresseId);
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les anciens tests de la session et des pages du compte.
