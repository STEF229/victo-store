#!/usr/bin/env bash
# VICTO STORE — rattrapage 095b et 095c.
#   • spec 095b : className complet des interrupteurs Promotions et En stock
#     (le modèle avait recopié la forme sans l'état : échec identique deux fois)
#   • spec 095c : className complet des quatre pilules de la barre
#   • tests 095b et 095c : chaque échec de classe nomme son élément
# Usage :  cd ~/victo-store && bash rattrapage-095.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }
annuler(){ git reset -q --hard HEAD; git clean -fdq -- tests tickets; mort "$*  — rien n'a été modifié"; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
ok "main à jour ($(git rev-parse --short HEAD))"

git log main -1 --format=%h --fixed-strings --grep="feat(095a): fusionné" | grep -q . || mort "095a n'est pas fusionné dans main"
[ -f src/components/catalogue/filtres-affichage.ts ] || mort "filtres-affichage.ts absent de main"
[ -f tickets/manifest-liste-v3.tsv ] || mort "tickets/manifest-liste-v3.tsv absent (lot v3 non installé ?)"
ok "095a fusionné, lot v3 présent"
cat > tickets/095b-tiroirs-filtres.md <<'__VICTO_FIN_0__'
TICKET 095b — tiroirs mobiles des filtres et du tri

Crée `src/components/catalogue/TiroirsFiltres.tsx`, export nommé `TiroirsFiltres`.
C'est un composant **sans état** : il affiche le tiroir demandé et remonte chaque
action par une prop. La barre de filtres l'utilisera au ticket suivant.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Aucun fichier baril n'existe.** Les déclarations des modules de `components/`
  te sont fournies en lecture seule ; les types de `lib/` sont donnés plus bas.
- **Toutes les classes de couleur et de forme viennent des constantes importées.**
  N'écris aucun `var(--vs-…)` dans ce fichier. Seules classes écrites à la main
  autorisées : celles des trois conteneurs donnés plus bas.
- Icône : `X` de `lucide-react`, avec `aria-hidden`. **Aucun `<h1>`, `<h2>`, `<h3>`.**

## Bloc d'imports exact
```tsx
import { X } from 'lucide-react';
import {
  FERMER, OPTION_MARQUE, OPTION_TAILLE, OPTION_TRI, OPTIONS_TRI, PILULE, PILULE_OFF, PILULE_ON,
  TIROIR, TIROIR_ENTETE, TIROIR_FOND, TIROIR_SECTION, TIROIR_TITRE, VALIDER,
} from '@/components/catalogue/filtres-affichage';
import type { Marque } from '@/lib/catalogue';
import type { Criteres, Tri } from '@/lib/filtres';
```

## Types importés
Leurs déclarations ne te sont pas fournies ; voici ce dont tu as besoin :
```ts
// '@/lib/catalogue' — d'autres champs peuvent exister
interface Marque { id: string; nom: string; slug: string }
// '@/lib/filtres' — d'autres champs optionnels peuvent exister
interface Criteres { marques?: string[]; tailles?: string[]; promotionSeulement?: boolean; enStockSeulement?: boolean }
type Tri = 'nouveautes' | 'prix-croissant' | 'prix-decroissant' | 'remise';
```

## Props
```ts
export type VueTiroir = 'filtres' | 'tri' | null;

interface TiroirsFiltresProps {
  vue: VueTiroir;
  marques: Marque[];
  tailles: string[];
  criteres: Criteres;
  tri: Tri;
  onMarque: (slug: string) => void;
  onTaille: (taille: string) => void;
  onPromo: () => void;
  onStock: () => void;
  onTri: (tri: Tri) => void;
  onFermer: () => void;
}
```
`VueTiroir` est exporté.

## Rendu
Taille attendue : ~130 lignes.

Si `vue` vaut `null`, le composant renvoie `null`. Sinon il renvoie un fragment :
1. `<div data-testid="tiroir-fond" aria-hidden="true" className={TIROIR_FOND} onClick={onFermer} />`
2. puis le tiroir correspondant à `vue`.

**Règle d'état** — un bouton qui a un état reçoit sa constante de forme suivie de
`PILULE_ON` s'il est actif, `PILULE_OFF` sinon, et `aria-pressed` égal à ce même
booléen : `` className={`${FORME} ${actif ? PILULE_ON : PILULE_OFF}`} ``.

**Rangée de titre**, en tête de chaque tiroir :
`<div className={TIROIR_ENTETE}>` contenant `<p className={TIROIR_TITRE}>` (texte
`Filtrer` ou `Trier par`) puis
`<button type="button" aria-label="Fermer" className={FERMER} onClick={onFermer}>`
contenant `<X aria-hidden size={18} />`.

### `vue === 'filtres'`
`<div data-testid="tiroir-filtres" role="dialog" aria-label="Filtrer" className={TIROIR}>`
contenant, dans l'ordre :
- la rangée de titre `Filtrer` ;
- `<p className={TIROIR_SECTION}>Marques</p>` puis `<div className="mb-6 flex flex-wrap gap-2">` :
  un bouton par marque, `` data-testid={`filtre-marque-${marque.slug}`} ``, texte
  `marque.nom`, forme `OPTION_MARQUE`, actif si `criteres.marques` contient
  `marque.slug`, clic → `onMarque(marque.slug)` ;
- `<p className={TIROIR_SECTION}>Tailles</p>` puis `<div className="mb-6 grid grid-cols-5 gap-2">` :
  un bouton par taille, `` data-testid={`filtre-taille-${taille}`} ``, texte `taille`,
  forme `OPTION_TAILLE`, actif si `criteres.tailles` contient `taille`, clic →
  `onTaille(taille)` ;
- `<div className="mb-6 flex gap-2">` contenant deux boutons, avec exactement ces
  attributs :
  ```tsx
  data-testid="filtre-promo"
  aria-pressed={criteres.promotionSeulement === true}
  className={`${PILULE} flex-1 justify-center ${criteres.promotionSeulement === true ? PILULE_ON : PILULE_OFF}`}
  onClick={onPromo}
  ```
  texte `Promotions` ; puis
  ```tsx
  data-testid="filtre-stock"
  aria-pressed={criteres.enStockSeulement === true}
  className={`${PILULE} flex-1 justify-center ${criteres.enStockSeulement === true ? PILULE_ON : PILULE_OFF}`}
  onClick={onStock}
  ```
  texte `En stock`. Les trois dernières classes changent avec l'état : c'est ce qui
  noircit l'interrupteur actif ;
- `<button type="button" className={VALIDER} onClick={onFermer}>Appliquer les filtres</button>`.

### `vue === 'tri'`
`<div data-testid="tiroir-tri" role="dialog" aria-label="Trier" className={TIROIR}>`
contenant la rangée de titre `Trier par`, puis `<div className="flex flex-col gap-2.5">` :
un bouton par élément de `OPTIONS_TRI`, texte `option.libelle`, forme `OPTION_TRI`,
actif si `tri === option.valeur`. Au clic : `onTri(option.valeur)` puis `onFermer()`.

Tous les boutons ont `type="button"`. Les listes utilisent `.map` avec une `key`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_0__
cat > tickets/095c-filtres-barre-v3.md <<'__VICTO_FIN_1__'
TICKET 095c — barre de filtres, réécriture complète

Écris `src/components/catalogue/FiltresBarre.tsx` en entier, export nommé
`FiltresBarre`, à partir de zéro. Il assemble `TiroirsFiltres` et les classes de
`filtres-affichage`, et porte la logique.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Aucun fichier baril n'existe.** Les déclarations des modules de `components/`
  te sont fournies en lecture seule ; les types de `lib/` sont donnés plus bas.
- **Toutes les classes de couleur et de forme viennent des constantes importées.**
  N'écris aucun `var(--vs-…)` dans ce fichier. Seules classes écrites à la main
  autorisées : celles des conteneurs donnés plus bas, sans couleur.
- Icônes `lucide-react` avec `aria-hidden`. **Aucun `<h1>`.**
- Ne mute jamais `criteres` : chaque changement appelle `onChange` avec un **nouvel**
  objet complet `{ ...criteres, … }`.

## Bloc d'imports exact
```tsx
'use client';

import { ChevronDown, SlidersHorizontal, X } from 'lucide-react';
import { useState } from 'react';
import {
  MOBILE_FILTRER, MOBILE_TRIER, OPTION_MARQUE, OPTION_TAILLE, OPTIONS_TRI, PANNEAU, PANNEAU_MARQUES,
  PANNEAU_TAILLES, PASTILLE, PASTILLE_CROIX, PASTILLES, PILULE, PILULE_OFF, PILULE_ON, TOUT_EFFACER, TRI_LIBELLE, TRI_SELECT,
} from '@/components/catalogue/filtres-affichage';
import { TiroirsFiltres } from '@/components/catalogue/TiroirsFiltres';
import type { Marque } from '@/lib/catalogue';
import type { Criteres, Tri } from '@/lib/filtres';
```

## Types importés
Leurs déclarations ne te sont pas fournies ; voici ce dont tu as besoin :
```ts
// '@/lib/catalogue' — d'autres champs peuvent exister
interface Marque { id: string; nom: string; slug: string }
// '@/lib/filtres' — d'autres champs optionnels peuvent exister
interface Criteres { marques?: string[]; tailles?: string[]; promotionSeulement?: boolean; enStockSeulement?: boolean }
type Tri = 'nouveautes' | 'prix-croissant' | 'prix-decroissant' | 'remise';
```

## Props et état
```ts
interface FiltresBarreProps {
  marques: Marque[];
  tailles: string[];
  criteres: Criteres;
  onChange: (criteres: Criteres) => void;
  tri: Tri;
  onTriChange: (tri: Tri) => void;
}
```
Seul état interne : `const [ouvert, setOuvert] = useState<null | 'marques' | 'tailles' | 'filtres' | 'tri'>(null);`
Cliquer le bouton d'une vue l'ouvre ; recliquer le bouton de la vue ouverte la
ferme ; ouvrir une vue ferme l'autre.

## Logique
- **Basculer une marque ou une taille** : si la valeur est déjà dans la liste
  (`criteres.marques ?? []`, idem `tailles`), la retirer avec `.filter` en gardant
  l'ordre des autres ; sinon l'ajouter à la fin. Appeler `onChange` avec la
  nouvelle liste, même vide.
- **Basculer Promotions** : `onChange({ ...criteres, promotionSeulement: !criteres.promotionSeulement })`.
  **En stock** de même avec `enStockSeulement`.
- **Retirer depuis une pastille** : une marque ou une taille se bascule comme
  ci-dessus ; Promotions et En stock passent à `false`.
- **Tout effacer** : `onChange({})`.
- **Nombre de filtres actifs** : marques choisies + tailles choisies + 1 si
  `promotionSeulement` + 1 si `enStockSeulement`.

## Rendu
Taille attendue : ~200 lignes.

**Règle d'état** — un bouton qui a un état reçoit sa constante de forme suivie de
`PILULE_ON` s'il est actif, `PILULE_OFF` sinon :
`` className={`${FORME} ${actif ? PILULE_ON : PILULE_OFF}`} ``. Tous les boutons
ont `type="button"`.

Racine `<div data-testid="filtres-barre">`, qui contient dans l'ordre :

**Les quatre pilules de la barre** ont exactement ces `className`, où
`marquesChoisies = criteres.marques ?? []` et `taillesChoisies = criteres.tailles ?? []` :
```tsx
// bouton-marques
className={`${PILULE} ${ouvert === 'marques' || marquesChoisies.length > 0 ? PILULE_ON : PILULE_OFF}`}
// bouton-tailles
className={`${PILULE} ${ouvert === 'tailles' || taillesChoisies.length > 0 ? PILULE_ON : PILULE_OFF}`}
// filtre-promo, avec aria-pressed={criteres.promotionSeulement === true}
className={`${PILULE} ${criteres.promotionSeulement === true ? PILULE_ON : PILULE_OFF}`}
// filtre-stock, avec aria-pressed={criteres.enStockSeulement === true}
className={`${PILULE} ${criteres.enStockSeulement === true ? PILULE_ON : PILULE_OFF}`}
```

**1. Barre, grand écran** — `<div data-testid="barre-bureau" className="hidden flex-wrap items-center gap-3 lg:flex">` :
- `<div className="relative">` avec le bouton `data-testid="bouton-marques"`,
  `aria-expanded={ouvert === 'marques'}`, `className` ci-dessus. Contenu :
  `<span>` de texte `Marque` sans sélection, `Marque (N)` avec N marques choisies,
  puis `<ChevronDown aria-hidden size={16} />`. Quand `ouvert === 'marques'`, suivi de
  `` <div data-testid="panneau-marques" className={`${PANNEAU} ${PANNEAU_MARQUES}`}> `` :
  un bouton par marque, `` data-testid={`filtre-marque-${marque.slug}`} ``, texte
  `marque.nom`, forme `OPTION_MARQUE`, `aria-pressed` et actif si la marque est choisie.
- même chose pour les tailles : `bouton-tailles`, texte `Taille` ou `Taille (N)`,
  `panneau-tailles` avec `PANNEAU_TAILLES`, boutons
  `` data-testid={`filtre-taille-${taille}`} `` de forme `OPTION_TAILLE`, `aria-pressed`.
- `data-testid="filtre-promo"`, texte `Promotions`, `className` et `aria-pressed` ci-dessus.
- `data-testid="filtre-stock"`, texte `En stock`, idem.
- `<div className="ml-auto flex items-center gap-2">` contenant
  `<label htmlFor="tri" className={TRI_LIBELLE}>Trier par</label>` et
  `<select id="tri" data-testid="tri" className={TRI_SELECT} value={tri}>` avec une
  `<option value={o.valeur}>{o.libelle}</option>` par élément de `OPTIONS_TRI`. Au
  changement : `onTriChange(e.target.value as Tri)`.

**2. Pastilles**, seulement s'il y a au moins un filtre actif —
`<div data-testid="pastilles" className={PASTILLES}>` : une pastille par filtre
actif, dans l'ordre marques, tailles, Promotions, En stock. Chaque pastille est un
`<button className={PASTILLE}>` avec `aria-label` `Retirer le filtre <texte>`,
contenant `<span>` du texte puis `<X aria-hidden size={14} className={PASTILLE_CROIX} />`.
Textes : le nom de la marque (retrouvé dans `marques` par son slug ; une marque
introuvable n'a pas de pastille), `Taille <valeur>`, `Promotions`, `En stock`.
Puis `<button data-testid="filtres-reinitialiser" className={TOUT_EFFACER}>Tout effacer</button>`.

**3. Barre, téléphone** — `<div data-testid="barre-mobile" className="flex items-center gap-3 lg:hidden">` :
- `data-testid="ouvrir-filtres"`, `className={MOBILE_FILTRER}`, contenant
  `<SlidersHorizontal aria-hidden size={17} />` puis `<span>` de texte `Filtrer` ou
  `Filtrer (N)`, N = nombre de filtres actifs. Ouvre ou ferme la vue `'filtres'`.
- `data-testid="ouvrir-tri"`, `className={MOBILE_TRIER}`, texte `Trier` seul.
  Ouvre ou ferme la vue `'tri'`.

**4. Tiroirs** — `<TiroirsFiltres>` avec
`vue={ouvert === 'filtres' || ouvert === 'tri' ? ouvert : null}`, les props
`marques`, `tailles`, `criteres`, `tri`, et : `onMarque` et `onTaille` basculent la
valeur, `onPromo` et `onStock` basculent l'interrupteur, `onTri` appelle
`onTriChange`, `onFermer` remet `ouvert` à `null`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont
`tests/FiltresBarre.test.tsx`, qui vérifie le comportement.
__VICTO_FIN_1__
cat > tickets/tests/TiroirsFiltres.test.tsx <<'__VICTO_FIN_2__'
import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import {
  FERMER, OPTION_MARQUE, OPTION_TAILLE, OPTION_TRI, PILULE, PILULE_OFF, PILULE_ON,
  TIROIR, TIROIR_ENTETE, TIROIR_FOND, TIROIR_SECTION, TIROIR_TITRE, VALIDER,
} from '../src/components/catalogue/filtres-affichage';
import { TiroirsFiltres, type VueTiroir } from '../src/components/catalogue/TiroirsFiltres';
import type { Marque } from '../src/lib/catalogue';
import type { Criteres } from '../src/lib/filtres';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const nom = (el: Element) =>
  el.getAttribute('data-testid') ?? el.getAttribute('aria-label') ?? el.textContent ?? el.tagName;
function porte(el: Element, ...attendues: string[]) {
  const reelles = classes(el);
  for (const chaine of attendues) {
    for (const k of chaine.split(' ')) expect(reelles, `${nom(el)} : classe ${k} manquante`).toContain(k);
  }
}
const MARQUES: Marque[] = [
  { id: 'm1', nom: 'Nike', slug: 'nike' },
  { id: 'm2', nom: 'Lacoste', slug: 'lacoste' },
];

function poser(vue: VueTiroir, criteres: Criteres = {}) {
  const f = {
    onMarque: vi.fn(), onTaille: vi.fn(), onPromo: vi.fn(), onStock: vi.fn(), onTri: vi.fn(), onFermer: vi.fn(),
  };
  const rendu = render(
    <TiroirsFiltres vue={vue} marques={MARQUES} tailles={['40', '41']} criteres={criteres} tri="nouveautes" {...f} />,
  );
  return { ...f, container: rendu.container };
}

describe('TiroirsFiltres — fermé', () => {
  it('ne rend rien quand vue vaut null', () => {
    const { container } = poser(null);
    expect(container.innerHTML).toBe('');
  });
});

describe('TiroirsFiltres — filtres', () => {
  it('rend le fond puis le tiroir, avec leurs classes', () => {
    poser('filtres');
    const fond = screen.getByTestId('tiroir-fond');
    const tiroir = screen.getByTestId('tiroir-filtres');
    porte(fond, TIROIR_FOND);
    expect(fond).toHaveAttribute('aria-hidden', 'true');
    porte(tiroir, TIROIR);
    expect(tiroir).toHaveAttribute('role', 'dialog');
    expect(tiroir).toHaveAttribute('aria-label', 'Filtrer');
    expect(fond.compareDocumentPosition(tiroir) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(screen.queryByTestId('tiroir-tri')).toBeNull();
  });

  it('titre le tiroir et ses sections', () => {
    poser('filtres');
    const tiroir = screen.getByTestId('tiroir-filtres');
    porte(within(tiroir).getByText('Filtrer', { selector: 'p' }), TIROIR_TITRE);
    porte(within(tiroir).getByText('Marques'), TIROIR_SECTION);
    porte(within(tiroir).getByText('Tailles'), TIROIR_SECTION);
    const fermer = within(tiroir).getByRole('button', { name: 'Fermer' });
    porte(fermer, FERMER);
    expect(fermer.querySelector('svg.lucide-x')).not.toBeNull();
    expect(tiroir.querySelector(`.${TIROIR_ENTETE.split(' ').join('.')}`)).not.toBeNull();
    expect(tiroir.querySelector('h1, h2, h3')).toBeNull();
  });

  it('marque les choix actifs et les autres', () => {
    poser('filtres', { marques: ['nike'], tailles: ['41'], promotionSeulement: true });
    const nike = screen.getByTestId('filtre-marque-nike');
    porte(nike, OPTION_MARQUE, PILULE_ON);
    expect(nike).toHaveAttribute('aria-pressed', 'true');
    porte(screen.getByTestId('filtre-marque-lacoste'), OPTION_MARQUE, PILULE_OFF);
    expect(screen.getByTestId('filtre-marque-lacoste')).toHaveAttribute('aria-pressed', 'false');
    porte(screen.getByTestId('filtre-taille-41'), OPTION_TAILLE, PILULE_ON);
    porte(screen.getByTestId('filtre-taille-40'), OPTION_TAILLE, PILULE_OFF);
    porte(screen.getByTestId('filtre-promo'), PILULE, 'flex-1 justify-center', PILULE_ON);
    porte(screen.getByTestId('filtre-stock'), PILULE, 'flex-1 justify-center', PILULE_OFF);
    expect(screen.getByTestId('filtre-stock')).toHaveAttribute('aria-pressed', 'false');
  });

  it('remonte chaque action', () => {
    const f = poser('filtres');
    fireEvent.click(screen.getByTestId('filtre-marque-lacoste'));
    expect(f.onMarque).toHaveBeenCalledWith('lacoste');
    fireEvent.click(screen.getByTestId('filtre-taille-40'));
    expect(f.onTaille).toHaveBeenCalledWith('40');
    fireEvent.click(screen.getByTestId('filtre-promo'));
    expect(f.onPromo).toHaveBeenCalledTimes(1);
    fireEvent.click(screen.getByTestId('filtre-stock'));
    expect(f.onStock).toHaveBeenCalledTimes(1);
    expect(f.onFermer).not.toHaveBeenCalled();
  });

  it('ferme par la croix, le bouton de validation et le fond', () => {
    const f = poser('filtres');
    const valider = screen.getByRole('button', { name: 'Appliquer les filtres' });
    porte(valider, VALIDER);
    fireEvent.click(screen.getByRole('button', { name: 'Fermer' }));
    fireEvent.click(valider);
    fireEvent.click(screen.getByTestId('tiroir-fond'));
    expect(f.onFermer).toHaveBeenCalledTimes(3);
  });
});

describe('TiroirsFiltres — tri', () => {
  it('rend le tiroir de tri et marque le tri courant', () => {
    poser('tri');
    const tiroir = screen.getByTestId('tiroir-tri');
    porte(tiroir, TIROIR);
    expect(tiroir).toHaveAttribute('aria-label', 'Trier');
    porte(within(tiroir).getByText('Trier par', { selector: 'p' }), TIROIR_TITRE);
    expect(within(tiroir).getAllByRole('button').map((b: HTMLElement) => b.textContent)).toEqual([
      '', 'Nouveautés', 'Prix croissant', 'Prix décroissant', 'Meilleures remises',
    ]);
    const courant = within(tiroir).getByRole('button', { name: 'Nouveautés' });
    porte(courant, OPTION_TRI, PILULE_ON);
    expect(courant).toHaveAttribute('aria-pressed', 'true');
    porte(within(tiroir).getByRole('button', { name: 'Prix croissant' }), OPTION_TRI, PILULE_OFF);
    expect(screen.queryByTestId('tiroir-filtres')).toBeNull();
  });

  it('choisit un tri puis ferme', () => {
    const f = poser('tri');
    fireEvent.click(screen.getByRole('button', { name: 'Meilleures remises' }));
    expect(f.onTri).toHaveBeenCalledWith('remise');
    expect(f.onFermer).toHaveBeenCalledTimes(1);
  });
});

describe('TiroirsFiltres — source', () => {
  it("ne code aucune couleur à la main : tout vient des constantes", () => {
    const source = readFileSync('src/components/catalogue/TiroirsFiltres.tsx', 'utf8');
    expect(source).not.toContain('var(--vs-');
    expect(source).toContain("from '@/components/catalogue/filtres-affichage'");
  });
});
__VICTO_FIN_2__
cat > tickets/tests/FiltresBarre-v3.test.tsx <<'__VICTO_FIN_3__'
import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { FiltresBarre } from '../src/components/catalogue/FiltresBarre';
import {
  MOBILE_FILTRER, MOBILE_TRIER, OPTION_MARQUE, OPTION_TAILLE, PANNEAU, PANNEAU_MARQUES, PANNEAU_TAILLES,
  PASTILLE, PASTILLE_CROIX, PASTILLES, PILULE, PILULE_OFF, PILULE_ON, TOUT_EFFACER, TRI_LIBELLE, TRI_SELECT,
} from '../src/components/catalogue/filtres-affichage';
// Dépendance déclarée pour le harnais : sans les tiroirs, ce ticket est BLOQUÉ.
import { TiroirsFiltres as _dependance } from '../src/components/catalogue/TiroirsFiltres';
import type { Marque } from '../src/lib/catalogue';
import type { Criteres } from '../src/lib/filtres';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const nom = (el: Element) =>
  el.getAttribute('data-testid') ?? el.getAttribute('aria-label') ?? el.textContent ?? el.tagName;
function porte(el: Element, ...attendues: string[]) {
  const reelles = classes(el);
  for (const chaine of attendues) {
    for (const k of chaine.split(' ')) expect(reelles, `${nom(el)} : classe ${k} manquante`).toContain(k);
  }
}
const MARQUES: Marque[] = [
  { id: 'm1', nom: 'Nike', slug: 'nike' },
  { id: 'm2', nom: 'Lacoste', slug: 'lacoste' },
];

function poser(criteres: Criteres = {}) {
  const onChange = vi.fn();
  const onTriChange = vi.fn();
  render(
    <FiltresBarre marques={MARQUES} tailles={['40', '41']} criteres={criteres}
      onChange={onChange} tri="nouveautes" onTriChange={onTriChange} />,
  );
  return { onChange, onTriChange };
}

describe('FiltresBarre v3 — pilules', () => {
  it('rend les quatre pilules inactives sans filtre', () => {
    poser();
    for (const id of ['bouton-marques', 'bouton-tailles', 'filtre-promo', 'filtre-stock']) {
      porte(screen.getByTestId(id), PILULE, PILULE_OFF);
    }
  });

  it('noircit chaque pilule active', () => {
    poser({ marques: ['nike'], tailles: ['41'], promotionSeulement: true, enStockSeulement: true });
    for (const id of ['bouton-marques', 'bouton-tailles', 'filtre-promo', 'filtre-stock']) {
      porte(screen.getByTestId(id), PILULE, PILULE_ON);
    }
    expect(screen.getByTestId('filtre-promo')).toHaveAttribute('aria-pressed', 'true');
  });

  it('noircit Marque tant que son panneau est ouvert', () => {
    poser();
    fireEvent.click(screen.getByTestId('bouton-marques'));
    porte(screen.getByTestId('bouton-marques'), PILULE_ON);
    porte(screen.getByTestId('bouton-tailles'), PILULE_OFF);
  });
});

describe('FiltresBarre v3 — panneaux et tri', () => {
  it('habille le panneau des marques', () => {
    poser({ marques: ['nike'] });
    fireEvent.click(screen.getByTestId('bouton-marques'));
    porte(screen.getByTestId('panneau-marques'), PANNEAU, PANNEAU_MARQUES);
    porte(screen.getByTestId('filtre-marque-nike'), OPTION_MARQUE, PILULE_ON);
    porte(screen.getByTestId('filtre-marque-lacoste'), OPTION_MARQUE, PILULE_OFF);
  });

  it('habille le panneau des tailles et le tri', () => {
    poser({ tailles: ['41'] });
    porte(screen.getByText('Trier par', { selector: 'label' }), TRI_LIBELLE);
    porte(screen.getByTestId('tri'), TRI_SELECT);
    fireEvent.click(screen.getByTestId('bouton-tailles'));
    porte(screen.getByTestId('panneau-tailles'), PANNEAU, PANNEAU_TAILLES);
    porte(screen.getByTestId('filtre-taille-41'), OPTION_TAILLE, PILULE_ON);
    expect(screen.getByTestId('filtre-taille-41')).toHaveAttribute('aria-pressed', 'true');
    expect(screen.getByTestId('filtre-taille-40')).toHaveAttribute('aria-pressed', 'false');
  });
});

describe('FiltresBarre v3 — pastilles', () => {
  it('rend des pastilles visibles avec une croix grise', () => {
    poser({ marques: ['nike'], tailles: ['41'], promotionSeulement: true, enStockSeulement: true });
    const zone = screen.getByTestId('pastilles');
    porte(zone, PASTILLES);
    const noms = within(zone).getAllByRole('button').map((b: HTMLElement) => b.getAttribute('aria-label') ?? b.textContent);
    expect(noms).toEqual([
      'Retirer le filtre Nike', 'Retirer le filtre Taille 41', 'Retirer le filtre Promotions',
      'Retirer le filtre En stock', 'Tout effacer',
    ]);
    for (const nom of ['Nike', 'Taille 41', 'Promotions', 'En stock']) {
      const p = within(zone).getByRole('button', { name: `Retirer le filtre ${nom}` });
      porte(p, PASTILLE);
      const croix = p.querySelector('svg.lucide-x');
      expect(croix).not.toBeNull();
      porte(croix as Element, PASTILLE_CROIX);
    }
    porte(screen.getByTestId('filtres-reinitialiser'), TOUT_EFFACER);
  });

  it('remet un interrupteur à false depuis sa pastille', () => {
    const { onChange } = poser({ promotionSeulement: true, marques: ['nike'] });
    fireEvent.click(screen.getByRole('button', { name: 'Retirer le filtre Promotions' }));
    expect(onChange).toHaveBeenCalledWith({ promotionSeulement: false, marques: ['nike'] });
  });
});

describe('FiltresBarre v3 — téléphone', () => {
  it('délègue les tiroirs à TiroirsFiltres et relaie ses actions', () => {
    const { onChange, onTriChange } = poser({ marques: ['lacoste'] });
    porte(screen.getByTestId('ouvrir-filtres'), MOBILE_FILTRER);
    porte(screen.getByTestId('ouvrir-tri'), MOBILE_TRIER);
    fireEvent.click(screen.getByTestId('ouvrir-filtres'));
    const tiroir = screen.getByTestId('tiroir-filtres');
    fireEvent.click(within(tiroir).getByTestId('filtre-marque-nike'));
    expect(onChange).toHaveBeenCalledWith({ marques: ['lacoste', 'nike'] });
    fireEvent.click(within(tiroir).getByTestId('filtre-stock'));
    expect(onChange).toHaveBeenLastCalledWith({ marques: ['lacoste'], enStockSeulement: true });
    fireEvent.click(screen.getByTestId('tiroir-fond'));
    expect(screen.queryByTestId('tiroir-filtres')).toBeNull();
    fireEvent.click(screen.getByTestId('ouvrir-tri'));
    fireEvent.click(within(screen.getByTestId('tiroir-tri')).getByRole('button', { name: 'Prix croissant' }));
    expect(onTriChange).toHaveBeenCalledWith('prix-croissant');
    expect(screen.queryByTestId('tiroir-tri')).toBeNull();
  });
});

describe('FiltresBarre v3 — source', () => {
  const source = readFileSync('src/components/catalogue/FiltresBarre.tsx', 'utf8');

  it('ne code aucune couleur à la main', () => {
    expect(source).not.toContain('var(--vs-');
    for (const k of ['rounded-md', 'shadow-sm', 'shadow-lg', 'ring-1']) expect(source).not.toContain(k);
  });

  it('ne réimplémente pas les tiroirs', () => {
    expect(source).toContain('<TiroirsFiltres');
    expect(source).not.toContain('tiroir-filtres');
    expect(source).not.toContain('tiroir-tri');
  });
});
__VICTO_FIN_3__
for t in tests/TiroirsFiltres.test.tsx tests/FiltresBarre-v3.test.tsx; do
  git ls-files --error-unmatch "$t" >/dev/null 2>&1 || rm -f "$t"
done
grep -P '^(095b|095c)\t' tickets/manifest-liste-v3.tsv > tickets/manifest-rattrapage-095.tsv
[ "$(wc -l < tickets/manifest-rattrapage-095.tsv)" -eq 2 ] || annuler "manifeste de rattrapage incomplet"
ok "specs et tests corrigés, manifeste de rattrapage écrit"

CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/095b-tiroirs-filtres.md tickets/095c-filtres-barre-v3.md "$CTL/"
cp tickets/tests/TiroirsFiltres.test.tsx tickets/tests/FiltresBarre-v3.test.tsx "$CTL/tests/"
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
ok "contrôle : 0 alerte"

npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head -10; annuler "tsc rouge"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head -12; annuler "tests rouges"; }
ok "base verte"

git add -A -- tickets tests
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "fix(tickets): 095b et 095c — className complet des éléments à état, échecs nominatifs"
  ok "commit $(git rev-parse --short HEAD)"
}
git branch -q -D auto/095b auto/095c 2>/dev/null || true
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else printf '  \033[33m!\033[0m push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert\n'; fi

cat <<'TXT'

Prêt :

    MANIFEST=tickets/manifest-rattrapage-095.tsv ./run.sh

Deux tickets : 095b puis 095c. Compte 30 à 50 minutes.
TXT
