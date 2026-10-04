#!/usr/bin/env bash
# VICTO STORE — lot 111 : mobile, troisième passe (six corrections ciblées).
#   111a vue des listes : fil d'Ariane avant le titre, marges réduites   111b la page de sous-catégorie l'y place
#   111c sous-catégories sur une ligne qui défile   111d cartes de même hauteur   111e bande sans barre de défilement
#   111f pied de page : Boutique et Aide côte à côte
# Remplacements EXACTS relevés dans tes fichiers ; les corrections de style ajoutent des classes.
# Usage :  cd ~/victo-store && bash lot-111.sh
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

fusionne(){ git log main -1 --format=%h --fixed-strings --grep="feat($1): fusionné" | grep -q .; }
for d in 108g 110h 110c 110k; do fusionne "$d" || mort "$d n'est pas fusionné : le lot 111 s'appuie dessus"; done
# ------------------------------------------------------------ chaque texte « avant », mot pour mot
python3 - <<'VERIF' || mort "un fichier ne correspond pas aux specs (détail ci-dessus) : rien n'a été modifié"
import json, sys
table = json.loads(r'''[["src/components/catalogue/VueCatalogue.tsx", "  entete?: ReactNode | undefined;\n}", "  entete?: ReactNode | undefined;\n  filAriane?: ReactNode | undefined;\n}", 1], ["src/components/catalogue/VueCatalogue.tsx", "export function VueCatalogue({ titre, description, produits, entete }: VueCatalogueProps) {", "export function VueCatalogue({ titre, description, produits, entete, filAriane }: VueCatalogueProps) {", 1], ["src/components/catalogue/VueCatalogue.tsx", "      <main className=\"mx-auto max-w-[1440px] px-5 py-12 lg:px-12\">", "      <main className=\"mx-auto max-w-[1440px] px-5 py-12 lg:px-12 max-sm:pt-6\">\n        {filAriane}", 1], ["src/components/catalogue/VueCatalogue.tsx", "          <div className=\"mt-8\">\n            {entete}", "          <div className=\"mt-8 max-sm:mt-5\">\n            {entete}", 1], ["src/components/catalogue/VueCatalogue.tsx", "        <div className=\"mt-8\">\n          <FiltresBarre", "        <div className=\"mt-8 max-sm:mt-5\">\n          <FiltresBarre", 1], ["src/components/catalogue/PageSousCategorie.tsx", "      entete={\n        <div className=\"flex flex-col gap-4\">\n          <FilAriane items={[{ label: 'Accueil', href: '/' }, ...fil]} />\n          <SousCategories titre={`Sous-catégories de ${trouve.noeud.libelle}`} forme=\"pastilles\" elements={pastilles} actif={hrefDe(rubrique, chemin)} />\n        </div>\n      }", "      filAriane={<FilAriane items={[{ label: 'Accueil', href: '/' }, ...fil]} />}\n      entete={<SousCategories titre={`Sous-catégories de ${trouve.noeud.libelle}`} forme=\"pastilles\" elements={pastilles} actif={hrefDe(rubrique, chemin)} />}", 1], ["src/components/catalogue/SousCategories.tsx", "className=\"grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4\"", "className=\"grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4 max-sm:-mx-5 max-sm:flex max-sm:gap-3 max-sm:overflow-x-auto max-sm:px-5 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden\"", 1], ["src/components/catalogue/SousCategories.tsx", "className=\"flex flex-col gap-2.5 text-[var(--vs-noir)]\"", "className=\"flex flex-col gap-2.5 text-[var(--vs-noir)] max-sm:w-[112px] max-sm:shrink-0 max-sm:gap-1.5\"", 1], ["src/components/catalogue/SousCategories.tsx", "className=\"h-[150px] rounded-[20px] bg-[var(--vs-surface)]\"", "className=\"h-[150px] rounded-[20px] bg-[var(--vs-surface)] max-sm:h-[112px] max-sm:rounded-[18px]\"", 1], ["src/components/catalogue/SousCategories.tsx", "className=\"text-base font-extrabold\"", "className=\"text-base font-extrabold max-sm:text-sm\"", 1], ["src/components/catalogue/SousCategories.tsx", "className=\"flex flex-wrap gap-2.5\"", "className=\"flex flex-wrap gap-2.5 max-sm:-mx-5 max-sm:flex-nowrap max-sm:overflow-x-auto max-sm:px-5 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden\"", 1], ["src/components/catalogue/SousCategories.tsx", "className={`${PILULE} ${e.href === actif ? PILULE_ON : PILULE_OFF}`}", "className={`${PILULE} ${e.href === actif ? PILULE_ON : PILULE_OFF} max-sm:shrink-0 max-sm:whitespace-nowrap`}", 1], ["src/components/ui/ProductCard.tsx", "className={`rounded-lg overflow-hidden bg-[var(--vs-surface)] ${className}`}", "className={`rounded-lg overflow-hidden bg-[var(--vs-surface)] h-full ${className}`}", 1], ["src/components/accueil/SectionBonnesAffaires.tsx", "md:overflow-visible mt-6 max-sm:gap-3\"", "md:overflow-visible mt-6 max-sm:gap-3 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden\"", 1], ["src/components/ui/SiteFooter.tsx", "className=\"grid grid-cols-1 md:grid-cols-2 gap-8\"", "className=\"grid grid-cols-1 md:grid-cols-2 gap-8 max-md:grid-cols-2 max-md:gap-6\"", 1]]''')
ko = 0
for f, avant, apres, n in table:
    try: s = open(f, encoding='utf-8').read()
    except FileNotFoundError: print(f"  ✗ {f} introuvable"); ko += 1; continue
    if apres in s: print(f"  ✗ {f} : déjà modifié (lot déjà passé ?)"); ko += 1; continue
    c = s.count(avant)
    if c != n: print(f"  ✗ {f} : « {avant.splitlines()[0][:80]} » trouvé {c} fois, attendu {n}"); ko += 1
sys.exit(1 if ko else 0)
VERIF
ok "les 15 textes à remplacer sont dans tes fichiers, au bon nombre d'occurrences"
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR

mkdir -p tickets/tests
cat > 'tickets/111a-vue-catalogue.md' <<'__VICTO_FIN_0__'
TICKET 111a — la vue des listes : fil d'Ariane en haut, marges réduites sur téléphone

Modifie `src/components/catalogue/VueCatalogue.tsx`. Une prop facultative `filAriane` est affichée **avant** le titre (rien ne change si elle est absente). Sur téléphone, la marge du haut passe de 48 à 24 px, et les écarts avant le bandeau et les filtres de 32 à 20 px.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
  entete?: ReactNode | undefined;
}
```
Après :
```tsx
  entete?: ReactNode | undefined;
  filAriane?: ReactNode | undefined;
}
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
export function VueCatalogue({ titre, description, produits, entete }: VueCatalogueProps) {
```
Après :
```tsx
export function VueCatalogue({ titre, description, produits, entete, filAriane }: VueCatalogueProps) {
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
      <main className="mx-auto max-w-[1440px] px-5 py-12 lg:px-12">
```
Après :
```tsx
      <main className="mx-auto max-w-[1440px] px-5 py-12 lg:px-12 max-sm:pt-6">
        {filAriane}
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
          <div className="mt-8">
            {entete}
```
Après :
```tsx
          <div className="mt-8 max-sm:mt-5">
            {entete}
```

## Remplacement 5 (l'occurrence unique)
Avant :
```tsx
        <div className="mt-8">
          <FiltresBarre
```
Après :
```tsx
        <div className="mt-8 max-sm:mt-5">
          <FiltresBarre
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_0__
cat > 'tickets/111b-page-sous-categorie.md' <<'__VICTO_FIN_1__'
TICKET 111b — la page de sous-catégorie met son fil d'Ariane en haut

Modifie `src/components/catalogue/PageSousCategorie.tsx`. Le fil d'Ariane passe dans la nouvelle prop `filAriane` de la vue des listes (au-dessus du titre) ; le bandeau ne garde que les pastilles.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
      entete={
        <div className="flex flex-col gap-4">
          <FilAriane items={[{ label: 'Accueil', href: '/' }, ...fil]} />
          <SousCategories titre={`Sous-catégories de ${trouve.noeud.libelle}`} forme="pastilles" elements={pastilles} actif={hrefDe(rubrique, chemin)} />
        </div>
      }
```
Après :
```tsx
      filAriane={<FilAriane items={[{ label: 'Accueil', href: '/' }, ...fil]} />}
      entete={<SousCategories titre={`Sous-catégories de ${trouve.noeud.libelle}`} forme="pastilles" elements={pastilles} actif={hrefDe(rubrique, chemin)} />}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > 'tickets/111c-sous-categories.md' <<'__VICTO_FIN_2__'
TICKET 111c — les sous-catégories tiennent sur une ligne qui défile, sur téléphone

Modifie `src/components/catalogue/SousCategories.tsx`. Sur téléphone : les vignettes deviennent un bandeau de carrés de 112 px qui défile, et les pastilles une seule ligne qui défile, sans barre de défilement visible. Rien ne change au-dessus de 640 px.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4"
```
Après :
```tsx
className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4 max-sm:-mx-5 max-sm:flex max-sm:gap-3 max-sm:overflow-x-auto max-sm:px-5 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
className="flex flex-col gap-2.5 text-[var(--vs-noir)]"
```
Après :
```tsx
className="flex flex-col gap-2.5 text-[var(--vs-noir)] max-sm:w-[112px] max-sm:shrink-0 max-sm:gap-1.5"
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
className="h-[150px] rounded-[20px] bg-[var(--vs-surface)]"
```
Après :
```tsx
className="h-[150px] rounded-[20px] bg-[var(--vs-surface)] max-sm:h-[112px] max-sm:rounded-[18px]"
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
className="text-base font-extrabold"
```
Après :
```tsx
className="text-base font-extrabold max-sm:text-sm"
```

## Remplacement 5 (l'occurrence unique)
Avant :
```tsx
className="flex flex-wrap gap-2.5"
```
Après :
```tsx
className="flex flex-wrap gap-2.5 max-sm:-mx-5 max-sm:flex-nowrap max-sm:overflow-x-auto max-sm:px-5 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
```

## Remplacement 6 (l'occurrence unique)
Avant :
```tsx
className={`${PILULE} ${e.href === actif ? PILULE_ON : PILULE_OFF}`}
```
Après :
```tsx
className={`${PILULE} ${e.href === actif ? PILULE_ON : PILULE_OFF} max-sm:shrink-0 max-sm:whitespace-nowrap`}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_2__
cat > 'tickets/111d-carte.md' <<'__VICTO_FIN_3__'
TICKET 111d — les cartes d'une même ligne ont la même hauteur

Modifie `src/components/ui/ProductCard.tsx`. La carte s'étire à la hauteur de sa case : dans une ligne de la grille ou de la bande des bonnes affaires, toutes les cartes ont la même hauteur, même quand un nom tient sur deux lignes.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className={`rounded-lg overflow-hidden bg-[var(--vs-surface)] ${className}`}
```
Après :
```tsx
className={`rounded-lg overflow-hidden bg-[var(--vs-surface)] h-full ${className}`}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_3__
cat > 'tickets/111e-bonnes-affaires.md' <<'__VICTO_FIN_4__'
TICKET 111e — la bande des bonnes affaires sans barre de défilement

Modifie `src/components/accueil/SectionBonnesAffaires.tsx`. La barre de défilement grise sous les cartes est masquée : on fait défiler du doigt.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
md:overflow-visible mt-6 max-sm:gap-3"
```
Après :
```tsx
md:overflow-visible mt-6 max-sm:gap-3 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_4__
cat > 'tickets/111f-pied-colonnes.md' <<'__VICTO_FIN_5__'
TICKET 111f — le pied de page, Boutique et Aide côte à côte sur téléphone

Modifie `src/components/ui/SiteFooter.tsx`. Sous 768 px, les colonnes « Boutique » et « Aide » sont côte à côte au lieu d'être empilées.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="grid grid-cols-1 md:grid-cols-2 gap-8"
```
Après :
```tsx
className="grid grid-cols-1 md:grid-cols-2 gap-8 max-md:grid-cols-2 max-md:gap-6"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_5__
cat > 'tickets/manifest-111.tsv' <<'__VICTO_FIN_6__'
111a	src/components/catalogue/VueCatalogue.tsx	tests/mobile-vue-catalogue.test.tsx	tickets/111a-vue-catalogue.md			
111b	src/components/catalogue/PageSousCategorie.tsx	tests/mobile-page-sous-categorie.test.tsx	tickets/111b-page-sous-categorie.md		111a	
111c	src/components/catalogue/SousCategories.tsx	tests/mobile-sous-categories.test.tsx	tickets/111c-sous-categories.md			
111d	src/components/ui/ProductCard.tsx	tests/mobile-carte-hauteur.test.tsx	tickets/111d-carte.md			
111e	src/components/accueil/SectionBonnesAffaires.tsx	tests/mobile-bonnes-affaires-defilement.test.tsx	tickets/111e-bonnes-affaires.md			
111f	src/components/ui/SiteFooter.tsx	tests/mobile-pied-colonnes.test.tsx	tickets/111f-pied-colonnes.md			
__VICTO_FIN_6__
cat > 'tickets/tests/mobile-bonnes-affaires-defilement.test.tsx' <<'__VICTO_FIN_7__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SectionBonnesAffaires } from '../src/components/accueil/SectionBonnesAffaires';

describe('bonnes affaires — défilement', () => {
  it('masque la barre de défilement de la bande', () => {
    render(<SectionBonnesAffaires produits={[]} />);
    const classes = (screen.getByTestId('rail').getAttribute('class') ?? '').split(/\s+/);
    for (const k of ['overflow-x-auto', '[scrollbar-width:none]', '[&::-webkit-scrollbar]:hidden']) expect(classes, k).toContain(k);
  });
});
__VICTO_FIN_7__
cat > 'tickets/tests/mobile-carte-hauteur.test.tsx' <<'__VICTO_FIN_8__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ProductCard } from '../src/components/ui/ProductCard';
import type { Produit } from '../src/lib/catalogue';

const P: Produit = {
  id: 'p1', slug: 'p1', nom: 'Chuck Taylor All Star', marque: { id: 'm1', nom: 'Converse', slug: 'converse' }, imageUrl: '/x.svg', prixCents: 8900,
  variantes: [{ id: 'v1', taille: '42', sku: 'S-42', stock: 2 }],
};

describe('carte produit — hauteur', () => {
  it('s’étire à la hauteur de sa case', () => {
    render(<ProductCard produit={P} />);
    const classes = (screen.getByTestId('carte-produit').getAttribute('class') ?? '').split(/\s+/);
    for (const k of ['h-full', 'rounded-lg', 'bg-[var(--vs-surface)]']) expect(classes, k).toContain(k);
  });
});
__VICTO_FIN_8__
cat > 'tickets/tests/mobile-page-sous-categorie.test.tsx' <<'__VICTO_FIN_9__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { PageSousCategorie } from '../src/components/catalogue/PageSousCategorie';

describe('page de sous-catégorie — fil d’Ariane en haut', () => {
  it('place le fil d’Ariane avant le titre, et les pastilles après', () => {
    render(<PageSousCategorie rubrique="femme" chemin={['vetements']} />);
    const fil = screen.getByTestId('fil-ariane');
    const titre = screen.getByTestId('liste-titre');
    const pastilles = screen.getByRole('navigation', { name: 'Sous-catégories de Vêtements' });
    expect(fil.compareDocumentPosition(titre) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(titre.compareDocumentPosition(pastilles) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  });
});
__VICTO_FIN_9__
cat > 'tickets/tests/mobile-pied-colonnes.test.tsx' <<'__VICTO_FIN_10__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteFooter } from '../src/components/ui/SiteFooter';
import { COLONNES_PIED } from '../src/lib/navigation';

describe('pied de page — colonnes sur téléphone', () => {
  it('place Boutique et Aide côte à côte sous 768 px', () => {
    render(<SiteFooter colonnes={COLONNES_PIED} />);
    const grille = screen.getByText('Boutique').closest('.grid');
    expect(grille?.contains(screen.getByText('Aide'))).toBe(true);
    const classes = (grille?.getAttribute('class') ?? '').split(/\s+/);
    for (const k of ['grid-cols-1', 'md:grid-cols-2', 'max-md:grid-cols-2', 'max-md:gap-6']) expect(classes, k).toContain(k);
  });
});
__VICTO_FIN_10__
cat > 'tickets/tests/mobile-sous-categories.test.tsx' <<'__VICTO_FIN_11__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SousCategories } from '../src/components/catalogue/SousCategories';

const ELEMENTS = [
  { libelle: 'Tout', href: '/femme/vetements', nombre: 2 },
  { libelle: 'Sweats et hoodies', href: '/femme/vetements/sweats', nombre: 1 },
];
const SANS_BARRE = ['[scrollbar-width:none]', '[&::-webkit-scrollbar]:hidden'];
const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('sous-catégories — une ligne qui défile sur téléphone', () => {
  it('met les pastilles sur une ligne, sans les couper', () => {
    render(<SousCategories titre="Sous-catégories de Vêtements" elements={ELEMENTS} forme="pastilles" actif="/femme/vetements" />);
    const nav = screen.getByRole('navigation', { name: 'Sous-catégories de Vêtements' });
    for (const k of ['flex-wrap', 'max-sm:flex-nowrap', 'max-sm:overflow-x-auto', ...SANS_BARRE]) expect(classes(nav), k).toContain(k);
    const longue = screen.getByRole('link', { name: 'Sweats et hoodies' });
    for (const k of ['max-sm:shrink-0', 'max-sm:whitespace-nowrap']) expect(classes(longue), k).toContain(k);
  });

  it('fait des vignettes un bandeau de carrés de 112 px', () => {
    render(<SousCategories titre="Sous-catégories de Femme" elements={ELEMENTS} forme="vignettes" />);
    const nav = screen.getByRole('navigation', { name: 'Sous-catégories de Femme' });
    for (const k of ['grid', 'max-sm:flex', 'max-sm:overflow-x-auto', ...SANS_BARRE]) expect(classes(nav), k).toContain(k);
    const lien = screen.getByRole('link', { name: /Sweats et hoodies/ });
    for (const k of ['max-sm:w-[112px]', 'max-sm:shrink-0']) expect(classes(lien), k).toContain(k);
    expect(classes(lien.querySelector('[aria-hidden="true"]'))).toContain('max-sm:h-[112px]');
  });
});
__VICTO_FIN_11__
cat > 'tickets/tests/mobile-vue-catalogue.test.tsx' <<'__VICTO_FIN_12__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { VueCatalogue } from '../src/components/catalogue/VueCatalogue';
import type { Produit } from '../src/lib/catalogue';

const UN: Produit[] = [{
  id: 'p1', slug: 'p1', nom: 'Produit', marque: { id: 'm1', nom: 'Nike', slug: 'nike' }, imageUrl: '/x.svg', prixCents: 1000,
  variantes: [{ id: 'v1', taille: '42', sku: 'S-42', stock: 2 }],
}];
const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('VueCatalogue — fil d’Ariane et marges', () => {
  it('affiche le fil d’Ariane avant le titre', () => {
    render(<VueCatalogue titre="Vêtements Femme" produits={UN} filAriane={<nav data-testid="fil-test">fil</nav>} />);
    const fil = screen.getByTestId('fil-test');
    expect(fil.compareDocumentPosition(screen.getByTestId('liste-titre')) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  });

  it('réduit les marges sur téléphone', () => {
    render(<VueCatalogue titre="Femme" produits={UN} entete={<nav data-testid="bandeau-test">b</nav>} />);
    expect(classes(screen.getByRole('main'))).toContain('max-sm:pt-6');
    expect(classes(screen.getByTestId('bandeau-test').closest('.mt-8'))).toContain('max-sm:mt-5');
    expect(classes(screen.getByTestId('filtres-barre').closest('.mt-8'))).toContain('max-sm:mt-5');
  });

  it('reste identique sans fil d’Ariane', () => {
    render(<VueCatalogue titre="Femme" produits={UN} />);
    expect(screen.getByTestId('liste-titre').textContent).toBe('Femme');
  });
});
__VICTO_FIN_12__
TESTS=(mobile-bonnes-affaires-defilement.test.tsx mobile-carte-hauteur.test.tsx mobile-page-sous-categorie.test.tsx mobile-pied-colonnes.test.tsx mobile-sous-categories.test.tsx mobile-vue-catalogue.test.tsx)
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
ok "6 specs, 6 tests en attente et le manifeste écrits"

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/111*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-111.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
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
  git commit -q -m "chore(tickets): lot 111 — mobile, troisième passe"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-111.tsv ./run.sh\n\nSix tickets courts. Compte environ une heure ; le 111b attend le 111a.\n'
