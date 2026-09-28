TICKET 104b — la session enregistre les adresses

Modifie `src/components/compte/SessionProvider.tsx`. Le fichier actuel est correct
et testé : tu ajoutes **une** fonction au contexte, rien d'autre ne change.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index sur un
  tableau. Un compte se lit par sa clé, `comptes[cle]`, puis `if (compte)`.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Aucune autre fonction, aucun autre effet ne change.

## Les quatre changements
1. Dans l'import depuis `'@/lib/compte'`, ajoute le type `Adresse` :
   `import type { Adresse, Client, DonneesInscription } from '@/lib/compte';`
2. Dans l'import depuis `'@/lib/comptes-locaux'`, ajoute `cleCourriel` à la liste.
3. Dans `interface ContexteSession`, ajoute, après `changerMotDePasse` :
   `mettreAJourAdresses: (adresses: Adresse[]) => void;`
   et, dans la **valeur par défaut** du contexte, `mettreAJourAdresses: () => {}`.
4. Dans `SessionProvider`, ajoute cette fonction, recopiée telle quelle, et passe-la
   dans la valeur du fournisseur avec les autres :
   ```ts
   function mettreAJourAdresses(adresses: Adresse[]) {
     if (client === null) return;
     const suivant: Client = { ...client, adresses };
     const cle = cleCourriel(client.courriel);
     const compte = comptes[cle];
     setClient(suivant);
     if (compte) setComptes({ ...comptes, [cle]: { client: suivant, motDePasse: compte.motDePasse } });
   }
   ```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/SessionProvider.test.tsx`
et `tests/session-comptes.test.tsx`.
