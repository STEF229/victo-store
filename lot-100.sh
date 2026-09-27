#!/usr/bin/env bash
# VICTO STORE — lot 100 : page panier et page des marques, d'après les maquettes du canevas.
#   100a  PanierProvider expose « pret » (pas de faux « panier vide » au chargement)
#   100b  src/lib/panier-detail.ts   100c LignePanier   100d RecapPanier   100e VuePanier
#   100f  src/app/panier/page.tsx
#   100g  src/lib/marques.ts         100h TuileMarque   100i src/app/marques/page.tsx
#   100j  généré ici s'il le faut : l'icône du panier de l'en-tête mène à /panier
# Usage :  cd ~/victo-store && bash lot-100.sh
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
for d in 098a 098b 098c 099a 099b; do fusionne "$d" || mort "$d n'est pas fusionné : le lot 100 s'appuie sur le panier et le fil d'Ariane"; done
PP=src/components/panier/PanierProvider.tsx
grep -q "setPret" "$PP" && grep -q "nombre: number;" "$PP" || mort "$PP ne ressemble pas à la version du 098b (état pret, nombre: number)"
grep -q "pret: boolean" "$PP" && mort "$PP expose déjà pret : lot déjà passé ?"
for e in MARQUES PRODUITS trouverProduit; do grep -qE "export (const|function) $e\b" src/lib/donnees.ts || mort "$e n'est pas exporté de src/lib/donnees.ts"; done
grep -q "/marques/" src/lib/catalogue.ts && grep -q "export function hrefProduit\|export const hrefProduit" src/lib/catalogue.ts || mort "hrefMarque ou hrefProduit ne correspondent pas aux specs"
grep -q "'/marques'" src/lib/navigation.ts || info "le menu ne mène pas encore à /marques (src/lib/navigation.ts)"
[ -f src/app/soldes/page.tsx ] || info "la page /soldes n'existe pas : le lien du panier vide y mènera quand même"
for f in src/app/panier src/app/marques/page.tsx src/components/marques src/lib/panier-detail.ts src/lib/marques.ts \
         src/components/panier/LignePanier.tsx src/components/panier/RecapPanier.tsx src/components/panier/VuePanier.tsx; do
  [ ! -e "$f" ] || mort "$f existe déjà : lot déjà passé ?"; done
for j in noir blanc surface ligne gris accent promo; do grep -qE -- "--vs-$j\s*:" src/styles/tokens.css || mort "jeton --vs-$j absent"; done
ok "panier, fil d'Ariane, données, liens et jetons conformes aux specs"

# Les tests s'appuient sur les vraies données : elles doivent en offrir assez.
cat > tests/zz-prevol-donnees.test.ts <<'__ENV__'
import { expect, it } from 'vitest';
import { MARQUES, PRODUITS } from '../src/lib/donnees';
it('données suffisantes pour les tests du lot 100', () => {
  expect(PRODUITS.filter((p) => p.variantes.some((v) => v.stock >= 2)).length).toBeGreaterThanOrEqual(2);
  expect(MARQUES.some((m) => PRODUITS.some((p) => p.marque.slug === m.slug))).toBe(true);
});
__ENV__
npx --no-install vitest run tests/zz-prevol-donnees.test.ts > /tmp/victo-prevol.log 2>&1 || true
rm -f tests/zz-prevol-donnees.test.ts; sed -i -E 's/\x1b\[[0-9;]*m//g' /tmp/victo-prevol.log
grep -qE "Tests +1 passed" /tmp/victo-prevol.log || { tail -12 /tmp/victo-prevol.log; mort "les données ne suffisent pas aux tests du panier (deux produits avec une pointure en stock ≥ 2)"; }
ok "données : assez de produits en stock pour les tests"

trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
mkdir -p tickets/tests
cat > 'tickets/100a-panier-pret.md' <<'__VICTO_FIN_0__'
TICKET 100a — le contexte du panier dit quand il est prêt

Modifie `src/components/panier/PanierProvider.tsx`. Le fichier actuel est correct et
testé : tu n'ajoutes qu'un champ `pret`, rien d'autre ne change.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Garde le bloc d'imports actuel à l'identique. Ne change aucune autre ligne.

## Les trois changements
1. Dans `interface ContextePanier`, juste après la ligne `nombre: number;`, ajoute
   exactement `pret: boolean;`.
2. Dans la **valeur par défaut** du contexte (celle passée à `createContext`),
   ajoute `pret: true`. Hors du fournisseur, un composant voit donc un panier vide
   et prêt.
3. Dans l'objet passé au fournisseur, ajoute `pret` : c'est l'état `pret` qui existe
   déjà dans le composant (faux au premier rendu, vrai une fois le panier relu).

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont
`tests/PanierProvider.test.tsx` (comportement existant).
__VICTO_FIN_0__
cat > 'tickets/100b-panier-detail.md' <<'__VICTO_FIN_1__'
TICKET 100b — détail et récapitulatif du panier

Crée `src/lib/panier-detail.ts`. Fonctions **pures** : aucune ne modifie ses arguments.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index
  (`tableau[i]`) ; utilise `.find`, `.flatMap`, `.reduce`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Bloc d'imports exact
```ts
import type { Produit, Variante } from '@/lib/catalogue';
import type { Panier } from '@/lib/panier';
```

## Exports exacts
Taille attendue : ~55 lignes.
```ts
export interface LigneDetaillee {
  slug: string;
  sku: string;
  quantite: number;
  produit: Produit;
  variante: Variante;
  totalCents: number;
  economieCents: number;
}
export interface RecapPanier {
  articles: number;
  sousTotalCents: number;
  economiesCents: number;
  totalCents: number;
}
export function detaillerPanier(lignes: Panier, trouver: (slug: string) => Produit | undefined): LigneDetaillee[];
export function recapitulerPanier(lignes: LigneDetaillee[]): RecapPanier;
export function libelleArticles(n: number): string;
```

## Règles
**`detaillerPanier`** : `lignes.flatMap((ligne) => { … })`, où pour chaque ligne :
- `const produit = trouver(ligne.slug);` — s'il est indéfini, renvoie `[]` ;
- `const variante = produit.variantes.find((v) => v.sku === ligne.sku);` — si elle
  est indéfinie, renvoie `[]` ;
- remise unitaire : `produit.prixCompareCents !== undefined && produit.prixCompareCents > produit.prixCents`
  ? `produit.prixCompareCents - produit.prixCents` : `0` ;
- renvoie `[{ slug: ligne.slug, sku: ligne.sku, quantite: ligne.quantite, produit, variante,
  totalCents: produit.prixCents * ligne.quantite, economieCents: remise * ligne.quantite }]`.

**`recapitulerPanier`** : `articles` = somme des `quantite` ; `sousTotalCents` = somme
des `totalCents` ; `economiesCents` = somme des `economieCents` ;
`totalCents` = `sousTotalCents` (livraison offerte, taxes calculées au paiement).
Un panier vide donne quatre zéros.

**`libelleArticles`** renvoie exactement
```ts
`${n} ${n > 1 ? 'articles' : 'article'}`
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > 'tickets/100c-ligne-panier.md' <<'__VICTO_FIN_2__'
TICKET 100c — une ligne du panier

Crée `src/components/panier/LignePanier.tsx`, export nommé `LignePanier`.
Composant **sans état** : il affiche une ligne et remonte les actions par ses props.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Icônes `lucide-react` avec `aria-hidden`. Balise `<img>` ordinaire.

## Bloc d'imports exact
```tsx
import { Minus, Plus } from 'lucide-react';
import Link from 'next/link';
import { hrefProduit } from '@/lib/catalogue';
import { texteStockBas } from '@/lib/fiche-produit';
import { formatPrice } from '@/lib/formatPrice';
import type { LigneDetaillee } from '@/lib/panier-detail';
```

## Props
Taille attendue : ~75 lignes.
```ts
interface LignePanierProps {
  ligne: LigneDetaillee;
  onQuantite: (sku: string, quantite: number, stock: number) => void;
  onRetirer: (sku: string) => void;
}
```
Dans le corps : `const { produit, variante, quantite, sku } = ligne;`,
`const promo = produit.prixCompareCents !== undefined && produit.prixCompareCents > produit.prixCents;`
et `const alerte = texteStockBas(produit, variante.taille);`.

## Rendu
Racine :
`<li data-testid="ligne-panier" className="grid grid-cols-[96px_minmax(0,1fr)] gap-3.5 border-b border-[var(--vs-ligne)] py-[18px] sm:grid-cols-[140px_minmax(0,1fr)_auto] sm:gap-6 sm:py-6">`
contenant, dans l'ordre :

**1. Image** :
```tsx
<Link href={hrefProduit(produit)} aria-label={produit.nom} className="block aspect-square overflow-hidden rounded-2xl bg-[var(--vs-surface)] sm:rounded-[20px]">
  <img src={produit.imageUrl} alt="" className="h-full w-full object-contain" />
</Link>
```

**2. Détails** — `<div className="flex flex-col gap-1.5">` :
- `<span className="text-xs font-extrabold uppercase tracking-[0.16em] text-[var(--vs-gris)]">{produit.marque.nom}</span>`
- `<Link href={hrefProduit(produit)} className="text-base font-extrabold text-[var(--vs-noir)] sm:text-lg">{produit.nom}</Link>`
- `<span data-testid="ligne-pointure" className="text-sm text-[var(--vs-gris)]">{`Pointure ${variante.taille}`}</span>`
- `<div className="flex items-baseline gap-2.5">` avec
  `<span data-testid="ligne-prix" className={promo ? 'text-[15px] font-extrabold text-[var(--vs-promo)]' : 'text-[15px] font-extrabold text-[var(--vs-noir)]'}>{formatPrice(produit.prixCents)}</span>`
  puis, seulement si `promo` et `produit.prixCompareCents !== undefined` :
  `<s className="text-[13px] text-[var(--vs-gris)]">{formatPrice(produit.prixCompareCents)}</s>`
- seulement si `alerte !== null` :
  `<p data-testid="ligne-stock-bas" className="text-[13px] font-bold text-[var(--vs-promo)]">{alerte}</p>`

**3. Actions** — `<div className="col-span-2 flex items-center justify-between gap-3 sm:col-span-1 sm:flex-col sm:items-end sm:justify-between">` :
- `<span data-testid="ligne-total" className="text-lg font-black text-[var(--vs-noir)]">{formatPrice(ligne.totalCents)}</span>`
- la quantité :
```tsx
<div className="flex h-11 items-center rounded-full border-[1.5px] border-[var(--vs-ligne)]">
  <button type="button" aria-label="Diminuer la quantité" disabled={quantite <= 1}
    onClick={() => onQuantite(sku, quantite - 1, variante.stock)}
    className={quantite <= 1
      ? 'flex h-10 w-11 items-center justify-center text-[#B5B5BA]'
      : 'flex h-10 w-11 items-center justify-center text-[var(--vs-noir)]'}>
    <Minus aria-hidden size={14} />
  </button>
  <span data-testid="ligne-quantite" className="min-w-[22px] text-center text-[15px] font-extrabold">{quantite}</span>
  <button type="button" aria-label="Augmenter la quantité" disabled={quantite >= variante.stock}
    onClick={() => onQuantite(sku, quantite + 1, variante.stock)}
    className={quantite >= variante.stock
      ? 'flex h-10 w-11 items-center justify-center text-[#B5B5BA]'
      : 'flex h-10 w-11 items-center justify-center text-[var(--vs-noir)]'}>
    <Plus aria-hidden size={14} />
  </button>
</div>
```
- `<button type="button" onClick={() => onRetirer(sku)} className="text-sm font-semibold text-[var(--vs-gris)] underline">Retirer</button>`

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_2__
cat > 'tickets/100d-recap-panier.md' <<'__VICTO_FIN_3__'
TICKET 100d — récapitulatif du panier

Crée `src/components/panier/RecapPanier.tsx`, export nommé `RecapPanier`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.

## Bloc d'imports exact
```tsx
import { formatPrice } from '@/lib/formatPrice';
import { libelleArticles, type RecapPanier as Recap } from '@/lib/panier-detail';
```
(Le type est importé sous le nom `Recap`, pour ne pas entrer en collision avec le
composant `RecapPanier`.)

## Rendu
Taille attendue : ~45 lignes.

`export function RecapPanier({ recap }: { recap: Recap })` rend :
```tsx
<aside data-testid="recap-panier" className="flex flex-col gap-[18px] rounded-3xl bg-[var(--vs-surface)] p-7">
  <h2 className="text-[22px] font-black text-[var(--vs-noir)]">Récapitulatif</h2>
  <div className="flex flex-col gap-3 text-[15px]">
    <div className="flex justify-between">
      <span>{`Sous-total (${libelleArticles(recap.articles)})`}</span>
      <span data-testid="recap-sous-total" className="font-bold">{formatPrice(recap.sousTotalCents)}</span>
    </div>
    {recap.economiesCents > 0 && (
      <div className="flex justify-between text-[var(--vs-promo)]">
        <span>Vos économies</span>
        <span data-testid="recap-economies" className="font-bold">{`\u2212${formatPrice(recap.economiesCents)}`}</span>
      </div>
    )}
    <div className="flex justify-between">
      <span>Livraison</span>
      <span className="font-bold">Offerte</span>
    </div>
  </div>
  <div className="h-px bg-[var(--vs-ligne)]" />
  <div className="flex items-baseline justify-between">
    <span className="text-[17px] font-extrabold">Total</span>
    <span data-testid="recap-total" className="text-[26px] font-black">{formatPrice(recap.totalCents)}</span>
  </div>
  <p className="text-[13px] text-[var(--vs-gris)]">Taxes (TPS et TVQ) calculées au paiement.</p>
  <button type="button" disabled className="h-[58px] cursor-not-allowed rounded-full bg-[var(--vs-accent)] text-[17px] font-extrabold text-[var(--vs-blanc)] opacity-60">
    Passer la commande
  </button>
  <p className="text-center text-[13px] text-[var(--vs-gris)]">Le paiement en ligne arrive bientôt.</p>
</aside>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_3__
cat > 'tickets/100e-vue-panier.md' <<'__VICTO_FIN_4__'
TICKET 100e — contenu de la page panier

Crée `src/components/panier/VuePanier.tsx`, export nommé `VuePanier`. Il lit le
panier, affiche les lignes et le récapitulatif, ou l'état vide. Le titre `<h1>`
n'est **pas** dans ce composant : la page le porte.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Icônes `lucide-react` avec `aria-hidden`. Apostrophes droites dans les textes.

## Bloc d'imports exact
```tsx
'use client';

import { ShoppingBag } from 'lucide-react';
import Link from 'next/link';
import { LignePanier } from '@/components/panier/LignePanier';
import { usePanier } from '@/components/panier/PanierProvider';
import { RecapPanier } from '@/components/panier/RecapPanier';
import { trouverProduit } from '@/lib/donnees';
import { detaillerPanier, libelleArticles, recapitulerPanier } from '@/lib/panier-detail';
```

## Logique et rendu
Taille attendue : ~55 lignes.

`export function VuePanier()` :
1. `const panier = usePanier();`
2. si `!panier.pret` : renvoie
   `<div data-testid="panier-chargement" aria-busy="true" className="min-h-[320px]" />`
   (le panier n'est pas encore relu : ne pas afficher un faux « panier vide ») ;
3. `const lignes = detaillerPanier(panier.lignes, trouverProduit);`
4. si `lignes.length === 0` : renvoie l'**état vide** :
```tsx
<div data-testid="panier-vide" className="flex flex-col items-center gap-[22px] py-20 text-center">
  <div className="flex h-24 w-24 items-center justify-center rounded-full bg-[var(--vs-surface)]">
    <ShoppingBag aria-hidden size={38} />
  </div>
  <h2 className="text-3xl font-black tracking-tight text-[var(--vs-noir)] lg:text-[44px]">Votre panier est vide</h2>
  <p className="max-w-[460px] text-base leading-relaxed text-[var(--vs-gris)]">Les grandes marques vous attendent, au bon prix.</p>
  <Link href="/soldes" className="flex h-14 items-center rounded-full bg-[var(--vs-accent)] px-8 text-base font-extrabold text-[var(--vs-blanc)]">
    Voir les soldes
  </Link>
</div>
```
5. sinon, `const recap = recapitulerPanier(lignes);` et renvoie :
```tsx
<div data-testid="panier-plein" className="grid gap-10 lg:grid-cols-[minmax(0,8fr)_minmax(0,4fr)] lg:items-start lg:gap-14">
  <div className="flex flex-col gap-5">
    <p data-testid="panier-articles" className="text-[15px] text-[var(--vs-gris)]">{libelleArticles(recap.articles)}</p>
    <ul className="border-t border-[var(--vs-ligne)]">
      {lignes.map((l) => (
        <LignePanier key={l.sku} ligne={l} onQuantite={panier.changerQuantite} onRetirer={panier.retirer} />
      ))}
    </ul>
    <Link href="/" className="self-start text-[15px] font-bold text-[var(--vs-noir)] underline">
      Continuer mes achats
    </Link>
  </div>
  <RecapPanier recap={recap} />
</div>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_4__
cat > 'tickets/100f-page-panier.md' <<'__VICTO_FIN_5__'
TICKET 100f — page panier

Crée `src/app/panier/page.tsx`. Ticket d'assemblage : le fichier est donné en entier,
recopie-le.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut `PagePanier`.** Aucun export nommé.
- Composant serveur : **pas** de `'use client'`.

## Fichier
Taille attendue : ~25 lignes.
```tsx
import { VuePanier } from '@/components/panier/VuePanier';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { COLONNES_PIED, NAV } from '@/lib/navigation';

export default function PagePanier() {
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Panier' }]} />
        <h1 className="mb-7 text-4xl font-black leading-none tracking-tight text-[var(--vs-noir)] lg:text-[56px]">
          Votre panier
        </h1>
        <VuePanier />
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_5__
cat > 'tickets/100g-marques.md' <<'__VICTO_FIN_6__'
TICKET 100g — résumé des marques

Crée `src/lib/marques.ts`. Fonctions **pures** : aucune ne modifie ses arguments.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`, `.filter`, `.sort` sur un tableau neuf.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Bloc d'imports exact
```ts
import { estEnPromotion, type Marque, type Produit } from '@/lib/catalogue';
```

## Exports exacts
Taille attendue : ~30 lignes.
```ts
export interface ResumeMarque {
  marque: Marque;
  nombre: number;
  enSoldes: number;
}
export function resumerMarques(marques: Marque[], produits: Produit[]): ResumeMarque[];
export function libelleMarques(n: number): string;
export function libelleProduits(n: number): string;
```

## Règles
**`resumerMarques`** :
1. pour chaque marque `m` (avec `.map`), `const siens = produits.filter((p) => p.marque.slug === m.slug);`
   puis `{ marque: m, nombre: siens.length, enSoldes: siens.filter(estEnPromotion).length }` ;
2. garde seulement les résumés dont `nombre > 0` (`.filter`) ;
3. trie ce **nouveau** tableau par nom de marque avec
   `.sort((a, b) => a.marque.nom.localeCompare(b.marque.nom, 'fr'))`.

**`libelleMarques`** et **`libelleProduits`** renvoient exactement
```ts
`${n} ${n > 1 ? 'marques' : 'marque'}`
`${n} ${n > 1 ? 'produits' : 'produit'}`
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_6__
cat > 'tickets/100h-tuile-marque.md' <<'__VICTO_FIN_7__'
TICKET 100h — tuile d'une marque

Crée `src/components/marques/TuileMarque.tsx`, export nommé `TuileMarque`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ; la
  teinte de fond se choisit par l'expression conditionnelle donnée plus bas, jamais
  dans un tableau.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Icône `lucide-react` avec `aria-hidden`.

## Bloc d'imports exact
```tsx
import { ArrowUpRight } from 'lucide-react';
import Link from 'next/link';
import { hrefMarque } from '@/lib/catalogue';
import { libelleProduits, type ResumeMarque } from '@/lib/marques';
```

## Props et rendu
Taille attendue : ~40 lignes.

`export function TuileMarque({ resume, rang }: { resume: ResumeMarque; rang: number })`, avec :
```tsx
const fond =
  rang % 3 === 0 ? 'bg-[#EEF1F8]' : rang % 3 === 1 ? 'bg-[#E9E4DA]' : 'bg-[var(--vs-surface)]';
```
rend :
```tsx
<Link
  href={hrefMarque(resume.marque)}
  data-testid={`tuile-marque-${resume.marque.slug}`}
  className={`flex h-[150px] flex-col justify-between rounded-[20px] p-4 text-[var(--vs-noir)] sm:h-[240px] sm:rounded-[28px] sm:p-7 ${fond}`}
>
  {resume.enSoldes > 0 ? (
    <span data-testid="tuile-soldes" className="self-start rounded-full bg-[var(--vs-promo)] px-[11px] py-[5px] text-xs font-extrabold text-[var(--vs-blanc)]">
      {`${resume.enSoldes} en soldes`}
    </span>
  ) : (
    <span />
  )}
  <div className="flex items-end justify-between gap-2">
    <div className="flex flex-col gap-1">
      <span className="text-lg font-black uppercase leading-none tracking-[0.04em] sm:text-[34px]">{resume.marque.nom}</span>
      <span data-testid="tuile-produits" className="text-xs text-[var(--vs-gris)] sm:text-sm">{libelleProduits(resume.nombre)}</span>
    </div>
    <span className="hidden h-11 w-11 shrink-0 items-center justify-center rounded-full bg-[var(--vs-blanc)] sm:flex">
      <ArrowUpRight aria-hidden size={18} />
    </span>
  </div>
</Link>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_7__
cat > 'tickets/100i-page-marques.md' <<'__VICTO_FIN_8__'
TICKET 100i — page des marques

Crée `src/app/marques/page.tsx`. Ticket d'assemblage : le fichier est donné en
entier, recopie-le. (La page `src/app/marques/[slug]/page.tsx` existe déjà et ne
change pas.)

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut `PageMarques`.** Aucun export nommé.
- Composant serveur : **pas** de `'use client'`.

## Fichier
Taille attendue : ~45 lignes.
```tsx
import { TuileMarque } from '@/components/marques/TuileMarque';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { MARQUES, PRODUITS } from '@/lib/donnees';
import { libelleMarques, resumerMarques } from '@/lib/marques';
import { COLONNES_PIED, NAV } from '@/lib/navigation';

export default function PageMarques() {
  const resumes = resumerMarques(MARQUES, PRODUITS);

  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Marques' }]} />
        <div className="mb-8 flex flex-wrap items-end justify-between gap-4">
          <div className="flex flex-col gap-3">
            <h1 className="text-[40px] font-black leading-none tracking-tight text-[var(--vs-noir)] lg:text-[64px]">Marques</h1>
            <p className="text-base text-[var(--vs-gris)] lg:text-[17px]">Les grandes marques de la sélection, au bon prix.</p>
          </div>
          <span data-testid="marques-nombre" className="text-[15px] text-[var(--vs-gris)]">
            {libelleMarques(resumes.length)}
          </span>
        </div>
        <div data-testid="grille-marques" className="grid grid-cols-2 gap-3 sm:gap-5 lg:grid-cols-3">
          {resumes.map((r, i) => (
            <TuileMarque key={r.marque.slug} resume={r} rang={i} />
          ))}
        </div>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_8__
cat > 'tickets/manifest-100.tsv' <<'__VICTO_FIN_9__'
100a	src/components/panier/PanierProvider.tsx	tests/panier-pret.test.tsx	tickets/100a-panier-pret.md			
100b	src/lib/panier-detail.ts	tests/panier-detail.test.ts	tickets/100b-panier-detail.md	src/lib/catalogue.ts,src/lib/panier.ts		
100c	src/components/panier/LignePanier.tsx	tests/LignePanier.test.tsx	tickets/100c-ligne-panier.md	src/lib/panier-detail.ts,src/lib/catalogue.ts,src/lib/fiche-produit.ts,src/lib/formatPrice.ts	100b	
100d	src/components/panier/RecapPanier.tsx	tests/RecapPanier.test.tsx	tickets/100d-recap-panier.md	src/lib/panier-detail.ts,src/lib/formatPrice.ts	100b	
100e	src/components/panier/VuePanier.tsx	tests/VuePanier.test.tsx	tickets/100e-vue-panier.md	src/components/panier/PanierProvider.tsx,src/components/panier/LignePanier.tsx,src/components/panier/RecapPanier.tsx,src/lib/panier-detail.ts,src/lib/donnees.ts	100a,100b,100c,100d	
100f	src/app/panier/page.tsx	tests/page-panier.test.tsx	tickets/100f-page-panier.md	src/components/panier/VuePanier.tsx,src/components/produit/FilAriane.tsx,src/lib/navigation.ts	100e	
100g	src/lib/marques.ts	tests/marques.test.ts	tickets/100g-marques.md	src/lib/catalogue.ts		
100h	src/components/marques/TuileMarque.tsx	tests/TuileMarque.test.tsx	tickets/100h-tuile-marque.md	src/lib/marques.ts,src/lib/catalogue.ts	100g	
100i	src/app/marques/page.tsx	tests/page-marques.test.tsx	tickets/100i-page-marques.md	src/components/marques/TuileMarque.tsx,src/components/produit/FilAriane.tsx,src/lib/marques.ts,src/lib/donnees.ts,src/lib/navigation.ts	100g,100h	
__VICTO_FIN_9__
cat > 'tickets/tests/LignePanier.test.tsx' <<'__VICTO_FIN_10__'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { LignePanier } from '../src/components/panier/LignePanier';
import { hrefProduit, type Produit } from '../src/lib/catalogue';
import { formatPrice } from '../src/lib/formatPrice';
import type { LigneDetaillee } from '../src/lib/panier-detail';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
function porte(el: Element, chaine: string) {
  const nom = el.getAttribute('aria-label') ?? el.getAttribute('data-testid') ?? el.textContent;
  for (const k of chaine.split(' ')) expect(classes(el), `${nom} : classe ${k} manquante`).toContain(k);
}
const SIMPLE: Produit = {
  id: 'p1', slug: 'pegasus', nom: 'Pegasus', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12600, categorie: 'chaussures',
  variantes: [{ id: 'v42', taille: '42', sku: 'peg-42', stock: 2 }],
};
const PROMO: Produit = { ...SIMPLE, prixCompareCents: 18000 };
function ligne(produit: Produit, quantite: number): LigneDetaillee {
  const variante = { id: 'v42', taille: '42', sku: 'peg-42', stock: 2 };
  return { slug: produit.slug, sku: 'peg-42', quantite, produit, variante, totalCents: produit.prixCents * quantite, economieCents: 0 };
}
function poser(l: LigneDetaillee) {
  const onQuantite = vi.fn();
  const onRetirer = vi.fn();
  render(<ul><LignePanier ligne={l} onQuantite={onQuantite} onRetirer={onRetirer} /></ul>);
  return { onQuantite, onRetirer };
}
const bouton = (nom: string) => screen.getByRole('button', { name: nom });

describe('LignePanier — contenu', () => {
  it('affiche marque, nom, pointure, prix remisé, prix barré et total', () => {
    poser(ligne(PROMO, 2));
    expect(screen.getByText('Nike')).toBeInTheDocument();
    expect(screen.getByTestId('ligne-pointure').textContent).toBe('Pointure 42');
    expect(screen.getByTestId('ligne-prix').textContent).toBe(formatPrice(12600));
    porte(screen.getByTestId('ligne-prix'), 'text-[var(--vs-promo)]');
    expect(screen.getByText(formatPrice(18000)).tagName).toBe('S');
    expect(screen.getByTestId('ligne-total').textContent).toBe(formatPrice(25200));
    expect(screen.getByTestId('ligne-quantite').textContent).toBe('2');
  });

  it('affiche un prix simple hors promotion', () => {
    poser(ligne(SIMPLE, 1));
    porte(screen.getByTestId('ligne-prix'), 'text-[var(--vs-noir)]');
    expect(screen.queryByText(formatPrice(18000))).toBeNull();
  });

  it('relie l’image et le nom à la fiche produit', () => {
    poser(ligne(SIMPLE, 1));
    const liens = screen.getAllByRole('link');
    expect(liens.map((l: HTMLElement) => l.getAttribute('href'))).toEqual([hrefProduit(SIMPLE), hrefProduit(SIMPLE)]);
    expect(screen.getAllByRole('link', { name: 'Pegasus' })).toHaveLength(2);
  });

  it('signale un stock bas', () => {
    poser(ligne(SIMPLE, 1));
    expect(screen.getByTestId('ligne-stock-bas').textContent).toBe('Plus que 2 paires en 42');
  });
});

describe('LignePanier — actions', () => {
  it('bloque la baisse à 1 et la hausse au stock', () => {
    const { unmount } = render(<ul><LignePanier ligne={ligne(SIMPLE, 1)} onQuantite={() => {}} onRetirer={() => {}} /></ul>);
    expect(bouton('Diminuer la quantité')).toBeDisabled();
    porte(bouton('Diminuer la quantité'), 'text-[#B5B5BA]');
    expect(bouton('Augmenter la quantité')).not.toBeDisabled();
    unmount();
    poser(ligne(SIMPLE, 2));
    expect(bouton('Augmenter la quantité')).toBeDisabled();
    expect(bouton('Diminuer la quantité')).not.toBeDisabled();
  });

  it('remonte la nouvelle quantité, le stock et le retrait', () => {
    const f = poser(ligne(SIMPLE, 2));
    fireEvent.click(bouton('Diminuer la quantité'));
    expect(f.onQuantite).toHaveBeenCalledWith('peg-42', 1, 2);
    fireEvent.click(bouton('Retirer'));
    expect(f.onRetirer).toHaveBeenCalledWith('peg-42');
  });
});
__VICTO_FIN_10__
cat > 'tickets/tests/RecapPanier.test.tsx' <<'__VICTO_FIN_11__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { RecapPanier } from '../src/components/panier/RecapPanier';
import { formatPrice } from '../src/lib/formatPrice';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('RecapPanier', () => {
  it('affiche sous-total, économies, livraison et total', () => {
    render(<RecapPanier recap={{ articles: 3, sousTotalCents: 34700, economiesCents: 10800, totalCents: 34700 }} />);
    expect(screen.getByText('Sous-total (3 articles)')).toBeInTheDocument();
    expect(screen.getByTestId('recap-sous-total').textContent).toBe(formatPrice(34700));
    expect(screen.getByTestId('recap-economies').textContent).toBe(`\u2212${formatPrice(10800)}`);
    expect(screen.getByText('Offerte')).toBeInTheDocument();
    expect(screen.getByTestId('recap-total').textContent).toBe(formatPrice(34700));
    expect(screen.getByRole('heading', { level: 2, name: 'Récapitulatif' })).toBeInTheDocument();
  });

  it('accorde au singulier et masque des économies nulles', () => {
    render(<RecapPanier recap={{ articles: 1, sousTotalCents: 14000, economiesCents: 0, totalCents: 14000 }} />);
    expect(screen.getByText('Sous-total (1 article)')).toBeInTheDocument();
    expect(screen.queryByTestId('recap-economies')).toBeNull();
  });

  it('désactive la commande en attendant le paiement en ligne', () => {
    render(<RecapPanier recap={{ articles: 1, sousTotalCents: 14000, economiesCents: 0, totalCents: 14000 }} />);
    const bouton = screen.getByRole('button', { name: 'Passer la commande' });
    expect(bouton).toBeDisabled();
    for (const k of ['cursor-not-allowed', 'bg-[var(--vs-accent)]', 'opacity-60']) expect(classes(bouton)).toContain(k);
    expect(screen.getByText('Le paiement en ligne arrive bientôt.')).toBeInTheDocument();
  });
});
__VICTO_FIN_11__
cat > 'tickets/tests/TuileMarque.test.tsx' <<'__VICTO_FIN_12__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { TuileMarque } from '../src/components/marques/TuileMarque';
import { hrefMarque, type Marque } from '../src/lib/catalogue';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const tuile = () => screen.getByTestId('tuile-marque-nike');

describe('TuileMarque', () => {
  it('mène à la page de la marque, avec son nom et son nombre de produits', () => {
    render(<TuileMarque resume={{ marque: NIKE, nombre: 14, enSoldes: 5 }} rang={0} />);
    expect(tuile()).toHaveAttribute('href', hrefMarque(NIKE));
    expect(tuile().textContent).toContain('Nike');
    expect(screen.getByTestId('tuile-produits').textContent).toBe('14 produits');
    expect(screen.getByTestId('tuile-soldes').textContent).toBe('5 en soldes');
    expect(tuile().querySelector('svg.lucide-arrow-up-right')).not.toBeNull();
  });

  it('n’affiche pas de pastille sans soldes', () => {
    render(<TuileMarque resume={{ marque: NIKE, nombre: 1, enSoldes: 0 }} rang={0} />);
    expect(screen.queryByTestId('tuile-soldes')).toBeNull();
    expect(screen.getByTestId('tuile-produits').textContent).toBe('1 produit');
  });

  it('alterne trois teintes selon le rang', () => {
    const teintes = [0, 1, 2, 3].map((rang) => {
      const { unmount } = render(<TuileMarque resume={{ marque: NIKE, nombre: 1, enSoldes: 0 }} rang={rang} />);
      const fond = classes(tuile()).filter((k) => k.startsWith('bg-'));
      unmount();
      return fond.join(' ');
    });
    expect(teintes).toEqual(['bg-[#EEF1F8]', 'bg-[#E9E4DA]', 'bg-[var(--vs-surface)]', 'bg-[#EEF1F8]']);
  });
});
__VICTO_FIN_12__
cat > 'tickets/tests/VuePanier.test.tsx' <<'__VICTO_FIN_13__'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { PanierProvider } from '../src/components/panier/PanierProvider';
import { VuePanier } from '../src/components/panier/VuePanier';
import { PRODUITS } from '../src/lib/donnees';
import { formatPrice } from '../src/lib/formatPrice';
import { CLE_PANIER } from '../src/lib/panier';

// Deux pointures réelles avec assez de stock pour monter à 2.
const CHOIX = PRODUITS.flatMap((p) => p.variantes.filter((v) => v.stock >= 2).map((v) => ({ p, v }))).filter(
  (c, i, tous) => tous.findIndex((x) => x.p.id === c.p.id) === i,
).slice(0, 2);
const [A, B] = [CHOIX[0]!, CHOIX[1]!];
const remplir = (lignes: Array<{ slug: string; sku: string; quantite: number }>) =>
  window.localStorage.setItem(CLE_PANIER, JSON.stringify(lignes));
const poser = () => render(<PanierProvider><VuePanier /></PanierProvider>);

beforeEach(() => window.localStorage.clear());

describe('VuePanier — panier vide', () => {
  it('invite à voir les soldes', () => {
    poser();
    const vide = screen.getByTestId('panier-vide');
    expect(within(vide).getByRole('heading', { level: 2, name: 'Votre panier est vide' })).toBeInTheDocument();
    expect(within(vide).getByRole('link', { name: 'Voir les soldes' })).toHaveAttribute('href', '/soldes');
    expect(screen.queryByTestId('recap-panier')).toBeNull();
  });

  it('traite une ligne dont le produit a disparu comme un panier vide', () => {
    remplir([{ slug: 'produit-disparu', sku: 'x-41', quantite: 1 }]);
    poser();
    expect(screen.getByTestId('panier-vide')).toBeInTheDocument();
  });
});

describe('VuePanier — panier rempli', () => {
  it('affiche les lignes, le nombre d’articles et le récapitulatif', () => {
    remplir([{ slug: A.p.slug, sku: A.v.sku, quantite: 1 }, { slug: B.p.slug, sku: B.v.sku, quantite: 1 }]);
    poser();
    expect(screen.getAllByTestId('ligne-panier')).toHaveLength(2);
    expect(screen.getByTestId('panier-articles').textContent).toBe('2 articles');
    expect(screen.getByTestId('recap-total').textContent).toBe(formatPrice(A.p.prixCents + B.p.prixCents));
    expect(screen.getByRole('link', { name: 'Continuer mes achats' })).toHaveAttribute('href', '/');
  });

  it('change une quantité puis retire une ligne', () => {
    remplir([{ slug: A.p.slug, sku: A.v.sku, quantite: 1 }, { slug: B.p.slug, sku: B.v.sku, quantite: 1 }]);
    poser();
    const premiere = () => screen.getAllByTestId('ligne-panier')[0]!;
    fireEvent.click(within(premiere()).getByRole('button', { name: 'Augmenter la quantité' }));
    expect(within(premiere()).getByTestId('ligne-quantite').textContent).toBe('2');
    expect(screen.getByTestId('panier-articles').textContent).toBe('3 articles');
    expect(screen.getByTestId('recap-total').textContent).toBe(formatPrice(A.p.prixCents * 2 + B.p.prixCents));
    fireEvent.click(within(premiere()).getByRole('button', { name: 'Retirer' }));
    expect(screen.getAllByTestId('ligne-panier')).toHaveLength(1);
    expect(screen.getByTestId('panier-articles').textContent).toBe('1 article');
  });

  it('se vide quand on retire la dernière ligne', () => {
    remplir([{ slug: A.p.slug, sku: A.v.sku, quantite: 1 }]);
    poser();
    fireEvent.click(screen.getByRole('button', { name: 'Retirer' }));
    expect(screen.getByTestId('panier-vide')).toBeInTheDocument();
  });
});
__VICTO_FIN_13__
cat > 'tickets/tests/marques.test.ts' <<'__VICTO_FIN_14__'
import { describe, expect, it } from 'vitest';
import type { Marque, Produit } from '../src/lib/catalogue';
import { libelleMarques, libelleProduits, resumerMarques } from '../src/lib/marques';

const M = (slug: string, nom: string): Marque => ({ id: slug, nom, slug });
const NIKE = M('nike', 'Nike');
const ADIDAS = M('adidas', 'Adidas');
const PUMA = M('puma', 'Puma');
const P = (id: string, marque: Marque, promo: boolean): Produit => {
  const base: Produit = {
    id, slug: id, nom: id, marque, imageUrl: '/img/x.svg', prixCents: 1000,
    variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 1 }],
  };
  return promo ? { ...base, prixCompareCents: 2000 } : base;
};
const PRODUITS = [P('a', NIKE, true), P('b', NIKE, false), P('c', ADIDAS, true), P('d', NIKE, true)];

describe('resumerMarques', () => {
  it('compte les produits et les soldes, par nom de marque', () => {
    expect(resumerMarques([NIKE, PUMA, ADIDAS], PRODUITS)).toEqual([
      { marque: ADIDAS, nombre: 1, enSoldes: 1 },
      { marque: NIKE, nombre: 3, enSoldes: 2 },
    ]);
  });

  it('écarte une marque sans produit et ne modifie pas la liste reçue', () => {
    const marques = [NIKE, PUMA, ADIDAS];
    resumerMarques(marques, PRODUITS);
    expect(marques.map((m) => m.slug)).toEqual(['nike', 'puma', 'adidas']);
    expect(resumerMarques([PUMA], PRODUITS)).toEqual([]);
  });
});

describe('libellés', () => {
  it('accordent en français, zéro au singulier', () => {
    expect([0, 1, 6].map(libelleMarques)).toEqual(['0 marque', '1 marque', '6 marques']);
    expect([0, 1, 14].map(libelleProduits)).toEqual(['0 produit', '1 produit', '14 produits']);
  });
});
__VICTO_FIN_14__
cat > 'tickets/tests/page-marques.test.tsx' <<'__VICTO_FIN_15__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageMarques from '../src/app/marques/page';
import { hrefMarque } from '../src/lib/catalogue';
import { MARQUES, PRODUITS } from '../src/lib/donnees';

const AVEC_PRODUITS = MARQUES.filter((m) => PRODUITS.some((p) => p.marque.slug === m.slug));

describe('page des marques', () => {
  it('assemble en-tête, titre, fil d’Ariane et pied', () => {
    render(<PageMarques />);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 1, name: 'Marques' })).toBeInTheDocument();
    expect(within(screen.getByTestId('fil-ariane')).getByText('Marques')).toHaveAttribute('aria-current', 'page');
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('montre une tuile par marque qui a des produits, triées par nom', () => {
    render(<PageMarques />);
    const tuiles = within(screen.getByTestId('grille-marques')).getAllByRole('link');
    expect(tuiles).toHaveLength(AVEC_PRODUITS.length);
    const attendues = [...AVEC_PRODUITS].sort((a, b) => a.nom.localeCompare(b.nom, 'fr')).map((m) => hrefMarque(m));
    expect(tuiles.map((t: HTMLElement) => t.getAttribute('href'))).toEqual(attendues);
    expect(screen.getByTestId('marques-nombre').textContent).toBe(
      `${AVEC_PRODUITS.length} ${AVEC_PRODUITS.length > 1 ? 'marques' : 'marque'}`,
    );
  });
});
__VICTO_FIN_15__
cat > 'tickets/tests/page-panier.test.tsx' <<'__VICTO_FIN_16__'
import { render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PagePanier from '../src/app/panier/page';
import { PanierProvider } from '../src/components/panier/PanierProvider';
import { PRODUITS } from '../src/lib/donnees';
import { CLE_PANIER } from '../src/lib/panier';

const PRODUIT = PRODUITS.find((p) => p.variantes.some((v) => v.stock > 0))!;
const VARIANTE = PRODUIT.variantes.find((v) => v.stock > 0)!;

beforeEach(() => window.localStorage.clear());

describe('page panier', () => {
  it('assemble en-tête, fil d’Ariane, titre, contenu et pied', () => {
    render(<PanierProvider><PagePanier /></PanierProvider>);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 1, name: 'Votre panier' })).toBeInTheDocument();
    const fil = screen.getByTestId('fil-ariane');
    expect(within(fil).getByRole('link', { name: 'Accueil' })).toHaveAttribute('href', '/');
    expect(within(fil).getByText('Panier')).toHaveAttribute('aria-current', 'page');
    expect(screen.getByTestId('panier-vide')).toBeInTheDocument();
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('montre le panier enregistré et le même nombre dans l’en-tête', () => {
    window.localStorage.setItem(CLE_PANIER, JSON.stringify([{ slug: PRODUIT.slug, sku: VARIANTE.sku, quantite: 1 }]));
    render(<PanierProvider><PagePanier /></PanierProvider>);
    expect(screen.getAllByTestId('ligne-panier')).toHaveLength(1);
    expect(screen.getByTestId('entete-panier-compte').textContent).toBe('1');
  });
});
__VICTO_FIN_16__
cat > 'tickets/tests/panier-detail.test.ts' <<'__VICTO_FIN_17__'
import { describe, expect, it } from 'vitest';
import type { Produit } from '../src/lib/catalogue';
import { detaillerPanier, libelleArticles, recapitulerPanier } from '../src/lib/panier-detail';

const PROMO: Produit = {
  id: 'p1', slug: 'pegasus', nom: 'Pegasus', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12600, prixCompareCents: 18000,
  variantes: [{ id: 'v42', taille: '42', sku: 'peg-42', stock: 3 }],
};
const SIMPLE: Produit = {
  id: 'p2', slug: 'samba', nom: 'Samba', marque: { id: 'm2', nom: 'Adidas', slug: 'adidas' },
  imageUrl: '/img/y.svg', prixCents: 14000,
  variantes: [{ id: 'v41', taille: '41', sku: 'sam-41', stock: 5 }],
};
const trouver = (slug: string) => [PROMO, SIMPLE].find((p) => p.slug === slug);

describe('detaillerPanier', () => {
  it('joint produit et variante, et calcule total et économie', () => {
    const d = detaillerPanier([{ slug: 'pegasus', sku: 'peg-42', quantite: 2 }], trouver);
    expect(d).toHaveLength(1);
    expect(d[0]?.produit).toBe(PROMO);
    expect(d[0]?.variante.taille).toBe('42');
    expect(d[0]?.totalCents).toBe(25200);
    expect(d[0]?.economieCents).toBe(10800);
  });

  it('n’invente pas d’économie hors promotion', () => {
    expect(detaillerPanier([{ slug: 'samba', sku: 'sam-41', quantite: 1 }], trouver)[0]?.economieCents).toBe(0);
  });

  it('ignore un produit ou une pointure disparus, sans changer l’ordre', () => {
    const d = detaillerPanier([
      { slug: 'samba', sku: 'sam-41', quantite: 1 },
      { slug: 'inconnu', sku: 'x', quantite: 1 },
      { slug: 'pegasus', sku: 'peg-99', quantite: 1 },
      { slug: 'pegasus', sku: 'peg-42', quantite: 1 },
    ], trouver);
    expect(d.map((l) => l.sku)).toEqual(['sam-41', 'peg-42']);
  });
});

describe('recapitulerPanier', () => {
  it('additionne articles, sous-total et économies', () => {
    const d = detaillerPanier([
      { slug: 'pegasus', sku: 'peg-42', quantite: 2 },
      { slug: 'samba', sku: 'sam-41', quantite: 1 },
    ], trouver);
    expect(recapitulerPanier(d)).toEqual({ articles: 3, sousTotalCents: 39200, economiesCents: 10800, totalCents: 39200 });
  });

  it('rend quatre zéros pour un panier vide', () => {
    expect(recapitulerPanier([])).toEqual({ articles: 0, sousTotalCents: 0, economiesCents: 0, totalCents: 0 });
  });
});

describe('libelleArticles', () => {
  it('accorde en français, zéro au singulier', () => {
    expect([0, 1, 2].map(libelleArticles)).toEqual(['0 article', '1 article', '2 articles']);
  });
});
__VICTO_FIN_17__
cat > 'tickets/tests/panier-pret.test.tsx' <<'__VICTO_FIN_18__'
import { readFileSync } from 'node:fs';
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { PanierProvider, usePanier } from '../src/components/panier/PanierProvider';

function Temoin() {
  const p = usePanier();
  return <span data-testid="pret">{String(p.pret)}</span>;
}

describe('PanierProvider — pret', () => {
  it('est prêt hors du fournisseur', () => {
    render(<Temoin />);
    expect(screen.getByTestId('pret').textContent).toBe('true');
  });

  it('est prêt une fois le panier relu', () => {
    render(<PanierProvider><Temoin /></PanierProvider>);
    expect(screen.getByTestId('pret').textContent).toBe('true');
  });

  it('déclare le champ dans le contrat', () => {
    const source = readFileSync('src/components/panier/PanierProvider.tsx', 'utf8');
    expect(source).toMatch(/nombre: number;\s*pret: boolean;/);
    expect(source).toContain('pret: true');
  });
});
__VICTO_FIN_18__
TESTS=(LignePanier.test.tsx RecapPanier.test.tsx TuileMarque.test.tsx VuePanier.test.tsx marques.test.ts page-marques.test.tsx page-panier.test.tsx panier-detail.test.ts panier-pret.test.tsx)

# ------------------------------------------------------------ 100j : l'icône du panier mène-t-elle à /panier ?
cat > /tmp/victo-analyse-entete.py <<'__ANALYSE__'
"""Usage : python3 analyse-entete.py src/components/ui/SiteHeader.tsx
Affiche « balise href » de l'élément data-testid="entete-panier" (href vide si absent)."""
import re, sys
s = open(sys.argv[1], encoding='utf-8').read()
m = re.search(r'data-testid="entete-panier"(?!-)', s)
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
read -r BALISE HREF <<< "$(python3 /tmp/victo-analyse-entete.py src/components/ui/SiteHeader.tsx)"
ECRIRE_100J=1
case "$BALISE" in
  a|Link)
    if [ "$HREF" = '"/panier"' ]; then ok "l'icône du panier mène déjà à /panier"; ECRIRE_100J=0
    else
      cat > tickets/100j-entete-lien-panier.md <<'__SPEC__'
TICKET 100j — l'icône du panier mène à la page panier

Modifie `src/components/ui/SiteHeader.tsx`. Un seul changement : sur l'élément qui
porte `data-testid="entete-panier"`, l'attribut `href` prend exactement la valeur
`"/panier"`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Garde le bloc d'imports actuel à l'identique. Aucune autre ligne ne change :
  ni les classes, ni les textes, ni les autres attributs.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__SPEC__
      ok "l'icône du panier mène à $HREF : ticket 100j généré (href → /panier)"
    fi ;;
  button)
    cat > tickets/100j-entete-lien-panier.md <<'__SPEC__'
TICKET 100j — l'icône du panier mène à la page panier

Modifie `src/components/ui/SiteHeader.tsx`. L'élément qui porte
`data-testid="entete-panier"` est aujourd'hui un `<button>` : il devient un lien Next
vers `/panier`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Aucune autre ligne ne change : ni les classes, ni les textes, ni le contenu de
  l'élément.

## Les deux changements
1. Remplace la balise ouvrante `<button …>` de cet élément par `<Link href="/panier" …>`,
   avec **exactement les mêmes attributs**, sauf `type="button"` et un éventuel
   `onClick`, que tu retires. Remplace sa balise fermante `</button>` par `</Link>`.
   Son contenu (icône, pastille du nombre) ne change pas.
2. Si la ligne `import Link from 'next/link';` n'est pas déjà dans les imports,
   ajoute-la à la suite des imports existants.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__SPEC__
    ok "l'icône du panier est un bouton : ticket 100j généré (bouton → lien /panier)"
    boutons="$(grep -rlE "getByRole\('button'[^)]*[Pp]anier" tests || true)"
    [ -z "$boutons" ] || info "ces tests cherchent le panier comme un bouton, 100j pourrait caler : $(echo $boutons)" ;;
  *) info "élément entete-panier introuvable ou inattendu ($BALISE) : pas de ticket 100j"; ECRIRE_100J=0 ;;
esac
if [ "$ECRIRE_100J" = 1 ]; then
  cat > tickets/tests/entete-lien-panier.test.tsx <<'__TEST__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteHeader } from '../src/components/ui/SiteHeader';

describe('en-tête — lien du panier', () => {
  it('mène à la page panier', () => {
    render(<SiteHeader navItems={[]} />);
    const lien = screen.getByTestId('entete-panier').closest('a');
    expect(lien?.getAttribute('href')).toBe('/panier');
  });
});
__TEST__
  printf '100j\tsrc/components/ui/SiteHeader.tsx\ttests/entete-lien-panier.test.tsx\ttickets/100j-entete-lien-panier.md\t\t\t\n' >> tickets/manifest-100.tsv
  TESTS+=(entete-lien-panier.test.tsx)
fi
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
ok "$(wc -l < tickets/manifest-100.tsv) tickets écrits, manifeste tickets/manifest-100.tsv"

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/100*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-100.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
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
  git commit -q -m "chore(tickets): lot 100 — page panier et page des marques"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-100.tsv ./run.sh\n\n%s tickets. Le panier et les marques avancent en parallèle ; chaque page attend ses composants.\nCompte deux heures à deux heures et demie : un run à lancer le soir.\n' "$(wc -l < tickets/manifest-100.tsv)"
