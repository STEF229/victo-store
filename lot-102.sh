#!/usr/bin/env bash
# VICTO STORE — lot 102 : espace client, première partie (données de démonstration).
#   102a lib/compte.ts   102b compte-affichage.ts   102c SessionProvider   102d layout (session)
#   102e MenuCompte      102f EspaceClient          102g CarteCommande
#   102h /connexion      102i /inscription          102j /mot-de-passe-oublie
#   102k /compte         102l /compte/commandes     102m généré s'il le faut : « Mon compte » → lien /compte
# Anciens tests assouplis à l'installation (layout, « Mon compte »), pour accepter avant ET après le lot.
# Usage :  cd ~/victo-store && bash lot-102.sh
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
for d in 098a 098b 098c 099b 100a 100b 095a; do fusionne "$d" || mort "$d n'est pas fusionné"; done
grep -qF '<PanierProvider>{children}</PanierProvider>' src/app/layout.tsx || mort "layout.tsx : <PanierProvider>{children}</PanierProvider> introuvable (spec 102d)"
grep -q "export function libelleArticles" src/lib/panier-detail.ts || mort "libelleArticles absent de panier-detail.ts"
grep -q "export const PILULE " src/components/catalogue/filtres-affichage.ts || mort "PILULE absent de filtres-affichage.ts"
grep -q 'aria-label="Mon compte"' src/components/ui/SiteHeader.tsx || mort "SiteHeader : élément « Mon compte » introuvable"
for f in src/lib/compte.ts src/components/compte src/app/connexion src/app/inscription src/app/mot-de-passe-oublie src/app/compte; do
  [ ! -e "$f" ] || mort "$f existe déjà : lot déjà passé ?"; done
for j in noir blanc surface ligne gris accent promo; do grep -qE -- "--vs-$j\s*:" src/styles/tokens.css || mort "jeton --vs-$j absent"; done
ICONES="$(node -e "
const l = require('lucide-react');
const voulues = ['Package','Heart','MapPin','User','LogOut','Eye','EyeOff','Gift','Mail','ArrowLeft'];
const manquent = voulues.filter((n) => !l[n]);
if (manquent.length) { console.log('MANQUE ' + manquent.join(' ')); process.exit(0); }
console.log(l.House ? 'House' : (l.Home ? 'Home' : 'MANQUE House'));" 2>/dev/null || echo "MANQUE lucide-react")"
case "$ICONES" in MANQUE*) mort "icônes lucide absentes de ta version : ${ICONES#MANQUE }" ;; esac
ok "fusions, layout, en-tête, jetons et icônes lucide conformes aux specs (maison : $ICONES)"

# L'environnement : imitation partielle de next/navigation et dates en français sous vitest.
cat > tests/zz-prevol-env.test.ts <<'__ENV__'
import { expect, it, vi } from 'vitest';
const { pousser } = vi.hoisted(() => ({ pousser: vi.fn() }));
vi.mock('next/navigation', async (original) => ({
  ...(await original<typeof import('next/navigation')>()),
  useRouter: () => ({ push: pousser }),
}));
import { usePathname, useRouter } from 'next/navigation';
it('imitation partielle du routeur et dates en français', () => {
  useRouter().push('/compte');
  expect(pousser).toHaveBeenCalledWith('/compte');
  expect(typeof usePathname).toBe('function');
  expect(new Intl.DateTimeFormat('fr-CA', { day: 'numeric', month: 'long', year: 'numeric', timeZone: 'UTC' }).format(new Date('2026-09-24'))).toBe('24 septembre 2026');
});
__ENV__
npx --no-install vitest run tests/zz-prevol-env.test.ts > /tmp/victo-prevol.log 2>&1 || true
rm -f tests/zz-prevol-env.test.ts; sed -i -E 's/\x1b\[[0-9;]*m//g' /tmp/victo-prevol.log
grep -qE "Tests +1 passed" /tmp/victo-prevol.log || { tail -12 /tmp/victo-prevol.log; mort "l'environnement de test ne permet pas l'imitation du routeur ou les dates en français"; }
ok "environnement : imitation du routeur et dates en français fonctionnent sous vitest"

trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
mkdir -p tickets/tests
cat > 'tickets/102a-compte.md' <<'__VICTO_FIN_0__'
TICKET 102a — compte : types, données de démonstration, validations, totaux

Crée `src/lib/compte.ts`. Fonctions **pures** ; données de démonstration en
attendant Medusa (le vrai branchement ne changera que ce fichier).

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index
  (`tableau[i]`) ; utilise `.find`, `.filter`, `.reduce`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier. Aucun import.
- Recopie les données de démonstration **exactement**.

## Types et données
Taille attendue : ~140 lignes.
```ts
export type StatutCommande = 'preparation' | 'expediee' | 'livree' | 'annulee';
export type FiltreCommandes = 'toutes' | 'en-cours' | 'livrees' | 'annulees';

export interface Adresse {
  id: string;
  libelle: string;
  nomComplet: string;
  ligne1: string;
  ville: string;
  province: string;
  codePostal: string;
  telephone: string;
  parDefaut: boolean;
}
export interface Client {
  prenom: string;
  nom: string;
  courriel: string;
  membreDepuis: string;
  adresses: Adresse[];
}
export interface LigneCommande {
  slug: string;
  nom: string;
  marque: string;
  taille: string;
  quantite: number;
  prixCents: number;
  economieCents: number;
}
export interface Commande {
  numero: string;
  date: string;
  statut: StatutCommande;
  lignes: LigneCommande[];
  adresseId: string;
  paiement: string;
  suivi: string | null;
}
export interface DonneesInscription {
  prenom: string;
  nom: string;
  courriel: string;
  motDePasse: string;
}
export type ErreursInscription = Partial<Record<keyof DonneesInscription, string>>;
export interface TotauxCommande {
  articles: number;
  sousTotalCents: number;
  economiesCents: number;
  tpsCents: number;
  tvqCents: number;
  totalCents: number;
}

export const COURRIEL_DEMO = 'camille.tremblay@exemple.ca';
export const MOT_DE_PASSE_DEMO = 'victo2026';

export const CLIENT_DEMO: Client = {
  prenom: 'Camille',
  nom: 'Tremblay',
  courriel: COURRIEL_DEMO,
  membreDepuis: '2026-03-12',
  adresses: [
    { id: 'domicile', libelle: 'Domicile', nomComplet: 'Camille Tremblay', ligne1: '4520, rue Saint-Denis, app. 3', ville: 'Montréal', province: 'QC', codePostal: 'H2J 2L3', telephone: '514 555-0142', parDefaut: true },
    { id: 'bureau', libelle: 'Bureau', nomComplet: 'Camille Tremblay', ligne1: '1000, rue De La Gauchetière O., 12e étage', ville: 'Montréal', province: 'QC', codePostal: 'H3B 4W5', telephone: '514 555-0188', parDefaut: false },
  ],
};

export const COMMANDES_DEMO: Commande[] = [
  {
    numero: 'VS-10482', date: '2026-09-24', statut: 'expediee', adresseId: 'domicile',
    paiement: 'Visa se terminant par 4242', suivi: '7302 1154 8890 4412',
    lignes: [
      { slug: 'air-zoom-pegasus-41', nom: 'Air Zoom Pegasus 41', marque: 'Nike', taille: '41', quantite: 1, prixCents: 12900, economieCents: 3000 },
      { slug: 'polo-shirt', nom: 'Polo Shirt', marque: 'Lacoste', taille: 'M', quantite: 1, prixCents: 5900, economieCents: 2000 },
      { slug: 'chuck-taylor-all-star', nom: 'Chuck Taylor All Star', marque: 'Converse', taille: '39', quantite: 1, prixCents: 8900, economieCents: 0 },
    ],
  },
  {
    numero: 'VS-10417', date: '2026-09-02', statut: 'livree', adresseId: 'domicile',
    paiement: 'Visa se terminant par 4242', suivi: '7302 1154 8871 0935',
    lignes: [
      { slug: 'ultra-boost-22', nom: 'Ultra Boost 22', marque: 'Adidas', taille: '42', quantite: 1, prixCents: 18900, economieCents: 3000 },
    ],
  },
  {
    numero: 'VS-10360', date: '2026-08-18', statut: 'livree', adresseId: 'bureau',
    paiement: 'Mastercard se terminant par 8210', suivi: '7302 1154 8702 3318',
    lignes: [
      { slug: 'chuck-taylor-all-star', nom: 'Chuck Taylor All Star', marque: 'Converse', taille: '38', quantite: 2, prixCents: 8900, economieCents: 0 },
    ],
  },
  {
    numero: 'VS-10291', date: '2026-07-30', statut: 'annulee', adresseId: 'domicile',
    paiement: 'Visa se terminant par 4242', suivi: null,
    lignes: [
      { slug: 'polo-shirt', nom: 'Polo Shirt', marque: 'Lacoste', taille: 'L', quantite: 1, prixCents: 5900, economieCents: 2000 },
    ],
  },
];
```

## Fonctions
```ts
export function courrielValide(courriel: string): boolean;
export function verifierConnexion(courriel: string, motDePasse: string): boolean;
export function validerInscription(donnees: DonneesInscription): ErreursInscription;
export function commandesDe(client: Client): Commande[];
export function filtrerCommandes(commandes: Commande[], filtre: FiltreCommandes): Commande[];
export function totauxCommande(commande: Commande): TotauxCommande;
export function formaterDate(iso: string): string;
export function formaterMois(iso: string): string;
export function libelleCommandes(n: number): string;
```
- **`courrielValide`** : `/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(courriel.trim())`.
- **`verifierConnexion`** : vrai si `courriel.trim().toLowerCase() === COURRIEL_DEMO`
  et `motDePasse === MOT_DE_PASSE_DEMO`.
- **`validerInscription`** : part d'un objet vide `const erreurs: ErreursInscription = {};`
  et ajoute, dans cet ordre, seulement les erreurs présentes :
  `prenom` vide après `.trim()` → `'Indiquez votre prénom.'` ;
  `nom` vide après `.trim()` → `'Indiquez votre nom.'` ;
  `!courrielValide(courriel)` → `'Indiquez un courriel valide.'` ;
  `motDePasse.length < 8 || !/\d/.test(motDePasse)` → `'Au moins 8 caractères, dont un chiffre.'`.
  Renvoie `erreurs` (objet vide si tout est bon).
- **`commandesDe`** : `COMMANDES_DEMO` si `client.courriel === COURRIEL_DEMO`, sinon `[]`.
- **`filtrerCommandes`** (nouveau tableau, ordre conservé) : `'toutes'` → toutes ;
  `'en-cours'` → statut `'preparation'` ou `'expediee'` ; `'livrees'` → `'livree'` ;
  `'annulees'` → `'annulee'`.
- **`totauxCommande`** : `articles` = somme des quantités ; `sousTotalCents` = somme
  de `prixCents * quantite` ; `economiesCents` = somme de `economieCents * quantite` ;
  `tpsCents = Math.round(sousTotalCents * 0.05)` ;
  `tvqCents = Math.round(sousTotalCents * 0.09975)` (taxes non composées) ;
  `totalCents = sousTotalCents + tpsCents + tvqCents`.
- **`formaterDate`** : `new Intl.DateTimeFormat('fr-CA', { day: 'numeric', month: 'long', year: 'numeric', timeZone: 'UTC' }).format(new Date(iso))`
  (donne par exemple `24 septembre 2026`).
- **`formaterMois`** : même chose avec `{ month: 'long', year: 'numeric', timeZone: 'UTC' }`
  (donne `mars 2026`).
- **`libelleCommandes`** renvoie exactement `` `${n} ${n > 1 ? 'commandes' : 'commande'}` ``.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_0__
cat > 'tickets/102b-compte-affichage.md' <<'__VICTO_FIN_1__'
TICKET 102b — constantes d'affichage du compte

Crée `src/components/compte/compte-affichage.ts` avec **exactement** le contenu
ci-dessous. Ces chaînes viennent des maquettes validées.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Recopie chaque chaîne telle quelle.

## Contenu du fichier
Taille attendue : ~30 lignes.
```ts
import type { StatutCommande } from '@/lib/compte';

export const TITRE_PAGE = 'text-[40px] font-black leading-none tracking-tight text-[var(--vs-noir)] lg:text-[52px]';
export const SOUS_TITRE = 'text-base text-[var(--vs-gris)]';
export const CHAMP = 'flex flex-col gap-2';
export const CHAMP_LIBELLE = 'text-sm font-bold text-[var(--vs-noir)]';
export const CHAMP_SAISIE = 'h-[54px] w-full rounded-[14px] border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-[18px] text-base text-[var(--vs-noir)]';
export const CHAMP_SAISIE_ERREUR = 'h-[54px] w-full rounded-[14px] border-[1.5px] border-[var(--vs-promo)] bg-[var(--vs-blanc)] px-[18px] text-base text-[var(--vs-noir)]';
export const CHAMP_AIDE = 'text-[13px] text-[var(--vs-gris)]';
export const CHAMP_ERREUR = 'text-[13px] font-bold text-[var(--vs-promo)]';
export const BOUTON_PRINCIPAL = 'flex h-14 w-full items-center justify-center rounded-full bg-[var(--vs-accent)] px-7 text-base font-extrabold text-[var(--vs-blanc)]';
export const BOUTON_SECONDAIRE = 'flex h-14 w-full items-center justify-center rounded-full border-[1.5px] border-[var(--vs-noir)] bg-[var(--vs-blanc)] px-7 text-base font-extrabold text-[var(--vs-noir)]';
export const LIEN = 'text-sm font-bold text-[var(--vs-noir)] underline';
export const CARTE = 'flex flex-col gap-3.5 rounded-3xl border-[1.5px] border-[var(--vs-ligne)] p-[26px]';
export const MENU_LIEN = 'flex h-[50px] items-center gap-3 rounded-full px-[18px] text-[15px] font-semibold text-[var(--vs-noir)]';
export const MENU_LIEN_ACTIF = 'flex h-[50px] items-center gap-3 rounded-full bg-[var(--vs-noir)] px-[18px] text-[15px] font-bold text-[var(--vs-blanc)]';

export const CLASSES_STATUT: Record<StatutCommande, string> = {
  preparation: 'whitespace-nowrap rounded-full bg-[#E9E4DA] px-3 py-1.5 text-[13px] font-extrabold text-[var(--vs-noir)]',
  expediee: 'whitespace-nowrap rounded-full bg-[#EEF1F8] px-3 py-1.5 text-[13px] font-extrabold text-[var(--vs-accent)]',
  livree: 'whitespace-nowrap rounded-full bg-[#F0F0EE] px-3 py-1.5 text-[13px] font-extrabold text-[var(--vs-noir)]',
  annulee: 'whitespace-nowrap rounded-full bg-[#FFD3DB] px-3 py-1.5 text-[13px] font-extrabold text-[#C70026]',
};
export const LIBELLES_STATUT: Record<StatutCommande, string> = {
  preparation: 'En préparation',
  expediee: 'Expédiée',
  livree: 'Livrée',
  annulee: 'Annulée',
};
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > 'tickets/102c-session.md' <<'__VICTO_FIN_2__'
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
__VICTO_FIN_2__
cat > 'tickets/102d-layout-session.md' <<'__VICTO_FIN_3__'
TICKET 102d — session autour de tout le site

Modifie `src/app/layout.tsx`. Deux changements, rien d'autre : ni les métadonnées,
ni `<head>`, ni les attributs de `<html>` ne bougent.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Le fichier reste un composant serveur : **pas** de `'use client'`.

## Les deux changements
1. Ajoute, à la suite des imports existants :
   ```tsx
   import { SessionProvider } from '@/components/compte/SessionProvider';
   ```
2. Remplace exactement `<PanierProvider>{children}</PanierProvider>` par
   ```tsx
   <PanierProvider>
     <SessionProvider>{children}</SessionProvider>
   </PanierProvider>
   ```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/layout-panier.test.ts`.
__VICTO_FIN_3__
cat > 'tickets/102e-menu-compte.md' <<'__VICTO_FIN_4__'
TICKET 102e — menu de l'espace client

Crée `src/components/compte/MenuCompte.tsx`, avec l'export de type `EntreeCompte`
et le composant `MenuCompte`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Icônes `lucide-react` avec `aria-hidden`.

## Bloc d'imports exact
```tsx
'use client';

import { Heart, House, LogOut, MapPin, Package, User } from 'lucide-react';
import Link from 'next/link';
import { MENU_LIEN, MENU_LIEN_ACTIF } from '@/components/compte/compte-affichage';
import { useSession } from '@/components/compte/SessionProvider';
```

## Contenu
Taille attendue : ~50 lignes.
```tsx
export type EntreeCompte = 'tableau' | 'commandes' | 'favoris' | 'adresses' | 'informations';

const ENTREES = [
  { cle: 'tableau', libelle: 'Tableau de bord', href: '/compte', Icone: House },
  { cle: 'commandes', libelle: 'Mes commandes', href: '/compte/commandes', Icone: Package },
  { cle: 'favoris', libelle: 'Favoris', href: '/compte/favoris', Icone: Heart },
  { cle: 'adresses', libelle: 'Adresses', href: '/compte/adresses', Icone: MapPin },
  { cle: 'informations', libelle: 'Informations personnelles', href: '/compte/informations', Icone: User },
] as const;
```
`export function MenuCompte({ actif }: { actif: EntreeCompte })` :
- `const session = useSession();`
- rend `<nav aria-label="Espace client" data-testid="menu-compte" className="flex flex-col gap-1">`
  contenant, pour chaque entrée `e` (`ENTREES.map((e) => …)`, `key={e.cle}`) :
  ```tsx
  <Link href={e.href} aria-current={e.cle === actif ? 'page' : undefined}
    className={e.cle === actif ? MENU_LIEN_ACTIF : MENU_LIEN}>
    <e.Icone aria-hidden size={19} />
    {e.libelle}
  </Link>
  ```
- puis `<div className="my-3 h-px bg-[var(--vs-ligne)]" />`
- puis
  ```tsx
  <button type="button" onClick={() => session.deconnecter()}
    className="flex h-[50px] items-center gap-3 rounded-full px-[18px] text-[15px] font-semibold text-[var(--vs-gris)]">
    <LogOut aria-hidden size={19} />
    Se déconnecter
  </button>
  ```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_4__
cat > 'tickets/102f-espace-client.md' <<'__VICTO_FIN_5__'
TICKET 102f — espace client protégé

Crée `src/components/compte/EspaceClient.tsx`, export nommé `EspaceClient`. Il
affiche le menu et le contenu à un client connecté, et invite les autres à se
connecter.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.

## Bloc d'imports exact
```tsx
'use client';

import Link from 'next/link';
import type { ReactNode } from 'react';
import { BOUTON_PRINCIPAL, BOUTON_SECONDAIRE, SOUS_TITRE } from '@/components/compte/compte-affichage';
import { MenuCompte, type EntreeCompte } from '@/components/compte/MenuCompte';
import { useSession } from '@/components/compte/SessionProvider';
```

## Rendu
Taille attendue : ~40 lignes.

`export function EspaceClient({ actif, children }: { actif: EntreeCompte; children: ReactNode })` :
1. `const session = useSession();`
2. si `!session.pret` : `<div data-testid="compte-chargement" aria-busy="true" className="min-h-[320px]" />`
3. si `session.client === null` :
```tsx
<div data-testid="compte-invitation" className="mx-auto flex max-w-[520px] flex-col items-center gap-5 py-20 text-center">
  <h2 className="text-3xl font-black tracking-tight text-[var(--vs-noir)]">Connectez-vous pour accéder à votre compte</h2>
  <p className={SOUS_TITRE}>Suivez vos commandes, gérez vos adresses et retrouvez vos favoris.</p>
  <div className="flex w-full flex-col gap-3 sm:flex-row">
    <Link href="/connexion" className={BOUTON_PRINCIPAL}>Se connecter</Link>
    <Link href="/inscription" className={BOUTON_SECONDAIRE}>Créer un compte</Link>
  </div>
</div>
```
4. sinon :
```tsx
<div data-testid="espace-client" className="grid gap-10 lg:grid-cols-[280px_minmax(0,1fr)] lg:items-start lg:gap-14">
  <MenuCompte actif={actif} />
  <div className="flex min-w-0 flex-col gap-7">{children}</div>
</div>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_5__
cat > 'tickets/102g-carte-commande.md' <<'__VICTO_FIN_6__'
TICKET 102g — carte d'une commande

Crée `src/components/compte/CarteCommande.tsx`, export nommé `CarteCommande`.
Composant **sans état**.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index sur un
  tableau ; utilise `.map`. (Lire `CLASSES_STATUT[commande.statut]` est permis :
  c'est un `Record` dont la clé est le type exact du statut.)
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.

## Bloc d'imports exact
```tsx
import { CARTE, CLASSES_STATUT, LIBELLES_STATUT } from '@/components/compte/compte-affichage';
import { formaterDate, totauxCommande, type Commande } from '@/lib/compte';
import { formatPrice } from '@/lib/formatPrice';
import { libelleArticles } from '@/lib/panier-detail';
```

## Rendu
Taille attendue : ~35 lignes.

`export function CarteCommande({ commande }: { commande: Commande })`, avec
`const totaux = totauxCommande(commande);`, rend :
```tsx
<article data-testid="carte-commande" className={CARTE}>
  <div className="flex items-start justify-between gap-4">
    <div className="flex flex-col gap-1">
      <h3 className="text-[17px] font-extrabold text-[var(--vs-noir)]">{`Commande ${commande.numero}`}</h3>
      <p data-testid="commande-resume" className="text-sm text-[var(--vs-gris)]">
        {`${formaterDate(commande.date)} · ${libelleArticles(totaux.articles)} · ${formatPrice(totaux.totalCents)}`}
      </p>
    </div>
    <span data-testid="commande-statut" className={CLASSES_STATUT[commande.statut]}>
      {LIBELLES_STATUT[commande.statut]}
    </span>
  </div>
  <ul className="flex flex-wrap gap-2">
    {commande.lignes.map((l) => (
      <li key={`${l.slug}-${l.taille}`} className="rounded-full bg-[var(--vs-surface)] px-3 py-1.5 text-[13px] text-[var(--vs-noir)]">
        {`${l.marque} ${l.nom} · ${l.taille}${l.quantite > 1 ? ` × ${l.quantite}` : ''}`}
      </li>
    ))}
  </ul>
</article>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_6__
cat > 'tickets/102h-page-connexion.md' <<'__VICTO_FIN_7__'
TICKET 102h — page de connexion

Crée `src/app/connexion/page.tsx`. Page **client** (`'use client'`), un seul
export : l'export par défaut `PageConnexion`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Aucun export nommé. Chaque `className` est écrit exactement comme ci-dessous.
- Icônes `lucide-react` avec `aria-hidden`. Apostrophes droites dans les textes.

## Bloc d'imports exact
```tsx
'use client';

import { Eye, EyeOff, Gift, Heart, Package } from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useState, type FormEvent } from 'react';
import {
  BOUTON_PRINCIPAL, BOUTON_SECONDAIRE, CHAMP, CHAMP_ERREUR, CHAMP_LIBELLE, CHAMP_SAISIE, LIEN, SOUS_TITRE, TITRE_PAGE,
} from '@/components/compte/compte-affichage';
import { useSession } from '@/components/compte/SessionProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { COURRIEL_DEMO, MOT_DE_PASSE_DEMO } from '@/lib/compte';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```

## Logique
Taille attendue : ~95 lignes.

Dans `export default function PageConnexion()` :
```tsx
const session = useSession();
const router = useRouter();
const [courriel, setCourriel] = useState('');
const [motDePasse, setMotDePasse] = useState('');
const [voir, setVoir] = useState(false);
const [erreur, setErreur] = useState(false);

function soumettre(e: FormEvent<HTMLFormElement>) {
  e.preventDefault();
  if (session.connecter(courriel, motDePasse)) {
    setErreur(false);
    router.push('/compte');
  } else {
    setErreur(true);
  }
}
```

## Rendu
```tsx
<>
  <SiteHeader navItems={NAV} />
  <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
    <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Connexion' }]} />
    <div className="grid gap-12 lg:grid-cols-2 lg:gap-16">
      <form onSubmit={soumettre} noValidate className="flex w-full max-w-[480px] flex-col gap-[22px]">
        <div className="flex flex-col gap-2.5">
          <h1 className={TITRE_PAGE}>Connexion</h1>
          <p className={SOUS_TITRE}>Heureux de vous revoir.</p>
        </div>
        <p data-testid="connexion-demo" className="rounded-2xl bg-[var(--vs-surface)] p-4 text-sm text-[var(--vs-noir)]">
          {`Compte de démonstration : ${COURRIEL_DEMO} — mot de passe ${MOT_DE_PASSE_DEMO}`}
        </p>
        <div className={CHAMP}>
          <label htmlFor="courriel" className={CHAMP_LIBELLE}>Courriel</label>
          <input id="courriel" type="email" autoComplete="email" value={courriel}
            onChange={(e) => setCourriel(e.target.value)} className={CHAMP_SAISIE} />
        </div>
        <div className={CHAMP}>
          <label htmlFor="mot-de-passe" className={CHAMP_LIBELLE}>Mot de passe</label>
          <div className="relative">
            <input id="mot-de-passe" type={voir ? 'text' : 'password'} autoComplete="current-password" value={motDePasse}
              onChange={(e) => setMotDePasse(e.target.value)} className={CHAMP_SAISIE} />
            <button type="button" aria-label={voir ? 'Masquer le mot de passe' : 'Afficher le mot de passe'}
              onClick={() => setVoir(!voir)}
              className="absolute right-2 top-[7px] flex h-10 w-10 items-center justify-center text-[var(--vs-gris)]">
              {voir ? <EyeOff aria-hidden size={19} /> : <Eye aria-hidden size={19} />}
            </button>
          </div>
        </div>
        {erreur && <p role="alert" className={CHAMP_ERREUR}>Courriel ou mot de passe incorrect.</p>}
        <div className="flex justify-end">
          <Link href="/mot-de-passe-oublie" className={LIEN}>Mot de passe oublié ?</Link>
        </div>
        <button type="submit" className={BOUTON_PRINCIPAL}>Se connecter</button>
        <Link href="/inscription" className={BOUTON_SECONDAIRE}>Créer un compte</Link>
      </form>
      <aside className="hidden flex-col gap-7 rounded-[28px] bg-[var(--vs-noir)] p-12 text-[var(--vs-blanc)] lg:flex">
        <h2 className="text-4xl font-black leading-tight tracking-tight">Tout votre shopping, au même endroit.</h2>
        <ul className="flex flex-col gap-5">
          <li className="flex items-start gap-3.5"><Package aria-hidden size={20} /><span><strong>Suivez vos commandes</strong>, de la préparation à la livraison.</span></li>
          <li className="flex items-start gap-3.5"><Heart aria-hidden size={20} /><span><strong>Gardez vos favoris</strong> sur tous vos appareils.</span></li>
          <li className="flex items-start gap-3.5"><Gift aria-hidden size={20} /><span><strong>−10 % sur la première commande</strong> avec l'infolettre.</span></li>
        </ul>
      </aside>
    </div>
  </main>
  <SiteFooter colonnes={COLONNES_PIED} />
</>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_7__
cat > 'tickets/102i-page-inscription.md' <<'__VICTO_FIN_8__'
TICKET 102i — page d'inscription

Crée `src/app/inscription/page.tsx`. Page **client** (`'use client'`), un seul
export : l'export par défaut `PageInscription`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Aucun export nommé. Chaque `className` est écrit exactement comme ci-dessous.
- Apostrophes droites dans les textes.

## Bloc d'imports exact
```tsx
'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useState, type FormEvent } from 'react';
import {
  BOUTON_PRINCIPAL, CHAMP, CHAMP_AIDE, CHAMP_ERREUR, CHAMP_LIBELLE, CHAMP_SAISIE, CHAMP_SAISIE_ERREUR, LIEN, SOUS_TITRE, TITRE_PAGE,
} from '@/components/compte/compte-affichage';
import { useSession } from '@/components/compte/SessionProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { validerInscription, type DonneesInscription, type ErreursInscription } from '@/lib/compte';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```

## Un champ — fonction locale, non exportée
Taille attendue : ~115 lignes.
```tsx
function Champ(props: {
  id: keyof DonneesInscription;
  libelle: string;
  type: string;
  valeur: string;
  auto: string;
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

## La page
Dans `export default function PageInscription()` :
```tsx
const session = useSession();
const router = useRouter();
const [donnees, setDonnees] = useState<DonneesInscription>({ prenom: '', nom: '', courriel: '', motDePasse: '' });
const [erreurs, setErreurs] = useState<ErreursInscription>({});
const changer = (cle: keyof DonneesInscription) => (valeur: string) => setDonnees({ ...donnees, [cle]: valeur });

function soumettre(e: FormEvent<HTMLFormElement>) {
  e.preventDefault();
  const trouvees = validerInscription(donnees);
  setErreurs(trouvees);
  if (Object.keys(trouvees).length === 0) {
    session.inscrire(donnees);
    router.push('/compte');
  }
}
```
Rendu :
```tsx
<>
  <SiteHeader navItems={NAV} />
  <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
    <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Créer un compte' }]} />
    <form onSubmit={soumettre} noValidate className="mx-auto flex w-full max-w-[560px] flex-col gap-[22px]">
      <div className="flex flex-col gap-2.5">
        <h1 className={TITRE_PAGE}>Créer un compte</h1>
        <p className={SOUS_TITRE}>Suivez vos commandes et gardez vos favoris.</p>
      </div>
      <div className="grid gap-4 sm:grid-cols-2">
        <Champ id="prenom" libelle="Prénom" type="text" auto="given-name" valeur={donnees.prenom} erreur={erreurs.prenom} onChange={changer('prenom')} />
        <Champ id="nom" libelle="Nom" type="text" auto="family-name" valeur={donnees.nom} erreur={erreurs.nom} onChange={changer('nom')} />
      </div>
      <Champ id="courriel" libelle="Courriel" type="email" auto="email" valeur={donnees.courriel} erreur={erreurs.courriel} onChange={changer('courriel')} />
      <Champ id="motDePasse" libelle="Mot de passe" type="password" auto="new-password" valeur={donnees.motDePasse}
        erreur={erreurs.motDePasse} aide="8 caractères minimum, dont au moins un chiffre." onChange={changer('motDePasse')} />
      <label className="flex items-start gap-2.5 text-sm leading-relaxed">
        <input type="checkbox" defaultChecked className="mt-0.5 h-5 w-5 accent-[var(--vs-noir)]" />
        <span>Recevoir les arrivages et les ventes privées par courriel, et −10 % sur ma première commande.</span>
      </label>
      <p className="text-[13px] leading-relaxed text-[var(--vs-gris)]">
        En créant un compte, vous acceptez les conditions de vente et la politique de confidentialité.
      </p>
      <button type="submit" className={BOUTON_PRINCIPAL}>Créer mon compte</button>
      <p className="text-center text-[15px]">
        Déjà un compte ? <Link href="/connexion" className={LIEN}>Se connecter</Link>
      </p>
    </form>
  </main>
  <SiteFooter colonnes={COLONNES_PIED} />
</>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_8__
cat > 'tickets/102j-page-mot-de-passe.md' <<'__VICTO_FIN_9__'
TICKET 102j — page « mot de passe oublié »

Crée `src/app/mot-de-passe-oublie/page.tsx`. Page **client** (`'use client'`), un
seul export : l'export par défaut `PageMotDePasseOublie`. Démonstration : aucun
courriel n'est réellement envoyé.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Aucun export nommé. Chaque `className` est écrit exactement comme ci-dessous.
- Icônes `lucide-react` avec `aria-hidden`. Apostrophes droites dans les textes.

## Bloc d'imports exact
```tsx
'use client';

import { ArrowLeft, Mail } from 'lucide-react';
import Link from 'next/link';
import { useState, type FormEvent } from 'react';
import {
  BOUTON_PRINCIPAL, CARTE, CHAMP, CHAMP_ERREUR, CHAMP_LIBELLE, CHAMP_SAISIE, LIEN, SOUS_TITRE, TITRE_PAGE,
} from '@/components/compte/compte-affichage';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { courrielValide } from '@/lib/compte';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```

## Logique et rendu
Taille attendue : ~70 lignes.
```tsx
const [courriel, setCourriel] = useState('');
const [envoye, setEnvoye] = useState(false);
const [erreur, setErreur] = useState(false);

function soumettre(e: FormEvent<HTMLFormElement>) {
  e.preventDefault();
  if (courrielValide(courriel)) {
    setErreur(false);
    setEnvoye(true);
  } else {
    setErreur(true);
  }
}
```
Rendu :
```tsx
<>
  <SiteHeader navItems={NAV} />
  <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
    <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Connexion', href: '/connexion' }, { label: 'Mot de passe oublié' }]} />
    <div className="mx-auto flex w-full max-w-[560px] flex-col gap-6">
      <h1 className={TITRE_PAGE}>Mot de passe oublié</h1>
      {envoye ? (
        <section data-testid="lien-envoye" className={`${CARTE} bg-[var(--vs-surface)]`}>
          <Mail aria-hidden size={24} />
          <h2 className="text-2xl font-black text-[var(--vs-noir)]">Vérifiez votre boîte de réception</h2>
          <p className={SOUS_TITRE}>{`Si un compte existe pour ${courriel.trim()}, un lien vous attend. Il reste valide une heure.`}</p>
          <button type="button" onClick={() => setEnvoye(false)} className={`self-start ${LIEN}`}>Renvoyer le lien</button>
        </section>
      ) : (
        <form onSubmit={soumettre} noValidate className="flex flex-col gap-[22px]">
          <p className={SOUS_TITRE}>Indiquez le courriel de votre compte : nous vous envoyons un lien pour choisir un nouveau mot de passe.</p>
          <div className={CHAMP}>
            <label htmlFor="courriel" className={CHAMP_LIBELLE}>Courriel</label>
            <input id="courriel" type="email" autoComplete="email" value={courriel}
              onChange={(e) => setCourriel(e.target.value)} className={CHAMP_SAISIE} />
          </div>
          {erreur && <p role="alert" className={CHAMP_ERREUR}>Indiquez un courriel valide.</p>}
          <button type="submit" className={BOUTON_PRINCIPAL}>Envoyer le lien</button>
        </form>
      )}
      <Link href="/connexion" className="flex items-center gap-1.5 text-[15px] font-bold text-[var(--vs-noir)]">
        <ArrowLeft aria-hidden size={18} />
        Retour à la connexion
      </Link>
    </div>
  </main>
  <SiteFooter colonnes={COLONNES_PIED} />
</>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_9__
cat > 'tickets/102k-page-compte.md' <<'__VICTO_FIN_10__'
TICKET 102k — tableau de bord du compte

Crée `src/app/compte/page.tsx`. Page **client** (`'use client'`), un seul export :
l'export par défaut `PageCompte`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index. La
  dernière commande se lit par déstructuration : `const [derniere] = commandes;`
  (elle vaut alors `Commande | undefined`). Lire `CLASSES_STATUT[x.statut]` est permis.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Aucun export nommé. Chaque `className` est écrit exactement comme ci-dessous.
- Apostrophes droites dans les textes.

## Bloc d'imports exact
```tsx
'use client';

import Link from 'next/link';
import { CarteCommande } from '@/components/compte/CarteCommande';
import { CARTE, CLASSES_STATUT, LIBELLES_STATUT, LIEN, SOUS_TITRE, TITRE_PAGE } from '@/components/compte/compte-affichage';
import { EspaceClient } from '@/components/compte/EspaceClient';
import { useSession } from '@/components/compte/SessionProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { commandesDe, formaterDate, formaterMois, type Client } from '@/lib/compte';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```

## Le contenu — fonction locale, non exportée
Taille attendue : ~95 lignes.

`function Tableau({ client }: { client: Client })` avec
`const commandes = commandesDe(client);`, `const [derniere] = commandes;` et
`const adresse = client.adresses.find((a) => a.parDefaut);`, rend :
```tsx
<>
  <div className="flex flex-col gap-2.5">
    <h1 className={TITRE_PAGE}>{`Bonjour, ${client.prenom}`}</h1>
    <p className={SOUS_TITRE}>{`Membre depuis ${formaterMois(client.membreDepuis)}`}</p>
  </div>
  <div className="grid gap-5 lg:grid-cols-3">
    <section data-testid="carte-derniere-commande" className={CARTE}>
      <h2 className="text-lg font-extrabold text-[var(--vs-noir)]">Dernière commande</h2>
      {derniere ? (
        <>
          <p className="text-[15px] font-bold">{`${derniere.numero} · ${formaterDate(derniere.date)}`}</p>
          <span className={`self-start ${CLASSES_STATUT[derniere.statut]}`}>{LIBELLES_STATUT[derniere.statut]}</span>
          <Link href="/compte/commandes" className={LIEN}>Voir mes commandes</Link>
        </>
      ) : (
        <>
          <p className={SOUS_TITRE}>Aucune commande pour l'instant.</p>
          <Link href="/soldes" className={LIEN}>Voir les soldes</Link>
        </>
      )}
    </section>
    <section data-testid="carte-adresse" className={CARTE}>
      <h2 className="text-lg font-extrabold text-[var(--vs-noir)]">Adresse de livraison</h2>
      {adresse ? (
        <p className="text-[15px] leading-relaxed">
          {adresse.nomComplet}<br />{adresse.ligne1}<br />{`${adresse.ville} (${adresse.province}) ${adresse.codePostal}`}
        </p>
      ) : (
        <p className={SOUS_TITRE}>Aucune adresse enregistrée.</p>
      )}
    </section>
    <section className="flex flex-col gap-3.5 rounded-3xl bg-[var(--vs-accent)] p-[26px] text-[var(--vs-blanc)]">
      <h2 className="text-lg font-extrabold">Votre avantage</h2>
      <p className="text-3xl font-black">−10 %</p>
      <p className="text-sm leading-relaxed">sur votre prochaine commande avec le code BIENVENUE10.</p>
    </section>
  </div>
  <section className="flex flex-col gap-4">
    <h2 className="text-lg font-extrabold text-[var(--vs-noir)]">Commandes récentes</h2>
    {commandes.length > 0
      ? commandes.slice(0, 2).map((c) => <CarteCommande key={c.numero} commande={c} />)
      : <p className={SOUS_TITRE}>Vos commandes apparaîtront ici.</p>}
  </section>
</>
```

## La page
```tsx
export default function PageCompte() {
  const session = useSession();
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Mon compte' }]} />
        <EspaceClient actif="tableau">
          {session.client && <Tableau client={session.client} />}
        </EspaceClient>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```
Le contenu n'est construit que si `session.client` existe : `EspaceClient` affiche
lui-même l'invitation à se connecter dans le cas contraire.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_10__
cat > 'tickets/102l-page-commandes.md' <<'__VICTO_FIN_11__'
TICKET 102l — mes commandes

Crée `src/app/compte/commandes/page.tsx`. Page **client** (`'use client'`), un
seul export : l'export par défaut `PageCommandes`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Aucun export nommé. Chaque `className` est écrit exactement comme ci-dessous.

## Bloc d'imports exact
```tsx
'use client';

import { useState } from 'react';
import { PILULE, PILULE_OFF, PILULE_ON } from '@/components/catalogue/filtres-affichage';
import { CarteCommande } from '@/components/compte/CarteCommande';
import { SOUS_TITRE, TITRE_PAGE } from '@/components/compte/compte-affichage';
import { EspaceClient } from '@/components/compte/EspaceClient';
import { useSession } from '@/components/compte/SessionProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { commandesDe, filtrerCommandes, libelleCommandes, type Client, type FiltreCommandes } from '@/lib/compte';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```

## Contenu
Taille attendue : ~65 lignes.
```tsx
const FILTRES: { valeur: FiltreCommandes; libelle: string }[] = [
  { valeur: 'toutes', libelle: 'Toutes' },
  { valeur: 'en-cours', libelle: 'En cours' },
  { valeur: 'livrees', libelle: 'Livrées' },
  { valeur: 'annulees', libelle: 'Annulées' },
];
```
Fonction locale non exportée `function Liste({ client }: { client: Client })` :
```tsx
const [filtre, setFiltre] = useState<FiltreCommandes>('toutes');
const commandes = filtrerCommandes(commandesDe(client), filtre);
return (
  <>
    <h1 className={TITRE_PAGE}>Mes commandes</h1>
    <div className="flex flex-wrap items-center justify-between gap-4">
      <div className="flex flex-wrap gap-2.5">
        {FILTRES.map((f) => (
          <button key={f.valeur} type="button" aria-pressed={f.valeur === filtre} onClick={() => setFiltre(f.valeur)}
            className={`${PILULE} ${f.valeur === filtre ? PILULE_ON : PILULE_OFF}`}>
            {f.libelle}
          </button>
        ))}
      </div>
      <p data-testid="commandes-nombre" className={SOUS_TITRE}>{libelleCommandes(commandes.length)}</p>
    </div>
    {commandes.length > 0
      ? commandes.map((c) => <CarteCommande key={c.numero} commande={c} />)
      : <p data-testid="commandes-vides" className={SOUS_TITRE}>Aucune commande dans cette catégorie.</p>}
  </>
);
```
La page :
```tsx
export default function PageCommandes() {
  const session = useSession();
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Mon compte', href: '/compte' }, { label: 'Mes commandes' }]} />
        <EspaceClient actif="commandes">
          {session.client && <Liste client={session.client} />}
        </EspaceClient>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_11__
cat > 'tickets/manifest-102.tsv' <<'__VICTO_FIN_12__'
102a	src/lib/compte.ts	tests/compte.test.ts	tickets/102a-compte.md			
102b	src/components/compte/compte-affichage.ts	tests/compte-affichage.test.ts	tickets/102b-compte-affichage.md	src/lib/compte.ts	102a	
102c	src/components/compte/SessionProvider.tsx	tests/SessionProvider.test.tsx	tickets/102c-session.md	src/lib/compte.ts	102a	
102d	src/app/layout.tsx	tests/layout-session.test.ts	tickets/102d-layout-session.md		102c	
102e	src/components/compte/MenuCompte.tsx	tests/MenuCompte.test.tsx	tickets/102e-menu-compte.md	src/components/compte/compte-affichage.ts,src/components/compte/SessionProvider.tsx	102b,102c	
102f	src/components/compte/EspaceClient.tsx	tests/EspaceClient.test.tsx	tickets/102f-espace-client.md	src/components/compte/compte-affichage.ts,src/components/compte/MenuCompte.tsx,src/components/compte/SessionProvider.tsx	102b,102c,102e	
102g	src/components/compte/CarteCommande.tsx	tests/CarteCommande.test.tsx	tickets/102g-carte-commande.md	src/components/compte/compte-affichage.ts,src/lib/compte.ts,src/lib/panier-detail.ts,src/lib/formatPrice.ts	102a,102b	
102h	src/app/connexion/page.tsx	tests/page-connexion.test.tsx	tickets/102h-page-connexion.md	src/components/compte/compte-affichage.ts,src/components/compte/SessionProvider.tsx,src/lib/compte.ts,src/components/produit/FilAriane.tsx,src/lib/navigation.ts	102a,102b,102c	
102i	src/app/inscription/page.tsx	tests/page-inscription.test.tsx	tickets/102i-page-inscription.md	src/components/compte/compte-affichage.ts,src/components/compte/SessionProvider.tsx,src/lib/compte.ts,src/components/produit/FilAriane.tsx,src/lib/navigation.ts	102a,102b,102c	
102j	src/app/mot-de-passe-oublie/page.tsx	tests/page-mot-de-passe.test.tsx	tickets/102j-page-mot-de-passe.md	src/components/compte/compte-affichage.ts,src/lib/compte.ts,src/components/produit/FilAriane.tsx,src/lib/navigation.ts	102a,102b	
102k	src/app/compte/page.tsx	tests/page-compte.test.tsx	tickets/102k-page-compte.md	src/components/compte/CarteCommande.tsx,src/components/compte/compte-affichage.ts,src/components/compte/EspaceClient.tsx,src/components/compte/SessionProvider.tsx,src/lib/compte.ts	102a,102b,102c,102f,102g	
102l	src/app/compte/commandes/page.tsx	tests/page-commandes.test.tsx	tickets/102l-page-commandes.md	src/components/catalogue/filtres-affichage.ts,src/components/compte/CarteCommande.tsx,src/components/compte/compte-affichage.ts,src/components/compte/EspaceClient.tsx,src/components/compte/SessionProvider.tsx,src/lib/compte.ts	102a,102b,102c,102f,102g	
__VICTO_FIN_12__
cat > 'tickets/tests/CarteCommande.test.tsx' <<'__VICTO_FIN_13__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { CLASSES_STATUT } from '../src/components/compte/compte-affichage';
import { CarteCommande } from '../src/components/compte/CarteCommande';
import { COMMANDES_DEMO, totauxCommande, type Commande } from '../src/lib/compte';
import { formatPrice } from '../src/lib/formatPrice';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const commande = (numero: string) => COMMANDES_DEMO.find((c) => c.numero === numero) as Commande;

describe('CarteCommande', () => {
  it('résume numéro, date, articles et total', () => {
    const c = commande('VS-10482');
    render(<CarteCommande commande={c} />);
    expect(screen.getByRole('heading', { level: 3 }).textContent).toBe('Commande VS-10482');
    expect(screen.getByTestId('commande-resume').textContent).toBe(
      `24 septembre 2026 · 3 articles · ${formatPrice(totauxCommande(c).totalCents)}`,
    );
  });

  it('colore le statut', () => {
    render(<CarteCommande commande={commande('VS-10291')} />);
    const statut = screen.getByTestId('commande-statut');
    expect(statut.textContent).toBe('Annulée');
    for (const k of CLASSES_STATUT.annulee.split(' ')) expect(classes(statut)).toContain(k);
  });

  it('liste les articles, avec la quantité quand elle dépasse un', () => {
    render(<CarteCommande commande={commande('VS-10360')} />);
    expect(screen.getAllByRole('listitem').map((li: HTMLElement) => li.textContent)).toEqual([
      'Converse Chuck Taylor All Star · 38 × 2',
    ]);
  });
});
__VICTO_FIN_13__
cat > 'tickets/tests/EspaceClient.test.tsx' <<'__VICTO_FIN_14__'
import { render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { EspaceClient } from '../src/components/compte/EspaceClient';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO } from '../src/lib/compte';

beforeEach(() => window.localStorage.clear());

describe('EspaceClient', () => {
  it('invite à se connecter ou à créer un compte', () => {
    render(<SessionProvider><EspaceClient actif="tableau"><p>secret</p></EspaceClient></SessionProvider>);
    const invitation = screen.getByTestId('compte-invitation');
    expect(within(invitation).getByRole('heading', { level: 2 }).textContent).toBe('Connectez-vous pour accéder à votre compte');
    expect(within(invitation).getByRole('link', { name: 'Se connecter' })).toHaveAttribute('href', '/connexion');
    expect(within(invitation).getByRole('link', { name: 'Créer un compte' })).toHaveAttribute('href', '/inscription');
    expect(screen.queryByText('secret')).toBeNull();
  });

  it('montre menu et contenu à un client connecté', () => {
    window.localStorage.setItem(CLE_SESSION, JSON.stringify(CLIENT_DEMO));
    render(<SessionProvider><EspaceClient actif="commandes"><p>secret</p></EspaceClient></SessionProvider>);
    const espace = screen.getByTestId('espace-client');
    expect(within(espace).getByRole('navigation', { name: 'Espace client' })).toBeInTheDocument();
    expect(within(espace).getByRole('link', { name: 'Mes commandes' })).toHaveAttribute('aria-current', 'page');
    expect(within(espace).getByText('secret')).toBeInTheDocument();
    expect(screen.queryByTestId('compte-invitation')).toBeNull();
  });
});
__VICTO_FIN_14__
cat > 'tickets/tests/MenuCompte.test.tsx' <<'__VICTO_FIN_15__'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { MENU_LIEN, MENU_LIEN_ACTIF } from '../src/components/compte/compte-affichage';
import { MenuCompte } from '../src/components/compte/MenuCompte';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO } from '../src/lib/compte';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

beforeEach(() => window.localStorage.clear());

describe('MenuCompte', () => {
  it('liste les cinq entrées, dans l’ordre, avec leurs liens', () => {
    render(<MenuCompte actif="commandes" />);
    const menu = screen.getByRole('navigation', { name: 'Espace client' });
    expect(within(menu).getAllByRole('link').map((l: HTMLElement) => [l.textContent, l.getAttribute('href')])).toEqual([
      ['Tableau de bord', '/compte'],
      ['Mes commandes', '/compte/commandes'],
      ['Favoris', '/compte/favoris'],
      ['Adresses', '/compte/adresses'],
      ['Informations personnelles', '/compte/informations'],
    ]);
  });

  it('marque l’entrée active, seule', () => {
    render(<MenuCompte actif="commandes" />);
    const actif = screen.getByRole('link', { name: 'Mes commandes' });
    expect(actif).toHaveAttribute('aria-current', 'page');
    for (const k of MENU_LIEN_ACTIF.split(' ')) expect(classes(actif)).toContain(k);
    const autre = screen.getByRole('link', { name: 'Favoris' });
    expect(autre).not.toHaveAttribute('aria-current');
    for (const k of MENU_LIEN.split(' ')) expect(classes(autre)).toContain(k);
  });

  it('déconnecte', () => {
    window.localStorage.setItem(CLE_SESSION, JSON.stringify(CLIENT_DEMO));
    render(<SessionProvider><MenuCompte actif="tableau" /></SessionProvider>);
    fireEvent.click(screen.getByRole('button', { name: 'Se déconnecter' }));
    expect(window.localStorage.getItem(CLE_SESSION)).toBeNull();
  });
});
__VICTO_FIN_15__
cat > 'tickets/tests/SessionProvider.test.tsx' <<'__VICTO_FIN_16__'
import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { CLE_SESSION, SessionProvider, useSession } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO, COURRIEL_DEMO, MOT_DE_PASSE_DEMO } from '../src/lib/compte';

let dernierRetour: boolean | null = null;
function Temoin() {
  const s = useSession();
  return (
    <div>
      <span data-testid="client">{s.client ? `${s.client.prenom} ${s.client.nom}` : 'aucun'}</span>
      <span data-testid="pret">{String(s.pret)}</span>
      <button type="button" onClick={() => { dernierRetour = s.connecter(COURRIEL_DEMO, MOT_DE_PASSE_DEMO); }}>bon</button>
      <button type="button" onClick={() => { dernierRetour = s.connecter(COURRIEL_DEMO, 'faux'); }}>faux</button>
      <button type="button" onClick={() => s.inscrire({ prenom: ' Léa ', nom: 'Roy', courriel: 'LEA@exemple.ca', motDePasse: 'motdepasse1' })}>inscrire</button>
      <button type="button" onClick={() => s.deconnecter()}>sortir</button>
    </div>
  );
}
const cliquer = (n: string) => fireEvent.click(screen.getByRole('button', { name: n }));
const client = () => screen.getByTestId('client').textContent;
const enregistre = () => JSON.parse(window.localStorage.getItem(CLE_SESSION) ?? 'null') as { courriel?: string } | null;

beforeEach(() => { window.localStorage.clear(); dernierRetour = null; });

describe('useSession — hors du fournisseur', () => {
  it('ne connaît aucun client et reste prêt', () => {
    render(<Temoin />);
    expect(client()).toBe('aucun');
    expect(screen.getByTestId('pret').textContent).toBe('true');
    cliquer('bon');
    expect(dernierRetour).toBe(false);
  });
});

describe('SessionProvider', () => {
  it('connecte le compte de démonstration et refuse un mauvais mot de passe', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('faux');
    expect(dernierRetour).toBe(false);
    expect(client()).toBe('aucun');
    cliquer('bon');
    expect(dernierRetour).toBe(true);
    expect(client()).toBe('Camille Tremblay');
    expect(enregistre()?.courriel).toBe(COURRIEL_DEMO);
  });

  it('inscrit un nouveau client, nettoyé', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('inscrire');
    expect(client()).toBe('Léa Roy');
    expect(enregistre()?.courriel).toBe('lea@exemple.ca');
  });

  it('déconnecte et oublie la session', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('bon');
    cliquer('sortir');
    expect(client()).toBe('aucun');
    expect(window.localStorage.getItem(CLE_SESSION)).toBeNull();
  });

  it('relit une session enregistrée et ignore une session illisible', () => {
    window.localStorage.setItem(CLE_SESSION, JSON.stringify(CLIENT_DEMO));
    const { unmount } = render(<SessionProvider><Temoin /></SessionProvider>);
    expect(client()).toBe('Camille Tremblay');
    unmount();
    window.localStorage.setItem(CLE_SESSION, '{"prenom":1}');
    render(<SessionProvider><Temoin /></SessionProvider>);
    expect(client()).toBe('aucun');
  });
});
__VICTO_FIN_16__
cat > 'tickets/tests/compte-affichage.test.ts' <<'__VICTO_FIN_17__'
import { describe, expect, it } from 'vitest';
import * as A from '../src/components/compte/compte-affichage';

const ATTENDU: Record<string, string> = {
  TITRE_PAGE: 'text-[40px] font-black leading-none tracking-tight text-[var(--vs-noir)] lg:text-[52px]',
  SOUS_TITRE: 'text-base text-[var(--vs-gris)]',
  CHAMP: 'flex flex-col gap-2',
  CHAMP_LIBELLE: 'text-sm font-bold text-[var(--vs-noir)]',
  CHAMP_SAISIE: 'h-[54px] w-full rounded-[14px] border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-[18px] text-base text-[var(--vs-noir)]',
  CHAMP_SAISIE_ERREUR: 'h-[54px] w-full rounded-[14px] border-[1.5px] border-[var(--vs-promo)] bg-[var(--vs-blanc)] px-[18px] text-base text-[var(--vs-noir)]',
  CHAMP_AIDE: 'text-[13px] text-[var(--vs-gris)]',
  CHAMP_ERREUR: 'text-[13px] font-bold text-[var(--vs-promo)]',
  BOUTON_PRINCIPAL: 'flex h-14 w-full items-center justify-center rounded-full bg-[var(--vs-accent)] px-7 text-base font-extrabold text-[var(--vs-blanc)]',
  BOUTON_SECONDAIRE: 'flex h-14 w-full items-center justify-center rounded-full border-[1.5px] border-[var(--vs-noir)] bg-[var(--vs-blanc)] px-7 text-base font-extrabold text-[var(--vs-noir)]',
  LIEN: 'text-sm font-bold text-[var(--vs-noir)] underline',
  CARTE: 'flex flex-col gap-3.5 rounded-3xl border-[1.5px] border-[var(--vs-ligne)] p-[26px]',
  MENU_LIEN: 'flex h-[50px] items-center gap-3 rounded-full px-[18px] text-[15px] font-semibold text-[var(--vs-noir)]',
  MENU_LIEN_ACTIF: 'flex h-[50px] items-center gap-3 rounded-full bg-[var(--vs-noir)] px-[18px] text-[15px] font-bold text-[var(--vs-blanc)]',
};

describe('compte-affichage', () => {
  it("n'exporte que les constantes prévues", () => {
    expect(Object.keys(A).sort()).toEqual([
      'BOUTON_PRINCIPAL', 'BOUTON_SECONDAIRE', 'CARTE', 'CHAMP', 'CHAMP_AIDE', 'CHAMP_ERREUR', 'CHAMP_LIBELLE', 'CHAMP_SAISIE', 'CHAMP_SAISIE_ERREUR', 'CLASSES_STATUT', 'LIBELLES_STATUT', 'LIEN', 'MENU_LIEN', 'MENU_LIEN_ACTIF', 'SOUS_TITRE', 'TITRE_PAGE',
    ]);
  });

  it('recopie chaque classe à l\'identique', () => {
    const reel: Record<string, unknown> = { ...A };
    for (const [nom, valeur] of Object.entries(ATTENDU)) expect(reel[nom], nom).toBe(valeur);
  });

  it('donne une pastille et un libellé à chaque statut', () => {
    expect(Object.keys(A.CLASSES_STATUT).sort()).toEqual(['annulee', 'expediee', 'livree', 'preparation']);
    expect(A.LIBELLES_STATUT).toEqual({ preparation: 'En préparation', expediee: 'Expédiée', livree: 'Livrée', annulee: 'Annulée' });
    expect(A.CLASSES_STATUT.annulee).toContain('bg-[#FFD3DB]');
    expect(A.CLASSES_STATUT.expediee).toContain('text-[var(--vs-accent)]');
  });
});
__VICTO_FIN_17__
cat > 'tickets/tests/compte.test.ts' <<'__VICTO_FIN_18__'
import { describe, expect, it } from 'vitest';
import {
  CLIENT_DEMO, COMMANDES_DEMO, COURRIEL_DEMO, MOT_DE_PASSE_DEMO, commandesDe, courrielValide, filtrerCommandes,
  formaterDate, formaterMois, libelleCommandes, totauxCommande, validerInscription, verifierConnexion, type Commande,
} from '../src/lib/compte';

describe('connexion et inscription', () => {
  it('reconnaît le compte de démonstration, courriel sans casse ni espaces', () => {
    expect(verifierConnexion(COURRIEL_DEMO, MOT_DE_PASSE_DEMO)).toBe(true);
    expect(verifierConnexion('  Camille.Tremblay@Exemple.ca ', MOT_DE_PASSE_DEMO)).toBe(true);
    expect(verifierConnexion(COURRIEL_DEMO, 'mauvais')).toBe(false);
    expect(verifierConnexion('autre@exemple.ca', MOT_DE_PASSE_DEMO)).toBe(false);
  });

  it('valide un courriel', () => {
    expect(courrielValide('a@b.ca')).toBe(true);
    expect(courrielValide('pas un courriel')).toBe(false);
    expect(courrielValide('a@b')).toBe(false);
  });

  it('signale chaque champ fautif de l’inscription', () => {
    expect(validerInscription({ prenom: ' ', nom: '', courriel: 'x', motDePasse: 'court' })).toEqual({
      prenom: 'Indiquez votre prénom.',
      nom: 'Indiquez votre nom.',
      courriel: 'Indiquez un courriel valide.',
      motDePasse: 'Au moins 8 caractères, dont un chiffre.',
    });
    expect(validerInscription({ prenom: 'Léa', nom: 'Roy', courriel: 'lea@exemple.ca', motDePasse: 'sanschiffre' })).toEqual({
      motDePasse: 'Au moins 8 caractères, dont un chiffre.',
    });
    expect(validerInscription({ prenom: 'Léa', nom: 'Roy', courriel: 'lea@exemple.ca', motDePasse: 'motdepasse1' })).toEqual({});
  });
});

describe('commandes', () => {
  it('ne montre les commandes de démonstration qu’au compte de démonstration', () => {
    expect(commandesDe(CLIENT_DEMO)).toBe(COMMANDES_DEMO);
    expect(commandesDe({ ...CLIENT_DEMO, courriel: 'autre@exemple.ca' })).toEqual([]);
  });

  it('filtre par statut en gardant l’ordre', () => {
    const numeros = (f: Parameters<typeof filtrerCommandes>[1]) => filtrerCommandes(COMMANDES_DEMO, f).map((c) => c.numero);
    expect(numeros('toutes')).toEqual(['VS-10482', 'VS-10417', 'VS-10360', 'VS-10291']);
    expect(numeros('en-cours')).toEqual(['VS-10482']);
    expect(numeros('livrees')).toEqual(['VS-10417', 'VS-10360']);
    expect(numeros('annulees')).toEqual(['VS-10291']);
  });

  it('calcule TPS et TVQ non composées, arrondies au cent', () => {
    const c = COMMANDES_DEMO.find((x) => x.numero === 'VS-10482') as Commande;
    expect(totauxCommande(c)).toEqual({
      articles: 3, sousTotalCents: 27700, economiesCents: 5000, tpsCents: 1385, tvqCents: 2763, totalCents: 31848,
    });
    const deux = COMMANDES_DEMO.find((x) => x.numero === 'VS-10360') as Commande;
    expect(totauxCommande(deux)).toMatchObject({ articles: 2, sousTotalCents: 17800, tpsCents: 890, tvqCents: 1776, totalCents: 20466 });
  });
});

describe('formats', () => {
  it('écrit les dates en français', () => {
    expect(formaterDate('2026-09-24')).toBe('24 septembre 2026');
    expect(formaterMois('2026-03-12')).toBe('mars 2026');
  });

  it('accorde le nombre de commandes, zéro au singulier', () => {
    expect([0, 1, 4].map(libelleCommandes)).toEqual(['0 commande', '1 commande', '4 commandes']);
  });
});
__VICTO_FIN_18__
cat > 'tickets/tests/layout-session.test.ts' <<'__VICTO_FIN_19__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('layout — session', () => {
  const source = readFileSync('src/app/layout.tsx', 'utf8');

  it('enveloppe le site dans la session, à l’intérieur du panier', () => {
    expect(source).toContain("import { SessionProvider } from '@/components/compte/SessionProvider';");
    expect(source).toMatch(/<PanierProvider>\s*<SessionProvider>\{children\}<\/SessionProvider>\s*<\/PanierProvider>/);
    expect(source).not.toContain('use client');
  });
});
__VICTO_FIN_19__
cat > 'tickets/tests/page-commandes.test.tsx' <<'__VICTO_FIN_20__'
import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PageCommandes from '../src/app/compte/commandes/page';
import { PILULE_ON } from '../src/components/catalogue/filtres-affichage';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO } from '../src/lib/compte';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const connecter = (client: object) => window.localStorage.setItem(CLE_SESSION, JSON.stringify(client));
const poser = () => render(<SessionProvider><PageCommandes /></SessionProvider>);
const filtre = (nom: string) => screen.getByRole('button', { name: nom });
const numeros = () => screen.queryAllByRole('heading', { level: 3 }).map((h: HTMLElement) => h.textContent);

beforeEach(() => window.localStorage.clear());

describe('mes commandes', () => {
  it('liste toutes les commandes du client de démonstration', () => {
    connecter(CLIENT_DEMO);
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Mes commandes' })).toBeInTheDocument();
    expect(numeros()).toEqual(['Commande VS-10482', 'Commande VS-10417', 'Commande VS-10360', 'Commande VS-10291']);
    expect(screen.getByTestId('commandes-nombre').textContent).toBe('4 commandes');
    expect(filtre('Toutes')).toHaveAttribute('aria-pressed', 'true');
    expect(screen.getByRole('link', { name: 'Mes commandes' })).toHaveAttribute('aria-current', 'page');
  });

  it('filtre par statut', () => {
    connecter(CLIENT_DEMO);
    poser();
    fireEvent.click(filtre('Livrées'));
    expect(numeros()).toEqual(['Commande VS-10417', 'Commande VS-10360']);
    expect(filtre('Livrées')).toHaveAttribute('aria-pressed', 'true');
    for (const k of PILULE_ON.split(' ')) expect(classes(filtre('Livrées'))).toContain(k);
    fireEvent.click(filtre('Annulées'));
    expect(numeros()).toEqual(['Commande VS-10291']);
    expect(screen.getByTestId('commandes-nombre').textContent).toBe('1 commande');
  });

  it('dit qu’il n’y a rien pour un nouveau client', () => {
    connecter({ ...CLIENT_DEMO, courriel: 'lea@exemple.ca' });
    poser();
    expect(screen.getByTestId('commandes-vides')).toBeInTheDocument();
    expect(screen.getByTestId('commandes-nombre').textContent).toBe('0 commande');
  });
});
__VICTO_FIN_20__
cat > 'tickets/tests/page-compte.test.tsx' <<'__VICTO_FIN_21__'
import { render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PageCompte from '../src/app/compte/page';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO } from '../src/lib/compte';

const connecter = (client: object) => window.localStorage.setItem(CLE_SESSION, JSON.stringify(client));
const poser = () => render(<SessionProvider><PageCompte /></SessionProvider>);

beforeEach(() => window.localStorage.clear());

describe('tableau de bord', () => {
  it('invite à se connecter quand personne ne l’est', () => {
    poser();
    expect(screen.getByTestId('compte-invitation')).toBeInTheDocument();
    expect(screen.queryByRole('heading', { level: 1 })).toBeNull();
  });

  it('accueille le client de démonstration avec ses informations', () => {
    connecter(CLIENT_DEMO);
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Bonjour, Camille' })).toBeInTheDocument();
    expect(screen.getByText('Membre depuis mars 2026')).toBeInTheDocument();
    expect(within(screen.getByTestId('carte-derniere-commande')).getByText('VS-10482 · 24 septembre 2026')).toBeInTheDocument();
    expect(within(screen.getByTestId('carte-derniere-commande')).getByText('Expédiée')).toBeInTheDocument();
    expect(screen.getByTestId('carte-adresse').textContent).toContain('4520, rue Saint-Denis, app. 3');
    expect(screen.getAllByTestId('carte-commande')).toHaveLength(2);
    expect(screen.getByRole('navigation', { name: 'Espace client' })).toBeInTheDocument();
  });

  it('reste utile à un nouveau client sans commande ni adresse', () => {
    connecter({ ...CLIENT_DEMO, prenom: 'Léa', courriel: 'lea@exemple.ca', adresses: [] });
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Bonjour, Léa' })).toBeInTheDocument();
    expect(screen.getByText("Aucune commande pour l'instant.")).toBeInTheDocument();
    expect(screen.getByText('Aucune adresse enregistrée.')).toBeInTheDocument();
    expect(screen.queryAllByTestId('carte-commande')).toHaveLength(0);
  });
});
__VICTO_FIN_21__
cat > 'tickets/tests/page-connexion.test.tsx' <<'__VICTO_FIN_22__'
import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import PageConnexion from '../src/app/connexion/page';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { COURRIEL_DEMO, MOT_DE_PASSE_DEMO } from '../src/lib/compte';

const { pousser } = vi.hoisted(() => ({ pousser: vi.fn() }));
vi.mock('next/navigation', async (original) => ({
  ...(await original<typeof import('next/navigation')>()),
  useRouter: () => ({ push: pousser, replace: vi.fn(), prefetch: vi.fn(), back: vi.fn(), forward: vi.fn(), refresh: vi.fn() }),
}));

const poser = () => render(<SessionProvider><PageConnexion /></SessionProvider>);
const saisir = (libelle: string, valeur: string) => fireEvent.change(screen.getByLabelText(libelle), { target: { value: valeur } });

beforeEach(() => { window.localStorage.clear(); pousser.mockClear(); });

describe('page de connexion', () => {
  it('assemble titre, champs, liens et rappel du compte de démonstration', () => {
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Connexion' })).toBeInTheDocument();
    expect(screen.getByLabelText('Courriel')).toHaveAttribute('type', 'email');
    expect(screen.getByLabelText('Mot de passe')).toHaveAttribute('type', 'password');
    expect(screen.getByTestId('connexion-demo').textContent).toContain(COURRIEL_DEMO);
    expect(screen.getByRole('link', { name: 'Mot de passe oublié ?' })).toHaveAttribute('href', '/mot-de-passe-oublie');
    expect(screen.getByRole('link', { name: 'Créer un compte' })).toHaveAttribute('href', '/inscription');
  });

  it('refuse un mauvais mot de passe, sans rediriger', () => {
    poser();
    saisir('Courriel', COURRIEL_DEMO);
    saisir('Mot de passe', 'mauvais');
    fireEvent.click(screen.getByRole('button', { name: 'Se connecter' }));
    expect(screen.getByRole('alert').textContent).toBe('Courriel ou mot de passe incorrect.');
    expect(pousser).not.toHaveBeenCalled();
  });

  it('connecte le compte de démonstration et mène au compte', () => {
    poser();
    saisir('Courriel', COURRIEL_DEMO);
    saisir('Mot de passe', MOT_DE_PASSE_DEMO);
    fireEvent.click(screen.getByRole('button', { name: 'Se connecter' }));
    expect(pousser).toHaveBeenCalledWith('/compte');
    expect(window.localStorage.getItem(CLE_SESSION)).toContain(COURRIEL_DEMO);
    expect(screen.queryByRole('alert')).toBeNull();
  });

  it('affiche et masque le mot de passe', () => {
    poser();
    fireEvent.click(screen.getByRole('button', { name: 'Afficher le mot de passe' }));
    expect(screen.getByLabelText('Mot de passe')).toHaveAttribute('type', 'text');
    fireEvent.click(screen.getByRole('button', { name: 'Masquer le mot de passe' }));
    expect(screen.getByLabelText('Mot de passe')).toHaveAttribute('type', 'password');
  });
});
__VICTO_FIN_22__
cat > 'tickets/tests/page-inscription.test.tsx' <<'__VICTO_FIN_23__'
import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import PageInscription from '../src/app/inscription/page';
import { CHAMP_SAISIE_ERREUR } from '../src/components/compte/compte-affichage';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';

const { pousser } = vi.hoisted(() => ({ pousser: vi.fn() }));
vi.mock('next/navigation', async (original) => ({
  ...(await original<typeof import('next/navigation')>()),
  useRouter: () => ({ push: pousser, replace: vi.fn(), prefetch: vi.fn(), back: vi.fn(), forward: vi.fn(), refresh: vi.fn() }),
}));

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const poser = () => render(<SessionProvider><PageInscription /></SessionProvider>);
const saisir = (libelle: string, valeur: string) => fireEvent.change(screen.getByLabelText(libelle), { target: { value: valeur } });
const envoyer = () => fireEvent.click(screen.getByRole('button', { name: 'Créer mon compte' }));

beforeEach(() => { window.localStorage.clear(); pousser.mockClear(); });

describe('page d’inscription', () => {
  it('assemble titre, champs et lien de connexion', () => {
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Créer un compte' })).toBeInTheDocument();
    for (const l of ['Prénom', 'Nom', 'Courriel', 'Mot de passe']) expect(screen.getByLabelText(l)).toBeInTheDocument();
    expect(screen.getByText('8 caractères minimum, dont au moins un chiffre.')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Se connecter' })).toHaveAttribute('href', '/connexion');
  });

  it('signale chaque champ fautif, sans inscrire', () => {
    poser();
    envoyer();
    expect(screen.getByText('Indiquez votre prénom.')).toBeInTheDocument();
    expect(screen.getByText('Indiquez un courriel valide.')).toBeInTheDocument();
    const courriel = screen.getByLabelText('Courriel');
    expect(courriel).toHaveAttribute('aria-invalid', 'true');
    expect(courriel.getAttribute('aria-describedby')).toBe('erreur-courriel');
    for (const k of CHAMP_SAISIE_ERREUR.split(' ')) expect(classes(courriel)).toContain(k);
    expect(screen.getByLabelText('Mot de passe').getAttribute('aria-describedby')).toBe('aide-motDePasse erreur-motDePasse');
    expect(pousser).not.toHaveBeenCalled();
    expect(window.localStorage.getItem(CLE_SESSION)).toBeNull();
  });

  it('inscrit et mène au compte quand tout est valide', () => {
    poser();
    saisir('Prénom', 'Léa');
    saisir('Nom', 'Roy');
    saisir('Courriel', 'Lea@Exemple.ca');
    saisir('Mot de passe', 'motdepasse1');
    envoyer();
    expect(pousser).toHaveBeenCalledWith('/compte');
    expect(window.localStorage.getItem(CLE_SESSION)).toContain('lea@exemple.ca');
    expect(screen.getByLabelText('Courriel')).not.toHaveAttribute('aria-invalid');
  });
});
__VICTO_FIN_23__
cat > 'tickets/tests/page-mot-de-passe.test.tsx' <<'__VICTO_FIN_24__'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageMotDePasseOublie from '../src/app/mot-de-passe-oublie/page';

const saisir = (valeur: string) => fireEvent.change(screen.getByLabelText('Courriel'), { target: { value: valeur } });
const envoyer = () => fireEvent.click(screen.getByRole('button', { name: 'Envoyer le lien' }));

describe('page mot de passe oublié', () => {
  it('assemble titre, champ et retour à la connexion', () => {
    render(<PageMotDePasseOublie />);
    expect(screen.getByRole('heading', { level: 1, name: 'Mot de passe oublié' })).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Retour à la connexion' })).toHaveAttribute('href', '/connexion');
  });

  it('refuse un courriel invalide', () => {
    render(<PageMotDePasseOublie />);
    saisir('pas un courriel');
    envoyer();
    expect(screen.getByRole('alert').textContent).toBe('Indiquez un courriel valide.');
    expect(screen.queryByTestId('lien-envoye')).toBeNull();
  });

  it('confirme l’envoi pour le courriel saisi, puis permet de recommencer', () => {
    render(<PageMotDePasseOublie />);
    saisir(' lea@exemple.ca ');
    envoyer();
    const confirmation = screen.getByTestId('lien-envoye');
    expect(confirmation.textContent).toContain('Si un compte existe pour lea@exemple.ca, un lien vous attend.');
    fireEvent.click(screen.getByRole('button', { name: 'Renvoyer le lien' }));
    expect(screen.getByRole('button', { name: 'Envoyer le lien' })).toBeInTheDocument();
  });
});
__VICTO_FIN_24__
TESTS=(CarteCommande.test.tsx EspaceClient.test.tsx MenuCompte.test.tsx SessionProvider.test.tsx compte-affichage.test.ts compte.test.ts layout-session.test.ts page-commandes.test.tsx page-compte.test.tsx page-connexion.test.tsx page-inscription.test.tsx page-mot-de-passe.test.tsx)
if [ "$ICONES" = Home ]; then
  sed -i 's/\bHouse\b/Home/g' tickets/102e-menu-compte.md
  info "ta version de lucide n'a pas House : le menu utilisera Home"
fi

# ------------------------------------------------------------ anciens tests : accepter avant ET après le lot
python3 - <<'PYT'
import glob, re
changes = []
for f in sorted(glob.glob('tests/*.ts*') + glob.glob('tickets/tests/*.ts*')):
    s = open(f, encoding='utf-8').read(); t = s
    t = re.sub(r"""getByRole\((['"])button\1,\s*\{\s*name:\s*(['"])Mon compte\2\s*\}\)""", "getByLabelText('Mon compte')", t)
    t = t.replace("expect(source).toContain('<PanierProvider>{children}</PanierProvider>');",
                  "expect(source).toMatch(/<PanierProvider>[\\s\\S]*\\{children\\}[\\s\\S]*<\\/PanierProvider>/);")
    if t != s:
        open(f, 'w', encoding='utf-8').write(t); changes.append(f)
print(' '.join(changes))
PYT
# Nom accessible EXACT « Mon compte », ou expression régulière qui contient « compte » ;
# « Créer mon compte » (bouton de l'inscription) n'est pas concerné.
restes="$(grep -rnE "getByRole\(['\"]button['\"],[[:space:]]*\{[[:space:]]*name:[[:space:]]*(['\"]Mon compte['\"]|/[^/]*[Cc]ompte[^/]*/)" tests tickets/tests || true)"
[ -z "$restes" ] && [ -z "$(grep -rn "PanierProvider>{children}</PanierProvider>')" tests tickets/tests || true)" ] \
  || { echo "$restes"; annuler "un ancien test fige « Mon compte » ou le layout sous une forme que je ne sais pas assouplir"; }
ok "anciens tests assouplis : « Mon compte » trouvé par son étiquette, layout accepté avec ou sans session"

# ------------------------------------------------------------ 102m : « Mon compte » mène-t-il à /compte ?
cat > /tmp/victo-analyse-compte.py <<'__ANALYSE__'
"""Usage : python3 analyse-entete.py src/components/ui/SiteHeader.tsx
Affiche « balise href » de l’élément aria-label="Mon compte" (href vide si absent)."""
import re, sys
s = open(sys.argv[1], encoding='utf-8').read()
m = re.search(r'aria-label="Mon compte"', s)
if not m:
    print('absent -'); sys.exit(0)
debut = s.rfind('<', 0, m.start())
nom = re.match(r'<([A-Za-z][\w.]*)', s[debut:])
# fin de la balise ouvrante : premier « > » hors accolades et hors chaînes
prof, quote, i = 0, None, debut + 1
while i < len(s):
    c = s[i]
    if quote:
        if c == quote: quote = None
    elif c in '"\'`': quote = c
    elif c == '{': prof += 1
    elif c == '}': prof -= 1
    elif c == '>' and prof == 0: break
    i += 1
balise = s[debut:i + 1]
h = re.search(r'\bhref=("[^"]*"|\{[^}]*\})', balise)
print((nom.group(1) if nom else '?'), (h.group(1) if h else '-'))
__ANALYSE__
read -r BALISE HREF <<< "$(python3 /tmp/victo-analyse-compte.py src/components/ui/SiteHeader.tsx)"
ECRIRE_102M=1
case "$BALISE" in
  a|Link)
    if [ "$HREF" = '"/compte"' ]; then ok "« Mon compte » mène déjà à /compte"; ECRIRE_102M=0
    else cat > tickets/102m-entete-compte.md <<'__SPEC__'
TICKET 102m — « Mon compte » mène à l'espace client

Modifie `src/components/ui/SiteHeader.tsx`. Un seul changement : sur l'élément qui
porte `aria-label="Mon compte"`, l'attribut `href` prend exactement la valeur
`"/compte"`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Garde le bloc d'imports actuel à l'identique. Aucune autre ligne ne change.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__SPEC__
      ok "« Mon compte » mène à $HREF : ticket 102m généré (href → /compte)"; fi ;;
  button)
    cat > tickets/102m-entete-compte.md <<'__SPEC__'
TICKET 102m — « Mon compte » mène à l'espace client

Modifie `src/components/ui/SiteHeader.tsx`. L'élément qui porte
`aria-label="Mon compte"` est aujourd'hui un `<button>` : il devient un lien Next
vers `/compte`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Aucune autre ligne ne change : ni les classes, ni l'icône, ni les autres éléments.

## Les deux changements
1. Remplace la balise ouvrante `<button …>` de cet élément par `<Link href="/compte" …>`,
   avec **exactement les mêmes attributs**, sauf `type="button"` et un éventuel
   `onClick`, que tu retires. Remplace sa balise fermante `</button>` par `</Link>`.
   Son contenu (l'icône) ne change pas.
2. Si la ligne `import Link from 'next/link';` n'est pas déjà dans les imports,
   ajoute-la à la suite des imports existants.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__SPEC__
    ok "« Mon compte » est un bouton : ticket 102m généré (bouton → lien /compte)" ;;
  *) info "élément « Mon compte » inattendu ($BALISE) : pas de ticket 102m"; ECRIRE_102M=0 ;;
esac
if [ "$ECRIRE_102M" = 1 ]; then
  cat > tickets/tests/entete-compte.test.tsx <<'__TEST__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteHeader } from '../src/components/ui/SiteHeader';

describe('en-tête — lien du compte', () => {
  it('mène à l’espace client, avec son icône', () => {
    render(<SiteHeader navItems={[]} />);
    const lien = screen.getByRole('link', { name: 'Mon compte' });
    expect(lien).toHaveAttribute('href', '/compte');
    expect(lien.querySelector('svg.lucide-user')).not.toBeNull();
  });
});
__TEST__
  printf '102m\tsrc/components/ui/SiteHeader.tsx\ttests/entete-compte.test.tsx\ttickets/102m-entete-compte.md\t\t\t\n' >> tickets/manifest-102.tsv
  TESTS+=(entete-compte.test.tsx)
fi
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
ok "$(wc -l < tickets/manifest-102.tsv) tickets écrits, manifeste tickets/manifest-102.tsv"

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/102*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-102.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
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
mkdir -p tests
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

# ------------------------------------------------------------ base verte (anciens tests assouplis compris), commit
npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head; annuler "tsc rouge"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges après assouplissement des anciens tests"; }
ok "base verte"
git add -A -- tickets tests
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "chore(tickets): lot 102 — espace client (connexion, inscription, compte, commandes)"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-102.tsv ./run.sh\n\n%s tickets enchaînés par leurs dépendances. Compte deux heures et demie à trois heures : un run à lancer le soir.\nCompte de démonstration : camille.tremblay@exemple.ca — mot de passe victo2026\n' "$(wc -l < tickets/manifest-102.tsv)"
