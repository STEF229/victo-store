TICKET 103b — session appuyée sur le registre des comptes

Écris `src/components/compte/SessionProvider.tsx` **en entier, à partir de zéro**.
Le contrat existant ne change pas (il reste vérifié par `tests/SessionProvider.test.tsx`) ;
deux fonctions s'y ajoutent : `modifierProfil` et `changerMotDePasse`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Exports nommés : `CLE_SESSION`, `SessionProvider`, `useSession` et le type `ContexteSession`. Aucun autre.
- Tout accès à `localStorage` est dans un `try { … } catch { }`.
- Pour distinguer succès et erreurs des fonctions du registre, utilise `'erreurs' in r`.

## Bloc d'imports exact
```tsx
'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import type { Client, DonneesInscription } from '@/lib/compte';
import {
  CLE_COMPTES, authentifier, changerMotDePasse as changerMotDePasseRegistre, comptesInitiaux, ecrireComptes,
  enregistrer, lireComptes, modifierProfil as modifierProfilRegistre,
  type Comptes, type ErreursMotDePasse, type ErreursProfil, type Profil,
} from '@/lib/comptes-locaux';
```

## Contrat
Taille attendue : ~120 lignes.
```ts
export const CLE_SESSION = 'victo-session';
export interface ContexteSession {
  client: Client | null;
  pret: boolean;
  connecter: (courriel: string, motDePasse: string) => boolean;
  inscrire: (donnees: DonneesInscription) => Client;
  deconnecter: () => void;
  modifierProfil: (profil: Profil) => ErreursProfil;
  changerMotDePasse: (actuel: string, nouveau: string) => ErreursMotDePasse;
}
```
Fonctions locales, non exportées, recopiées telles quelles :
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
**Valeur par défaut du contexte** (hors fournisseur) : `client: null`, `pret: true`,
`connecter` renvoie `false`, `inscrire` renvoie `nouveauClient(donnees)` sans rien
enregistrer, `deconnecter` ne fait rien, `modifierProfil` et `changerMotDePasse`
renvoient `{}`.

`export function useSession(): ContexteSession` renvoie `useContext(...)`.

`export function SessionProvider({ children }: { children: ReactNode })` :
1. états : `client` (`Client | null`, `null`), `comptes` (`Comptes`, initialisé par
   `useState<Comptes>(comptesInitiaux)`), `pret` (`false`) ;
2. **au montage** (effet `[]`), dans un `try` : `setComptes(lireComptes(window.localStorage.getItem(CLE_COMPTES)))` ;
   puis lit `CLE_SESSION` : si le texte existe, `JSON.parse` et, si `estClient(valeur)`,
   `setClient(valeur)` ; enfin, hors du `try`, `setPret(true)` ;
3. **quand `client` change**, seulement si `pret` (effet `[client, pret]`) : client
   non nul → `setItem(CLE_SESSION, JSON.stringify(client))` ; nul → `removeItem(CLE_SESSION)` ;
4. **quand `comptes` change**, seulement si `pret` (effet `[comptes, pret]`) :
   `setItem(CLE_COMPTES, ecrireComptes(comptes))` ;
5. `connecter(courriel, motDePasse)` : `const c = authentifier(comptes, courriel, motDePasse);`
   si `c`, `setClient(c)` et renvoie `true` ; sinon renvoie `false` ;
6. `inscrire(d)` : `const c = nouveauClient(d); setComptes(enregistrer(comptes, c, d.motDePasse)); setClient(c); return c;` ;
7. `deconnecter()` : `setClient(null)` ;
8. `modifierProfil(profil)` : si `client` est nul, renvoie
   `{ courriel: 'Connectez-vous pour modifier votre profil.' }` ; sinon
   `const r = modifierProfilRegistre(comptes, client.courriel, profil);` — si
   `'erreurs' in r`, renvoie `r.erreurs` ; sinon `setComptes(r.comptes); setClient(r.client);`
   et renvoie `{}` ;
9. `changerMotDePasse(actuel, nouveau)` : si `client` est nul, renvoie
   `{ actuel: 'Connectez-vous pour changer votre mot de passe.' }` ; sinon
   `const r = changerMotDePasseRegistre(comptes, client.courriel, actuel, nouveau);` — si
   `'erreurs' in r`, renvoie `r.erreurs` ; sinon `setComptes(r.comptes)` et renvoie `{}` ;
10. rend le fournisseur du contexte autour de `children`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/SessionProvider.test.tsx`
et les tests des pages de connexion, d'inscription et du compte.
