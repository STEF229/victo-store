#!/usr/bin/env bash
# VICTO STORE — lot 109 : finitions et mobile.
#   109a la page ne déborde plus sur le côté (html et body), avertissement des extensions muet
#   109b le filigrane du pied de page reste dans l'écran (la cause du débordement sur téléphone)
#   109c le compteur passe sous le titre des listes   109d chargement du panier moins haut
#   109e couleur au survol dans le méga-menu          109f recherche dans le menu mobile
#   109g/h le cœur des cartes produit garde le favori (état local sans fournisseur, comme avant)
#   + retrait du code mort FiltresPanneau et TriSelect, s'il n'est plus importé nulle part
# Toutes les corrections de style AJOUTENT des classes : les anciens tests restent valables.
# Usage :  cd ~/victo-store && bash lot-109.sh
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

# ------------------------------------------------------------ chaque valeur remplacée, mot pour mot
fusionne(){ git log main -1 --format=%h --fixed-strings --grep="feat($1): fusionné" | grep -q .; }
for d in 104e 108k 108l; do fusionne "$d" || mort "$d n'est pas fusionné : le lot 109 s'appuie dessus"; done
une(){ [ "$(grep -cF -- "$1" "$2" || true)" = 1 ] || mort "$2 : « $1 » introuvable ou en double"; }
une '<html lang="fr" suppressHydrationWarning>' src/app/layout.tsx
une '<body>' src/app/layout.tsx
une 'select-none text-[200px] font-black leading-none text-[#1E1E26]' src/components/ui/SiteFooter.tsx
une 'className="flex items-end justify-between gap-8"' src/components/catalogue/VueCatalogue.tsx
une 'className="min-h-[320px]"' src/components/panier/VuePanier.tsx
NP=src/components/navigation/NavigationPrincipale.tsx
for c in 'flex items-center gap-1.5 text-[15px] font-extrabold' 'flex h-[110px] items-center justify-center rounded-[18px] bg-[var(--vs-surface)] text-lg font-black tracking-wide' \
         'flex flex-col gap-2.5' 'mb-1.5 text-base font-black' 'py-1.5 text-[15px] font-medium' 'mt-1.5 text-sm font-bold text-[var(--vs-gris)] underline'; do
  une "className=\"$c\"" "$NP"; done
grep -q "hover:text-\[var(--vs-accent)\]" "$NP" && mort "$NP a déjà la couleur au survol : lot déjà passé ?"
une "import { ChevronLeft, ChevronRight, Menu, X } from 'lucide-react';" src/components/navigation/MenuMobile.tsx
grep -q 'recherche-mobile' src/components/navigation/MenuMobile.tsx && mort "le menu mobile a déjà sa recherche : lot déjà passé ?"
grep -q "interface ContexteFavoris" src/components/favoris/FavorisProvider.tsx || mort "FavorisProvider : interface ContexteFavoris introuvable"
grep -qE "present\s*:" src/components/favoris/FavorisProvider.tsx && mort "FavorisProvider a déjà « present » : lot déjà passé ?"
une 'const [favori, setFavori] = useState(false);' src/components/ui/ProductCard.tsx
une 'onClick={() => setFavori(!favori)}' src/components/ui/ProductCard.tsx
for j in surface gris noir accent; do grep -qE -- "--vs-$j\s*:" src/styles/tokens.css || mort "jeton --vs-$j absent"; done
manque="$(node -e "const l=require('lucide-react');console.log(['Search'].filter(n=>!l[n]).join(' '))" 2>/dev/null || echo lucide-react)"
[ -z "$manque" ] || mort "icônes lucide absentes de ta version : $manque"
ok "mise en page, méga-menu, menu mobile, favoris et carte produit conformes aux specs"
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
mkdir -p tickets/tests
cat > 'tickets/109a-layout-debordement.md' <<'__VICTO_FIN_0__'
TICKET 109a — la page ne déborde plus jamais sur le côté

Modifie `src/app/layout.tsx`. Deux balises reçoivent des attributs, rien d'autre ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Les fournisseurs (favoris, panier, session), les métadonnées et `<head>` ne bougent pas.

## Les deux remplacements
1. Remplace exactement `<html lang="fr" suppressHydrationWarning>` par
   `<html lang="fr" suppressHydrationWarning className="overflow-x-clip">`
2. Remplace exactement `<body>` par
   `<body className="overflow-x-clip" suppressHydrationWarning>`

(`suppressHydrationWarning` sur `<body>` fait taire l'avertissement causé par les
extensions de navigateur, comme Grammarly, qui ajoutent leurs attributs au `<body>`.)

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les tests `layout-*`.
__VICTO_FIN_0__
cat > 'tickets/109b-pied-filigrane.md' <<'__VICTO_FIN_1__'
TICKET 109b — le filigrane du pied de page reste dans l'écran

Modifie `src/components/ui/SiteFooter.tsx`. Le grand « VICTO » en filigrane fait 200 px de
haut : sur téléphone, il est plus large que l'écran et élargit toute la page. Il est rogné
à la largeur disponible ; rien d'autre ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.

## Le remplacement
Remplace exactement la valeur de classe
`select-none text-[200px] font-black leading-none text-[#1E1E26]`
par
`block max-w-full select-none overflow-hidden whitespace-nowrap text-[200px] font-black leading-none text-[#1E1E26]`
(les classes d'origine restent toutes ; quatre s'ajoutent).

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > 'tickets/109c-liste-titre-mobile.md' <<'__VICTO_FIN_2__'
TICKET 109c — sur téléphone, le compteur passe sous le titre de la liste

Modifie `src/components/catalogue/VueCatalogue.tsx`. Une seule valeur de classe change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.

## Le remplacement
Sur le `<div>` qui contient le titre (`data-testid="liste-titre"`) et le compteur
(`data-testid="compteur"`), remplace exactement
`className="flex items-end justify-between gap-8"`
par
`className="flex items-end justify-between gap-8 max-sm:flex-col max-sm:items-start max-sm:gap-3"`
(au-dessus de 640 px, rien ne change ; en dessous, le compteur passe sous le titre).

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les tests de `VueCatalogue`.
__VICTO_FIN_2__
cat > 'tickets/109d-panier-chargement.md' <<'__VICTO_FIN_3__'
TICKET 109d — sur téléphone, le chargement du panier ne laisse plus un grand vide

Modifie `src/components/panier/VuePanier.tsx`. Une seule valeur de classe change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.

## Le remplacement
Sur l'élément `data-testid="panier-chargement"`, remplace exactement
`className="min-h-[320px]"` par `className="min-h-[320px] max-sm:min-h-[96px]"`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les tests du panier.
__VICTO_FIN_3__
cat > 'tickets/109e-survol-mega-menu.md' <<'__VICTO_FIN_4__'
TICKET 109e — les liens du méga-menu changent de couleur au survol

Modifie `src/components/navigation/NavigationPrincipale.tsx`. Au survol, les liens des
panneaux passent en bleu (`--vs-accent`), avec une transition douce. Rien d'autre ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Les classes existantes restent toutes : tu **ajoutes** seulement
  ` transition-colors hover:text-[var(--vs-accent)]` à la fin de chacune des six valeurs
  de classe ci-dessous.

## Les six valeurs de classe, et leur nouvelle forme
| Lien | Avant | Après |
| --- | --- | --- |
| « Tout voir … » (en-tête du panneau) | `flex items-center gap-1.5 text-[15px] font-extrabold` | `flex items-center gap-1.5 text-[15px] font-extrabold transition-colors hover:text-[var(--vs-accent)]` |
| vignette d'une marque | `flex h-[110px] items-center justify-center rounded-[18px] bg-[var(--vs-surface)] text-lg font-black tracking-wide` | `flex h-[110px] items-center justify-center rounded-[18px] bg-[var(--vs-surface)] text-lg font-black tracking-wide transition-colors hover:text-[var(--vs-accent)]` |
| vignette de Chaussures | `flex flex-col gap-2.5` | `flex flex-col gap-2.5 transition-colors hover:text-[var(--vs-accent)]` |
| titre d'une sous-catégorie | `mb-1.5 text-base font-black` | `mb-1.5 text-base font-black transition-colors hover:text-[var(--vs-accent)]` |
| sous-sous-catégorie | `py-1.5 text-[15px] font-medium` | `py-1.5 text-[15px] font-medium transition-colors hover:text-[var(--vs-accent)]` |
| « Tout … » d'une colonne | `mt-1.5 text-sm font-bold text-[var(--vs-gris)] underline` | `mt-1.5 text-sm font-bold text-[var(--vs-gris)] underline transition-colors hover:text-[var(--vs-accent)]` |

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/NavigationPrincipale.test.tsx`.
__VICTO_FIN_4__
cat > 'tickets/109f-recherche-menu-mobile.md' <<'__VICTO_FIN_5__'
TICKET 109f — la recherche dans le menu mobile

Modifie `src/components/navigation/MenuMobile.tsx`. Sur téléphone, l'en-tête n'a pas de
champ de recherche : le menu en propose un, tout en haut du premier niveau.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Rien d'autre ne change. Aucun `<button>` de plus (la touche Entrée lance la recherche).

## Les deux changements
1. Ajoute `Search` à l'import depuis `'lucide-react'`.
2. Dans `niveau1`, **avant** le `navItems.map(…)`, ajoute exactement :
   ```tsx
   <form role="search" action="/recherche" method="get" className="my-3">
     <label htmlFor="recherche-mobile" className="sr-only">Rechercher dans la boutique</label>
     <div className="flex h-12 items-center gap-2.5 rounded-full bg-[var(--vs-surface)] px-4">
       <Search aria-hidden size={17} className="shrink-0 text-[var(--vs-gris)]" />
       <input id="recherche-mobile" name="q" type="search" placeholder="Rechercher" autoComplete="off"
         className="h-10 min-w-0 flex-1 border-none bg-transparent text-base text-[var(--vs-noir)] outline-none" />
     </div>
   </form>
   ```
   (`text-base` fait 16 px : en dessous, l'iPhone zoome sur le champ.)

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/MenuMobile.test.tsx`.
__VICTO_FIN_5__
cat > 'tickets/109g-favoris-presence.md' <<'__VICTO_FIN_6__'
TICKET 109g — le fournisseur de favoris signale sa présence

Modifie `src/components/favoris/FavorisProvider.tsx`. Le contexte gagne un champ
`present` : `false` hors du fournisseur (valeur par défaut), `true` dedans. Les cartes
produit s'en serviront (ticket 109h). Rien d'autre ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.

## Les trois changements
1. Dans `interface ContexteFavoris`, ajoute `present: boolean;`.
2. Dans la **valeur par défaut** du contexte, ajoute `present: false`.
3. Dans la valeur passée au fournisseur par `FavorisProvider`, ajoute `present: true`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/FavorisProvider.test.tsx`.
__VICTO_FIN_6__
cat > 'tickets/109h-carte-favoris.md' <<'__VICTO_FIN_7__'
TICKET 109h — le cœur des cartes produit garde le favori

Modifie `src/components/ui/ProductCard.tsx`. Avec le fournisseur de favoris (le cas du
site), le cœur lit et bascule les favoris gardés ; sans fournisseur, il garde son état
local comme aujourd'hui. Aucune classe, aucun texte ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- `useState` reste importé (il sert encore à l'état local).

## Les trois changements
1. Ajoute, à la suite des imports existants :
   `import { useFavoris } from '@/components/favoris/FavorisProvider';`
2. Remplace exactement `const [favori, setFavori] = useState(false);` par :
   ```tsx
   const favoris = useFavoris();
   const [favoriLocal, setFavoriLocal] = useState(false);
   const favori = favoris.present ? favoris.estFavori(produit.slug) : favoriLocal;
   const basculerFavori = () => (favoris.present ? favoris.basculer(produit.slug) : setFavoriLocal(!favoriLocal));
   ```
3. Sur le bouton « Ajouter aux favoris », remplace exactement
   `onClick={() => setFavori(!favori)}` par `onClick={basculerFavori}`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/accueil2-ProductCard.test.tsx`
et `tests/finitions-ProductCard.test.tsx` (comportement sans fournisseur).
__VICTO_FIN_7__
cat > 'tickets/manifest-109.tsv' <<'__VICTO_FIN_8__'
109a	src/app/layout.tsx	tests/layout-debordement.test.ts	tickets/109a-layout-debordement.md			
109b	src/components/ui/SiteFooter.tsx	tests/pied-filigrane.test.tsx	tickets/109b-pied-filigrane.md			
109c	src/components/catalogue/VueCatalogue.tsx	tests/liste-titre-mobile.test.tsx	tickets/109c-liste-titre-mobile.md			
109d	src/components/panier/VuePanier.tsx	tests/panier-chargement-mobile.test.ts	tickets/109d-panier-chargement.md			
109e	src/components/navigation/NavigationPrincipale.tsx	tests/survol-mega-menu.test.tsx	tickets/109e-survol-mega-menu.md			
109f	src/components/navigation/MenuMobile.tsx	tests/recherche-menu-mobile.test.tsx	tickets/109f-recherche-menu-mobile.md			
109g	src/components/favoris/FavorisProvider.tsx	tests/favoris-presence.test.tsx	tickets/109g-favoris-presence.md			
109h	src/components/ui/ProductCard.tsx	tests/carte-favoris.test.tsx	tickets/109h-carte-favoris.md	src/components/favoris/FavorisProvider.tsx	109g	
__VICTO_FIN_8__
cat > 'tickets/tests/carte-favoris.test.tsx' <<'__VICTO_FIN_9__'
import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { CLE_FAVORIS, FavorisProvider } from '../src/components/favoris/FavorisProvider';
import { ProductCard } from '../src/components/ui/ProductCard';
import type { Produit } from '../src/lib/catalogue';

const P: Produit = {
  id: 'p1', slug: 'air-zoom-pegasus-41', nom: 'Air Zoom Pegasus 41', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12900, variantes: [{ id: 'v1', taille: '42', sku: 'NK-42', stock: 5 }],
};
const coeur = () => screen.getByRole('button', { name: 'Ajouter aux favoris' });

beforeEach(() => window.localStorage.clear());

describe('ProductCard — favori gardé', () => {
  it('bascule le favori gardé, partagé avec le reste du site', () => {
    render(<FavorisProvider><ProductCard produit={P} /></FavorisProvider>);
    expect(coeur()).toHaveAttribute('aria-pressed', 'false');
    fireEvent.click(coeur());
    expect(coeur()).toHaveAttribute('aria-pressed', 'true');
    expect(window.localStorage.getItem(CLE_FAVORIS)).toBe(JSON.stringify([P.slug]));
  });

  it('montre un favori déjà gardé', () => {
    window.localStorage.setItem(CLE_FAVORIS, JSON.stringify([P.slug]));
    render(<FavorisProvider><ProductCard produit={P} /></FavorisProvider>);
    expect(coeur()).toHaveAttribute('aria-pressed', 'true');
  });

  it('garde son état local sans fournisseur', () => {
    render(<ProductCard produit={P} />);
    fireEvent.click(coeur());
    expect(coeur()).toHaveAttribute('aria-pressed', 'true');
    expect(window.localStorage.getItem(CLE_FAVORIS)).toBeNull();
  });
});
__VICTO_FIN_9__
cat > 'tickets/tests/favoris-presence.test.tsx' <<'__VICTO_FIN_10__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { FavorisProvider, useFavoris } from '../src/components/favoris/FavorisProvider';

function Temoin() {
  const f = useFavoris();
  return <span data-testid="present">{String(f.present)}</span>;
}

describe('favoris — présence du fournisseur', () => {
  it('n’est pas présent hors du fournisseur', () => {
    render(<Temoin />);
    expect(screen.getByTestId('present').textContent).toBe('false');
  });

  it('est présent dans le fournisseur', () => {
    render(<FavorisProvider><Temoin /></FavorisProvider>);
    expect(screen.getByTestId('present').textContent).toBe('true');
  });
});
__VICTO_FIN_10__
cat > 'tickets/tests/layout-debordement.test.ts' <<'__VICTO_FIN_11__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('layout — jamais de défilement horizontal', () => {
  const source = readFileSync('src/app/layout.tsx', 'utf8');
  const balise = (nom: string) => source.match(new RegExp(`<${nom}\\b[^>]*>`))?.[0] ?? '';

  it('rogne tout débordement horizontal, sur html et body', () => {
    expect(balise('html')).toContain('className="overflow-x-clip"');
    expect(balise('html')).toContain('lang="fr"');
    expect(balise('body')).toContain('className="overflow-x-clip"');
  });

  it('ignore les attributs ajoutés au body par les extensions', () => {
    expect(balise('body')).toContain('suppressHydrationWarning');
  });
});
__VICTO_FIN_11__
cat > 'tickets/tests/liste-titre-mobile.test.tsx' <<'__VICTO_FIN_12__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { VueCatalogue } from '../src/components/catalogue/VueCatalogue';
import type { Produit } from '../src/lib/catalogue';

const UN: Produit[] = [{
  id: 'p1', slug: 'p1', nom: 'Produit', marque: { id: 'm1', nom: 'Nike', slug: 'nike' }, imageUrl: '/x.svg', prixCents: 1000,
  variantes: [{ id: 'v1', taille: '42', sku: 'S-42', stock: 2 }],
}];
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('VueCatalogue — titre et compteur sur téléphone', () => {
  it('empile le compteur sous le titre sous 640 px, sans changer l’ordinateur', () => {
    render(<VueCatalogue titre="Sneakers Femme" produits={UN} />);
    const ligne = screen.getByTestId('liste-titre').closest('.justify-between');
    expect(ligne).not.toBeNull();
    expect(ligne?.contains(screen.getByTestId('compteur'))).toBe(true);
    for (const k of ['flex', 'items-end', 'justify-between', 'gap-8', 'max-sm:flex-col', 'max-sm:items-start', 'max-sm:gap-3']) {
      expect(classes(ligne as Element), k).toContain(k);
    }
  });
});
__VICTO_FIN_12__
cat > 'tickets/tests/panier-chargement-mobile.test.ts' <<'__VICTO_FIN_13__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('panier — chargement sur téléphone', () => {
  it('réduit la réserve de hauteur sous 640 px', () => {
    const source = readFileSync('src/components/panier/VuePanier.tsx', 'utf8');
    expect(source).toContain('data-testid="panier-chargement"');
    expect(source).toContain('className="min-h-[320px] max-sm:min-h-[96px]"');
  });
});
__VICTO_FIN_13__
cat > 'tickets/tests/pied-filigrane.test.tsx' <<'__VICTO_FIN_14__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteFooter } from '../src/components/ui/SiteFooter';
import { COLONNES_PIED } from '../src/lib/navigation';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('pied de page — filigrane', () => {
  it('rogne le filigrane à la largeur de l’écran, sans changer son style', () => {
    render(<SiteFooter colonnes={COLONNES_PIED} />);
    const filigrane = screen.getByText('VICTO');
    for (const k of ['block', 'max-w-full', 'overflow-hidden', 'whitespace-nowrap', 'text-[200px]', 'text-[#1E1E26]']) {
      expect(classes(filigrane), k).toContain(k);
    }
  });
});
__VICTO_FIN_14__
cat > 'tickets/tests/recherche-menu-mobile.test.tsx' <<'__VICTO_FIN_15__'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { MenuMobile } from '../src/components/navigation/MenuMobile';
import { NAV } from '../src/lib/navigation';

describe('menu mobile — recherche', () => {
  it('propose un vrai formulaire de recherche en haut du menu', () => {
    render(<MenuMobile navItems={NAV} />);
    fireEvent.click(screen.getByRole('button', { name: 'Ouvrir le menu' }));
    const tiroir = within(screen.getByRole('dialog', { name: 'Menu' }));
    const formulaire = tiroir.getByRole('search');
    expect(formulaire).toHaveAttribute('action', '/recherche');
    expect(formulaire).toHaveAttribute('method', 'get');
    const champ = tiroir.getByLabelText('Rechercher dans la boutique');
    expect(champ).toHaveAttribute('name', 'q');
    expect(champ).toHaveAttribute('type', 'search');
    expect(champ.getAttribute('class') ?? '').toContain('text-base');
  });

  it('le place avant les rubriques, et pas au second niveau', () => {
    render(<MenuMobile navItems={NAV} />);
    fireEvent.click(screen.getByRole('button', { name: 'Ouvrir le menu' }));
    const tiroir = screen.getByRole('dialog', { name: 'Menu' });
    const formulaire = within(tiroir).getByRole('search');
    const femme = within(tiroir).getByRole('button', { name: 'Femme' });
    expect(formulaire.compareDocumentPosition(femme) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    fireEvent.click(femme);
    expect(within(screen.getByRole('dialog', { name: 'Menu' })).queryByRole('search')).toBeNull();
  });
});
__VICTO_FIN_15__
cat > 'tickets/tests/survol-mega-menu.test.tsx' <<'__VICTO_FIN_16__'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { NavigationPrincipale } from '../src/components/navigation/NavigationPrincipale';
import { listerMarques } from '../src/lib/donnees';
import { NAV } from '../src/lib/navigation';

const SURVOL = ['transition-colors', 'hover:text-[var(--vs-accent)]'];
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const rubrique = (nom: string) => within(screen.getByRole('navigation', { name: 'Navigation principale' })).getByRole('link', { name: nom });
const panneau = (nom: string) => screen.getByRole('region', { name: `Sous-catégories de ${nom}` });
const survole = (zone: HTMLElement, nom: string | RegExp) => {
  const lien = within(zone).getByRole('link', { name: nom });
  for (const k of SURVOL) expect(classes(lien), `${String(nom)} : ${k}`).toContain(k);
};

describe('méga-menu — couleur au survol', () => {
  it('colore les sous-catégories, leurs enfants et les « Tout… »', () => {
    render(<NavigationPrincipale navItems={NAV} />);
    fireEvent.mouseEnter(rubrique('Homme'));
    const zone = panneau('Homme');
    survole(zone, 'Chaussures');
    survole(zone, 'Course');
    survole(zone, 'Tout vêtements');
    survole(zone, /^Tout voir Homme/);
  });

  it('colore les vignettes de Chaussures et des marques', () => {
    render(<NavigationPrincipale navItems={NAV} />);
    fireEvent.mouseEnter(rubrique('Chaussures'));
    survole(panneau('Chaussures'), 'Sneakers');
    fireEvent.mouseEnter(rubrique('Marques'));
    const premiere = listerMarques().find(() => true);
    if (premiere) survole(panneau('Marques'), premiere.nom);
  });
});
__VICTO_FIN_16__
TESTS=(carte-favoris.test.tsx favoris-presence.test.tsx layout-debordement.test.ts liste-titre-mobile.test.tsx panier-chargement-mobile.test.ts pied-filigrane.test.tsx recherche-menu-mobile.test.tsx survol-mega-menu.test.tsx)
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
ok "8 specs, 8 tests en attente et le manifeste écrits"

# ------------------------------------------------------------ code mort : FiltresPanneau et TriSelect
MORTS="src/components/catalogue/FiltresPanneau.tsx src/components/catalogue/TriSelect.tsx"
encore="$(grep -rlE "from ['\"][^'\"]*(FiltresPanneau|TriSelect)['\"]" src tests | grep -vE "FiltresPanneau\.(tsx|test\.tsx)$|TriSelect\.(tsx|test\.tsx)$" || true)"
if [ -n "$encore" ]; then
  info "FiltresPanneau ou TriSelect encore importé par : $(echo $encore) — gardés"
else
  retires=""
  for f in $MORTS tests/FiltresPanneau.test.tsx tests/TriSelect.test.tsx tickets/tests/FiltresPanneau.test.tsx tickets/tests/TriSelect.test.tsx; do
    if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then git rm -q -- "$f"; retires="$retires $(basename "$f")"; fi
  done
  [ -n "$retires" ] && ok "code mort retiré :$retires" || ok "code mort déjà retiré"
fi

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/109*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-109.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
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
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges après le retrait du code mort"; }
ok "base verte"
git add -A -- tickets tests
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "chore(tickets): lot 109 — finitions et mobile ; code mort retiré"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-109.tsv ./run.sh\n\nHuit tickets courts. Compte environ une heure et demie.\n'
