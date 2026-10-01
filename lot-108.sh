#!/usr/bin/env bash
# VICTO STORE — lot 108 : navigation par sous-catégories.
#   108a arbre des catégories   108b vignettes et pastilles   108c bandeau dans la vue des listes
#   108d-f pages Femme, Homme, Chaussures avec leurs sous-catégories
#   108g page de sous-catégorie   108h-j routes /femme/…, /homme/…, /chaussures/…
#   108k méga-menu   108l menu mobile à deux niveaux   108m branchés dans l'en-tête
# Usage :  cd ~/victo-store && bash lot-108.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
info(){ printf '  \033[33m!\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }
annuler(){ rm -f tests/zz-prevol-*; git reset -q --hard HEAD; git clean -fdq -- tests tickets; mort "$*  — rien n'a été modifié"; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
modifies="$(git ls-files -m -- '*.tsbuildinfo')"
[ -z "$modifies" ] || git checkout -q -- $modifies
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase=merges || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
ok "main à jour ($(git rev-parse --short HEAD))"

# ------------------------------------------------------------ ce que les specs supposent (au plus juste)
SH=src/components/ui/SiteHeader.tsx; VC=src/components/catalogue/VueCatalogue.tsx
fusionne(){ git log main -1 --format=%h --fixed-strings --grep="feat($1): fusionné" | grep -q .; }
for d in 095c 099b 105b 107d; do fusionne "$d" || mort "$d n'est pas fusionné : le lot 108 s'appuie dessus"; done
compte(){ grep -cF -- "$1" "$2" || true; }
[ "$(compte 'function classeLien(' "$SH")" = 1 ] && [ "$(compte 'const chemin: string | null = usePathname();' "$SH")" = 1 ] \
  || mort "$SH : la logique de la page active n'est pas celle du 105b"
[ "$(compte 'aria-label="Ouvrir le menu"' "$SH")" = 1 ] && [ "$(compte 'aria-label="Navigation principale"' "$SH")" = 1 ] \
  || mort "$SH : le bouton de menu ou la navigation n'est pas unique"
grep -qE "export (type|interface) NavItem" "$SH" || mort "$SH n'exporte pas NavItem"
grep -qE "NavigationPrincipale|MenuMobile" "$SH" && mort "$SH utilise déjà la nouvelle navigation : lot déjà passé ?"
[ "$(compte '<FiltresBarre' "$VC")" = 1 ] || mort "$VC : la barre de filtres n'est pas unique"
grep -q "entete" "$VC" && mort "$VC a déjà un bandeau : lot déjà passé ?"
for r in femme homme chaussures; do
  [ "$(compte '<VueCatalogue' "src/app/$r/page.tsx")" = 1 ] || mort "src/app/$r/page.tsx : une seule <VueCatalogue> attendue"
  grep -q "entete=" "src/app/$r/page.tsx" && mort "src/app/$r/page.tsx a déjà ses sous-catégories : lot déjà passé ?"
  [ ! -e "src/app/$r/[...chemin]" ] || mort "src/app/$r/[...chemin] existe déjà : lot déjà passé ?"
done
grep -q "export function correspondAuGenre" src/lib/catalogue.ts && grep -q "export function hrefMarque" src/lib/catalogue.ts || mort "correspondAuGenre ou hrefMarque absent de catalogue.ts"
grep -q 'data-testid="fil-ariane"' src/components/produit/FilAriane.tsx || mort "FilAriane : data-testid=\"fil-ariane\" absent"
for c in PILULE PILULE_ON PILULE_OFF; do grep -qE "export const $c = " src/components/catalogue/filtres-affichage.ts || mort "filtres-affichage : $c absent"; done
for f in src/lib/arbre-categories.ts src/components/catalogue/SousCategories.tsx src/components/catalogue/PageSousCategorie.tsx src/components/navigation; do
  [ ! -e "$f" ] || mort "$f existe déjà : lot déjà passé ?"; done
for j in noir blanc surface ligne gris; do grep -qE -- "--vs-$j\s*:" src/styles/tokens.css || mort "jeton --vs-$j absent"; done
manque="$(node -e "const l=require('lucide-react');console.log(['ChevronLeft','ChevronRight','Menu','X'].filter(n=>!l[n]).join(' '))" 2>/dev/null || echo lucide-react)"
[ -z "$manque" ] || mort "icônes lucide absentes de ta version : $manque"
ok "en-tête (105b, 107d), vue des listes, pages de rubrique, fil d'Ariane et icônes conformes aux specs"
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
mkdir -p tickets/tests
cat > 'tickets/108a-arbre-categories.md' <<'__VICTO_FIN_0__'
TICKET 108a — arbre des catégories

Crée `src/lib/arbre-categories.ts`. Fonctions **pures**, recopiées telles quelles.
Le deuxième niveau (chaussures, vêtements, accessoires) s'appuie sur le vrai champ
`categorie` ; le troisième (sneakers, course…) sur un classement de démonstration, en
attendant les catégories de Medusa.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index sur un
  tableau ; utilise `.find`, `.filter`, `.map`, la déstructuration. Lire `ARBRE[r]` ou
  `TYPES_DEMO[slug]` est permis : ce sont des `Record` (le second est partiel).
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~85 lignes.
```ts
import { correspondAuGenre, type Produit } from '@/lib/catalogue';

export interface Noeud {
  slug: string;
  libelle: string;
  enfants: Noeud[];
}
export type Rubrique = 'femme' | 'homme' | 'chaussures';
export interface ElementSousCategorie {
  libelle: string;
  href: string;
  nombre: number;
}

const feuille = (slug: string, libelle: string): Noeud => ({ slug, libelle, enfants: [] });
const TYPES_CHAUSSURES = [feuille('sneakers', 'Sneakers'), feuille('course', 'Course'), feuille('basket', 'Basket'), feuille('sandales', 'Sandales')];
const PAR_GENRE: Noeud[] = [
  { slug: 'chaussures', libelle: 'Chaussures', enfants: TYPES_CHAUSSURES },
  { slug: 'vetements', libelle: 'Vêtements', enfants: [feuille('t-shirts', 'T-shirts'), feuille('polos', 'Polos'), feuille('sweats', 'Sweats et hoodies'), feuille('jeans', 'Jeans'), feuille('vestes', 'Vestes')] },
  { slug: 'accessoires', libelle: 'Accessoires', enfants: [feuille('casquettes', 'Casquettes'), feuille('sacs', 'Sacs'), feuille('chaussettes', 'Chaussettes')] },
];

export const ARBRE: Record<Rubrique, Noeud> = {
  femme: { slug: 'femme', libelle: 'Femme', enfants: PAR_GENRE },
  homme: { slug: 'homme', libelle: 'Homme', enfants: PAR_GENRE },
  chaussures: { slug: 'chaussures', libelle: 'Chaussures', enfants: [...TYPES_CHAUSSURES, feuille('bottes', 'Bottes')] },
};

/** Classement de démonstration : slug du produit → type (troisième niveau). */
export const TYPES_DEMO: Partial<Record<string, string>> = {
  'air-zoom-pegasus-41': 'course',
  'ultra-boost-22': 'course',
  'chuck-taylor-all-star': 'sneakers',
  'polo-shirt': 'polos',
};

export function estRubrique(x: string): x is Rubrique {
  return x === 'femme' || x === 'homme' || x === 'chaussures';
}

export function hrefDe(rubrique: Rubrique, chemin: string[]): string {
  return `/${[rubrique, ...chemin].join('/')}`;
}

/** La lignée de la racine au nœud visé, ou undefined si un segment n'existe pas. */
export function trouverNoeud(rubrique: Rubrique, chemin: string[]): { noeud: Noeud; lignee: Noeud[] } | undefined {
  let noeud: Noeud = ARBRE[rubrique];
  const lignee: Noeud[] = [noeud];
  for (const segment of chemin) {
    const suivant = noeud.enfants.find((e) => e.slug === segment);
    if (!suivant) return undefined;
    lignee.push(suivant);
    noeud = suivant;
  }
  return { noeud, lignee };
}

export function produitsDe(produits: Produit[], rubrique: Rubrique, chemin: string[]): Produit[] {
  if (rubrique === 'chaussures') {
    const [type] = chemin;
    return produits.filter((p) => p.categorie === 'chaussures' && (type === undefined || TYPES_DEMO[p.slug] === type));
  }
  const [categorie, type] = chemin;
  return produits.filter(
    (p) => correspondAuGenre(p, rubrique)
      && (categorie === undefined || p.categorie === categorie)
      && (type === undefined || TYPES_DEMO[p.slug] === type),
  );
}

/** Les enfants du nœud visé, avec leur adresse et leur nombre de produits. */
export function sousCategories(produits: Produit[], rubrique: Rubrique, chemin: string[]): ElementSousCategorie[] {
  const trouve = trouverNoeud(rubrique, chemin);
  if (!trouve) return [];
  return trouve.noeud.enfants.map((e) => ({
    libelle: e.libelle,
    href: hrefDe(rubrique, [...chemin, e.slug]),
    nombre: produitsDe(produits, rubrique, [...chemin, e.slug]).length,
  }));
}

/** « Chaussures Homme », « Course Homme » ; sous la rubrique Chaussures : « Course ». */
export function titreDe(rubrique: Rubrique, chemin: string[]): string {
  const trouve = trouverNoeud(rubrique, chemin);
  if (!trouve) return '';
  if (chemin.length === 0 || rubrique === 'chaussures') return trouve.noeud.libelle;
  return `${trouve.noeud.libelle} ${ARBRE[rubrique].libelle}`;
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_0__
cat > 'tickets/108b-sous-categories.md' <<'__VICTO_FIN_1__'
TICKET 108b — sous-catégories, en vignettes ou en pastilles

Crée `src/components/catalogue/SousCategories.tsx`, export nommé `SousCategories`.
Composant **sans état**, serveur (pas de `'use client'`).

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.

## Fichier complet
Taille attendue : ~45 lignes.
```tsx
import Link from 'next/link';
import { PILULE, PILULE_OFF, PILULE_ON } from '@/components/catalogue/filtres-affichage';
import type { ElementSousCategorie } from '@/lib/arbre-categories';

export function SousCategories({ titre, elements, forme, actif }: {
  titre: string;
  elements: ElementSousCategorie[];
  forme: 'vignettes' | 'pastilles';
  actif?: string | undefined;
}) {
  if (elements.length === 0) return null;
  if (forme === 'vignettes') {
    return (
      <nav aria-label={titre} className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
        {elements.map((e) => (
          <Link key={e.href} href={e.href} className="flex flex-col gap-2.5 text-[var(--vs-noir)]">
            <span aria-hidden="true" className="h-[150px] rounded-[20px] bg-[var(--vs-surface)]" />
            <span className="text-base font-extrabold">{e.libelle}</span>
            <span className="text-[13px] text-[var(--vs-gris)]">{`${e.nombre} ${e.nombre > 1 ? 'produits' : 'produit'}`}</span>
          </Link>
        ))}
      </nav>
    );
  }
  return (
    <nav aria-label={titre} className="flex flex-wrap gap-2.5">
      {elements.map((e) => (
        <Link key={e.href} href={e.href} aria-current={e.href === actif ? 'page' : undefined}
          className={`${PILULE} ${e.href === actif ? PILULE_ON : PILULE_OFF}`}>
          {e.libelle}
        </Link>
      ))}
    </nav>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > 'tickets/108c-vue-catalogue-entete.md' <<'__VICTO_FIN_2__'
TICKET 108c — la vue des listes accepte un bandeau sous son titre

Modifie `src/components/catalogue/VueCatalogue.tsx`. Le fichier actuel est correct et
testé : tu ajoutes une prop facultative, rien d'autre ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Aucune autre ligne ne change : titre, compteur, barre de filtres, grille et pagination
  restent identiques.

## Les trois changements
1. Si `ReactNode` n'est pas déjà importé, ajoute `import type { ReactNode } from 'react';`
   à la suite des imports existants.
2. Dans les props de `VueCatalogue`, ajoute `entete?: ReactNode | undefined;` et lis-la
   avec les autres.
3. Rends `{entete}` **juste avant** l'élément `<FiltresBarre …>` : entre le bloc du titre
   (titre, description, compteur) et la barre de filtres.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/VueCatalogue-v2.test.tsx`.
__VICTO_FIN_2__
cat > 'tickets/108d-page-femme.md' <<'__VICTO_FIN_3__'
TICKET 108d — la page Femme affiche ses sous-catégories

Modifie `src/app/femme/page.tsx`. La page est correcte et testée : elle garde exactement son
titre, sa description et ses produits ; elle ajoute seulement ses sous-catégories en
vignettes, sous le titre.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Un seul export : l'export par défaut, inchangé. Pas de `'use client'`.

## Les deux changements
1. Ajoute, à la suite des imports existants :
   ```tsx
   import { SousCategories } from '@/components/catalogue/SousCategories';
   import { sousCategories } from '@/lib/arbre-categories';
   ```
   (`listerProduits` est déjà importé depuis `'@/lib/donnees'` ; s'il ne l'est pas, ajoute-le.)
2. Sur l'élément `<VueCatalogue …>`, ajoute l'attribut exactement :
   ```tsx
   entete={<SousCategories titre="Sous-catégories de Femme" forme="vignettes" elements={sousCategories(listerProduits(), 'femme', [])} />}
   ```
   Ses autres attributs ne changent pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_3__
cat > 'tickets/108e-page-homme.md' <<'__VICTO_FIN_4__'
TICKET 108e — la page Homme affiche ses sous-catégories

Modifie `src/app/homme/page.tsx`. La page est correcte et testée : elle garde exactement son
titre, sa description et ses produits ; elle ajoute seulement ses sous-catégories en
vignettes, sous le titre.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Un seul export : l'export par défaut, inchangé. Pas de `'use client'`.

## Les deux changements
1. Ajoute, à la suite des imports existants :
   ```tsx
   import { SousCategories } from '@/components/catalogue/SousCategories';
   import { sousCategories } from '@/lib/arbre-categories';
   ```
   (`listerProduits` est déjà importé depuis `'@/lib/donnees'` ; s'il ne l'est pas, ajoute-le.)
2. Sur l'élément `<VueCatalogue …>`, ajoute l'attribut exactement :
   ```tsx
   entete={<SousCategories titre="Sous-catégories de Homme" forme="vignettes" elements={sousCategories(listerProduits(), 'homme', [])} />}
   ```
   Ses autres attributs ne changent pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_4__
cat > 'tickets/108f-page-chaussures.md' <<'__VICTO_FIN_5__'
TICKET 108f — la page Chaussures affiche ses sous-catégories

Modifie `src/app/chaussures/page.tsx`. La page est correcte et testée : elle garde exactement son
titre, sa description et ses produits ; elle ajoute seulement ses sous-catégories en
vignettes, sous le titre.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Un seul export : l'export par défaut, inchangé. Pas de `'use client'`.

## Les deux changements
1. Ajoute, à la suite des imports existants :
   ```tsx
   import { SousCategories } from '@/components/catalogue/SousCategories';
   import { sousCategories } from '@/lib/arbre-categories';
   ```
   (`listerProduits` est déjà importé depuis `'@/lib/donnees'` ; s'il ne l'est pas, ajoute-le.)
2. Sur l'élément `<VueCatalogue …>`, ajoute l'attribut exactement :
   ```tsx
   entete={<SousCategories titre="Sous-catégories de Chaussures" forme="vignettes" elements={sousCategories(listerProduits(), 'chaussures', [])} />}
   ```
   Ses autres attributs ne changent pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_5__
cat > 'tickets/108g-page-sous-categorie.md' <<'__VICTO_FIN_6__'
TICKET 108g — page d'une sous-catégorie

Crée `src/components/catalogue/PageSousCategorie.tsx`, export nommé `PageSousCategorie`.
Composant **serveur** (pas de `'use client'`), utilisé par les routes
`/femme/…`, `/homme/…` et `/chaussures/…`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`, `.slice`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~40 lignes.
```tsx
import { notFound } from 'next/navigation';
import { SousCategories } from '@/components/catalogue/SousCategories';
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { FilAriane } from '@/components/produit/FilAriane';
import { hrefDe, produitsDe, sousCategories, titreDe, trouverNoeud, type Rubrique } from '@/lib/arbre-categories';
import { listerProduits } from '@/lib/donnees';

export function PageSousCategorie({ rubrique, chemin }: { rubrique: Rubrique; chemin: string[] }) {
  const trouve = trouverNoeud(rubrique, chemin);
  if (!trouve || chemin.length === 0) notFound();
  const tous = listerProduits();
  // Un nœud qui a des enfants les propose ; une feuille propose ses sœurs, elle-même marquée.
  const base = trouve.noeud.enfants.length > 0 ? chemin : chemin.slice(0, -1);
  const pastilles = [
    { libelle: 'Tout', href: hrefDe(rubrique, base), nombre: produitsDe(tous, rubrique, base).length },
    ...sousCategories(tous, rubrique, base),
  ];
  const fil = trouve.lignee.map((n, i) =>
    i === trouve.lignee.length - 1 ? { label: n.libelle } : { label: n.libelle, href: hrefDe(rubrique, chemin.slice(0, i)) },
  );
  return (
    <VueCatalogue
      titre={titreDe(rubrique, chemin)}
      produits={produitsDe(tous, rubrique, chemin)}
      entete={
        <div className="flex flex-col gap-4">
          <FilAriane items={[{ label: 'Accueil', href: '/' }, ...fil]} />
          <SousCategories titre={`Sous-catégories de ${trouve.noeud.libelle}`} forme="pastilles" elements={pastilles} actif={hrefDe(rubrique, chemin)} />
        </div>
      }
    />
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_6__
cat > 'tickets/108h-route-femme.md' <<'__VICTO_FIN_7__'
TICKET 108h — les sous-catégories de Femme ont leur adresse

Crée `src/app/femme/[...chemin]/page.tsx` (le dossier s'appelle exactement `[...chemin]`).
Export par défaut seulement ; composant serveur, pas de `'use client'`.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~10 lignes.
```tsx
import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';

export default async function PageSousCategorieFemme({ params }: { params: Promise<{ chemin: string[] }> }) {
  const { chemin } = await params;
  return <PageSousCategorie rubrique="femme" chemin={chemin} />;
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_7__
cat > 'tickets/108i-route-homme.md' <<'__VICTO_FIN_8__'
TICKET 108i — les sous-catégories de Homme ont leur adresse

Crée `src/app/homme/[...chemin]/page.tsx` (le dossier s'appelle exactement `[...chemin]`).
Export par défaut seulement ; composant serveur, pas de `'use client'`.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~10 lignes.
```tsx
import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';

export default async function PageSousCategorieHomme({ params }: { params: Promise<{ chemin: string[] }> }) {
  const { chemin } = await params;
  return <PageSousCategorie rubrique="homme" chemin={chemin} />;
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_8__
cat > 'tickets/108j-route-chaussures.md' <<'__VICTO_FIN_9__'
TICKET 108j — les sous-catégories de Chaussures ont leur adresse

Crée `src/app/chaussures/[...chemin]/page.tsx` (le dossier s'appelle exactement `[...chemin]`).
Export par défaut seulement ; composant serveur, pas de `'use client'`.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~10 lignes.
```tsx
import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';

export default async function PageSousCategorieChaussures({ params }: { params: Promise<{ chemin: string[] }> }) {
  const { chemin } = await params;
  return <PageSousCategorie rubrique="chaussures" chemin={chemin} />;
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_9__
cat > 'tickets/108k-navigation-principale.md' <<'__VICTO_FIN_10__'
TICKET 108k — navigation principale avec méga-menu

Crée `src/components/navigation/NavigationPrincipale.tsx`, export nommé
`NavigationPrincipale`. Elle remplacera la `<nav>` actuelle de l'en-tête (ticket 108m) :
mêmes liens, même marquage de la page active, plus un panneau de sous-catégories qui
s'ouvre au survol ou au focus d'une rubrique.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index sur un
  tableau ; utilise `.map`. Lire `ARBRE[panneau]` est permis (un `Record`).
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Icônes `lucide-react` avec
  `aria-hidden`.

## Fichier complet
Taille attendue : ~125 lignes.
```tsx
'use client';

import { ChevronRight } from 'lucide-react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useEffect, useRef, useState } from 'react';
import type { NavItem } from '@/components/ui/SiteHeader';
import { ARBRE, estRubrique, hrefDe, produitsDe, type Rubrique } from '@/lib/arbre-categories';
import { hrefMarque } from '@/lib/catalogue';
import { listerMarques, listerProduits } from '@/lib/donnees';

type Panneau = Rubrique | 'marques';

function classeLien(promo: boolean | undefined, actif: boolean): string | undefined {
  if (promo && actif) return 'text-[#FF5A74] font-extrabold underline decoration-2 underline-offset-[10px]';
  if (promo) return 'text-[#FF5A74]';
  if (actif) return 'font-extrabold underline decoration-2 underline-offset-[10px]';
  return undefined;
}

function panneauDe(href: string): Panneau | null {
  const segment = href.replace(/^\//, '');
  if (estRubrique(segment)) return segment;
  return segment === 'marques' ? 'marques' : null;
}

const CADRE = 'fixed inset-x-0 top-[84px] z-50 grid gap-x-10 gap-y-6 border-t border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-20 pb-10 pt-8 text-[var(--vs-noir)] shadow-[0_24px_40px_rgba(16,16,20,0.18)]';

function Tete({ titre, href, texte }: { titre: string; href: string; texte: string }) {
  return (
    <div className="col-span-full flex items-baseline justify-between border-b border-[var(--vs-ligne)] pb-4">
      <p className="text-2xl font-black">{titre}</p>
      <Link href={href} className="flex items-center gap-1.5 text-[15px] font-extrabold">
        {texte}
        <ChevronRight aria-hidden size={16} />
      </Link>
    </div>
  );
}

function PanneauMega({ panneau }: { panneau: Panneau }) {
  if (panneau === 'marques') {
    return (
      <div role="region" aria-label="Sous-catégories de Marques" className={`${CADRE} grid-cols-5`}>
        <Tete titre="Marques" href="/marques" texte="Toutes les marques" />
        {listerMarques().map((m) => (
          <Link key={m.slug} href={hrefMarque(m)} className="flex h-[110px] items-center justify-center rounded-[18px] bg-[var(--vs-surface)] text-lg font-black tracking-wide">
            {m.nom}
          </Link>
        ))}
      </div>
    );
  }
  const racine = ARBRE[panneau];
  const total = produitsDe(listerProduits(), panneau, []).length;
  const tete = <Tete titre={racine.libelle} href={hrefDe(panneau, [])} texte={`Tout voir ${racine.libelle} (${total} ${total > 1 ? 'produits' : 'produit'})`} />;
  if (panneau === 'chaussures') {
    return (
      <div role="region" aria-label="Sous-catégories de Chaussures" className={`${CADRE} grid-cols-5`}>
        {tete}
        {racine.enfants.map((e) => (
          <Link key={e.slug} href={hrefDe(panneau, [e.slug])} className="flex flex-col gap-2.5">
            <span aria-hidden="true" className="h-[150px] rounded-[20px] bg-[var(--vs-surface)]" />
            <span className="text-base font-extrabold">{e.libelle}</span>
          </Link>
        ))}
      </div>
    );
  }
  return (
    <div role="region" aria-label={`Sous-catégories de ${racine.libelle}`} className={`${CADRE} grid-cols-3`}>
      {tete}
      {racine.enfants.map((sc) => (
        <div key={sc.slug} className="flex flex-col">
          <Link href={hrefDe(panneau, [sc.slug])} className="mb-1.5 text-base font-black">{sc.libelle}</Link>
          {sc.enfants.map((f) => (
            <Link key={f.slug} href={hrefDe(panneau, [sc.slug, f.slug])} className="py-1.5 text-[15px] font-medium">{f.libelle}</Link>
          ))}
          <Link href={hrefDe(panneau, [sc.slug])} className="mt-1.5 text-sm font-bold text-[var(--vs-gris)] underline">{`Tout ${sc.libelle.toLowerCase()}`}</Link>
        </div>
      ))}
    </div>
  );
}

export function NavigationPrincipale({ navItems }: { navItems: NavItem[] }) {
  const chemin: string | null = usePathname();
  const [ouvert, setOuvert] = useState<Panneau | null>(null);
  const minuterie = useRef<ReturnType<typeof setTimeout> | null>(null);

  function annuler() {
    if (minuterie.current !== null) clearTimeout(minuterie.current);
    minuterie.current = null;
  }
  function fermerBientot() {
    annuler();
    minuterie.current = setTimeout(() => setOuvert(null), 200);
  }
  useEffect(() => () => { if (minuterie.current !== null) clearTimeout(minuterie.current); }, []);
  useEffect(() => { setOuvert(null); }, [chemin]);

  return (
    <nav aria-label="Navigation principale" className="hidden justify-self-center gap-8 text-[15px] font-semibold lg:flex"
      onMouseEnter={annuler} onMouseLeave={fermerBientot}
      onKeyDown={(e) => { if (e.key === 'Escape') setOuvert(null); }}>
      {navItems.map((item) => {
        const actif = chemin !== null && (chemin === item.href || chemin.startsWith(`${item.href}/`));
        const panneau = panneauDe(item.href);
        return (
          <a key={item.href} href={item.href} aria-current={actif ? 'page' : undefined} className={classeLien(item.promo, actif)}
            onMouseEnter={() => { annuler(); setOuvert(panneau); }}
            onFocus={() => setOuvert(panneau)}>
            {item.label}
          </a>
        );
      })}
      {ouvert !== null && <PanneauMega panneau={ouvert} />}
    </nav>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_10__
cat > 'tickets/108l-menu-mobile.md' <<'__VICTO_FIN_11__'
TICKET 108l — menu mobile à deux niveaux

Crée `src/components/navigation/MenuMobile.tsx`, export nommé `MenuMobile`. Il contient
le bouton « Ouvrir le menu » de l'en-tête (mêmes nom, classes et icône qu'aujourd'hui) et
le tiroir qu'il ouvre : les rubriques, puis les sous-catégories de la rubrique choisie.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index sur un
  tableau ; utilise `.map`. Lire `ARBRE[rubrique]` est permis (un `Record`).
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Icônes `lucide-react` avec
  `aria-hidden`.

## Fichier complet
Taille attendue : ~120 lignes.
```tsx
'use client';

import { ChevronLeft, ChevronRight, Menu, X } from 'lucide-react';
import Link from 'next/link';
import { useState } from 'react';
import type { NavItem } from '@/components/ui/SiteHeader';
import { ARBRE, estRubrique, hrefDe, type Rubrique } from '@/lib/arbre-categories';

const LIGNE = 'flex h-[58px] w-full items-center justify-between border-b border-[var(--vs-ligne)] text-[17px] font-extrabold';

export function MenuMobile({ navItems }: { navItems: NavItem[] }) {
  const [ouvert, setOuvert] = useState(false);
  const [rubrique, setRubrique] = useState<Rubrique | null>(null);
  const [deplie, setDeplie] = useState<string | null>(null);

  function fermer() {
    setOuvert(false);
    setRubrique(null);
    setDeplie(null);
  }

  const niveau1 = (
    <>
      {navItems.map((item) => {
        const segment = item.href.replace(/^\//, '');
        if (estRubrique(segment)) {
          return (
            <button key={item.href} type="button" onClick={() => setRubrique(segment)} className={LIGNE}>
              {item.label}
              <ChevronRight aria-hidden size={18} />
            </button>
          );
        }
        return (
          <Link key={item.href} href={item.href} onClick={fermer}
            className={item.promo ? `${LIGNE} text-[#E4002B]` : LIGNE}>
            {item.label}
          </Link>
        );
      })}
      <div className="mt-6 flex flex-col">
        <Link href="/compte" onClick={fermer} className="flex h-12 items-center text-[15px] font-bold">Mon compte</Link>
        <Link href="/livraison" onClick={fermer} className="flex h-12 items-center text-[15px] font-bold">Aide et livraison</Link>
      </div>
    </>
  );

  const niveau2 = rubrique === null ? null : (
    <>
      <Link href={hrefDe(rubrique, [])} onClick={fermer}
        className="my-2.5 flex h-14 items-center justify-between rounded-2xl bg-[var(--vs-noir)] px-[18px] text-base font-extrabold text-[var(--vs-blanc)]">
        {`Tout voir ${ARBRE[rubrique].libelle}`}
        <ChevronRight aria-hidden size={18} />
      </Link>
      {ARBRE[rubrique].enfants.map((sc) => sc.enfants.length === 0 ? (
        <Link key={sc.slug} href={hrefDe(rubrique, [sc.slug])} onClick={fermer} className={LIGNE}>{sc.libelle}</Link>
      ) : (
        <div key={sc.slug} className="border-b border-[var(--vs-ligne)]">
          <button type="button" aria-expanded={deplie === sc.slug} onClick={() => setDeplie(deplie === sc.slug ? null : sc.slug)}
            className="flex h-[54px] w-full items-center justify-between text-[17px] font-extrabold">
            {sc.libelle}
            <span aria-hidden="true" className="text-[22px] font-medium">{deplie === sc.slug ? '−' : '+'}</span>
          </button>
          {deplie === sc.slug && (
            <div className="flex flex-col pb-2 pl-3.5">
              {sc.enfants.map((f) => (
                <Link key={f.slug} href={hrefDe(rubrique, [sc.slug, f.slug])} onClick={fermer} className="py-2 text-[15px]">{f.libelle}</Link>
              ))}
              <Link href={hrefDe(rubrique, [sc.slug])} onClick={fermer} className="py-2 text-[15px] font-extrabold underline">{`Tout ${sc.libelle.toLowerCase()}`}</Link>
            </div>
          )}
        </div>
      ))}
    </>
  );

  return (
    <>
      <button type="button" aria-label="Ouvrir le menu" aria-expanded={ouvert} onClick={() => setOuvert(true)}
        className="flex h-11 w-11 items-center justify-center lg:hidden">
        <Menu aria-hidden size={22} />
      </button>
      {ouvert && (
        <div className="fixed inset-0 z-50 lg:hidden" onKeyDown={(e) => { if (e.key === 'Escape') fermer(); }}>
          <div aria-hidden="true" data-testid="menu-mobile-fond" onClick={fermer} className="absolute inset-0 bg-[rgba(16,16,20,0.45)]" />
          <div role="dialog" aria-modal="true" aria-label="Menu" className="absolute inset-y-0 left-0 flex w-[350px] max-w-[90vw] flex-col bg-[var(--vs-blanc)] text-[var(--vs-noir)]">
            <div className="flex h-[60px] shrink-0 items-center justify-between border-b border-[var(--vs-ligne)] px-[18px]">
              {rubrique === null ? (
                <span className="text-xl font-black tracking-[0.06em]">VICTO STORE</span>
              ) : (
                <button type="button" onClick={() => { setRubrique(null); setDeplie(null); }}
                  className="flex items-center gap-1.5 text-[17px] font-extrabold">
                  <ChevronLeft aria-hidden size={20} />
                  {ARBRE[rubrique].libelle}
                </button>
              )}
              <button type="button" aria-label="Fermer le menu" onClick={fermer}
                className="flex h-11 w-11 items-center justify-center rounded-full bg-[var(--vs-surface)]">
                <X aria-hidden size={18} />
              </button>
            </div>
            <div className="flex-1 overflow-y-auto px-5 pb-6">{rubrique === null ? niveau1 : niveau2}</div>
          </div>
        </div>
      )}
    </>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_11__
cat > 'tickets/108m-entete-navigation.md' <<'__VICTO_FIN_12__'
TICKET 108m — l'en-tête utilise la nouvelle navigation et le menu mobile

Modifie `src/components/ui/SiteHeader.tsx`. Deux éléments sont remplacés par les
composants des tickets 108k et 108l, qui reprennent exactement leur rôle.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Rien d'autre ne change : logo, champ de recherche, « Mon compte » et panier restent
  tels quels. `export type NavItem` (ou `interface NavItem`) reste exporté par ce fichier.
- `noUnusedLocals` est actif : retire ce qui ne sert plus (voir l'étape 4).

## Les quatre changements
1. Ajoute, à la suite des imports existants :
   ```tsx
   import { MenuMobile } from '@/components/navigation/MenuMobile';
   import { NavigationPrincipale } from '@/components/navigation/NavigationPrincipale';
   ```
2. Remplace tout l'élément `<nav aria-label="Navigation principale" …>…</nav>` par :
   `<NavigationPrincipale navItems={navItems} />`
3. Remplace tout l'élément `<button … aria-label="Ouvrir le menu" …>…</button>` par :
   `<MenuMobile navItems={navItems} />`
4. Retire de `SiteHeader.tsx` ce qui ne sert plus : la fonction `classeLien`, la ligne
   `const chemin: string | null = usePathname();`, l'import de `usePathname`, et l'icône
   `Menu` de l'import `lucide-react` si plus rien ne l'utilise.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/entete-v3.test.tsx`,
`tests/entete-page-active.test.tsx` et `tests/finitions-SiteHeader.test.tsx`.
__VICTO_FIN_12__
cat > 'tickets/manifest-108.tsv' <<'__VICTO_FIN_13__'
108a	src/lib/arbre-categories.ts	tests/arbre-categories.test.ts	tickets/108a-arbre-categories.md	src/lib/catalogue.ts		
108b	src/components/catalogue/SousCategories.tsx	tests/SousCategories.test.tsx	tickets/108b-sous-categories.md	src/lib/arbre-categories.ts,src/components/catalogue/filtres-affichage.ts	108a	
108c	src/components/catalogue/VueCatalogue.tsx	tests/vue-catalogue-entete.test.tsx	tickets/108c-vue-catalogue-entete.md		108a	
108d	src/app/femme/page.tsx	tests/page-femme-sous-categories.test.tsx	tickets/108d-page-femme.md	src/components/catalogue/SousCategories.tsx,src/lib/arbre-categories.ts	108b,108c	
108e	src/app/homme/page.tsx	tests/page-homme-sous-categories.test.tsx	tickets/108e-page-homme.md	src/components/catalogue/SousCategories.tsx,src/lib/arbre-categories.ts	108b,108c	
108f	src/app/chaussures/page.tsx	tests/page-chaussures-sous-categories.test.tsx	tickets/108f-page-chaussures.md	src/components/catalogue/SousCategories.tsx,src/lib/arbre-categories.ts	108b,108c	
108g	src/components/catalogue/PageSousCategorie.tsx	tests/PageSousCategorie.test.tsx	tickets/108g-page-sous-categorie.md	src/lib/arbre-categories.ts,src/components/catalogue/SousCategories.tsx,src/components/produit/FilAriane.tsx	108a,108b,108c	
108h	src/app/femme/[...chemin]/page.tsx	tests/route-femme-sous-categorie.test.tsx	tickets/108h-route-femme.md	src/components/catalogue/PageSousCategorie.tsx	108g	
108i	src/app/homme/[...chemin]/page.tsx	tests/route-homme-sous-categorie.test.tsx	tickets/108i-route-homme.md	src/components/catalogue/PageSousCategorie.tsx	108g	
108j	src/app/chaussures/[...chemin]/page.tsx	tests/route-chaussures-sous-categorie.test.tsx	tickets/108j-route-chaussures.md	src/components/catalogue/PageSousCategorie.tsx	108g	
108k	src/components/navigation/NavigationPrincipale.tsx	tests/NavigationPrincipale.test.tsx	tickets/108k-navigation-principale.md	src/lib/arbre-categories.ts	108a	
108l	src/components/navigation/MenuMobile.tsx	tests/MenuMobile.test.tsx	tickets/108l-menu-mobile.md	src/lib/arbre-categories.ts	108a	
108m	src/components/ui/SiteHeader.tsx	tests/entete-navigation.test.tsx	tickets/108m-entete-navigation.md	src/components/navigation/NavigationPrincipale.tsx,src/components/navigation/MenuMobile.tsx	108k,108l	
__VICTO_FIN_13__
cat > 'tickets/tests/MenuMobile.test.tsx' <<'__VICTO_FIN_14__'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { MenuMobile } from '../src/components/navigation/MenuMobile';
import { ARBRE } from '../src/lib/arbre-categories';
import { NAV } from '../src/lib/navigation';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const ouvrir = () => fireEvent.click(screen.getByRole('button', { name: 'Ouvrir le menu' }));
const tiroir = () => screen.getByRole('dialog', { name: 'Menu' });

describe('MenuMobile — le bouton', () => {
  it('garde le nom, la classe et l’icône du bouton de l’en-tête', () => {
    render(<MenuMobile navItems={NAV} />);
    const bouton = screen.getByRole('button', { name: 'Ouvrir le menu' });
    expect(classes(bouton)).toContain('lg:hidden');
    expect(bouton.querySelector('svg.lucide-menu')).not.toBeNull();
    expect(bouton).toHaveAttribute('aria-expanded', 'false');
    expect(screen.queryByRole('dialog')).toBeNull();
  });
});

describe('MenuMobile — le tiroir', () => {
  it('liste les rubriques, puis les sous-catégories de celle choisie', () => {
    render(<MenuMobile navItems={NAV} />);
    ouvrir();
    const t = within(tiroir());
    expect(t.getByRole('link', { name: 'Marques' })).toHaveAttribute('href', '/marques');
    expect(classes(t.getByRole('link', { name: 'Soldes' }))).toContain('text-[#E4002B]');
    fireEvent.click(t.getByRole('button', { name: 'Homme' }));
    expect(t.getByRole('link', { name: 'Tout voir Homme' })).toHaveAttribute('href', '/homme');
    const sections = ARBRE.homme.enfants.map((sc) => sc.libelle);
    for (const s of sections) expect(t.getByRole('button', { name: s })).toHaveAttribute('aria-expanded', 'false');
    fireEvent.click(t.getByRole('button', { name: 'Chaussures' }));
    expect(t.getByRole('button', { name: 'Chaussures' })).toHaveAttribute('aria-expanded', 'true');
    expect(t.getByRole('link', { name: 'Course' })).toHaveAttribute('href', '/homme/chaussures/course');
    expect(t.getByRole('link', { name: 'Tout chaussures' })).toHaveAttribute('href', '/homme/chaussures');
  });

  it('revient aux rubriques', () => {
    render(<MenuMobile navItems={NAV} />);
    ouvrir();
    fireEvent.click(within(tiroir()).getByRole('button', { name: 'Femme' }));
    fireEvent.click(within(tiroir()).getByRole('button', { name: 'Femme' }));
    expect(within(tiroir()).getByRole('button', { name: 'Homme' })).toBeInTheDocument();
  });

  it('propose directement les sous-catégories de Chaussures, sans niveau à déplier', () => {
    render(<MenuMobile navItems={NAV} />);
    ouvrir();
    fireEvent.click(within(tiroir()).getByRole('button', { name: 'Chaussures' }));
    expect(within(tiroir()).getByRole('link', { name: 'Sneakers' })).toHaveAttribute('href', '/chaussures/sneakers');
  });

  // (cliquer sur un lien Next tenterait une navigation hors du routeur : non testé ici)
  it('se ferme par la croix, Échap ou le fond', () => {
    render(<MenuMobile navItems={NAV} />);
    ouvrir();
    fireEvent.click(screen.getByRole('button', { name: 'Fermer le menu' }));
    expect(screen.queryByRole('dialog')).toBeNull();
    ouvrir();
    fireEvent.keyDown(tiroir(), { key: 'Escape' });
    expect(screen.queryByRole('dialog')).toBeNull();
    ouvrir();
    fireEvent.click(screen.getByTestId('menu-mobile-fond'));
    expect(screen.queryByRole('dialog')).toBeNull();
  });
});
__VICTO_FIN_14__
cat > 'tickets/tests/NavigationPrincipale.test.tsx' <<'__VICTO_FIN_15__'
import { act, fireEvent, render, screen, within } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { NavigationPrincipale } from '../src/components/navigation/NavigationPrincipale';
import { produitsDe } from '../src/lib/arbre-categories';
import { hrefMarque } from '../src/lib/catalogue';
import { listerMarques, listerProduits } from '../src/lib/donnees';
import { NAV } from '../src/lib/navigation';

const etat = vi.hoisted(() => ({ chemin: null as string | null }));
vi.mock('next/navigation', async (original) => ({
  ...(await original<typeof import('next/navigation')>()),
  usePathname: () => etat.chemin,
}));

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const nav = () => screen.getByRole('navigation', { name: 'Navigation principale' });
const rubrique = (nom: string) => within(nav()).getByRole('link', { name: nom });
const panneau = (nom: string) => screen.queryByRole('region', { name: `Sous-catégories de ${nom}` });
const href = (zone: HTMLElement, nom: string) => within(zone).getByRole('link', { name: nom }).getAttribute('href');

afterEach(() => { vi.useRealTimers(); etat.chemin = null; });

describe('NavigationPrincipale — comme avant', () => {
  it('garde le nom, les classes et le marquage de la page active', () => {
    etat.chemin = '/homme/chaussures';
    render(<NavigationPrincipale navItems={NAV} />);
    for (const k of ['hidden', 'justify-self-center', 'gap-8', 'lg:flex']) expect(classes(nav())).toContain(k);
    expect(rubrique('Homme')).toHaveAttribute('aria-current', 'page');
    expect(rubrique('Soldes')).toHaveAttribute('href', '/soldes');
    expect(classes(rubrique('Soldes'))).toContain('text-[#FF5A74]');
    expect(panneau('Homme')).toBeNull();
  });
});

describe('NavigationPrincipale — méga-menu', () => {
  it('ouvre les sous-catégories de Homme sur deux niveaux', () => {
    render(<NavigationPrincipale navItems={NAV} />);
    fireEvent.mouseEnter(rubrique('Homme'));
    const zone = panneau('Homme') as HTMLElement;
    expect(zone).not.toBeNull();
    expect(href(zone, 'Chaussures')).toBe('/homme/chaussures');
    expect(href(zone, 'Course')).toBe('/homme/chaussures/course');
    expect(href(zone, 'Tout vêtements')).toBe('/homme/vetements');
    const n = produitsDe(listerProduits(), 'homme', []).length;
    expect(href(zone, `Tout voir Homme (${n} ${n > 1 ? 'produits' : 'produit'})`)).toBe('/homme');
  });

  it('montre les chaussures en vignettes et les marques', () => {
    render(<NavigationPrincipale navItems={NAV} />);
    fireEvent.mouseEnter(rubrique('Chaussures'));
    expect(href(panneau('Chaussures') as HTMLElement, 'Sneakers')).toBe('/chaussures/sneakers');
    fireEvent.mouseEnter(rubrique('Marques'));
    expect(panneau('Chaussures')).toBeNull();
    const marques = panneau('Marques') as HTMLElement;
    for (const m of listerMarques()) expect(href(marques, m.nom)).toBe(hrefMarque(m));
  });

  it('n’ouvre rien pour les soldes, et s’ouvre aussi au clavier', () => {
    render(<NavigationPrincipale navItems={NAV} />);
    fireEvent.mouseEnter(rubrique('Soldes'));
    expect(screen.queryByRole('region')).toBeNull();
    fireEvent.focus(rubrique('Femme'));
    expect(panneau('Femme')).not.toBeNull();
  });

  it('se ferme avec Échap', () => {
    render(<NavigationPrincipale navItems={NAV} />);
    fireEvent.mouseEnter(rubrique('Homme'));
    fireEvent.keyDown(rubrique('Homme'), { key: 'Escape' });
    expect(panneau('Homme')).toBeNull();
  });

  it('se ferme 200 ms après la sortie, sauf si la souris revient', () => {
    vi.useFakeTimers();
    render(<NavigationPrincipale navItems={NAV} />);
    fireEvent.mouseEnter(rubrique('Homme'));
    fireEvent.mouseLeave(nav());
    act(() => { vi.advanceTimersByTime(100); });
    expect(panneau('Homme')).not.toBeNull();
    fireEvent.mouseEnter(nav());
    act(() => { vi.advanceTimersByTime(300); });
    expect(panneau('Homme')).not.toBeNull();
    fireEvent.mouseLeave(nav());
    act(() => { vi.advanceTimersByTime(250); });
    expect(panneau('Homme')).toBeNull();
  });
});
__VICTO_FIN_15__
cat > 'tickets/tests/PageSousCategorie.test.tsx' <<'__VICTO_FIN_16__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { PageSousCategorie } from '../src/components/catalogue/PageSousCategorie';

const pastilles = (nom: string) => within(screen.getByRole('navigation', { name: nom })).getAllByRole('link');

describe('PageSousCategorie', () => {
  it('titre la page et propose ses enfants, « Tout » marqué', () => {
    render(<PageSousCategorie rubrique="homme" chemin={['chaussures']} />);
    expect(screen.getByTestId('liste-titre').textContent).toBe('Chaussures Homme');
    const liens = pastilles('Sous-catégories de Chaussures');
    expect(liens.map((l: HTMLElement) => l.textContent)).toEqual(['Tout', 'Sneakers', 'Course', 'Basket', 'Sandales']);
    expect(liens.find((l: HTMLElement) => l.getAttribute('aria-current') === 'page')?.textContent).toBe('Tout');
  });

  it('sur une feuille, propose ses sœurs et se marque elle-même', () => {
    render(<PageSousCategorie rubrique="homme" chemin={['chaussures', 'course']} />);
    expect(screen.getByTestId('liste-titre').textContent).toBe('Course Homme');
    const liens = pastilles('Sous-catégories de Course');
    expect(liens.find((l: HTMLElement) => l.getAttribute('aria-current') === 'page')?.getAttribute('href')).toBe('/homme/chaussures/course');
    expect(liens.find((l: HTMLElement) => l.textContent === 'Tout')?.getAttribute('href')).toBe('/homme/chaussures');
  });

  it('remonte par le fil d’Ariane', () => {
    render(<PageSousCategorie rubrique="homme" chemin={['chaussures', 'course']} />);
    const fil = screen.getByTestId('fil-ariane');
    expect(within(fil).getByRole('link', { name: 'Homme' })).toHaveAttribute('href', '/homme');
    expect(within(fil).getByRole('link', { name: 'Chaussures' })).toHaveAttribute('href', '/homme/chaussures');
  });

  it('refuse un chemin inconnu ou vide', () => {
    expect(() => render(<PageSousCategorie rubrique="homme" chemin={['inconnu']} />)).toThrow();
    expect(() => render(<PageSousCategorie rubrique="homme" chemin={[]} />)).toThrow();
  });
});
__VICTO_FIN_16__
cat > 'tickets/tests/SousCategories.test.tsx' <<'__VICTO_FIN_17__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { PILULE_OFF, PILULE_ON } from '../src/components/catalogue/filtres-affichage';
import { SousCategories } from '../src/components/catalogue/SousCategories';

const ELEMENTS = [
  { libelle: 'Tout', href: '/homme/chaussures', nombre: 3 },
  { libelle: 'Course', href: '/homme/chaussures/course', nombre: 1 },
  { libelle: 'Basket', href: '/homme/chaussures/basket', nombre: 0 },
];
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('SousCategories', () => {
  it('affiche des vignettes avec leur nombre de produits, accordé', () => {
    render(<SousCategories titre="Sous-catégories de Homme" elements={ELEMENTS} forme="vignettes" />);
    const nav = screen.getByRole('navigation', { name: 'Sous-catégories de Homme' });
    const liens = within(nav).getAllByRole('link');
    expect(liens.map((l: HTMLElement) => l.getAttribute('href'))).toEqual(ELEMENTS.map((e) => e.href));
    expect(within(nav).getByText('3 produits')).toBeInTheDocument();
    expect(within(nav).getByText('1 produit')).toBeInTheDocument();
    expect(within(nav).getByText('0 produit')).toBeInTheDocument();
  });

  it('affiche des pastilles et marque celle de la page', () => {
    render(<SousCategories titre="Sous-catégories de Chaussures" elements={ELEMENTS} forme="pastilles" actif="/homme/chaussures/course" />);
    const course = screen.getByRole('link', { name: 'Course' });
    expect(course).toHaveAttribute('aria-current', 'page');
    for (const k of PILULE_ON.split(' ')) expect(classes(course)).toContain(k);
    const tout = screen.getByRole('link', { name: 'Tout' });
    expect(tout).not.toHaveAttribute('aria-current');
    for (const k of PILULE_OFF.split(' ')) expect(classes(tout)).toContain(k);
  });

  it('ne rend rien sans sous-catégorie', () => {
    const { container } = render(<SousCategories titre="x" elements={[]} forme="pastilles" />);
    expect(container.innerHTML).toBe('');
  });
});
__VICTO_FIN_17__
cat > 'tickets/tests/arbre-categories.test.ts' <<'__VICTO_FIN_18__'
import { describe, expect, it } from 'vitest';
import { correspondAuGenre, type Marque, type Produit } from '../src/lib/catalogue';
import { ARBRE, estRubrique, hrefDe, produitsDe, sousCategories, titreDe, trouverNoeud } from '../src/lib/arbre-categories';

const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const P = (slug: string, genre: Produit['genre'], categorie: Produit['categorie']): Produit => ({
  id: slug, slug, nom: slug, marque: NIKE, imageUrl: '/x.svg', prixCents: 1000, variantes: [],
  ...(genre ? { genre } : {}), ...(categorie ? { categorie } : {}),
});
const CATALOGUE = [
  P('air-zoom-pegasus-41', 'homme', 'chaussures'), P('chuck-taylor-all-star', 'mixte', 'chaussures'),
  P('polo-shirt', 'homme', 'vetements'), P('robe-ete', 'femme', 'vetements'), P('casquette', 'homme', 'accessoires'),
];
const slugs = (l: Produit[]) => l.map((p) => p.slug);
// Ce qui compte pour Homme dépend de correspondAuGenre (les produits « mixte ») : on le lui demande.
const homme = CATALOGUE.filter((p) => correspondAuGenre(p, 'homme'));
const hommeChaussures = homme.filter((p) => p.categorie === 'chaussures');

describe('arbre des catégories', () => {
  it('reconnaît les rubriques et construit les adresses', () => {
    expect(['femme', 'homme', 'chaussures', 'marques'].map(estRubrique)).toEqual([true, true, true, false]);
    expect(hrefDe('homme', [])).toBe('/homme');
    expect(hrefDe('homme', ['chaussures', 'course'])).toBe('/homme/chaussures/course');
    expect(ARBRE.homme.enfants.map((e) => e.slug)).toEqual(['chaussures', 'vetements', 'accessoires']);
    expect(ARBRE.chaussures.enfants.map((e) => e.slug)).toEqual(['sneakers', 'course', 'basket', 'sandales', 'bottes']);
  });

  it('retrouve un nœud et sa lignée, et refuse un chemin inconnu', () => {
    expect(trouverNoeud('homme', ['chaussures', 'course'])?.lignee.map((n) => n.libelle)).toEqual(['Homme', 'Chaussures', 'Course']);
    expect(trouverNoeud('homme', [])?.noeud.libelle).toBe('Homme');
    expect(trouverNoeud('homme', ['chaussures', 'inconnu'])).toBeUndefined();
    expect(trouverNoeud('chaussures', ['vetements'])).toBeUndefined();
  });

  it('choisit les produits par genre, catégorie puis type de démonstration', () => {
    expect(slugs(produitsDe(CATALOGUE, 'homme', []))).toEqual(slugs(homme));
    expect(slugs(produitsDe(CATALOGUE, 'homme', ['chaussures']))).toEqual(slugs(hommeChaussures));
    expect(slugs(produitsDe(CATALOGUE, 'homme', ['chaussures', 'course']))).toEqual(['air-zoom-pegasus-41']);
    expect(slugs(produitsDe(CATALOGUE, 'femme', ['vetements']))).toEqual(['robe-ete']);
    expect(slugs(produitsDe(CATALOGUE, 'chaussures', []))).toEqual(['air-zoom-pegasus-41', 'chuck-taylor-all-star']);
    expect(slugs(produitsDe(CATALOGUE, 'chaussures', ['sneakers']))).toEqual(['chuck-taylor-all-star']);
  });

  it('liste les sous-catégories avec leur adresse et leur nombre de produits', () => {
    expect(sousCategories(CATALOGUE, 'homme', [])).toEqual([
      { libelle: 'Chaussures', href: '/homme/chaussures', nombre: hommeChaussures.length },
      { libelle: 'Vêtements', href: '/homme/vetements', nombre: homme.filter((p) => p.categorie === 'vetements').length },
      { libelle: 'Accessoires', href: '/homme/accessoires', nombre: homme.filter((p) => p.categorie === 'accessoires').length },
    ]);
    expect(sousCategories(CATALOGUE, 'homme', ['chaussures', 'course'])).toEqual([]);
    expect(sousCategories(CATALOGUE, 'homme', ['inconnu'])).toEqual([]);
  });

  it('titre les pages', () => {
    expect(titreDe('homme', [])).toBe('Homme');
    expect(titreDe('homme', ['chaussures'])).toBe('Chaussures Homme');
    expect(titreDe('femme', ['vetements', 'jeans'])).toBe('Jeans Femme');
    expect(titreDe('chaussures', ['course'])).toBe('Course');
    expect(titreDe('homme', ['inconnu'])).toBe('');
  });
});
__VICTO_FIN_18__
cat > 'tickets/tests/entete-navigation.test.tsx' <<'__VICTO_FIN_19__'
import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ARBRE } from '../src/lib/arbre-categories';
import { SiteHeader } from '../src/components/ui/SiteHeader';
import { NAV } from '../src/lib/navigation';

describe('en-tête — navigation et menu mobile', () => {
  it('ouvre le méga-menu au survol d’une rubrique', () => {
    render(<SiteHeader navItems={NAV} />);
    const nav = screen.getByRole('navigation', { name: 'Navigation principale' });
    fireEvent.mouseEnter(within(nav).getByRole('link', { name: 'Homme' }));
    expect(screen.getByRole('region', { name: `Sous-catégories de ${ARBRE.homme.libelle}` })).toBeInTheDocument();
  });

  it('ouvre le menu mobile', () => {
    render(<SiteHeader navItems={NAV} />);
    fireEvent.click(screen.getByRole('button', { name: 'Ouvrir le menu' }));
    expect(screen.getByRole('dialog', { name: 'Menu' })).toBeInTheDocument();
  });

  it('délègue la navigation et le menu à leurs composants', () => {
    const source = readFileSync('src/components/ui/SiteHeader.tsx', 'utf8');
    expect(source).toContain("import { NavigationPrincipale } from '@/components/navigation/NavigationPrincipale';");
    expect(source).toContain("import { MenuMobile } from '@/components/navigation/MenuMobile';");
    expect(source).not.toContain('function classeLien');
  });
});
__VICTO_FIN_19__
cat > 'tickets/tests/page-chaussures-sous-categories.test.tsx' <<'__VICTO_FIN_20__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import Page from '../src/app/chaussures/page';
import { sousCategories } from '../src/lib/arbre-categories';
import { listerProduits } from '../src/lib/donnees';

describe('page Chaussures — sous-catégories', () => {
  it('affiche ses sous-catégories en vignettes, avec leur adresse', () => {
    render(<Page />);
    expect(screen.getByTestId('liste-titre').textContent).toBe('Chaussures');
    const nav = screen.getByRole('navigation', { name: 'Sous-catégories de Chaussures' });
    const attendues = sousCategories(listerProduits(), 'chaussures', []);
    expect(within(nav).getAllByRole('link').map((l: HTMLElement) => l.getAttribute('href'))).toEqual(attendues.map((e) => e.href));
  });
});
__VICTO_FIN_20__
cat > 'tickets/tests/page-femme-sous-categories.test.tsx' <<'__VICTO_FIN_21__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import Page from '../src/app/femme/page';
import { sousCategories } from '../src/lib/arbre-categories';
import { listerProduits } from '../src/lib/donnees';

describe('page Femme — sous-catégories', () => {
  it('affiche ses sous-catégories en vignettes, avec leur adresse', () => {
    render(<Page />);
    expect(screen.getByTestId('liste-titre').textContent).toBe('Femme');
    const nav = screen.getByRole('navigation', { name: 'Sous-catégories de Femme' });
    const attendues = sousCategories(listerProduits(), 'femme', []);
    expect(within(nav).getAllByRole('link').map((l: HTMLElement) => l.getAttribute('href'))).toEqual(attendues.map((e) => e.href));
  });
});
__VICTO_FIN_21__
cat > 'tickets/tests/page-homme-sous-categories.test.tsx' <<'__VICTO_FIN_22__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import Page from '../src/app/homme/page';
import { sousCategories } from '../src/lib/arbre-categories';
import { listerProduits } from '../src/lib/donnees';

describe('page Homme — sous-catégories', () => {
  it('affiche ses sous-catégories en vignettes, avec leur adresse', () => {
    render(<Page />);
    expect(screen.getByTestId('liste-titre').textContent).toBe('Homme');
    const nav = screen.getByRole('navigation', { name: 'Sous-catégories de Homme' });
    const attendues = sousCategories(listerProduits(), 'homme', []);
    expect(within(nav).getAllByRole('link').map((l: HTMLElement) => l.getAttribute('href'))).toEqual(attendues.map((e) => e.href));
  });
});
__VICTO_FIN_22__
cat > 'tickets/tests/route-chaussures-sous-categorie.test.tsx' <<'__VICTO_FIN_23__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import Page from '../src/app/chaussures/[...chemin]/page';
import { titreDe } from '../src/lib/arbre-categories';

describe('route /chaussures/…', () => {
  it('affiche la sous-catégorie demandée', async () => {
    const chemin = ['sneakers'];
    render(await Page({ params: Promise.resolve({ chemin }) }));
    expect(screen.getByTestId('liste-titre').textContent).toBe(titreDe('chaussures', chemin));
  });
});
__VICTO_FIN_23__
cat > 'tickets/tests/route-femme-sous-categorie.test.tsx' <<'__VICTO_FIN_24__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import Page from '../src/app/femme/[...chemin]/page';
import { titreDe } from '../src/lib/arbre-categories';

describe('route /femme/…', () => {
  it('affiche la sous-catégorie demandée', async () => {
    const chemin = ['chaussures'];
    render(await Page({ params: Promise.resolve({ chemin }) }));
    expect(screen.getByTestId('liste-titre').textContent).toBe(titreDe('femme', chemin));
  });
});
__VICTO_FIN_24__
cat > 'tickets/tests/route-homme-sous-categorie.test.tsx' <<'__VICTO_FIN_25__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import Page from '../src/app/homme/[...chemin]/page';
import { titreDe } from '../src/lib/arbre-categories';

describe('route /homme/…', () => {
  it('affiche la sous-catégorie demandée', async () => {
    const chemin = ['chaussures'];
    render(await Page({ params: Promise.resolve({ chemin }) }));
    expect(screen.getByTestId('liste-titre').textContent).toBe(titreDe('homme', chemin));
  });
});
__VICTO_FIN_25__
cat > 'tickets/tests/vue-catalogue-entete.test.tsx' <<'__VICTO_FIN_26__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { VueCatalogue } from '../src/components/catalogue/VueCatalogue';
import { sousCategories } from '../src/lib/arbre-categories';
import type { Produit } from '../src/lib/catalogue';

// Un produit, pour que la vue affiche sa barre de filtres (une liste vide a peut-être son propre écran).
const UN: Produit[] = [{
  id: 'p1', slug: 'p1', nom: 'Produit', marque: { id: 'm1', nom: 'Nike', slug: 'nike' }, imageUrl: '/x.svg', prixCents: 1000,
  variantes: [{ id: 'v1', taille: '42', sku: 'S-42', stock: 2 }],
}];

describe('VueCatalogue — bandeau sous le titre', () => {
  it('place le bandeau entre le titre et la barre de filtres', () => {
    render(<VueCatalogue titre="Homme" produits={UN} entete={<nav aria-label="Sous-catégories de Homme">bandeau</nav>} />);
    const bandeau = screen.getByRole('navigation', { name: 'Sous-catégories de Homme' });
    const titre = screen.getByTestId('liste-titre');
    const barre = screen.getByTestId('filtres-barre');
    expect(titre.compareDocumentPosition(bandeau) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(bandeau.compareDocumentPosition(barre) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(sousCategories([], 'homme', [])).toHaveLength(3);
  });

  it('reste identique sans bandeau', () => {
    render(<VueCatalogue titre="Homme" produits={UN} />);
    expect(screen.queryByRole('navigation', { name: 'Sous-catégories de Homme' })).toBeNull();
  });
});
__VICTO_FIN_26__
TESTS=(MenuMobile.test.tsx NavigationPrincipale.test.tsx PageSousCategorie.test.tsx SousCategories.test.tsx arbre-categories.test.ts entete-navigation.test.tsx page-chaussures-sous-categories.test.tsx page-femme-sous-categories.test.tsx page-homme-sous-categories.test.tsx route-chaussures-sous-categorie.test.tsx route-femme-sous-categorie.test.tsx route-homme-sous-categorie.test.tsx vue-catalogue-entete.test.tsx)
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
ok "13 specs, 13 tests en attente et le manifeste écrits"

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/108*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-108.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
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
  git commit -q -m "chore(tickets): lot 108 — navigation par sous-catégories"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-108.tsv ./run.sh\n\nTreize tickets, dont six très courts. Compte trois heures à trois heures et demie : un run à lancer le soir.\n'
