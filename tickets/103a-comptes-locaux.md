TICKET 103a — registre des comptes, gardé dans le navigateur

Crée `src/lib/comptes-locaux.ts`. Fonctions **pures** : aucune ne modifie ses
arguments. Démonstration en attendant Medusa : les mots de passe sont gardés en
clair, uniquement dans le navigateur de l'utilisateur.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index sur un
  tableau. Un compte se lit par sa clé, `const compte = comptes[cle];`, puis
  `if (compte)` : c'est permis ici, car `Comptes` est un `Partial<Record<…>>` et la
  valeur est déjà typée `CompteLocal | undefined`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque changement renvoie un **nouvel** objet `Comptes` (copie par `{ ...comptes }`).

## Bloc d'imports exact
```ts
import { CLIENT_DEMO, COURRIEL_DEMO, MOT_DE_PASSE_DEMO, courrielValide, type Client } from '@/lib/compte';
```

## Types et constante
Taille attendue : ~110 lignes.
```ts
export interface CompteLocal {
  client: Client;
  motDePasse: string;
}
export type Comptes = Partial<Record<string, CompteLocal>>;
export interface Profil {
  prenom: string;
  nom: string;
  courriel: string;
}
export type ErreursProfil = Partial<Record<keyof Profil, string>>;
export type ErreursMotDePasse = Partial<Record<'actuel' | 'nouveau', string>>;
export const CLE_COMPTES = 'victo-comptes';
```

## Fonctions
```ts
export function cleCourriel(courriel: string): string;
export function comptesInitiaux(): Comptes;
export function lireComptes(texte: string | null): Comptes;
export function ecrireComptes(comptes: Comptes): string;
export function authentifier(comptes: Comptes, courriel: string, motDePasse: string): Client | null;
export function enregistrer(comptes: Comptes, client: Client, motDePasse: string): Comptes;
export function validerProfil(profil: Profil): ErreursProfil;
export function modifierProfil(comptes: Comptes, courrielActuel: string, profil: Profil):
  { comptes: Comptes; client: Client } | { erreurs: ErreursProfil };
export function changerMotDePasse(comptes: Comptes, courriel: string, actuel: string, nouveau: string):
  { comptes: Comptes } | { erreurs: ErreursMotDePasse };
```
- **`cleCourriel`** : `courriel.trim().toLowerCase()`.
- **`comptesInitiaux`** : `{ [COURRIEL_DEMO]: { client: CLIENT_DEMO, motDePasse: MOT_DE_PASSE_DEMO } }`.
- **`lireComptes`** : part de `comptesInitiaux()`. Si `texte` n'est pas `null`, dans un
  `try` : `JSON.parse(texte)` ; si le résultat est un objet non nul qui n'est pas un
  tableau, pour chaque `[cle, valeur]` de `Object.entries(resultat as Record<string, unknown>)`,
  si `estCompte(valeur)`, ajoute `{ client: valeur.client, motDePasse: valeur.motDePasse }`
  sous `cle` (un compte lu remplace donc le compte de démonstration de même clé). En
  cas d'erreur, renvoie `comptesInitiaux()`. Garde de type locale, non exportée,
  recopiée telle quelle :
  ```ts
  function estCompte(x: unknown): x is CompteLocal {
    return (
      typeof x === 'object' && x !== null &&
      'motDePasse' in x && typeof x.motDePasse === 'string' &&
      'client' in x && typeof x.client === 'object' && x.client !== null &&
      'prenom' in x.client && typeof x.client.prenom === 'string' &&
      'nom' in x.client && typeof x.client.nom === 'string' &&
      'courriel' in x.client && typeof x.client.courriel === 'string' &&
      'membreDepuis' in x.client && typeof x.client.membreDepuis === 'string' &&
      'adresses' in x.client && Array.isArray(x.client.adresses)
    );
  }
  ```
- **`ecrireComptes`** : `JSON.stringify(comptes)`.
- **`authentifier`** : `const compte = comptes[cleCourriel(courriel)];` → renvoie
  `compte.client` si `compte` existe et `compte.motDePasse === motDePasse`, sinon `null`.
- **`enregistrer`** : `{ ...comptes, [cleCourriel(client.courriel)]: { client, motDePasse } }`.
- **`validerProfil`** : objet vide, puis, dans cet ordre et seulement si fautif :
  `prenom` vide après `.trim()` → `'Indiquez votre prénom.'` ; `nom` vide après
  `.trim()` → `'Indiquez votre nom.'` ; `!courrielValide(courriel)` →
  `'Indiquez un courriel valide.'`.
- **`modifierProfil`** :
  1. `const erreurs = validerProfil(profil);` — s'il y en a, renvoie `{ erreurs }` ;
  2. `const ancienne = cleCourriel(courrielActuel); const compte = comptes[ancienne];` —
     s'il n'existe pas, renvoie `{ erreurs: { courriel: 'Compte introuvable.' } }` ;
  3. `const nouvelle = cleCourriel(profil.courriel);` — si `nouvelle !== ancienne` et
     `comptes[nouvelle]` existe, renvoie `{ erreurs: { courriel: 'Ce courriel est déjà utilisé.' } }` ;
  4. `const client: Client = { ...compte.client, prenom: profil.prenom.trim(), nom: profil.nom.trim(), courriel: nouvelle };`
     puis `const suivants: Comptes = { ...comptes }; delete suivants[ancienne];
     suivants[nouvelle] = { client, motDePasse: compte.motDePasse };` et renvoie
     `{ comptes: suivants, client }`.
- **`changerMotDePasse`** : `const cle = cleCourriel(courriel); const compte = comptes[cle];`
  puis, objet d'erreurs vide : si `!compte || compte.motDePasse !== actuel` →
  `actuel: 'Mot de passe actuel incorrect.'` ; si `nouveau.length < 8 || !/\d/.test(nouveau)` →
  `nouveau: 'Au moins 8 caractères, dont un chiffre.'`. S'il y a au moins une erreur
  (ou pas de compte), renvoie `{ erreurs }` ; sinon
  `{ comptes: { ...comptes, [cle]: { client: compte.client, motDePasse: nouveau } } }`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
