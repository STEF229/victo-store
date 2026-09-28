#!/usr/bin/env bash
# VICTO STORE — lot 107 : la recherche complète.
#   107a logique (accents, majuscules, tous les mots, pertinence)   107b /recherche (résultats, aucun résultat, vide)
#   107c champ avec suggestions pendant la saisie                    107d branché dans l'en-tête
# Usage :  cd ~/victo-store && bash lot-107.sh
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
SH=src/components/ui/SiteHeader.tsx
fusionne(){ git log main -1 --format=%h --fixed-strings --grep="feat($1): fusionné" | grep -q .; }
for d in 095c 099b; do fusionne "$d" || mort "$d n'est pas fusionné : le lot 107 s'appuie dessus"; done
fusionne 102m || info "le lot 105 n'est pas encore passé : lance-le AVANT celui-ci (sinon le 102m devra être réécrit par le modèle)"
[ "$(grep -c 'htmlFor="recherche-entete"' "$SH")" = 1 ] && [ "$(grep -c 'id="recherche-entete"' "$SH")" = 1 ] || mort "$SH : le champ de recherche n'est pas unique (spec 107d)"
grep -q "ChampRecherche" "$SH" && mort "$SH utilise déjà ChampRecherche : lot déjà passé ?"
grep -qE "export function hrefMarque" src/lib/catalogue.ts && grep -qE "export function hrefProduit" src/lib/catalogue.ts || mort "hrefMarque ou hrefProduit absent de catalogue.ts"
grep -qE "export function listerMarques" src/lib/donnees.ts && grep -qE "export function listerProduits" src/lib/donnees.ts || mort "listerMarques ou listerProduits absent de donnees.ts"
[ -f src/components/catalogue/GrilleProduits.tsx ] && [ -f src/components/catalogue/VueCatalogue.tsx ] || mort "GrilleProduits ou VueCatalogue absent"
for f in src/lib/recherche.ts src/components/recherche src/app/recherche; do [ ! -e "$f" ] || mort "$f existe déjà : lot déjà passé ?"; done
for j in noir blanc surface gris accent; do grep -qE -- "--vs-$j\s*:" src/styles/tokens.css || mort "jeton --vs-$j absent"; done
manque="$(node -e "const l=require('lucide-react');console.log(['Search'].filter(n=>!l[n]).join(' '))" 2>/dev/null || echo lucide-react)"
[ -z "$manque" ] || mort "icônes lucide absentes de ta version : $manque"
ok "en-tête, catalogue, données et vue des listes conformes aux specs"
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
mkdir -p tickets/tests
cat > 'tickets/107a-recherche.md' <<'__VICTO_FIN_0__'
TICKET 107a — logique de recherche

Crée `src/lib/recherche.ts`. Fonctions **pures**, recopiées telles quelles.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`, `.filter`, `.every`, `.some`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~50 lignes.
```ts
import type { Marque, Produit } from '@/lib/catalogue';

/** Minuscules, sans accents, ponctuation remplacée par des espaces. */
export function normaliser(texte: string): string {
  return texte
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();
}

export function motsDe(texte: string): string[] {
  return normaliser(texte).split(' ').filter((m) => m !== '');
}

function texteDe(p: Produit): string {
  return normaliser([p.nom, p.marque.nom, p.description ?? '', p.categorie ?? '', p.genre ?? ''].join(' '));
}

function score(p: Produit, mots: string[]): number {
  const texte = texteDe(p);
  if (!mots.every((m) => texte.includes(m))) return 0;
  const nom = normaliser(p.nom);
  const marque = normaliser(p.marque.nom);
  return 1 + (mots.every((m) => nom.includes(m)) ? 2 : 0) + (mots.some((m) => marque.includes(m)) ? 1 : 0);
}

/** Tous les mots doivent se retrouver dans le produit ; les plus pertinents d'abord, l'ordre du catalogue ensuite. */
export function rechercherProduits(produits: Produit[], terme: string): Produit[] {
  const mots = motsDe(terme);
  if (mots.length === 0) return [];
  return produits
    .map((p, rang) => ({ p, rang, s: score(p, mots) }))
    .filter((x) => x.s > 0)
    .sort((a, b) => b.s - a.s || a.rang - b.rang)
    .map((x) => x.p);
}

/** Les marques dont un mot du nom commence par un mot cherché. */
export function marquesCorrespondantes(marques: Marque[], terme: string): Marque[] {
  const mots = motsDe(terme);
  if (mots.length === 0) return [];
  return marques.filter((ma) => motsDe(ma.nom).some((x) => mots.some((m) => x.startsWith(m))));
}

export function libelleResultats(n: number): string {
  return `${n} ${n > 1 ? 'résultats' : 'résultat'}`;
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_0__
cat > 'tickets/107b-page-recherche.md' <<'__VICTO_FIN_1__'
TICKET 107b — page de recherche

Crée `src/app/recherche/page.tsx`, export par défaut `PageRecherche`. Composant
**serveur** asynchrone : pas de `'use client'`. Le terme vient de l'adresse
(`/recherche?q=nike`).

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`, `.slice`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut.** Chaque `className` est écrit exactement.
- Recopie tous les textes exactement, apostrophes droites comprises. Icônes
  `lucide-react` avec `aria-hidden`.

## Fichier complet
Taille attendue : ~65 lignes.
```tsx
import { Search } from 'lucide-react';
import Link from 'next/link';
import { GrilleProduits } from '@/components/catalogue/GrilleProduits';
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { listerMarques, listerProduits } from '@/lib/donnees';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
import { rechercherProduits } from '@/lib/recherche';

export default async function PageRecherche({ searchParams }: { searchParams: Promise<{ q?: string | string[] }> }) {
  const { q } = await searchParams;
  const terme = (Array.isArray(q) ? q.join(' ') : q ?? '').trim();
  const resultats = rechercherProduits(listerProduits(), terme);

  if (resultats.length > 0) {
    return (
      <VueCatalogue
        titre={`Résultats pour « ${terme} »`}
        description="Recherche dans les noms, les marques et les descriptions."
        produits={resultats}
      />
    );
  }

  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Recherche' }]} />
        <section data-testid="recherche-vide" className="flex flex-col items-center gap-4 rounded-[28px] bg-[var(--vs-surface)] px-6 py-14 text-center">
          <span className="flex h-16 w-16 items-center justify-center rounded-full bg-[var(--vs-blanc)]">
            <Search aria-hidden size={28} />
          </span>
          <h1 className="text-3xl font-black tracking-tight text-[var(--vs-noir)] lg:text-[40px]">
            {terme === '' ? 'Que cherchez-vous ?' : `Aucun résultat pour « ${terme} »`}
          </h1>
          <p className="max-w-[560px] text-base leading-relaxed text-[var(--vs-gris)]">
            Vérifiez l'orthographe, essayez un terme plus court ou cherchez par marque. Les pointures se choisissent sur la fiche du produit.
          </p>
          <p className="text-[13px] font-extrabold uppercase tracking-[0.14em] text-[var(--vs-gris)]">Nos marques</p>
          <div className="flex max-w-[760px] flex-wrap justify-center gap-2.5">
            {listerMarques().map((m) => (
              <Link key={m.slug} href={`/recherche?q=${encodeURIComponent(m.nom)}`}
                className="rounded-full bg-[var(--vs-blanc)] px-4 py-2 text-[15px] font-semibold text-[var(--vs-noir)]">
                {m.nom}
              </Link>
            ))}
          </div>
        </section>
        <section className="mt-10 flex flex-col gap-5">
          <h2 className="text-[28px] font-black text-[var(--vs-noir)]">Ça pourrait vous plaire</h2>
          <GrilleProduits produits={listerProduits().slice(0, 4)} colonnes={4} />
        </section>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > 'tickets/107c-champ-recherche.md' <<'__VICTO_FIN_2__'
TICKET 107c — champ de recherche avec suggestions

Crée `src/components/recherche/ChampRecherche.tsx`, export nommé `ChampRecherche`.
C'est un vrai formulaire (`GET /recherche?q=…`) : la touche Entrée lance la recherche.
Dès 2 caractères, il propose les marques et les produits correspondants.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`, `.slice`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`, **aucun
  `<button>`**. Icônes `lucide-react` avec `aria-hidden`.

## Bloc d'imports exact
```tsx
'use client';

import { Search } from 'lucide-react';
import Link from 'next/link';
import { useState, type FocusEvent } from 'react';
import { hrefMarque, hrefProduit } from '@/lib/catalogue';
import { listerMarques, listerProduits } from '@/lib/donnees';
import { formatPrice } from '@/lib/formatPrice';
import { marquesCorrespondantes, rechercherProduits } from '@/lib/recherche';
```

## Logique
Taille attendue : ~85 lignes.
```tsx
export function ChampRecherche() {
  const [terme, setTerme] = useState('');
  const [ouvert, setOuvert] = useState(false);
  const actif = terme.trim().length >= 2;
  const produits = actif ? rechercherProduits(listerProduits(), terme) : [];
  const marques = actif ? marquesCorrespondantes(listerMarques(), terme).slice(0, 3) : [];
  const visible = ouvert && (produits.length > 0 || marques.length > 0);

  function quitter(e: FocusEvent<HTMLFormElement>) {
    if (!(e.relatedTarget instanceof Node && e.currentTarget.contains(e.relatedTarget))) setOuvert(false);
  }
```

## Rendu
```tsx
  return (
    <form role="search" action="/recherche" method="get" onBlur={quitter} className="relative">
      <label htmlFor="recherche-entete" className="sr-only">Rechercher un produit</label>
      <div className="flex h-11 w-[250px] items-center gap-2.5 rounded-full bg-[#1E1E26] px-[18px]">
        <Search aria-hidden size={17} className="shrink-0 text-[#B5B5BA]" />
        <input id="recherche-entete" name="q" type="search" autoComplete="off" placeholder="Rechercher" value={terme}
          onChange={(e) => { setTerme(e.target.value); setOuvert(true); }}
          onFocus={() => setOuvert(true)}
          onKeyDown={(e) => { if (e.key === 'Escape') setOuvert(false); }}
          className="h-10 min-w-0 flex-1 border-none bg-transparent text-sm text-[var(--vs-blanc)] outline-none placeholder:text-[#B5B5BA]" />
      </div>
      {visible && (
        <div data-testid="suggestions-recherche"
          className="absolute right-0 top-[54px] z-50 flex w-[480px] max-w-[calc(100vw-40px)] flex-col gap-3.5 rounded-[22px] bg-[var(--vs-blanc)] p-4 text-[var(--vs-noir)] shadow-[0_18px_50px_rgba(16,16,20,0.22)]">
          {marques.length > 0 && (
            <div className="flex flex-wrap gap-2 px-2.5">
              {marques.map((m) => (
                <Link key={m.slug} href={hrefMarque(m)} className="rounded-full bg-[var(--vs-noir)] px-3.5 py-1.5 text-sm font-bold text-[var(--vs-blanc)]">
                  {m.nom}
                </Link>
              ))}
            </div>
          )}
          {produits.length > 0 && (
            <ul className="flex flex-col gap-0.5">
              {produits.slice(0, 4).map((p) => (
                <li key={p.slug}>
                  <Link href={hrefProduit(p)} className="grid grid-cols-[52px_minmax(0,1fr)_auto] items-center gap-3.5 rounded-[14px] px-2.5 py-2">
                    <img src={p.imageUrl} alt="" className="h-[52px] w-[52px] rounded-xl bg-[var(--vs-surface)] object-cover" />
                    <span className="flex flex-col">
                      <span className="text-[11px] font-extrabold uppercase tracking-[0.14em] text-[var(--vs-gris)]">{p.marque.nom}</span>
                      <span className="text-[15px] font-bold">{p.nom}</span>
                    </span>
                    <span className="text-[15px] font-extrabold">{formatPrice(p.prixCents)}</span>
                  </Link>
                </li>
              ))}
            </ul>
          )}
          {produits.length > 0 && (
            <Link href={`/recherche?q=${encodeURIComponent(terme.trim())}`}
              className="flex h-[50px] items-center justify-center rounded-full bg-[var(--vs-accent)] text-[15px] font-extrabold text-[var(--vs-blanc)]">
              {produits.length > 1 ? `Voir les ${produits.length} résultats pour « ${terme.trim()} »` : `Voir le résultat pour « ${terme.trim()} »`}
            </Link>
          )}
        </div>
      )}
    </form>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_2__
cat > 'tickets/107d-entete-recherche.md' <<'__VICTO_FIN_3__'
TICKET 107d — l'en-tête utilise le champ de recherche

Modifie `src/components/ui/SiteHeader.tsx`. Le champ de recherche actuel est
décoratif : il est remplacé par le composant `ChampRecherche`, qui garde la même
étiquette, le même identifiant et le même texte indicatif.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Rien d'autre ne change : le bouton de menu, le bouton « Rechercher » (la loupe du
  téléphone), la navigation, « Mon compte » et le panier restent tels quels.

## Les deux changements
1. Ajoute, à la suite des imports existants :
   `import { ChampRecherche } from '@/components/recherche/ChampRecherche';`
2. Remplace l'élément `<label htmlFor="recherche-entete" …>…</label>` **et** l'élément
   qui le suit, celui qui contient `<input … id="recherche-entete" …>`, par exactement :
   ```tsx
   <div className="hidden lg:block">
     <ChampRecherche />
   </div>
   ```
   Il ne doit plus rester, dans `SiteHeader.tsx`, ni `htmlFor="recherche-entete"` ni
   `id="recherche-entete"` : ils sont dans `ChampRecherche`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/entete-v3.test.tsx`
et `tests/finitions-SiteHeader.test.tsx`.
__VICTO_FIN_3__
cat > 'tickets/manifest-107.tsv' <<'__VICTO_FIN_4__'
107a	src/lib/recherche.ts	tests/recherche.test.ts	tickets/107a-recherche.md			
107b	src/app/recherche/page.tsx	tests/page-recherche.test.tsx	tickets/107b-page-recherche.md	src/lib/recherche.ts,src/components/catalogue/VueCatalogue.tsx,src/components/produit/FilAriane.tsx	107a	
107c	src/components/recherche/ChampRecherche.tsx	tests/ChampRecherche.test.tsx	tickets/107c-champ-recherche.md	src/lib/recherche.ts,src/lib/catalogue.ts	107a	
107d	src/components/ui/SiteHeader.tsx	tests/entete-recherche.test.tsx	tickets/107d-entete-recherche.md	src/components/recherche/ChampRecherche.tsx	107c	
__VICTO_FIN_4__
cat > 'tickets/tests/ChampRecherche.test.tsx' <<'__VICTO_FIN_5__'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ChampRecherche } from '../src/components/recherche/ChampRecherche';
import { listerMarques, listerProduits } from '../src/lib/donnees';
import { rechercherProduits } from '../src/lib/recherche';

const champ = () => screen.getByLabelText('Rechercher un produit');
const taper = (t: string) => fireEvent.change(champ(), { target: { value: t } });
const suggestions = () => screen.queryByTestId('suggestions-recherche');
// une marque du vrai catalogue qui a des produits, et son nom tapé en minuscules
const marque = listerMarques().find((m) => rechercherProduits(listerProduits(), m.nom).length > 0);
const terme = (marque?.nom ?? '').toLowerCase();

describe('ChampRecherche', () => {
  it('garde l’étiquette, l’identifiant, le type et le texte indicatif de l’en-tête', () => {
    render(<ChampRecherche />);
    expect(champ()).toHaveAttribute('id', 'recherche-entete');
    expect(champ()).toHaveAttribute('type', 'search');
    expect(champ()).toHaveAttribute('placeholder', 'Rechercher');
    expect(champ()).toHaveAttribute('name', 'q');
    const formulaire = screen.getByRole('search');
    expect(formulaire).toHaveAttribute('action', '/recherche');
    expect(formulaire).toHaveAttribute('method', 'get');
    expect(screen.queryByRole('button')).toBeNull();
  });

  it('ne propose rien avant deux caractères', () => {
    render(<ChampRecherche />);
    taper(terme.slice(0, 1));
    expect(suggestions()).toBeNull();
  });

  it('propose la marque, quatre produits au plus et le lien vers tous les résultats', () => {
    expect(marque, 'au moins une marque du catalogue a des produits').toBeDefined();
    render(<ChampRecherche />);
    taper(terme);
    const liste = suggestions();
    expect(liste).not.toBeNull();
    const zone = within(liste as HTMLElement);
    expect(zone.getByRole('link', { name: marque?.nom ?? '' })).toBeInTheDocument();
    const n = rechercherProduits(listerProduits(), terme).length;
    expect(zone.getAllByRole('listitem')).toHaveLength(Math.min(n, 4));
    const nomLien = n > 1 ? `Voir les ${n} résultats pour « ${terme} »` : `Voir le résultat pour « ${terme} »`;
    const tout = zone.getByRole('link', { name: nomLien });
    expect(tout).toHaveAttribute('href', `/recherche?q=${encodeURIComponent(terme)}`);
  });

  it('se ferme avec Échap', () => {
    render(<ChampRecherche />);
    taper(terme);
    fireEvent.keyDown(champ(), { key: 'Escape' });
    expect(suggestions()).toBeNull();
  });

  it('ne propose rien quand rien ne correspond', () => {
    render(<ChampRecherche />);
    taper('zzqqxx');
    expect(suggestions()).toBeNull();
  });
});
__VICTO_FIN_5__
cat > 'tickets/tests/entete-recherche.test.tsx' <<'__VICTO_FIN_6__'
import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteHeader } from '../src/components/ui/SiteHeader';
import { listerMarques, listerProduits } from '../src/lib/donnees';
import { NAV } from '../src/lib/navigation';
import { rechercherProduits } from '../src/lib/recherche';

describe('en-tête — recherche', () => {
  it('cherche vraiment : un formulaire vers /recherche, un seul champ', () => {
    render(<SiteHeader navItems={NAV} />);
    const formulaire = within(screen.getByRole('banner')).getByRole('search');
    expect(formulaire).toHaveAttribute('action', '/recherche');
    expect(within(formulaire).getByLabelText('Rechercher un produit')).toHaveAttribute('name', 'q');
    expect(screen.getAllByLabelText('Rechercher un produit')).toHaveLength(1);
  });

  it('propose des suggestions pendant la saisie', () => {
    const marque = listerMarques().find((m) => rechercherProduits(listerProduits(), m.nom).length > 0);
    render(<SiteHeader navItems={NAV} />);
    fireEvent.change(screen.getByLabelText('Rechercher un produit'), { target: { value: (marque?.nom ?? '').toLowerCase() } });
    expect(screen.getByTestId('suggestions-recherche')).toBeInTheDocument();
  });

  it('délègue le champ au composant de recherche', () => {
    const source = readFileSync('src/components/ui/SiteHeader.tsx', 'utf8');
    expect(source).toContain("import { ChampRecherche } from '@/components/recherche/ChampRecherche';");
    expect(source).not.toContain('id="recherche-entete"');
  });
});
__VICTO_FIN_6__
cat > 'tickets/tests/page-recherche.test.tsx' <<'__VICTO_FIN_7__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageRecherche from '../src/app/recherche/page';
import { listerMarques, listerProduits } from '../src/lib/donnees';
import { rechercherProduits } from '../src/lib/recherche';

const poser = async (q?: string | string[]) =>
  render(await PageRecherche({ searchParams: Promise.resolve(q === undefined ? {} : { q }) }));
const marque = () => listerMarques().find((m) => rechercherProduits(listerProduits(), m.nom).length > 0);

describe('page de recherche — résultats', () => {
  it('affiche les produits trouvés dans la vue des listes', async () => {
    const m = marque();
    expect(m, 'au moins une marque du catalogue a des produits').toBeDefined();
    const nom = m?.nom ?? '';
    const n = rechercherProduits(listerProduits(), nom).length;
    await poser(nom);
    expect(screen.getByTestId('liste-titre').textContent).toBe(`Résultats pour « ${nom} »`);
    expect(screen.getByTestId('compteur').textContent).toBe(`${n} ${n > 1 ? 'produits' : 'produit'}`);
    expect(screen.getByTestId('filtres-barre')).toBeInTheDocument();
    expect(screen.queryByTestId('recherche-vide')).toBeNull();
  });

  it('accepte un terme répété dans l’adresse', async () => {
    const nom = marque()?.nom ?? '';
    await poser([nom]);
    expect(screen.getByTestId('liste-titre').textContent).toBe(`Résultats pour « ${nom} »`);
  });
});

describe('page de recherche — rien trouvé', () => {
  it('le dit, propose les marques et des produits', async () => {
    await poser('zzqqxx introuvable');
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe('Aucun résultat pour « zzqqxx introuvable »');
    const vide = screen.getByTestId('recherche-vide');
    const liens = within(vide).getAllByRole('link');
    expect(liens.map((l: HTMLElement) => l.textContent)).toEqual(listerMarques().map((mq) => mq.nom));
    expect(liens.map((l: HTMLElement) => l.getAttribute('href'))).toEqual(listerMarques().map((mq) => `/recherche?q=${encodeURIComponent(mq.nom)}`));
    expect(screen.getByRole('heading', { level: 2, name: 'Ça pourrait vous plaire' })).toBeInTheDocument();
  });

  it('invite à chercher quand rien n’est saisi', async () => {
    await poser();
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe('Que cherchez-vous ?');
  });
});
__VICTO_FIN_7__
cat > 'tickets/tests/recherche.test.ts' <<'__VICTO_FIN_8__'
import { describe, expect, it } from 'vitest';
import type { Marque, Produit } from '../src/lib/catalogue';
import { libelleResultats, marquesCorrespondantes, motsDe, normaliser, rechercherProduits } from '../src/lib/recherche';

const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const NB: Marque = { id: 'm2', nom: 'New Balance', slug: 'new-balance' };
const LACOSTE: Marque = { id: 'm3', nom: 'Lacoste', slug: 'lacoste' };
const P = (id: string, nom: string, marque: Marque, description?: string): Produit => ({
  id, slug: id, nom, marque, imageUrl: '/x.svg', prixCents: 1000, variantes: [], ...(description ? { description } : {}),
});
const CATALOGUE = [
  P('polo', 'Polo Classic', LACOSTE, 'Coton piqué, crocodile brodé.'),
  P('pegasus', 'Air Zoom Pegasus 41', NIKE, 'Chaussure de course, amorti réactif.'),
  P('nb530', '530 Retro', NB, 'Chaussure rétro inspirée de la course.'),
  P('club', 'Club Fleece', NIKE, 'Sweat molletonné.'),
  P('ete', 'Espadrille Été', LACOSTE),
];
const ids = (l: Produit[]) => l.map((p) => p.id);

describe('recherche — normalisation', () => {
  it('ignore accents, majuscules et ponctuation', () => {
    expect(normaliser('  Été — ÉCHANGÉ, s\u2019il vous plaît ! ')).toBe('ete echange s il vous plait');
    expect(motsDe("Levi's 501")).toEqual(['levi', 's', '501']);
    expect(motsDe('   ')).toEqual([]);
  });
});

describe('recherche — produits', () => {
  it('trouve par marque, nom ou description, sans accents', () => {
    expect(ids(rechercherProduits(CATALOGUE, 'nike'))).toEqual(['pegasus', 'club']);
    expect(ids(rechercherProduits(CATALOGUE, 'ete'))).toEqual(['ete']);
    expect(ids(rechercherProduits(CATALOGUE, 'crocodile'))).toEqual(['polo']);
  });

  it('exige tous les mots', () => {
    expect(ids(rechercherProduits(CATALOGUE, 'nike course'))).toEqual(['pegasus']);
    expect(ids(rechercherProduits(CATALOGUE, 'nike rouge'))).toEqual([]);
  });

  it('met d’abord ce qui correspond au nom, puis l’ordre du catalogue', () => {
    expect(ids(rechercherProduits(CATALOGUE, 'course'))).toEqual(['pegasus', 'nb530']);
    expect(ids(rechercherProduits(CATALOGUE, 'retro'))).toEqual(['nb530']);
    expect(ids(rechercherProduits(CATALOGUE, 'pegasus'))).toEqual(['pegasus']);
  });

  it('ne renvoie rien pour une recherche vide', () => {
    expect(rechercherProduits(CATALOGUE, '  ')).toEqual([]);
  });
});

describe('recherche — marques et libellés', () => {
  it('trouve les marques par le début d’un de leurs mots', () => {
    expect(marquesCorrespondantes([NIKE, NB, LACOSTE], 'ni').map((m) => m.nom)).toEqual(['Nike']);
    expect(marquesCorrespondantes([NIKE, NB, LACOSTE], 'bal').map((m) => m.nom)).toEqual(['New Balance']);
    expect(marquesCorrespondantes([NIKE, NB, LACOSTE], '')).toEqual([]);
  });

  it('accorde le nombre de résultats, zéro au singulier', () => {
    expect([0, 1, 12].map(libelleResultats)).toEqual(['0 résultat', '1 résultat', '12 résultats']);
  });
});
__VICTO_FIN_8__
TESTS=(ChampRecherche.test.tsx entete-recherche.test.tsx page-recherche.test.tsx recherche.test.ts)
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
ok "4 specs, 4 tests en attente et le manifeste écrits"

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/107*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-107.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
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
  git commit -q -m "chore(tickets): lot 107 — recherche complète"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-107.tsv ./run.sh\n\nQuatre tickets : 107a, puis 107b et 107c, puis 107d. Compte environ une heure et demie.\n'
