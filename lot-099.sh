#!/usr/bin/env bash
# VICTO STORE — lot 099 : la fiche produit /produits/[slug], d'après la maquette validée.
#   099a  src/lib/fiche-produit.ts               fil d'Ariane, stock bas, produits similaires
#   099b  src/components/produit/FilAriane       099c  GalerieProduit        099d  SelecteurPointure
#   099e  BlocAchat (prix, pointure, quantité, ajout au panier)   099f  InfosProduit (réassurance, sections)
#   099g  src/app/produits/[slug]/page.tsx       assemblage, 404, « Vous aimerez aussi »
# Nettoyage : exception de FiltresBarre retirée de la garde des jetons ; rattrapage-095c.sh supprimé.
# Avant livraison : l'environnement (notFound sous vitest) et chaque test passent un pré-vol.
# Usage :  cd ~/victo-store && bash lot-099.sh
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
for d in 098a 098b 098c; do fusionne "$d" || mort "$d n'est pas fusionné : la fiche a besoin du panier et du compteur"; done
grep -q "/produits/" src/lib/catalogue.ts || mort "hrefProduit ne mène pas à /produits/… : la page serait créée au mauvais endroit"
for f in src/lib/formatPrice.ts src/lib/donnees.ts src/components/panier/PanierProvider.tsx src/components/ui/ProductCard.tsx; do
  [ -f "$f" ] || mort "$f absent"; done
grep -q "export function formatPrice" src/lib/formatPrice.ts || mort "formatPrice n'est pas exporté de src/lib/formatPrice.ts"
grep -q "LIBELLES_CATEGORIE" src/lib/catalogue.ts || mort "LIBELLES_CATEGORIE absent de catalogue.ts"
grep -qE "export (function|const) trouverProduit" src/lib/donnees.ts || mort "trouverProduit absent de donnees.ts"
[ ! -e src/app/produits ] && [ ! -e src/components/produit ] && [ ! -e src/lib/fiche-produit.ts ] || mort "un fichier de la fiche produit existe déjà : lot déjà passé ?"
for j in noir blanc surface ligne gris accent promo; do grep -qE -- "--vs-$j\s*:" src/styles/tokens.css || mort "jeton --vs-$j absent"; done
ok "panier fusionné, liens produit, modules et jetons conformes aux specs"

# L'environnement : la page lève notFound() pour un produit inconnu ; vitest doit savoir l'importer.
cat > tests/zz-prevol-env.test.ts <<'__ENV__'
import { notFound } from 'next/navigation';
import { expect, it } from 'vitest';
it('notFound se lève sous vitest', () => { expect(() => notFound()).toThrow(); });
__ENV__
npx --no-install vitest run tests/zz-prevol-env.test.ts > /tmp/victo-prevol.log 2>&1 || true
rm -f tests/zz-prevol-env.test.ts; sed -i -E 's/\x1b\[[0-9;]*m//g' /tmp/victo-prevol.log
grep -qE "Tests +1 passed" /tmp/victo-prevol.log || { tail -12 /tmp/victo-prevol.log; mort "notFound() de next/navigation ne fonctionne pas sous vitest : le test de la page ne le pourrait pas non plus"; }
ok "environnement : notFound() se lève sous vitest"

trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
mkdir -p tickets/tests
cat > 'tickets/099a-fiche-produit.md' <<'__VICTO_FIN_0__'
TICKET 099a — logique de la fiche produit

Crée `src/lib/fiche-produit.ts`. Fonctions **pures** : aucune ne modifie ses
arguments.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index
  (`tableau[i]`) ; utilise `.find`, `.map`, `.filter`, `.slice`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Aucun fichier baril n'existe.**

## Bloc d'imports exact
```ts
import { hrefMarque, LIBELLES_CATEGORIE, type Produit } from '@/lib/catalogue';
```

## Exports exacts
Taille attendue : ~55 lignes.
```ts
export interface ElementFil {
  label: string;
  href?: string;
}
export const TEXTE_LIVRAISON =
  "Expédiée du Québec sous 48 heures, livraison offerte partout au Canada. Retours gratuits pendant 30 jours, article non porté dans sa boîte d'origine.";

export function filAriane(produit: Produit): ElementFil[];
export function texteStockBas(produit: Produit, taille: string | null): string | null;
export function produitsSimilaires(produit: Produit, tous: Produit[], nombre?: number): Produit[];
```

## Règles
**`filAriane`** renvoie, dans cet ordre :
1. `{ label: 'Accueil', href: '/' }` ;
2. seulement si `produit.categorie` est défini : si c'est `'chaussures'`,
   `{ label: LIBELLES_CATEGORIE[produit.categorie], href: '/chaussures' }` ; sinon
   `{ label: LIBELLES_CATEGORIE[produit.categorie] }`, **sans clé `href`** ;
3. `{ label: produit.marque.nom, href: hrefMarque(produit.marque) }` ;
4. `{ label: produit.nom }`, sans clé `href`.

Un élément sans lien ne contient pas la clé `href` du tout (pas `href: undefined`).

**`texteStockBas`** :
- `taille` vaut `null` → `null` ;
- `const variante = produit.variantes.find((v) => v.taille === taille);` ; si elle
  n'existe pas, ou si `variante.stock <= 0`, ou si `variante.stock > 3` → `null` ;
- sinon, avec `n = variante.stock`, renvoie exactement
  ```ts
  `Plus que ${n} ${unite} en ${taille}`
  ```
  où `unite` vaut, pour `produit.categorie === 'chaussures'`,
  `n > 1 ? 'paires' : 'paire'`, et pour toute autre catégorie (ou aucune),
  `n > 1 ? 'pièces' : 'pièce'`.

**`produitsSimilaires`** (`nombre` vaut 4 par défaut) :
1. `autres` = `tous` sans le produit lui-même (comparaison par `id`) ;
2. d'abord les `autres` de la même `categorie` que le produit, dans leur ordre,
   puis les `autres` d'une catégorie différente, dans leur ordre ;
3. renvoie les `nombre` premiers avec `.slice(0, nombre)`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_0__
cat > 'tickets/099b-fil-ariane.md' <<'__VICTO_FIN_1__'
TICKET 099b — fil d'Ariane

Crée `src/components/produit/FilAriane.tsx`, export nommé `FilAriane`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  pour savoir si un élément est le dernier, compare son rang `i` (donné par `.map`)
  à `items.length - 1`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.

## Bloc d'imports exact
```tsx
import Link from 'next/link';
import type { ElementFil } from '@/lib/fiche-produit';
```

## Rendu
Taille attendue : ~30 lignes.

`export function FilAriane({ items }: { items: ElementFil[] })` rend :
```tsx
<nav aria-label="Fil d'Ariane" data-testid="fil-ariane" className="flex flex-wrap items-center gap-2.5 py-4 text-sm text-[var(--vs-gris)]">
  <ol className="flex flex-wrap items-center gap-2.5">
    {/* un <li> par élément */}
  </ol>
</nav>
```
Pour chaque élément `e` de rang `i`, un `<li className="flex items-center gap-2.5">`
qui contient, dans l'ordre :
- si `i > 0` : `<span aria-hidden="true">/</span>` ;
- si `i === items.length - 1` (le dernier) :
  `<span aria-current="page" className="font-semibold text-[var(--vs-noir)]">{e.label}</span>` ;
- sinon, si `e.href` est défini : `<Link href={e.href}>{e.label}</Link>` ;
- sinon : `<span>{e.label}</span>`.

Le commentaire du bloc de rendu indique seulement où placer les `<li>` : ne le
recopie pas. `aria-current` n'apparaît que sur le dernier élément ; ne l'écris
jamais avec une valeur `false` (pour les autres, n'écris pas l'attribut, ou donne
`undefined`).

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > 'tickets/099c-galerie-produit.md' <<'__VICTO_FIN_2__'
TICKET 099c — galerie de la fiche produit

Crée `src/components/produit/GalerieProduit.tsx`, export nommé `GalerieProduit`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
  L'image affichée se lit avec
  `const courante = images.find((_, i) => i === vue) ?? '';`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Utilise une balise `<img>` ordinaire, pas `next/image`.

## Bloc d'imports exact
```tsx
'use client';

import { useState } from 'react';
```

## Props et état
Taille attendue : ~50 lignes.
```ts
interface GalerieProduitProps {
  images: string[];
  nom: string;
  remise: number | null;
}
```
État : `const [vue, setVue] = useState(0);` (rang de l'image affichée).

## Rendu
```tsx
<div data-testid="galerie" className="flex flex-col gap-4">
  <div className="relative flex aspect-square items-center justify-center overflow-hidden rounded-[28px] bg-[var(--vs-surface)] lg:aspect-auto lg:h-[680px]">
    {/* pastille de remise */}
    <img src={courante} alt={`${nom}, vue ${vue + 1}`} className="h-full w-full object-contain" />
  </div>
  {/* vignettes */}
</div>
```
**Pastille de remise**, seulement si `remise !== null` :
```tsx
<span data-testid="galerie-remise" className="absolute left-6 top-6 rounded-full bg-[var(--vs-promo)] px-[13px] py-[7px] text-sm font-extrabold text-[var(--vs-blanc)]">
  {`\u2212${remise}\u00a0%`}
</span>
```
**Vignettes**, seulement si `images.length > 1` :
`<div className="grid grid-cols-4 gap-4">` contenant, pour chaque image `src` de
rang `i` (avec `images.map((src, i) => ...)` et `key={src + i}`), un bouton avec
exactement ces attributs :
```tsx
type="button"
aria-label={`Afficher la vue ${i + 1}`}
aria-pressed={i === vue}
onClick={() => setVue(i)}
className={i === vue
  ? 'h-[110px] overflow-hidden rounded-[18px] border-2 border-[var(--vs-noir)] bg-[var(--vs-surface)]'
  : 'h-[110px] overflow-hidden rounded-[18px] border-2 border-transparent bg-[var(--vs-surface)]'}
```
et pour seul contenu `<img src={src} alt="" className="h-full w-full object-contain" />`.

Les deux commentaires du bloc de rendu indiquent seulement où placer ces
éléments : ne les recopie pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_2__
cat > 'tickets/099d-selecteur-pointure.md' <<'__VICTO_FIN_3__'
TICKET 099d — choix de la pointure

Crée `src/components/produit/SelecteurPointure.tsx`, export nommé `SelecteurPointure`.
Composant **sans état** : la pointure choisie vient des props.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.

## Bloc d'imports exact
```tsx
import type { Variante } from '@/lib/catalogue';
```

## Props
Taille attendue : ~45 lignes.
```ts
interface SelecteurPointureProps {
  variantes: Variante[];
  valeur: string | null;
  onChoisir: (taille: string) => void;
}
```

## Rendu
```tsx
<div data-testid="selecteur-pointure" className="flex flex-col gap-3.5">
  <span id="libelle-pointure" className="text-[15px] font-extrabold text-[var(--vs-noir)]">
    Pointure{' '}
    <span data-testid="pointure-choisie" className="font-medium text-[var(--vs-gris)]">
      {valeur ?? '— à choisir'}
    </span>
  </span>
  <div role="group" aria-labelledby="libelle-pointure" className="grid grid-cols-3 gap-2.5 sm:grid-cols-6">
    {/* un bouton par variante */}
  </div>
</div>
```
Pour chaque variante `v` (avec `variantes.map((v) => ...)` et `key={v.id}`), avec
`const choisie = v.taille === valeur;` et `const epuisee = v.stock <= 0;`, un bouton
de contenu `{v.taille}` et d'attributs exactement :
```tsx
type="button"
aria-pressed={choisie}
disabled={epuisee}
onClick={() => onChoisir(v.taille)}
className={choisie
  ? 'h-14 rounded-[14px] border-[1.5px] text-base font-bold border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]'
  : epuisee
    ? 'h-14 rounded-[14px] border-[1.5px] text-base font-bold cursor-not-allowed border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[#B5B5BA] line-through'
    : 'h-14 rounded-[14px] border-[1.5px] text-base font-bold border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]'}
```
Un bouton désactivé ne déclenche pas `onClick` : aucune autre garde n'est à écrire.
Le commentaire du bloc de rendu indique seulement où placer les boutons : ne le
recopie pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_3__
cat > 'tickets/099e-bloc-achat.md' <<'__VICTO_FIN_4__'
TICKET 099e — bloc d'achat de la fiche produit

Crée `src/components/produit/BlocAchat.tsx`, export nommé `BlocAchat`. Il affiche
le prix, la description, le choix de pointure, la quantité, et ajoute au panier.
Le titre `<h1>` n'est **pas** dans ce composant : la page le porte.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
  La variante choisie se lit toujours avec
  `produit.variantes.find((v) => v.taille === taille)`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Aucun fichier baril n'existe.** Les déclarations des modules importés te sont
  fournies en lecture seule.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Icônes `lucide-react` avec `aria-hidden`. Apostrophes droites (`'`) dans tous les textes.

## Bloc d'imports exact
```tsx
'use client';

import { Check, Heart } from 'lucide-react';
import { useState } from 'react';
import { usePanier } from '@/components/panier/PanierProvider';
import { SelecteurPointure } from '@/components/produit/SelecteurPointure';
import { economieCents, estEnPromotion, type Produit } from '@/lib/catalogue';
import { texteStockBas } from '@/lib/fiche-produit';
import { formatPrice } from '@/lib/formatPrice';
```

## Props, état, logique
Taille attendue : ~120 lignes.

`export function BlocAchat({ produit }: { produit: Produit })`, avec :
```tsx
const panier = usePanier();
const [taille, setTaille] = useState<string | null>(null);
const [quantite, setQuantite] = useState(1);
const [favori, setFavori] = useState(false);
const [erreur, setErreur] = useState(false);
const [confirme, setConfirme] = useState(false);
const promo = estEnPromotion(produit);
const choisie = produit.variantes.find((v) => v.taille === taille);
const plafond = choisie ? choisie.stock : 9;
const alerte = texteStockBas(produit, taille);
```
- **`choisir(t: string)`** (passée à `onChoisir`) : `setTaille(t)`, `setErreur(false)`,
  `setConfirme(false)`, puis, si la variante de pointure `t` existe (lue avec `.find`),
  `setQuantite((q) => Math.min(q, Math.max(1, variante.stock)))`.
- **Moins** : `setQuantite(Math.max(1, quantite - 1))`. **Plus** :
  `setQuantite(Math.min(plafond, quantite + 1))`.
- **`ajouter()`** : si `choisie` est indéfinie → `setErreur(true)`,
  `setConfirme(false)`, et rien d'autre. Sinon
  `panier.ajouter({ slug: produit.slug, sku: choisie.sku }, quantite, choisie.stock)`,
  puis `setErreur(false)` et `setConfirme(true)`.

## Rendu
Racine : `<div data-testid="bloc-achat" className="flex flex-col gap-[22px]">`, qui
contient dans l'ordre :

**1. Prix** — `<div className="flex flex-wrap items-baseline gap-3.5">` :
```tsx
<span data-testid="fiche-prix" className={promo
  ? 'text-[32px] font-black text-[var(--vs-promo)]'
  : 'text-[32px] font-black text-[var(--vs-noir)]'}>
  {formatPrice(produit.prixCents)}
</span>
```
puis, seulement si `promo` et `produit.prixCompareCents !== undefined` :
`<s data-testid="fiche-prix-barre" className="text-lg text-[var(--vs-gris)]">{formatPrice(produit.prixCompareCents)}</s>`,
puis, seulement si `promo` :
`<span data-testid="fiche-economie" className="rounded-full bg-[#FFD3DB] px-[11px] py-[5px] text-sm font-extrabold text-[var(--vs-promo)]">{`Économisez ${formatPrice(economieCents(produit))}`}</span>`.

**2. Description**, seulement si `produit.description` est défini :
`<p data-testid="fiche-description" className="text-base leading-relaxed text-[var(--vs-gris)]">{produit.description}</p>`.

**3. Séparateur** : `<div className="h-px bg-[var(--vs-ligne)]" />`.

**4. Pointure** : `<SelecteurPointure variantes={produit.variantes} valeur={taille} onChoisir={choisir} />`,
puis, seulement si `alerte !== null` :
`<p data-testid="stock-bas" className="text-sm font-bold text-[var(--vs-promo)]">{alerte}</p>`.

**5. Actions** — `<div className="flex flex-wrap items-stretch gap-3">`, avec dans
l'ordre la quantité, le bouton d'ajout, le favori :
```tsx
<div className="flex h-[58px] items-center rounded-full border-[1.5px] border-[var(--vs-ligne)]">
  <button type="button" aria-label="Diminuer la quantité" disabled={quantite <= 1} onClick={moins}
    className={quantite <= 1 ? 'h-14 w-[52px] text-[22px] text-[#B5B5BA]' : 'h-14 w-[52px] text-[22px] text-[var(--vs-noir)]'}>
    −
  </button>
  <span data-testid="quantite" aria-live="polite" className="min-w-7 text-center text-[17px] font-extrabold">{quantite}</span>
  <button type="button" aria-label="Augmenter la quantité" onClick={plus} className="h-14 w-[52px] text-[22px] text-[var(--vs-noir)]">
    +
  </button>
</div>
<button type="button" onClick={ajouter}
  className="order-last h-[58px] basis-full rounded-full bg-[var(--vs-accent)] text-[17px] font-extrabold text-[var(--vs-blanc)] sm:order-none sm:basis-auto sm:flex-1">
  Ajouter au panier
</button>
<button type="button" aria-label="Ajouter aux favoris" aria-pressed={favori} onClick={() => setFavori(!favori)}
  className="flex h-[58px] w-[58px] items-center justify-center rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)]">
  <Heart aria-hidden size={20} className={favori ? 'fill-[var(--vs-promo)] text-[var(--vs-promo)]' : 'text-[var(--vs-noir)]'} />
</button>
```
(`moins` et `plus` sont les deux fonctions décrites plus haut.)

**6. Erreur**, seulement si `erreur` :
`<p role="alert" className="text-sm font-bold text-[var(--vs-promo)]">Choisissez une pointure avant d'ajouter au panier.</p>`.

**7. Confirmation**, seulement si `confirme` :
```tsx
<p role="status" className="flex items-center gap-2 text-sm font-bold text-[var(--vs-accent)]">
  <Check aria-hidden size={18} />
  {`Ajouté au panier — pointure ${taille}, quantité ${quantite}`}
</p>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_4__
cat > 'tickets/099f-infos-produit.md' <<'__VICTO_FIN_5__'
TICKET 099f — réassurance et sections repliables

Crée `src/components/produit/InfosProduit.tsx`, export nommé `InfosProduit`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.filter` et `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Icônes `lucide-react` avec `aria-hidden`. Apostrophes droites (`'`) dans les textes.

## Bloc d'imports exact
```tsx
'use client';

import { ChevronDown, RotateCcw, ShieldCheck, Truck } from 'lucide-react';
import { useState } from 'react';
import type { Produit } from '@/lib/catalogue';
import { TEXTE_LIVRAISON } from '@/lib/fiche-produit';
```

## Logique
Taille attendue : ~65 lignes.

`export function InfosProduit({ produit }: { produit: Produit })`, avec :
```tsx
const sections = [
  { titre: 'Description', texte: produit.description ?? '' },
  { titre: 'Détails et composition', texte: produit.composition ?? '' },
  { titre: 'Livraison et retours', texte: TEXTE_LIVRAISON },
].filter((s) => s.texte !== '');
const [ouverts, setOuverts] = useState<number[]>([0]);
```
`basculer(i)` : `setOuverts((o) => (o.includes(i) ? o.filter((x) => x !== i) : [...o, i]))`.
La première section affichée est donc ouverte au départ, les autres fermées.

## Rendu
Racine : `<div data-testid="infos-produit" className="flex flex-col gap-[22px]">`.

**1. Réassurance** :
```tsx
<ul className="flex flex-col gap-3.5 rounded-[20px] bg-[var(--vs-surface)] p-5">
  <li className="flex items-center gap-3 text-sm"><Truck aria-hidden size={18} /><span><strong>Livraison offerte</strong> — reçue d'ici 2 à 4 jours ouvrables</span></li>
  <li className="flex items-center gap-3 text-sm"><RotateCcw aria-hidden size={18} /><span><strong>Retours gratuits</strong> pendant 30 jours</span></li>
  <li className="flex items-center gap-3 text-sm"><ShieldCheck aria-hidden size={18} /><span><strong>Authenticité garantie</strong>, neuf en boîte d'origine</span></li>
</ul>
```

**2. Sections** — `<div className="border-t border-[var(--vs-ligne)]">` contenant,
pour chaque section `s` de rang `i` (`sections.map((s, i) => ...)`, `key={s.titre}`),
avec `const ouvert = ouverts.includes(i);` :
```tsx
<div className="border-b border-[var(--vs-ligne)]">
  <button type="button" aria-expanded={ouvert} onClick={() => basculer(i)}
    className="flex h-16 w-full items-center justify-between text-left text-base font-extrabold text-[var(--vs-noir)]">
    {s.titre}
    <ChevronDown aria-hidden size={18} className={ouvert ? 'rotate-180' : undefined} />
  </button>
  {ouvert && <p className="mb-5 text-[15px] leading-relaxed text-[var(--vs-gris)]">{s.texte}</p>}
</div>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_5__
cat > 'tickets/099g-page-produit.md' <<'__VICTO_FIN_6__'
TICKET 099g — page de la fiche produit

Crée `src/app/produits/[slug]/page.tsx`. Ticket d'assemblage : le fichier est
donné presque en entier, recopie-le.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut `PageProduit`.** Aucun export nommé, pas
  de `generateStaticParams`, pas de `metadata`.
- Composant serveur : **pas** de `'use client'`. Les déclarations des modules
  importés te sont fournies en lecture seule.

## Fichier
Taille attendue : ~60 lignes.
```tsx
import Link from 'next/link';
import { notFound } from 'next/navigation';
import { BlocAchat } from '@/components/produit/BlocAchat';
import { FilAriane } from '@/components/produit/FilAriane';
import { GalerieProduit } from '@/components/produit/GalerieProduit';
import { InfosProduit } from '@/components/produit/InfosProduit';
import { ProductCard } from '@/components/ui/ProductCard';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { hrefMarque, imagesProduit, remisePourcent } from '@/lib/catalogue';
import { listerProduits, trouverProduit } from '@/lib/donnees';
import { filAriane, produitsSimilaires } from '@/lib/fiche-produit';
import { COLONNES_PIED, NAV } from '@/lib/navigation';

export default async function PageProduit({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const produit = trouverProduit(slug);
  if (!produit) notFound();
  const similaires = produitsSimilaires(produit, listerProduits());

  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={filAriane(produit)} />
        <section className="grid gap-10 pt-2 lg:grid-cols-[minmax(0,7fr)_minmax(0,5fr)] lg:gap-16">
          <GalerieProduit images={imagesProduit(produit)} nom={produit.nom} remise={remisePourcent(produit)} />
          <div className="flex flex-col gap-[22px]">
            <Link
              href={hrefMarque(produit.marque)}
              data-testid="fiche-marque"
              className="self-start rounded-full border-[1.5px] border-[var(--vs-ligne)] px-3.5 py-1.5 text-[13px] font-extrabold uppercase tracking-[0.16em] text-[var(--vs-gris)]"
            >
              {produit.marque.nom}
            </Link>
            <h1 className="text-4xl font-black leading-[1.02] tracking-tight text-[var(--vs-noir)] lg:text-5xl">
              {produit.nom}
            </h1>
            <BlocAchat produit={produit} />
            <InfosProduit produit={produit} />
          </div>
        </section>
        {similaires.length > 0 && (
          <section data-testid="vous-aimerez-aussi" className="mt-24 flex flex-col gap-8">
            <h2 className="text-3xl font-black tracking-tight text-[var(--vs-noir)] lg:text-[40px]">Vous aimerez aussi</h2>
            <div className="grid grid-cols-2 gap-5 lg:grid-cols-4">
              {similaires.map((p) => (
                <ProductCard key={p.id} produit={p} />
              ))}
            </div>
          </section>
        )}
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_6__
cat > 'tickets/manifest-099.tsv' <<'__VICTO_FIN_7__'
099a	src/lib/fiche-produit.ts	tests/fiche-produit.test.ts	tickets/099a-fiche-produit.md	src/lib/catalogue.ts		
099b	src/components/produit/FilAriane.tsx	tests/FilAriane.test.tsx	tickets/099b-fil-ariane.md	src/lib/fiche-produit.ts	099a	
099c	src/components/produit/GalerieProduit.tsx	tests/GalerieProduit.test.tsx	tickets/099c-galerie-produit.md			
099d	src/components/produit/SelecteurPointure.tsx	tests/SelecteurPointure.test.tsx	tickets/099d-selecteur-pointure.md	src/lib/catalogue.ts		
099e	src/components/produit/BlocAchat.tsx	tests/BlocAchat.test.tsx	tickets/099e-bloc-achat.md	src/components/panier/PanierProvider.tsx,src/components/produit/SelecteurPointure.tsx,src/lib/fiche-produit.ts,src/lib/catalogue.ts,src/lib/formatPrice.ts	099a,099d	
099f	src/components/produit/InfosProduit.tsx	tests/InfosProduit.test.tsx	tickets/099f-infos-produit.md	src/lib/fiche-produit.ts	099a	
099g	src/app/produits/[slug]/page.tsx	tests/page-produit.test.tsx	tickets/099g-page-produit.md	src/components/produit/BlocAchat.tsx,src/components/produit/FilAriane.tsx,src/components/produit/GalerieProduit.tsx,src/components/produit/InfosProduit.tsx,src/lib/fiche-produit.ts,src/lib/catalogue.ts,src/lib/donnees.ts	099a,099b,099c,099e,099f	
__VICTO_FIN_7__
cat > 'tickets/tests/BlocAchat.test.tsx' <<'__VICTO_FIN_8__'
import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { PanierProvider } from '../src/components/panier/PanierProvider';
import { BlocAchat } from '../src/components/produit/BlocAchat';
import { economieCents, type Produit } from '../src/lib/catalogue';
import { formatPrice } from '../src/lib/formatPrice';
import { CLE_PANIER } from '../src/lib/panier';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
function porte(el: Element, chaine: string) {
  const nom = el.getAttribute('aria-label') ?? el.getAttribute('data-testid') ?? el.textContent;
  for (const k of chaine.split(' ')) expect(classes(el), `${nom} : classe ${k} manquante`).toContain(k);
}
const SANS_PROMO: Produit = {
  id: 'p1', slug: 'pegasus', nom: 'Pegasus', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12600, categorie: 'chaussures',
  description: 'Amorti réactif.',
  variantes: [
    { id: 'v40', taille: '40', sku: 'peg-40', stock: 5 },
    { id: 'v41', taille: '41', sku: 'peg-41', stock: 0 },
    { id: 'v42', taille: '42', sku: 'peg-42', stock: 2 },
  ],
};
const PROMO: Produit = { ...SANS_PROMO, prixCompareCents: 18000 };
const bouton = (nom: string) => screen.getByRole('button', { name: nom });
const quantite = () => screen.getByTestId('quantite').textContent;

beforeEach(() => window.localStorage.clear());

describe('BlocAchat — prix', () => {
  it('affiche le prix remisé, le prix barré et l’économie', () => {
    render(<BlocAchat produit={PROMO} />);
    expect(screen.getByTestId('fiche-prix').textContent).toBe(formatPrice(12600));
    porte(screen.getByTestId('fiche-prix'), 'text-[32px] font-black text-[var(--vs-promo)]');
    expect(screen.getByTestId('fiche-prix-barre').textContent).toBe(formatPrice(18000));
    expect(screen.getByTestId('fiche-economie').textContent).toBe(`Économisez ${formatPrice(economieCents(PROMO))}`);
    porte(screen.getByTestId('fiche-economie'), 'rounded-full bg-[#FFD3DB] text-[var(--vs-promo)]');
    expect(screen.getByTestId('fiche-description').textContent).toBe('Amorti réactif.');
  });

  it('affiche un prix simple hors promotion', () => {
    render(<BlocAchat produit={SANS_PROMO} />);
    porte(screen.getByTestId('fiche-prix'), 'text-[var(--vs-noir)]');
    expect(screen.queryByTestId('fiche-prix-barre')).toBeNull();
    expect(screen.queryByTestId('fiche-economie')).toBeNull();
  });
});

describe('BlocAchat — pointure et quantité', () => {
  it('annonce un stock bas pour la pointure choisie', () => {
    render(<BlocAchat produit={PROMO} />);
    expect(screen.queryByTestId('stock-bas')).toBeNull();
    fireEvent.click(bouton('42'));
    expect(screen.getByTestId('stock-bas').textContent).toBe('Plus que 2 paires en 42');
    fireEvent.click(bouton('40'));
    expect(screen.queryByTestId('stock-bas')).toBeNull();
  });

  it('plafonne la quantité au stock et la réduit en changeant de pointure', () => {
    render(<BlocAchat produit={PROMO} />);
    expect(quantite()).toBe('1');
    expect(bouton('Diminuer la quantité')).toBeDisabled();
    porte(bouton('Diminuer la quantité'), 'text-[#B5B5BA]');
    fireEvent.click(bouton('40'));
    for (let i = 0; i < 6; i += 1) fireEvent.click(bouton('Augmenter la quantité'));
    expect(quantite()).toBe('5');
    fireEvent.click(bouton('42'));
    expect(quantite()).toBe('2');
    fireEvent.click(bouton('Diminuer la quantité'));
    expect(quantite()).toBe('1');
  });
});

describe('BlocAchat — ajout au panier', () => {
  it('refuse sans pointure, avec un message', () => {
    render(<BlocAchat produit={PROMO} />);
    fireEvent.click(bouton('Ajouter au panier'));
    expect(screen.getByRole('alert').textContent).toBe("Choisissez une pointure avant d'ajouter au panier.");
    expect(screen.queryByRole('status')).toBeNull();
  });

  it('ajoute la pointure et la quantité choisies, puis confirme', () => {
    render(<PanierProvider><BlocAchat produit={PROMO} /></PanierProvider>);
    fireEvent.click(bouton('Ajouter au panier'));
    fireEvent.click(bouton('42'));
    expect(screen.queryByRole('alert')).toBeNull();
    fireEvent.click(bouton('Augmenter la quantité'));
    fireEvent.click(bouton('Ajouter au panier'));
    expect(JSON.parse(window.localStorage.getItem(CLE_PANIER) ?? '[]')).toEqual([
      { slug: 'pegasus', sku: 'peg-42', quantite: 2 },
    ]);
    const statut = screen.getByRole('status');
    expect(statut.textContent).toBe('Ajouté au panier — pointure 42, quantité 2');
    porte(statut, 'text-[var(--vs-accent)]');
    expect(statut.querySelector('svg.lucide-check')).not.toBeNull();
  });
});

describe('BlocAchat — boutons', () => {
  it('habille le bouton d’ajout et bascule le favori', () => {
    render(<BlocAchat produit={PROMO} />);
    porte(bouton('Ajouter au panier'), 'h-[58px] rounded-full bg-[var(--vs-accent)] text-[var(--vs-blanc)] sm:flex-1');
    const favori = bouton('Ajouter aux favoris');
    expect(favori).toHaveAttribute('aria-pressed', 'false');
    fireEvent.click(favori);
    expect(favori).toHaveAttribute('aria-pressed', 'true');
    const coeur = favori.querySelector('svg.lucide-heart');
    expect(coeur).not.toBeNull();
    porte(coeur as Element, 'fill-[var(--vs-promo)] text-[var(--vs-promo)]');
  });
});
__VICTO_FIN_8__
cat > 'tickets/tests/FilAriane.test.tsx' <<'__VICTO_FIN_9__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { FilAriane } from '../src/components/produit/FilAriane';
import type { ElementFil } from '../src/lib/fiche-produit';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
function porte(el: Element, chaine: string) {
  for (const k of chaine.split(' ')) expect(classes(el), `${el.tagName} : classe ${k} manquante`).toContain(k);
}
const ITEMS: ElementFil[] = [
  { label: 'Accueil', href: '/' },
  { label: 'Vêtements' },
  { label: 'Nike', href: '/marques/nike' },
  { label: 'Air Zoom Pegasus 41' },
];

describe('FilAriane', () => {
  it('rend une navigation étiquetée, en liste ordonnée', () => {
    render(<FilAriane items={ITEMS} />);
    const nav = screen.getByRole('navigation', { name: "Fil d'Ariane" });
    porte(nav, 'flex flex-wrap items-center gap-2.5 py-4 text-sm text-[var(--vs-gris)]');
    expect(within(nav).getAllByRole('listitem')).toHaveLength(4);
  });

  it('relie les éléments qui ont un lien, sauf le dernier', () => {
    render(<FilAriane items={ITEMS} />);
    const liens = within(screen.getByTestId('fil-ariane')).getAllByRole('link');
    expect(liens.map((l: HTMLElement) => [l.textContent, l.getAttribute('href')])).toEqual([
      ['Accueil', '/'],
      ['Nike', '/marques/nike'],
    ]);
  });

  it('marque la page courante, seule', () => {
    render(<FilAriane items={ITEMS} />);
    const courant = screen.getByText('Air Zoom Pegasus 41');
    expect(courant).toHaveAttribute('aria-current', 'page');
    porte(courant, 'font-semibold text-[var(--vs-noir)]');
    for (const autre of ['Accueil', 'Vêtements', 'Nike']) {
      expect(screen.getByText(autre)).not.toHaveAttribute('aria-current');
    }
  });

  it('sépare les éléments par des barres cachées aux lecteurs d’écran', () => {
    const { container } = render(<FilAriane items={ITEMS} />);
    const barres = Array.from(container.querySelectorAll('span[aria-hidden="true"]'));
    expect(barres.map((b) => b.textContent)).toEqual(['/', '/', '/']);
  });
});
__VICTO_FIN_9__
cat > 'tickets/tests/GalerieProduit.test.tsx' <<'__VICTO_FIN_10__'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { GalerieProduit } from '../src/components/produit/GalerieProduit';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
function porte(el: Element, chaine: string) {
  const nom = el.getAttribute('aria-label') ?? el.getAttribute('data-testid') ?? el.tagName;
  for (const k of chaine.split(' ')) expect(classes(el), `${nom} : classe ${k} manquante`).toContain(k);
}
const IMAGES = ['/img/a.svg', '/img/b.svg', '/img/c.svg', '/img/d.svg'];
const VIGNETTE = 'h-[110px] overflow-hidden rounded-[18px] border-2 bg-[var(--vs-surface)]';
const principale = () => screen.getByAltText(/, vue \d$/);

describe('GalerieProduit — image principale', () => {
  it('affiche la première vue, décrite', () => {
    render(<GalerieProduit images={IMAGES} nom="Pegasus" remise={30} />);
    expect(principale()).toHaveAttribute('src', '/img/a.svg');
    expect(principale()).toHaveAttribute('alt', 'Pegasus, vue 1');
    porte(screen.getByTestId('galerie'), 'flex flex-col gap-4');
  });

  it('pose la pastille de remise seulement s’il y en a une', () => {
    const { unmount } = render(<GalerieProduit images={IMAGES} nom="Pegasus" remise={30} />);
    const pastille = screen.getByTestId('galerie-remise');
    expect(pastille.textContent).toContain('30');
    expect(pastille.textContent).toContain('%');
    porte(pastille, 'absolute rounded-full bg-[var(--vs-promo)] text-[var(--vs-blanc)]');
    unmount();
    render(<GalerieProduit images={IMAGES} nom="Pegasus" remise={null} />);
    expect(screen.queryByTestId('galerie-remise')).toBeNull();
  });
});

describe('GalerieProduit — vignettes', () => {
  it('rend une vignette par vue et marque la vue affichée', () => {
    render(<GalerieProduit images={IMAGES} nom="Pegasus" remise={null} />);
    const v1 = screen.getByRole('button', { name: 'Afficher la vue 1' });
    const v2 = screen.getByRole('button', { name: 'Afficher la vue 2' });
    expect(screen.getAllByRole('button', { name: /^Afficher la vue/ })).toHaveLength(4);
    porte(v1, VIGNETTE);
    porte(v1, 'border-[var(--vs-noir)]');
    expect(v1).toHaveAttribute('aria-pressed', 'true');
    porte(v2, 'border-transparent');
    expect(v2).toHaveAttribute('aria-pressed', 'false');
  });

  it('change de vue au clic', () => {
    render(<GalerieProduit images={IMAGES} nom="Pegasus" remise={null} />);
    fireEvent.click(screen.getByRole('button', { name: 'Afficher la vue 3' }));
    expect(principale()).toHaveAttribute('src', '/img/c.svg');
    expect(principale()).toHaveAttribute('alt', 'Pegasus, vue 3');
    expect(screen.getByRole('button', { name: 'Afficher la vue 3' })).toHaveAttribute('aria-pressed', 'true');
    expect(screen.getByRole('button', { name: 'Afficher la vue 1' })).toHaveAttribute('aria-pressed', 'false');
  });

  it('n’affiche pas de vignettes pour une seule image', () => {
    render(<GalerieProduit images={['/img/a.svg']} nom="Pegasus" remise={null} />);
    expect(screen.queryAllByRole('button')).toHaveLength(0);
    expect(principale()).toHaveAttribute('src', '/img/a.svg');
  });
});
__VICTO_FIN_10__
cat > 'tickets/tests/InfosProduit.test.tsx' <<'__VICTO_FIN_11__'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { InfosProduit } from '../src/components/produit/InfosProduit';
import type { Produit } from '../src/lib/catalogue';
import { TEXTE_LIVRAISON } from '../src/lib/fiche-produit';

const SANS_COMPOSITION: Produit = {
  id: 'p1', slug: 'pegasus', nom: 'Pegasus', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12600, description: 'Amorti réactif.',
  variantes: [{ id: 'v40', taille: '40', sku: 'peg-40', stock: 5 }],
};
const COMPLET: Produit = { ...SANS_COMPOSITION, composition: 'Tige en mesh.' };
const titre = (nom: string) => screen.getByRole('button', { name: nom });

describe('InfosProduit — réassurance', () => {
  it('reprend les trois engagements, avec leurs icônes', () => {
    const { container } = render(<InfosProduit produit={COMPLET} />);
    const items = Array.from(container.querySelectorAll('ul > li'));
    expect(items.map((li) => li.textContent)).toEqual([
      "Livraison offerte — reçue d'ici 2 à 4 jours ouvrables",
      'Retours gratuits pendant 30 jours',
      "Authenticité garantie, neuf en boîte d'origine",
    ]);
    const icones = ['lucide-truck', 'lucide-rotate-ccw', 'lucide-shield-check'];
    expect(items.map((li, i) => li.querySelector(`svg.${icones[i] ?? 'absente'}`) !== null)).toEqual([true, true, true]);
  });
});

describe('InfosProduit — sections', () => {
  it('ouvre la description et ferme les autres', () => {
    render(<InfosProduit produit={COMPLET} />);
    expect(titre('Description')).toHaveAttribute('aria-expanded', 'true');
    expect(screen.getByText('Amorti réactif.')).toBeInTheDocument();
    expect(titre('Détails et composition')).toHaveAttribute('aria-expanded', 'false');
    expect(screen.queryByText('Tige en mesh.')).toBeNull();
    expect(titre('Livraison et retours')).toHaveAttribute('aria-expanded', 'false');
  });

  it('ouvre et referme une section au clic', () => {
    render(<InfosProduit produit={COMPLET} />);
    fireEvent.click(titre('Livraison et retours'));
    expect(titre('Livraison et retours')).toHaveAttribute('aria-expanded', 'true');
    expect(screen.getByText(TEXTE_LIVRAISON)).toBeInTheDocument();
    fireEvent.click(titre('Description'));
    expect(screen.queryByText('Amorti réactif.')).toBeNull();
    expect(screen.getByText(TEXTE_LIVRAISON)).toBeInTheDocument();
  });

  it('omet une section sans texte', () => {
    render(<InfosProduit produit={SANS_COMPOSITION} />);
    expect(screen.queryByRole('button', { name: 'Détails et composition' })).toBeNull();
    expect(screen.getAllByRole('button').map((b: HTMLElement) => b.textContent)).toEqual([
      'Description', 'Livraison et retours',
    ]);
  });
});
__VICTO_FIN_11__
cat > 'tickets/tests/SelecteurPointure.test.tsx' <<'__VICTO_FIN_12__'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { SelecteurPointure } from '../src/components/produit/SelecteurPointure';
import type { Variante } from '../src/lib/catalogue';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
function porte(el: Element, chaine: string) {
  for (const k of chaine.split(' ')) expect(classes(el), `pointure ${el.textContent} : classe ${k} manquante`).toContain(k);
}
const V = (taille: string, stock: number): Variante => ({ id: `v${taille}`, taille, sku: `sku-${taille}`, stock });
const VARIANTES = [V('40', 5), V('41', 0), V('42', 2)];
const BASE = 'h-14 rounded-[14px] border-[1.5px] text-base font-bold';
const bouton = (t: string) => screen.getByRole('button', { name: t });

describe('SelecteurPointure — affichage', () => {
  it('annonce la pointure à choisir, puis la pointure choisie', () => {
    const { unmount } = render(<SelecteurPointure variantes={VARIANTES} valeur={null} onChoisir={() => {}} />);
    expect(screen.getByTestId('pointure-choisie').textContent).toBe('— à choisir');
    unmount();
    render(<SelecteurPointure variantes={VARIANTES} valeur="42" onChoisir={() => {}} />);
    expect(screen.getByTestId('pointure-choisie').textContent).toBe('42');
  });

  it('regroupe les pointures sous leur libellé', () => {
    render(<SelecteurPointure variantes={VARIANTES} valeur={null} onChoisir={() => {}} />);
    const groupe = screen.getByRole('group');
    expect(groupe).toHaveAttribute('aria-labelledby', 'libelle-pointure');
    expect(within(groupe).getAllByRole('button').map((b: HTMLElement) => b.textContent)).toEqual(['40', '41', '42']);
  });
});

describe('SelecteurPointure — états', () => {
  it('noircit la pointure choisie', () => {
    render(<SelecteurPointure variantes={VARIANTES} valeur="42" onChoisir={() => {}} />);
    porte(bouton('42'), BASE);
    porte(bouton('42'), 'border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]');
    expect(bouton('42')).toHaveAttribute('aria-pressed', 'true');
    porte(bouton('40'), 'border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]');
    expect(bouton('40')).toHaveAttribute('aria-pressed', 'false');
  });

  it('barre et désactive une pointure épuisée', () => {
    render(<SelecteurPointure variantes={VARIANTES} valeur={null} onChoisir={() => {}} />);
    expect(bouton('41')).toBeDisabled();
    porte(bouton('41'), 'cursor-not-allowed text-[#B5B5BA] line-through');
    expect(bouton('40')).not.toBeDisabled();
    expect(classes(bouton('40'))).not.toContain('line-through');
  });
});

describe('SelecteurPointure — choix', () => {
  it('remonte la pointure cliquée, jamais une pointure épuisée', () => {
    const onChoisir = vi.fn();
    render(<SelecteurPointure variantes={VARIANTES} valeur={null} onChoisir={onChoisir} />);
    fireEvent.click(bouton('41'));
    expect(onChoisir).not.toHaveBeenCalled();
    fireEvent.click(bouton('40'));
    expect(onChoisir).toHaveBeenCalledWith('40');
  });
});
__VICTO_FIN_12__
cat > 'tickets/tests/fiche-produit.test.ts' <<'__VICTO_FIN_13__'
import { describe, expect, it } from 'vitest';
import { hrefMarque, LIBELLES_CATEGORIE, type Marque, type Produit } from '../src/lib/catalogue';
import { filAriane, produitsSimilaires, TEXTE_LIVRAISON, texteStockBas } from '../src/lib/fiche-produit';

const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
function P(id: string, categorie: Produit['categorie'], stocks: Array<[string, number]> = [['41', 5]]): Produit {
  const p: Produit = {
    id, slug: `s-${id}`, nom: `Produit ${id}`, marque: NIKE, imageUrl: '/img/x.svg', prixCents: 1000,
    variantes: stocks.map(([taille, stock]) => ({ id: `${id}-${taille}`, taille, sku: `${id}-${taille}`, stock })),
  };
  return categorie ? { ...p, categorie } : p;
}

describe('filAriane', () => {
  it('relie accueil, catégorie chaussures, marque puis produit', () => {
    const p = P('a', 'chaussures');
    expect(filAriane(p)).toEqual([
      { label: 'Accueil', href: '/' },
      { label: LIBELLES_CATEGORIE.chaussures, href: '/chaussures' },
      { label: 'Nike', href: hrefMarque(NIKE) },
      { label: 'Produit a' },
    ]);
  });

  it('ne met pas de lien sur une catégorie sans page, ni sur le produit', () => {
    const fil = filAriane(P('b', 'vetements'));
    expect(fil.map((e) => e.label)).toEqual(['Accueil', LIBELLES_CATEGORIE.vetements, 'Nike', 'Produit b']);
    expect(fil.map((e) => 'href' in e)).toEqual([true, false, true, false]);
  });

  it('saute la catégorie quand le produit n’en a pas', () => {
    expect(filAriane(P('c', undefined)).map((e) => e.label)).toEqual(['Accueil', 'Nike', 'Produit c']);
  });
});

describe('texteStockBas', () => {
  const chaussure = P('d', 'chaussures', [['40', 1], ['41', 3], ['42', 4], ['43', 0]]);

  it('annonce le stock bas, accordé', () => {
    expect(texteStockBas(chaussure, '40')).toBe('Plus que 1 paire en 40');
    expect(texteStockBas(chaussure, '41')).toBe('Plus que 3 paires en 41');
  });

  it('se tait au-dessus de trois, en rupture, sans taille ou pour une taille inconnue', () => {
    expect(texteStockBas(chaussure, '42')).toBeNull();
    expect(texteStockBas(chaussure, '43')).toBeNull();
    expect(texteStockBas(chaussure, null)).toBeNull();
    expect(texteStockBas(chaussure, '99')).toBeNull();
  });

  it('parle de pièces hors des chaussures', () => {
    const polo = P('e', 'vetements', [['M', 2], ['L', 1]]);
    expect(texteStockBas(polo, 'M')).toBe('Plus que 2 pièces en M');
    expect(texteStockBas(polo, 'L')).toBe('Plus que 1 pièce en L');
  });
});

describe('produitsSimilaires', () => {
  const base = P('x', 'chaussures');
  const tous = [P('v1', 'vetements'), base, P('c1', 'chaussures'), P('v2', 'vetements'), P('c2', 'chaussures')];

  it('exclut le produit, met la même catégorie en premier et garde l’ordre', () => {
    expect(produitsSimilaires(base, tous).map((p) => p.id)).toEqual(['c1', 'c2', 'v1', 'v2']);
  });

  it('respecte le nombre demandé et ne modifie pas la liste', () => {
    const avant = tous.map((p) => p.id);
    expect(produitsSimilaires(base, tous, 3).map((p) => p.id)).toEqual(['c1', 'c2', 'v1']);
    expect(tous.map((p) => p.id)).toEqual(avant);
  });
});

describe('TEXTE_LIVRAISON', () => {
  it('reprend le texte de la maquette', () => {
    expect(TEXTE_LIVRAISON).toContain('Expédiée du Québec sous 48 heures');
    expect(TEXTE_LIVRAISON).toContain('Retours gratuits pendant 30 jours');
  });
});
__VICTO_FIN_13__
cat > 'tickets/tests/page-produit.test.tsx' <<'__VICTO_FIN_14__'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PageProduit from '../src/app/produits/[slug]/page';
import { PanierProvider } from '../src/components/panier/PanierProvider';
import { PRODUITS } from '../src/lib/donnees';

// Un produit réel qui a au moins une pointure disponible.
const PRODUIT = PRODUITS.find((p) => p.variantes.some((v) => v.stock > 0))!;
const DISPONIBLE = PRODUIT.variantes.find((v) => v.stock > 0)!;
const page = (slug: string) => PageProduit({ params: Promise.resolve({ slug }) });

beforeEach(() => window.localStorage.clear());

describe('page produit — structure', () => {
  it('assemble en-tête, fil d’Ariane, galerie, achat, infos et pied', async () => {
    render(await page(PRODUIT.slug));
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 1, name: PRODUIT.nom })).toBeInTheDocument();
    for (const id of ['fil-ariane', 'galerie', 'bloc-achat', 'infos-produit', 'fiche-marque']) {
      expect(screen.getByTestId(id), id).toBeInTheDocument();
    }
    expect(screen.getByTestId('fiche-marque').textContent).toBe(PRODUIT.marque.nom);
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('propose d’autres produits, sans le produit affiché', async () => {
    render(await page(PRODUIT.slug));
    const zone = screen.getByTestId('vous-aimerez-aussi');
    const cartes = within(zone).getAllByTestId('carte-produit');
    expect(cartes).toHaveLength(Math.min(4, PRODUITS.length - 1));
    expect(within(zone).queryAllByTestId('carte-nom').map((e: HTMLElement) => e.textContent)).not.toContain(PRODUIT.nom);
  });

  it('renvoie une page introuvable pour un produit inconnu', async () => {
    await expect(page('produit-qui-n-existe-pas')).rejects.toThrow();
  });
});

describe('page produit — ajout au panier', () => {
  it('ajoute depuis la fiche et met à jour le compteur de l’en-tête', async () => {
    render(<PanierProvider>{await page(PRODUIT.slug)}</PanierProvider>);
    const bloc = screen.getByTestId('bloc-achat');
    fireEvent.click(within(bloc).getByRole('button', { name: DISPONIBLE.taille }));
    fireEvent.click(within(bloc).getByRole('button', { name: 'Ajouter au panier' }));
    expect(screen.getByTestId('entete-panier-compte').textContent).toBe('1');
  });
});
__VICTO_FIN_14__
TESTS=(BlocAchat.test.tsx FilAriane.test.tsx GalerieProduit.test.tsx InfosProduit.test.tsx SelecteurPointure.test.tsx fiche-produit.test.ts page-produit.test.tsx)
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
ok "7 specs, 7 tests en attente et le manifeste écrits"

# ------------------------------------------------------------ nettoyage
G=tests/garde-jetons.test.ts
if [ -f "$G" ] && grep -qF "const EN_ATTENTE = new Set(['src/components/catalogue/FiltresBarre.tsx']);" "$G"; then
  python3 - "$G" <<'PYG'
import sys
p = sys.argv[1]; s = open(p).read()
s = s.replace("// Fichiers couverts par leur propre test en attendant leur ticket.\n// FiltresBarre.tsx : tickets/tests/FiltresBarre-v2.test.tsx (ticket 095).\n", "// Fichiers couverts par leur propre test en attendant leur ticket (aucun aujourd'hui).\n")
s = s.replace("const EN_ATTENTE = new Set(['src/components/catalogue/FiltresBarre.tsx']);", "const EN_ATTENTE = new Set<string>();")
open(p, 'w').write(s)
PYG
  ok "garde des jetons : exception de FiltresBarre retirée"
else
  info "garde des jetons : exception de FiltresBarre déjà retirée ou fichier différent, laissé tel quel"
fi
if git ls-files --error-unmatch rattrapage-095c.sh >/dev/null 2>&1; then git rm -q rattrapage-095c.sh; ok "rattrapage-095c.sh retiré du dépôt"; fi

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/099*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-099.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
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
    n = re.search(r'Taille attendue : ~?(\d+) lignes', open(spec).read())
    total = car // 3 + 2000 + (int(n.group(1)) * 40 // 3 if n else 0)
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
ok "base verte (garde des jetons comprise, désormais sans exception)"
git add -A -- tickets tests
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "chore(tickets): lot 099 — fiche produit ; garde des jetons sans exception"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

cat <<'TXT'

Prêt :

    MANIFEST=tickets/manifest-099.tsv ./run.sh

Sept tickets. 099c et 099d partent sans attendre ; la page (099g) attend tous les autres.
Compte deux heures à deux heures et demie : c'est un run à lancer le soir.
TXT
