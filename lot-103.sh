#!/usr/bin/env bash
# VICTO STORE — lot 103 : espace client, partie 2.
#   103a lib/comptes-locaux.ts : registre des comptes (démonstration, mots de passe en clair
#        dans le navigateur, en attendant Medusa)
#   103b SessionProvider réécrit : se reconnecter après inscription, modifier son profil,
#        changer son mot de passe (contrat du lot 102 inchangé)
#   103c /compte/informations   103d « Voir le détail » sur les cartes   103e /compte/commandes/[numero]
# Usage :  cd ~/victo-store && bash lot-103.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
info(){ printf '  \033[33m!\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }
annuler(){ rm -f tests/zz-prevol-*; git reset -q --hard HEAD; git clean -fdq -- tests tickets; mort "$*  — rien n'a été modifié"; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
modifies="$(git ls-files -m -- '*.tsbuildinfo')"
[ -z "$modifies" ] || git checkout -q -- $modifies
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase=merges || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
ok "main à jour ($(git rev-parse --short HEAD))"

# ------------------------------------------------------------ ce que les specs supposent
fusionne(){ git log main -1 --format=%h --fixed-strings --grep="feat($1): fusionné" | grep -q .; }
for d in 102a 102b 102c 102d 102e 102f 102g 102h 102i 102j 102k 102l 102m; do fusionne "$d" || mort "$d n'est pas fusionné"; done
SP=src/components/compte/SessionProvider.tsx; CC=src/components/compte/CarteCommande.tsx
grep -q "export const CLE_SESSION" "$SP" && grep -q "verifierConnexion" "$SP" || mort "$SP ne ressemble pas à la version du lot 102"
grep -q "comptes-locaux" "$SP" && mort "$SP utilise déjà le registre : lot déjà passé ?"
[ "$(grep -c '</ul>' "$CC")" = 1 ] || mort "$CC : la liste des articles (</ul>) n'est pas unique"
grep -q "Voir le détail" "$CC" && mort "$CC a déjà son lien de détail : lot déjà passé ?"
for f in src/lib/comptes-locaux.ts src/app/compte/informations "src/app/compte/commandes/[numero]"; do
  [ ! -e "$f" ] || mort "$f existe déjà : lot déjà passé ?"; done
grep -q "export function libelleArticles" src/lib/panier-detail.ts || mort "libelleArticles absent de panier-detail.ts"
for j in noir blanc surface ligne gris accent promo; do grep -qE -- "--vs-$j\s*:" src/styles/tokens.css || mort "jeton --vs-$j absent"; done
manque="$(node -e "const l=require('lucide-react');console.log(['ArrowLeft','Check','Truck'].filter(n=>!l[n]).join(' '))" 2>/dev/null || echo lucide-react)"
[ -z "$manque" ] || mort "icônes lucide absentes de ta version : $manque"
ok "lot 102 fusionné, session et carte de commande conformes, icônes présentes"

cat > tests/zz-prevol-env.test.ts <<'__ENV__'
import { expect, it, vi } from 'vitest';
const etat = vi.hoisted(() => ({ numero: 'VS-1' }));
vi.mock('next/navigation', async (original) => ({
  ...(await original<typeof import('next/navigation')>()),
  useParams: () => ({ numero: etat.numero }),
}));
import { useParams, usePathname } from 'next/navigation';
it('imitation partielle de useParams', () => {
  etat.numero = 'VS-2';
  expect(useParams<{ numero: string }>().numero).toBe('VS-2');
  expect(typeof usePathname).toBe('function');
});
__ENV__
npx --no-install vitest run tests/zz-prevol-env.test.ts > /tmp/victo-prevol.log 2>&1 || true
rm -f tests/zz-prevol-env.test.ts; sed -i -E 's/\x1b\[[0-9;]*m//g' /tmp/victo-prevol.log
grep -qE "Tests +1 passed" /tmp/victo-prevol.log || { tail -12 /tmp/victo-prevol.log; mort "l'imitation de useParams ne fonctionne pas sous vitest"; }
ok "environnement : imitation de useParams fonctionnelle"

trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
mkdir -p tickets/tests
cat > 'tickets/103a-comptes-locaux.md' <<'__VICTO_FIN_0__'
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
__VICTO_FIN_0__
cat > 'tickets/103b-session-comptes.md' <<'__VICTO_FIN_1__'
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
__VICTO_FIN_1__
cat > 'tickets/103c-page-informations.md' <<'__VICTO_FIN_2__'
TICKET 103c — informations personnelles

Crée `src/app/compte/informations/page.tsx`. Page **client** (`'use client'`), un
seul export : l'export par défaut `PageInformations`. On y modifie le prénom, le nom,
le courriel et le mot de passe.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Aucun export nommé. Chaque `className` est écrit exactement comme ci-dessous.
- Apostrophes droites dans les textes.

## Bloc d'imports exact
```tsx
'use client';

import { useState, type FormEvent } from 'react';
import {
  BOUTON_SECONDAIRE, CARTE, CHAMP, CHAMP_AIDE, CHAMP_ERREUR, CHAMP_LIBELLE, CHAMP_SAISIE, CHAMP_SAISIE_ERREUR, TITRE_PAGE,
} from '@/components/compte/compte-affichage';
import { EspaceClient } from '@/components/compte/EspaceClient';
import { useSession } from '@/components/compte/SessionProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import type { Client } from '@/lib/compte';
import type { ErreursMotDePasse, ErreursProfil } from '@/lib/comptes-locaux';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```

## Un champ — fonction locale, non exportée, recopiée telle quelle
Taille attendue : ~150 lignes.
```tsx
function Champ(props: {
  id: string;
  libelle: string;
  type: string;
  auto: string;
  valeur: string;
  erreur: string | undefined;
  aide?: string | undefined;
  onChange: (valeur: string) => void;
}) {
  const decrit = [props.aide ? `aide-${props.id}` : '', props.erreur ? `erreur-${props.id}` : ''].filter(Boolean).join(' ');
  return (
    <div className={CHAMP}>
      <label htmlFor={props.id} className={CHAMP_LIBELLE}>{props.libelle}</label>
      <input id={props.id} type={props.type} autoComplete={props.auto} value={props.valeur}
        onChange={(e) => props.onChange(e.target.value)}
        aria-invalid={props.erreur ? true : undefined}
        aria-describedby={decrit || undefined}
        className={props.erreur ? CHAMP_SAISIE_ERREUR : CHAMP_SAISIE} />
      {props.aide && <p id={`aide-${props.id}`} className={CHAMP_AIDE}>{props.aide}</p>}
      {props.erreur && <p id={`erreur-${props.id}`} className={CHAMP_ERREUR}>{props.erreur}</p>}
    </div>
  );
}
```

## Le contenu — fonction locale `Formulaires({ client }: { client: Client })`
```tsx
const session = useSession();
const [profil, setProfil] = useState({ prenom: client.prenom, nom: client.nom, courriel: client.courriel });
const [erreursProfil, setErreursProfil] = useState<ErreursProfil>({});
const [profilEnregistre, setProfilEnregistre] = useState(false);
const [actuel, setActuel] = useState('');
const [nouveau, setNouveau] = useState('');
const [erreursMdp, setErreursMdp] = useState<ErreursMotDePasse>({});
const [mdpChange, setMdpChange] = useState(false);

function enregistrerProfil(e: FormEvent<HTMLFormElement>) {
  e.preventDefault();
  const erreurs = session.modifierProfil(profil);
  setErreursProfil(erreurs);
  setProfilEnregistre(Object.keys(erreurs).length === 0);
}
function changerMdp(e: FormEvent<HTMLFormElement>) {
  e.preventDefault();
  const erreurs = session.changerMotDePasse(actuel, nouveau);
  setErreursMdp(erreurs);
  const ok = Object.keys(erreurs).length === 0;
  setMdpChange(ok);
  if (ok) {
    setActuel('');
    setNouveau('');
  }
}
```
Rendu :
```tsx
<>
  <h1 className={TITRE_PAGE}>Informations personnelles</h1>
  <form onSubmit={enregistrerProfil} noValidate aria-labelledby="titre-profil" className={`${CARTE} gap-5`}>
    <h2 id="titre-profil" className="text-lg font-extrabold text-[var(--vs-noir)]">Profil</h2>
    <div className="grid gap-4 sm:grid-cols-2">
      <Champ id="prenom" libelle="Prénom" type="text" auto="given-name" valeur={profil.prenom} erreur={erreursProfil.prenom}
        onChange={(v) => setProfil({ ...profil, prenom: v })} />
      <Champ id="nom" libelle="Nom" type="text" auto="family-name" valeur={profil.nom} erreur={erreursProfil.nom}
        onChange={(v) => setProfil({ ...profil, nom: v })} />
    </div>
    <Champ id="courriel" libelle="Courriel" type="email" auto="email" valeur={profil.courriel} erreur={erreursProfil.courriel}
      onChange={(v) => setProfil({ ...profil, courriel: v })} />
    {profilEnregistre && <p role="status" className="text-sm font-bold text-[var(--vs-accent)]">Vos informations sont enregistrées.</p>}
    <button type="submit" className={`self-start ${BOUTON_SECONDAIRE} sm:w-auto`}>Enregistrer</button>
  </form>
  <form onSubmit={changerMdp} noValidate aria-labelledby="titre-mdp" className={`${CARTE} gap-5`}>
    <h2 id="titre-mdp" className="text-lg font-extrabold text-[var(--vs-noir)]">Mot de passe</h2>
    <div className="grid gap-4 sm:grid-cols-2">
      <Champ id="actuel" libelle="Mot de passe actuel" type="password" auto="current-password" valeur={actuel}
        erreur={erreursMdp.actuel} onChange={setActuel} />
      <Champ id="nouveau" libelle="Nouveau mot de passe" type="password" auto="new-password" valeur={nouveau}
        erreur={erreursMdp.nouveau} aide="8 caractères minimum, dont au moins un chiffre." onChange={setNouveau} />
    </div>
    {mdpChange && <p role="status" className="text-sm font-bold text-[var(--vs-accent)]">Mot de passe modifié.</p>}
    <button type="submit" className={`self-start ${BOUTON_SECONDAIRE} sm:w-auto`}>Changer le mot de passe</button>
  </form>
</>
```

## La page
```tsx
export default function PageInformations() {
  const session = useSession();
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Mon compte', href: '/compte' }, { label: 'Informations personnelles' }]} />
        <EspaceClient actif="informations">
          {session.client && <Formulaires client={session.client} />}
        </EspaceClient>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_2__
cat > 'tickets/103d-carte-commande-lien.md' <<'__VICTO_FIN_3__'
TICKET 103d — lien « Voir le détail » sur chaque carte de commande

Modifie `src/components/compte/CarteCommande.tsx`. Le fichier actuel est correct et
testé : deux ajouts, rien d'autre ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Garde les imports actuels ; aucune classe, aucun texte existant ne change.

## Les deux ajouts
1. En tête des imports, ajoute `import Link from 'next/link';`.
2. Juste après la balise fermante `</ul>`, avant `</article>`, ajoute exactement :
   ```tsx
   <Link href={`/compte/commandes/${commande.numero}`} className="self-start text-[15px] font-bold text-[var(--vs-noir)] underline">
     Voir le détail
   </Link>
   ```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/CarteCommande.test.tsx`.
__VICTO_FIN_3__
cat > 'tickets/103e-page-detail-commande.md' <<'__VICTO_FIN_4__'
TICKET 103e — détail d'une commande

Crée `src/app/compte/commandes/[numero]/page.tsx`. Page **client** (`'use client'`),
un seul export : l'export par défaut `PageDetailCommande`. Le numéro vient de
l'adresse, lu avec `useParams`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index sur un
  tableau ; utilise `.find`, `.map`. Lire `CLASSES_STATUT[x]`, `LIBELLES_STATUT[x]`
  ou `ATTEINTE[x]` est permis : ce sont des `Record` dont la clé est un type exact.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Aucun export nommé. Chaque `className` est écrit exactement comme ci-dessous.
- Icônes `lucide-react` avec `aria-hidden`. Apostrophes droites dans les textes.
- Tout montant passe par `formatPrice`.

## Bloc d'imports exact
```tsx
'use client';

import { ArrowLeft, Check, Truck } from 'lucide-react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { CARTE, CLASSES_STATUT, LIBELLES_STATUT, LIEN, SOUS_TITRE, TITRE_PAGE } from '@/components/compte/compte-affichage';
import { EspaceClient } from '@/components/compte/EspaceClient';
import { useSession } from '@/components/compte/SessionProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { commandesDe, formaterDate, totauxCommande, type Client, type StatutCommande } from '@/lib/compte';
import { formatPrice } from '@/lib/formatPrice';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
import { libelleArticles } from '@/lib/panier-detail';
```

## Constantes
Taille attendue : ~155 lignes.
```tsx
const ETAPES = ['Confirmée', 'En préparation', 'Expédiée', 'Livrée'] as const;
const ATTEINTE: Record<Exclude<StatutCommande, 'annulee'>, number> = { preparation: 1, expediee: 2, livree: 3 };
const LIGNE_RECAP = 'flex justify-between';
```

## Le contenu — fonction locale `Detail({ client, numero }: { client: Client; numero: string })`
1. `const commande = commandesDe(client).find((c) => c.numero === numero);`
2. **Commande introuvable** — si `commande` est indéfinie, renvoie :
```tsx
<>
  <h1 className={TITRE_PAGE}>Commande introuvable</h1>
  <p data-testid="commande-introuvable" className={SOUS_TITRE}>{`Aucune commande ${numero} dans votre compte.`}</p>
  <Link href="/compte/commandes" className={LIEN}>Toutes mes commandes</Link>
</>
```
3. Sinon :
```tsx
const totaux = totauxCommande(commande);
const adresse = client.adresses.find((a) => a.id === commande.adresseId);
const atteinte = commande.statut === 'annulee' ? -1 : ATTEINTE[commande.statut];
```
et renvoie :
```tsx
<>
  <Link href="/compte/commandes" className="flex items-center gap-1.5 self-start text-[15px] font-bold text-[var(--vs-noir)]">
    <ArrowLeft aria-hidden size={18} />
    Toutes mes commandes
  </Link>
  <div className="flex flex-col gap-2.5">
    <h1 className={TITRE_PAGE}>{`Commande ${commande.numero}`}</h1>
    <p className={SOUS_TITRE}>{`Passée le ${formaterDate(commande.date)}`}</p>
  </div>
  <section data-testid="suivi" className={CARTE}>
    <div className="flex items-center justify-between gap-4">
      <h2 className="text-lg font-extrabold text-[var(--vs-noir)]">Suivi</h2>
      <span data-testid="detail-statut" className={CLASSES_STATUT[commande.statut]}>{LIBELLES_STATUT[commande.statut]}</span>
    </div>
    {commande.statut === 'annulee' ? (
      <p data-testid="commande-annulee" className={SOUS_TITRE}>Cette commande a été annulée. Aucun montant n'a été débité.</p>
    ) : (
      <ol className="grid grid-cols-4 gap-2">
        {ETAPES.map((etape, i) => (
          <li key={etape} data-testid="etape" data-etat={i <= atteinte ? 'faite' : 'a-venir'} className="flex flex-col gap-2">
            <span className={i <= atteinte
              ? 'flex h-[30px] w-[30px] items-center justify-center rounded-full bg-[var(--vs-noir)] text-[var(--vs-blanc)]'
              : 'flex h-[30px] w-[30px] rounded-full border-2 border-[var(--vs-ligne)]'}>
              {i <= atteinte && <Check aria-hidden size={16} />}
            </span>
            <span className="text-sm font-bold text-[var(--vs-noir)]">{etape}</span>
          </li>
        ))}
      </ol>
    )}
    {commande.suivi !== null && (
      <p data-testid="suivi-colis" className="flex items-center gap-2.5 text-sm text-[var(--vs-gris)]">
        <Truck aria-hidden size={19} />
        {`Postes Canada · n° de suivi ${commande.suivi}`}
      </p>
    )}
  </section>
  <div className="grid gap-7 lg:grid-cols-[minmax(0,7fr)_minmax(0,5fr)] lg:items-start">
    <section className="flex flex-col gap-1.5">
      <h2 className="text-lg font-extrabold text-[var(--vs-noir)]">{libelleArticles(totaux.articles)}</h2>
      <ul>
        {commande.lignes.map((l) => (
          <li key={`${l.slug}-${l.taille}`} data-testid="ligne-commande"
            className="flex items-center justify-between gap-4 border-b border-[var(--vs-ligne)] py-4">
            <div className="flex flex-col gap-1">
              <span className="text-xs font-extrabold uppercase tracking-[0.16em] text-[var(--vs-gris)]">{l.marque}</span>
              <Link href={`/produits/${l.slug}`} className="text-base font-extrabold text-[var(--vs-noir)]">{l.nom}</Link>
              <span className="text-sm text-[var(--vs-gris)]">{`Pointure ${l.taille} · Quantité ${l.quantite}`}</span>
            </div>
            <span className="text-base font-extrabold text-[var(--vs-noir)]">{formatPrice(l.prixCents * l.quantite)}</span>
          </li>
        ))}
      </ul>
    </section>
    <div className="flex flex-col gap-5">
      <section className="flex flex-col gap-3 rounded-3xl bg-[var(--vs-surface)] p-[26px] text-[15px]">
        <h2 className="text-lg font-extrabold text-[var(--vs-noir)]">Récapitulatif</h2>
        <div className={LIGNE_RECAP}><span>Sous-total</span><span data-testid="detail-sous-total" className="font-bold">{formatPrice(totaux.sousTotalCents)}</span></div>
        {totaux.economiesCents > 0 && (
          <div className={`${LIGNE_RECAP} text-[var(--vs-promo)]`}><span>Vos économies</span><span className="font-bold">{`\u2212${formatPrice(totaux.economiesCents)}`}</span></div>
        )}
        <div className={LIGNE_RECAP}><span>Livraison</span><span className="font-bold">Offerte</span></div>
        <div className={LIGNE_RECAP}><span>TPS (5 %)</span><span data-testid="detail-tps" className="font-bold">{formatPrice(totaux.tpsCents)}</span></div>
        <div className={LIGNE_RECAP}><span>TVQ (9,975 %)</span><span data-testid="detail-tvq" className="font-bold">{formatPrice(totaux.tvqCents)}</span></div>
        <div className="h-px bg-[var(--vs-ligne)]" />
        <div className="flex items-baseline justify-between"><span className="font-extrabold">Total payé</span><span data-testid="detail-total" className="text-2xl font-black">{formatPrice(totaux.totalCents)}</span></div>
      </section>
      <section data-testid="detail-livraison" className={CARTE}>
        <h2 className="text-base font-extrabold text-[var(--vs-noir)]">Livraison</h2>
        {adresse ? (
          <p className="text-[15px] leading-relaxed">
            {adresse.nomComplet}<br />{adresse.ligne1}<br />{`${adresse.ville} (${adresse.province}) ${adresse.codePostal}`}
          </p>
        ) : (
          <p className={SOUS_TITRE}>Adresse non disponible.</p>
        )}
        <h2 className="text-base font-extrabold text-[var(--vs-noir)]">Paiement</h2>
        <p className="text-[15px]">{commande.paiement}</p>
      </section>
    </div>
  </div>
</>
```

## La page
```tsx
export default function PageDetailCommande() {
  const session = useSession();
  const params = useParams<{ numero: string }>();
  const numero = params.numero;
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[
          { label: 'Accueil', href: '/' },
          { label: 'Mon compte', href: '/compte' },
          { label: 'Mes commandes', href: '/compte/commandes' },
          { label: `Commande ${numero}` },
        ]} />
        <EspaceClient actif="commandes">
          {session.client && <Detail client={session.client} numero={numero} />}
        </EspaceClient>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_4__
cat > 'tickets/manifest-103.tsv' <<'__VICTO_FIN_5__'
103a	src/lib/comptes-locaux.ts	tests/comptes-locaux.test.ts	tickets/103a-comptes-locaux.md	src/lib/compte.ts		
103b	src/components/compte/SessionProvider.tsx	tests/session-comptes.test.tsx	tickets/103b-session-comptes.md	src/lib/comptes-locaux.ts,src/lib/compte.ts	103a	neuf
103c	src/app/compte/informations/page.tsx	tests/page-informations.test.tsx	tickets/103c-page-informations.md	src/components/compte/compte-affichage.ts,src/components/compte/EspaceClient.tsx,src/components/compte/SessionProvider.tsx,src/lib/comptes-locaux.ts	103b	
103d	src/components/compte/CarteCommande.tsx	tests/carte-commande-lien.test.tsx	tickets/103d-carte-commande-lien.md			
103e	src/app/compte/commandes/[numero]/page.tsx	tests/page-detail-commande.test.tsx	tickets/103e-page-detail-commande.md	src/components/compte/compte-affichage.ts,src/components/compte/EspaceClient.tsx,src/components/compte/SessionProvider.tsx,src/lib/compte.ts,src/lib/panier-detail.ts		
__VICTO_FIN_5__
cat > 'tickets/tests/carte-commande-lien.test.tsx' <<'__VICTO_FIN_6__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { CarteCommande } from '../src/components/compte/CarteCommande';
import { COMMANDES_DEMO, type Commande } from '../src/lib/compte';

describe('CarteCommande — détail', () => {
  it('mène au détail de la commande', () => {
    render(<CarteCommande commande={COMMANDES_DEMO.find((c) => c.numero === 'VS-10417') as Commande} />);
    expect(screen.getByRole('link', { name: 'Voir le détail' })).toHaveAttribute('href', '/compte/commandes/VS-10417');
  });
});
__VICTO_FIN_6__
cat > 'tickets/tests/comptes-locaux.test.ts' <<'__VICTO_FIN_7__'
import { describe, expect, it } from 'vitest';
import { CLIENT_DEMO, COURRIEL_DEMO, MOT_DE_PASSE_DEMO, type Client } from '../src/lib/compte';
import {
  authentifier, changerMotDePasse, cleCourriel, comptesInitiaux, ecrireComptes, enregistrer, lireComptes,
  modifierProfil, validerProfil, type Comptes,
} from '../src/lib/comptes-locaux';

const LEA: Client = { prenom: 'Léa', nom: 'Roy', courriel: 'lea@exemple.ca', membreDepuis: '2026-09-27', adresses: [] };
const avecLea = (): Comptes => enregistrer(comptesInitiaux(), LEA, 'motdepasse1');

describe('registre — base', () => {
  it('contient le compte de démonstration', () => {
    expect(authentifier(comptesInitiaux(), COURRIEL_DEMO, MOT_DE_PASSE_DEMO)).toBe(CLIENT_DEMO);
    expect(authentifier(comptesInitiaux(), ' Camille.Tremblay@Exemple.CA ', MOT_DE_PASSE_DEMO)).toBe(CLIENT_DEMO);
    expect(authentifier(comptesInitiaux(), COURRIEL_DEMO, 'faux')).toBeNull();
    expect(authentifier(comptesInitiaux(), 'inconnu@exemple.ca', 'x')).toBeNull();
  });

  it('enregistre un compte sans modifier le registre reçu', () => {
    const avant = comptesInitiaux();
    const apres = enregistrer(avant, LEA, 'motdepasse1');
    expect(authentifier(apres, 'LEA@exemple.ca', 'motdepasse1')).toEqual(LEA);
    expect(authentifier(avant, 'lea@exemple.ca', 'motdepasse1')).toBeNull();
    expect(cleCourriel(' A@B.ca ')).toBe('a@b.ca');
  });

  it('relit ce qu’il écrit, garde le compte de démonstration et ignore l’illisible', () => {
    const relu = lireComptes(ecrireComptes(avecLea()));
    expect(authentifier(relu, 'lea@exemple.ca', 'motdepasse1')).toEqual(LEA);
    expect(authentifier(relu, COURRIEL_DEMO, MOT_DE_PASSE_DEMO)).toEqual(CLIENT_DEMO);
    expect(authentifier(lireComptes('{pas du json'), COURRIEL_DEMO, MOT_DE_PASSE_DEMO)).toEqual(CLIENT_DEMO);
    expect(Object.keys(lireComptes(JSON.stringify({ 'x@y.ca': { motDePasse: 1 } })))).toEqual([COURRIEL_DEMO]);
    expect(authentifier(lireComptes(null), COURRIEL_DEMO, MOT_DE_PASSE_DEMO)).toEqual(CLIENT_DEMO);
  });
});

describe('registre — profil', () => {
  it('valide prénom, nom et courriel', () => {
    expect(validerProfil({ prenom: '', nom: ' ', courriel: 'x' })).toEqual({
      prenom: 'Indiquez votre prénom.', nom: 'Indiquez votre nom.', courriel: 'Indiquez un courriel valide.',
    });
    expect(validerProfil({ prenom: 'Léa', nom: 'Roy', courriel: 'lea@exemple.ca' })).toEqual({});
  });

  it('modifie le profil et déplace le compte vers le nouveau courriel', () => {
    const r = modifierProfil(avecLea(), 'lea@exemple.ca', { prenom: ' Léa-Marie ', nom: 'Roy', courriel: 'LM@Exemple.ca' });
    if (!('comptes' in r)) throw new Error('erreurs inattendues');
    expect(r.client.prenom).toBe('Léa-Marie');
    expect(r.client.courriel).toBe('lm@exemple.ca');
    expect(authentifier(r.comptes, 'lm@exemple.ca', 'motdepasse1')?.prenom).toBe('Léa-Marie');
    expect(authentifier(r.comptes, 'lea@exemple.ca', 'motdepasse1')).toBeNull();
  });

  it('refuse un courriel déjà pris et un profil invalide', () => {
    expect(modifierProfil(avecLea(), 'lea@exemple.ca', { prenom: 'Léa', nom: 'Roy', courriel: COURRIEL_DEMO }))
      .toEqual({ erreurs: { courriel: 'Ce courriel est déjà utilisé.' } });
    expect(modifierProfil(avecLea(), 'lea@exemple.ca', { prenom: '', nom: 'Roy', courriel: 'lea@exemple.ca' }))
      .toEqual({ erreurs: { prenom: 'Indiquez votre prénom.' } });
    expect(modifierProfil(avecLea(), 'personne@exemple.ca', { prenom: 'A', nom: 'B', courriel: 'a@b.ca' }))
      .toEqual({ erreurs: { courriel: 'Compte introuvable.' } });
  });
});

describe('registre — mot de passe', () => {
  it('change le mot de passe quand l’actuel est bon', () => {
    const r = changerMotDePasse(avecLea(), 'lea@exemple.ca', 'motdepasse1', 'nouveau2026');
    if (!('comptes' in r)) throw new Error('erreurs inattendues');
    expect(authentifier(r.comptes, 'lea@exemple.ca', 'nouveau2026')).toEqual(LEA);
    expect(authentifier(r.comptes, 'lea@exemple.ca', 'motdepasse1')).toBeNull();
  });

  it('signale un mot de passe actuel faux et un nouveau trop faible', () => {
    expect(changerMotDePasse(avecLea(), 'lea@exemple.ca', 'faux', 'court')).toEqual({
      erreurs: { actuel: 'Mot de passe actuel incorrect.', nouveau: 'Au moins 8 caractères, dont un chiffre.' },
    });
    expect(changerMotDePasse(avecLea(), 'lea@exemple.ca', 'motdepasse1', 'sanschiffre')).toEqual({
      erreurs: { nouveau: 'Au moins 8 caractères, dont un chiffre.' },
    });
  });
});
__VICTO_FIN_7__
cat > 'tickets/tests/page-detail-commande.test.tsx' <<'__VICTO_FIN_8__'
import { render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import PageDetailCommande from '../src/app/compte/commandes/[numero]/page';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO, COMMANDES_DEMO, totauxCommande, type Commande } from '../src/lib/compte';
import { formatPrice } from '../src/lib/formatPrice';

const etat = vi.hoisted(() => ({ numero: 'VS-10482' }));
vi.mock('next/navigation', async (original) => ({
  ...(await original<typeof import('next/navigation')>()),
  useParams: () => ({ numero: etat.numero }),
}));

const poser = (numero: string, connecte = true) => {
  etat.numero = numero;
  if (connecte) window.localStorage.setItem(CLE_SESSION, JSON.stringify(CLIENT_DEMO));
  render(<SessionProvider><PageDetailCommande /></SessionProvider>);
};
const commande = (n: string) => COMMANDES_DEMO.find((c) => c.numero === n) as Commande;
const etats = () => screen.queryAllByTestId('etape').map((e: HTMLElement) => e.getAttribute('data-etat'));

beforeEach(() => window.localStorage.clear());

describe('détail d’une commande expédiée', () => {
  it('titre, date et retour à la liste', () => {
    poser('VS-10482');
    expect(screen.getByRole('heading', { level: 1, name: 'Commande VS-10482' })).toBeInTheDocument();
    expect(screen.getByText('Passée le 24 septembre 2026')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Toutes mes commandes' })).toHaveAttribute('href', '/compte/commandes');
  });

  it('montre le suivi en quatre étapes, dont trois faites, et le colis', () => {
    poser('VS-10482');
    expect(etats()).toEqual(['faite', 'faite', 'faite', 'a-venir']);
    expect(screen.getByTestId('detail-statut').textContent).toBe('Expédiée');
    expect(screen.getByTestId('suivi-colis').textContent).toBe('Postes Canada · n° de suivi 7302 1154 8890 4412');
  });

  it('liste les articles avec leur lien et calcule les taxes', () => {
    poser('VS-10482');
    const lignes = screen.getAllByTestId('ligne-commande');
    expect(lignes).toHaveLength(3);
    expect(within(lignes[0] as HTMLElement).getByRole('link', { name: 'Air Zoom Pegasus 41' })).toHaveAttribute('href', '/produits/air-zoom-pegasus-41');
    const t = totauxCommande(commande('VS-10482'));
    expect(screen.getByTestId('detail-sous-total').textContent).toBe(formatPrice(t.sousTotalCents));
    expect(screen.getByTestId('detail-tps').textContent).toBe(formatPrice(t.tpsCents));
    expect(screen.getByTestId('detail-tvq').textContent).toBe(formatPrice(t.tvqCents));
    expect(screen.getByTestId('detail-total').textContent).toBe(formatPrice(t.totalCents));
  });

  it('rappelle l’adresse et le paiement', () => {
    poser('VS-10482');
    const livraison = screen.getByTestId('detail-livraison');
    expect(livraison.textContent).toContain('4520, rue Saint-Denis, app. 3');
    expect(livraison.textContent).toContain('Visa se terminant par 4242');
  });
});

describe('autres cas', () => {
  it('signale une commande annulée, sans étapes', () => {
    poser('VS-10291');
    expect(screen.getByTestId('commande-annulee')).toBeInTheDocument();
    expect(etats()).toEqual([]);
    expect(screen.queryByTestId('suivi-colis')).toBeNull();
  });

  it('suit une commande livrée jusqu’au bout, à l’adresse du bureau', () => {
    poser('VS-10360');
    expect(etats()).toEqual(['faite', 'faite', 'faite', 'faite']);
    expect(screen.getByTestId('detail-livraison').textContent).toContain('1000, rue De La Gauchetière O., 12e étage');
  });

  it('dit qu’une commande inconnue est introuvable', () => {
    poser('VS-99999');
    expect(screen.getByRole('heading', { level: 1, name: 'Commande introuvable' })).toBeInTheDocument();
    expect(screen.getByTestId('commande-introuvable').textContent).toBe('Aucune commande VS-99999 dans votre compte.');
  });

  it('invite à se connecter sans session', () => {
    poser('VS-10482', false);
    expect(screen.getByTestId('compte-invitation')).toBeInTheDocument();
  });
});
__VICTO_FIN_8__
cat > 'tickets/tests/page-informations.test.tsx' <<'__VICTO_FIN_9__'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PageInformations from '../src/app/compte/informations/page';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO, COURRIEL_DEMO, MOT_DE_PASSE_DEMO } from '../src/lib/compte';
import { CLE_COMPTES, authentifier, lireComptes } from '../src/lib/comptes-locaux';

const poser = () => {
  window.localStorage.setItem(CLE_SESSION, JSON.stringify(CLIENT_DEMO));
  render(<SessionProvider><PageInformations /></SessionProvider>);
};
const formulaire = (nom: string) => screen.getByRole('form', { name: nom });
const saisir = (libelle: string, valeur: string) => fireEvent.change(screen.getByLabelText(libelle), { target: { value: valeur } });
const registre = () => lireComptes(window.localStorage.getItem(CLE_COMPTES));

beforeEach(() => window.localStorage.clear());

describe('informations personnelles — profil', () => {
  it('préremplit le profil du client', () => {
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Informations personnelles' })).toBeInTheDocument();
    expect(screen.getByLabelText('Prénom')).toHaveValue('Camille');
    expect(screen.getByLabelText('Nom')).toHaveValue('Tremblay');
    expect(screen.getByLabelText('Courriel')).toHaveValue(COURRIEL_DEMO);
    expect(screen.getByRole('link', { name: 'Informations personnelles' })).toHaveAttribute('aria-current', 'page');
  });

  it('enregistre un nouveau nom et le confirme', () => {
    poser();
    saisir('Nom', 'Gagnon');
    fireEvent.click(within(formulaire('Profil')).getByRole('button', { name: 'Enregistrer' }));
    expect(within(formulaire('Profil')).getByRole('status').textContent).toBe('Vos informations sont enregistrées.');
    expect(window.localStorage.getItem(CLE_SESSION)).toContain('Gagnon');
    expect(authentifier(registre(), COURRIEL_DEMO, MOT_DE_PASSE_DEMO)?.nom).toBe('Gagnon');
  });

  it('signale un courriel invalide sans enregistrer', () => {
    poser();
    saisir('Courriel', 'pas un courriel');
    fireEvent.click(within(formulaire('Profil')).getByRole('button', { name: 'Enregistrer' }));
    expect(screen.getByText('Indiquez un courriel valide.')).toBeInTheDocument();
    expect(screen.getByLabelText('Courriel')).toHaveAttribute('aria-invalid', 'true');
    expect(within(formulaire('Profil')).queryByRole('status')).toBeNull();
  });
});

describe('informations personnelles — mot de passe', () => {
  it('refuse un mot de passe actuel faux', () => {
    poser();
    saisir('Mot de passe actuel', 'faux');
    saisir('Nouveau mot de passe', 'nouveau2026');
    fireEvent.click(screen.getByRole('button', { name: 'Changer le mot de passe' }));
    expect(screen.getByText('Mot de passe actuel incorrect.')).toBeInTheDocument();
    expect(within(formulaire('Mot de passe')).queryByRole('status')).toBeNull();
  });

  it('change le mot de passe, vide les champs et confirme', () => {
    poser();
    saisir('Mot de passe actuel', MOT_DE_PASSE_DEMO);
    saisir('Nouveau mot de passe', 'nouveau2026');
    fireEvent.click(screen.getByRole('button', { name: 'Changer le mot de passe' }));
    expect(within(formulaire('Mot de passe')).getByRole('status').textContent).toBe('Mot de passe modifié.');
    expect(screen.getByLabelText('Mot de passe actuel')).toHaveValue('');
    expect(authentifier(registre(), COURRIEL_DEMO, 'nouveau2026')).not.toBeNull();
    expect(authentifier(registre(), COURRIEL_DEMO, MOT_DE_PASSE_DEMO)).toBeNull();
  });
});

describe('informations personnelles — sans session', () => {
  it('invite à se connecter', () => {
    render(<SessionProvider><PageInformations /></SessionProvider>);
    expect(screen.getByTestId('compte-invitation')).toBeInTheDocument();
  });
});
__VICTO_FIN_9__
cat > 'tickets/tests/session-comptes.test.tsx' <<'__VICTO_FIN_10__'
import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { SessionProvider, useSession } from '../src/components/compte/SessionProvider';
import { COURRIEL_DEMO, MOT_DE_PASSE_DEMO } from '../src/lib/compte';
import { CLE_COMPTES, authentifier, lireComptes } from '../src/lib/comptes-locaux';

let retour: unknown = null;
function Temoin() {
  const s = useSession();
  return (
    <div>
      <span data-testid="client">{s.client ? `${s.client.prenom} ${s.client.nom} <${s.client.courriel}>` : 'aucun'}</span>
      <button type="button" onClick={() => { retour = s.connecter(COURRIEL_DEMO, MOT_DE_PASSE_DEMO); }}>demo</button>
      <button type="button" onClick={() => { retour = s.connecter(COURRIEL_DEMO, 'nouveau2026'); }}>demo-nouveau</button>
      <button type="button" onClick={() => { retour = s.connecter('lea@exemple.ca', 'motdepasse1'); }}>lea</button>
      <button type="button" onClick={() => s.inscrire({ prenom: 'Léa', nom: 'Roy', courriel: 'lea@exemple.ca', motDePasse: 'motdepasse1' })}>inscrire</button>
      <button type="button" onClick={() => s.deconnecter()}>sortir</button>
      <button type="button" onClick={() => { retour = s.modifierProfil({ prenom: 'Camille', nom: 'Gagnon', courriel: COURRIEL_DEMO }); }}>profil</button>
      <button type="button" onClick={() => { retour = s.modifierProfil({ prenom: '', nom: 'Gagnon', courriel: COURRIEL_DEMO }); }}>profil-faux</button>
      <button type="button" onClick={() => { retour = s.changerMotDePasse(MOT_DE_PASSE_DEMO, 'nouveau2026'); }}>mdp</button>
      <button type="button" onClick={() => { retour = s.changerMotDePasse('faux', 'nouveau2026'); }}>mdp-faux</button>
    </div>
  );
}
const cliquer = (n: string) => fireEvent.click(screen.getByRole('button', { name: n }));
const client = () => screen.getByTestId('client').textContent;
const registre = () => lireComptes(window.localStorage.getItem(CLE_COMPTES));

beforeEach(() => { window.localStorage.clear(); retour = null; });

describe('session — comptes gardés', () => {
  it('retrouve un compte créé à l’inscription après déconnexion', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('inscrire');
    cliquer('sortir');
    expect(client()).toBe('aucun');
    cliquer('lea');
    expect(retour).toBe(true);
    expect(client()).toBe('Léa Roy <lea@exemple.ca>');
  });

  it('relit le registre au montage', () => {
    const { unmount } = render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('inscrire');
    unmount();
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('sortir');
    cliquer('lea');
    expect(retour).toBe(true);
  });
});

describe('session — modifier le profil', () => {
  it('enregistre le nouveau nom, dans la session et le registre', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('demo');
    cliquer('profil');
    expect(retour).toEqual({});
    expect(client()).toBe(`Camille Gagnon <${COURRIEL_DEMO}>`);
    expect(authentifier(registre(), COURRIEL_DEMO, MOT_DE_PASSE_DEMO)?.nom).toBe('Gagnon');
  });

  it('renvoie les erreurs sans rien changer', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('demo');
    cliquer('profil-faux');
    expect(retour).toEqual({ prenom: 'Indiquez votre prénom.' });
    expect(client()).toBe(`Camille Tremblay <${COURRIEL_DEMO}>`);
  });
});

describe('session — changer le mot de passe', () => {
  it('permet de se reconnecter avec le nouveau mot de passe seulement', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('demo');
    cliquer('mdp-faux');
    expect(retour).toEqual({ actuel: 'Mot de passe actuel incorrect.' });
    cliquer('mdp');
    expect(retour).toEqual({});
    cliquer('sortir');
    cliquer('demo');
    expect(retour).toBe(false);
    cliquer('demo-nouveau');
    expect(retour).toBe(true);
  });

  it('refuse sans session', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('mdp');
    expect(retour).toEqual({ actuel: 'Connectez-vous pour changer votre mot de passe.' });
  });
});
__VICTO_FIN_10__
TESTS=(carte-commande-lien.test.tsx comptes-locaux.test.ts page-detail-commande.test.tsx page-informations.test.tsx session-comptes.test.tsx)
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
ok "5 specs, 5 tests en attente et le manifeste écrits"

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/103*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-103.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
import os, re, sys
ctx = 16384
try:
    m = re.search(r'num_ctx"?:\s*(\d+)', open('.aider.model.settings.yml').read()); ctx = int(m.group(1)) if m else ctx
except OSError: pass
plafond, ko = ctx * 90 // 100, False
for ligne in open(sys.argv[1]):
    c = (ligne.rstrip('\n').split('\t') + [''] * 7)[:7]
    tid, cible, test, spec, contexte, _, mode = c
    car = len(open(spec).read()) + len(open('tickets/tests/' + os.path.basename(test)).read())
    for f in filter(None, contexte.split(',')):
        car += len(open(f).read()) if os.path.isfile(f) else 3000
    existe = os.path.isfile(cible)
    if mode != 'neuf' and existe: car += len(open(cible).read())
    n = re.search(r'Taille attendue : ~?(\d+) lignes', open(spec).read())
    sortie = int(n.group(1)) * 40 // 3 if n else (len(open(cible).read()) * 11 // 30 if existe else 0)
    total = car // 3 + 2000 + sortie
    ko |= total > plafond
    print(f"  {'✓' if total <= plafond else '✗'} budget {tid} : ≈ {total} jetons / plafond {plafond}")
sys.exit(1 if ko else 0)
PYB
ok "contrôle : 0 alerte ; budgets dans le plafond"

# ------------------------------------------------------------ pré-vol de chaque test
MAUVAIS='TypeError|ReferenceError|SyntaxError|Transform failed|is not a function|Cannot read propert|is not defined'
mkdir -p tests   # git rm peut avoir retiré le dossier devenu vide
for t in "${TESTS[@]}"; do
  p="tests/zz-prevol-$t"; cp "tickets/tests/$t" "$p"
  npx --no-install vitest run "$p" > /tmp/victo-prevol.log 2>&1 || true
  rm -f "$p"; sed -i -E 's/\x1b\[[0-9;]*m//g' /tmp/victo-prevol.log
  if grep -qE "$MAUVAIS" /tmp/victo-prevol.log; then
    grep -nE "$MAUVAIS" /tmp/victo-prevol.log | head -4; annuler "pré-vol de $t : le test PLANTE — c'est le test qui est faux"
  elif grep -qE "Failed to resolve import|Cannot find module|Does the file exist" /tmp/victo-prevol.log; then
    ok "pré-vol $t : module à créer, pas encore exécutable (normal)"
  elif grep -qE "Tests +[0-9]+ (failed|passed)" /tmp/victo-prevol.log; then
    ok "pré-vol $t : $(grep -oE 'Tests +[0-9]+ (failed|passed)[^(]*' /tmp/victo-prevol.log | head -1 | tr -s ' '), sans plantage"
  else
    tail -12 /tmp/victo-prevol.log; annuler "pré-vol de $t : résultat illisible"
  fi
done

# ------------------------------------------------------------ base verte, commit
npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head; annuler "tsc rouge"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges"; }
ok "base verte"
git add -A -- tickets tests
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "chore(tickets): lot 103 — comptes, informations personnelles, détail des commandes"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-103.tsv ./run.sh\n\nCinq tickets : 103a → 103b → 103c ; 103d et 103e en parallèle. Compte une heure et demie.\n'
