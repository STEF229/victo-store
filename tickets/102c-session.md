TICKET 102c — session du client, gardée dans le navigateur

Crée `src/components/compte/SessionProvider.tsx`, avec les exports nommés
`CLE_SESSION`, `SessionProvider` et `useSession`. Connexion de **démonstration** :
le vrai compte arrivera avec Medusa.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Tout accès à `localStorage` est dans un `try { … } catch { }`.

## Bloc d'imports exact
```tsx
'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import { CLIENT_DEMO, verifierConnexion, type Client, type DonneesInscription } from '@/lib/compte';
```

## Contrat
Taille attendue : ~85 lignes.
```ts
export const CLE_SESSION = 'victo-session';
export interface ContexteSession {
  client: Client | null;
  pret: boolean;
  connecter: (courriel: string, motDePasse: string) => boolean;
  inscrire: (donnees: DonneesInscription) => Client;
  deconnecter: () => void;
}
```
**Construire un client à l'inscription** — fonction locale, non exportée :
```ts
function nouveauClient(d: DonneesInscription): Client {
  return {
    prenom: d.prenom.trim(),
    nom: d.nom.trim(),
    courriel: d.courriel.trim().toLowerCase(),
    membreDepuis: new Date().toISOString().slice(0, 10),
    adresses: [],
  };
}
```
**Relire une session enregistrée** — garde de type locale, non exportée, recopiée telle quelle :
```ts
function estClient(x: unknown): x is Client {
  return (
    typeof x === 'object' && x !== null &&
    'prenom' in x && typeof x.prenom === 'string' &&
    'nom' in x && typeof x.nom === 'string' &&
    'courriel' in x && typeof x.courriel === 'string' &&
    'membreDepuis' in x && typeof x.membreDepuis === 'string' &&
    'adresses' in x && Array.isArray(x.adresses)
  );
}
```
Le contexte est créé avec une **valeur par défaut** : `client: null`, `pret: true`,
`connecter` renvoie `false`, `inscrire` renvoie `nouveauClient(donnees)` sans rien
enregistrer, `deconnecter` ne fait rien.

`export function useSession(): ContexteSession` renvoie `useContext(...)`.

`export function SessionProvider({ children }: { children: ReactNode })` :
1. états `client` (`Client | null`, initialement `null`) et `pret` (initialement `false`) ;
2. **au montage** (effet, tableau `[]`) : lit `window.localStorage.getItem(CLE_SESSION)` ;
   si le texte existe, `JSON.parse` puis, si `estClient(valeur)`, `setClient(valeur)`
   (tout dans le `try`) ; enfin `setPret(true)` ;
3. **quand `client` change**, seulement si `pret` (effet `[client, pret]`) :
   `client` non nul → `setItem(CLE_SESSION, JSON.stringify(client))` ; nul →
   `removeItem(CLE_SESSION)` ;
4. `connecter(courriel, motDePasse)` : si `verifierConnexion(courriel, motDePasse)`,
   `setClient(CLIENT_DEMO)` et renvoie `true` ; sinon renvoie `false` ;
5. `inscrire(d)` : `const c = nouveauClient(d); setClient(c); return c;` ;
6. `deconnecter()` : `setClient(null)` ;
7. rend le fournisseur du contexte autour de `children`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
