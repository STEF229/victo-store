#!/usr/bin/env bash
# VICTO STORE — lot liste v2 : barre de filtres conforme, repère d'en-tête, nettoyage.
#   • tickets 095 (FiltresBarre selon la maquette) et 096 (data-testid entete-ligne)
#   • garde permanente tests/garde-jetons.test.ts : plus aucun var(--vs-…) inventé
#   • retrait de BarreAnnonce (code mort depuis le 091), de son test et de sa garde
#   • outillage : run.sh (arrêt sur échec répété, colonne dépend_de),
#     outils/controle-lot.py (navigation DOM, jetons)
# Usage :  cd ~/victo-store && bash lot-liste-v2.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }
annuler(){ git reset -q --hard HEAD; git clean -fdq -- tests tickets outils run.sh; mort "$*  — rien n'a été modifié"; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
ok "main à jour ($(git rev-parse --short HEAD))"

# ------------------------------------------------------------ préconditions
JETONS=src/styles/tokens.css
[ -f "$JETONS" ] || mort "$JETONS introuvable (npm run tokens)"
for j in noir blanc ligne gris accent; do
  grep -qE -- "--vs-$j\s*:" "$JETONS" || mort "le jeton --vs-$j n'est pas défini dans $JETONS"
done
[ -f src/components/catalogue/FiltresBarre.tsx ] || mort "FiltresBarre.tsx absent"
[ "$(grep -c 'grid-cols-\[auto_1fr_auto\]' src/components/ui/SiteHeader.tsx || true)" = 1 ] \
  || mort "SiteHeader.tsx : la rangée grid-cols-[auto_1fr_auto] n'est pas unique, la spec 096 serait ambiguë"
ok "jetons et fichiers cibles présents"

# ------------------------------------------------------------ fichiers du lot
mkdir -p tickets/tests tests outils
cat > tickets/095-filtres-barre-v2.md <<'__VICTO_FIN_0__'
TICKET 095 — barre de filtres conforme à la maquette

Modifie `src/components/catalogue/FiltresBarre.tsx`. Ce ticket ne change **que
l'apparence**. Le comportement actuel est correct et reste vérifié par
`tests/FiltresBarre.test.tsx`, qui doit rester vert : ne change ni les props, ni
l'état `ouvert`, ni les fonctions de critères, ni un seul `data-testid`, ni un
seul libellé, ni un seul `aria-label`.

## Pourquoi
Le fichier utilise `--vs-principal` et `--vs-fond`. **Ces jetons n'existent pas.**
Un jeton qui n'existe pas donne une couleur vide : le fond des pastilles est
transparent, leur texte blanc sur blanc, et elles ne se voient pas.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Export nommé `FiltresBarre`.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.**
- Icônes : **`lucide-react` uniquement**, chacune avec `aria-hidden`.
- **Jetons de couleur — liste fermée.** Les seuls `var(--vs-…)` autorisés dans ce
  fichier sont : `--vs-noir` `--vs-blanc` `--vs-ligne` `--vs-gris` `--vs-accent`.
  Aucun autre n'existe. Seule teinte fixe autorisée : `#F0F0EE`.
- **Supprime** toute classe `rounded-md`, `shadow-sm`, `shadow-lg`, `ring-*`,
  `hover:*` et `focus:*`. Aucune n'est remplacée.
- **Aucun `<h1>`.**

## Bloc d'imports exact (inchangé)
```tsx
'use client';

import { ChevronDown, SlidersHorizontal, X } from 'lucide-react';
import { useState } from 'react';
import type { Marque } from '@/lib/catalogue';
import type { Criteres, Tri } from '@/lib/filtres';
```

## Classes — à recopier telles quelles, juste après les imports
Ces constantes sont la seule source des classes visuelles du fichier. Elles sont
écrites en toutes lettres : ne les découpe pas, ne les reconstruis pas.
```ts
const PILULE = 'flex h-[46px] items-center gap-2 rounded-full border-[1.5px] px-[18px] text-[15px] font-semibold';
const PILULE_OFF = 'border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]';
const PILULE_ON = 'border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]';
const PANNEAU = 'absolute left-0 top-[54px] z-20 rounded-[20px] border border-[var(--vs-ligne)] bg-[var(--vs-blanc)] p-3.5 shadow-[0_18px_40px_rgba(16,16,20,0.12)]';
const PANNEAU_MARQUES = 'flex w-[300px] flex-wrap gap-2';
const PANNEAU_TAILLES = 'grid w-[320px] grid-cols-5 gap-2';
const OPTION_MARQUE = 'h-[38px] rounded-full border-[1.5px] px-3.5 text-sm font-semibold';
const OPTION_TAILLE = 'h-11 rounded-xl border-[1.5px] text-sm font-bold';
const TRI_LIBELLE = 'text-[15px] text-[var(--vs-gris)]';
const TRI_SELECT = 'h-[46px] rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-4 text-[15px] font-semibold text-[var(--vs-noir)]';
const PASTILLES = 'mt-4 flex flex-wrap items-center gap-2';
const PASTILLE = 'flex h-[34px] items-center gap-1.5 rounded-full bg-[#F0F0EE] pl-3.5 pr-2 text-sm font-semibold text-[var(--vs-noir)]';
const TOUT_EFFACER = 'h-[34px] px-3 text-sm font-semibold text-[var(--vs-gris)] underline';
const MOBILE_FILTRER = 'flex h-[46px] flex-1 items-center justify-center gap-2 rounded-full border-[1.5px] border-[var(--vs-noir)] bg-[var(--vs-blanc)] text-[15px] font-bold text-[var(--vs-noir)]';
const MOBILE_TRIER = 'h-[46px] flex-1 rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[15px] font-semibold text-[var(--vs-noir)]';
const TIROIR_FOND = 'fixed inset-0 z-40 bg-[rgba(16,16,20,0.45)] lg:hidden';
const TIROIR = 'fixed inset-x-0 bottom-0 z-50 max-h-[85vh] overflow-y-auto rounded-t-[28px] bg-[var(--vs-blanc)] px-5 pb-7 pt-6 lg:hidden';
const TIROIR_ENTETE = 'mb-5 flex items-center justify-between';
const TIROIR_TITRE = 'text-[22px] font-black text-[var(--vs-noir)]';
const TIROIR_SECTION = 'mb-2.5 text-[13px] font-bold uppercase tracking-[0.14em] text-[var(--vs-gris)]';
const FERMER = 'flex h-11 w-11 items-center justify-center rounded-full bg-[#F0F0EE] text-[var(--vs-noir)]';
const VALIDER = 'h-[54px] w-full rounded-full bg-[var(--vs-accent)] text-base font-extrabold text-[var(--vs-blanc)]';
const OPTION_TRI = 'h-[52px] w-full rounded-[14px] border-[1.5px] px-[18px] text-left text-base font-semibold';
```

## Où va chaque classe
Un élément qui a un état actif reçoit **une constante de forme** suivie de
`PILULE_ON` ou `PILULE_OFF`, exactement ainsi :
`` className={`${PILULE} ${actif ? PILULE_ON : PILULE_OFF}`} ``

**Éléments avec un état actif** — la condition est donnée en code exact :
- `bouton-marques` : `PILULE`, actif si `ouvert === 'marques' || marquesSelectionnees.length > 0`.
- `bouton-tailles` : `PILULE`, actif si `ouvert === 'tailles' || taillesSelectionnees.length > 0`.
- `filtre-promo` dans la barre : `PILULE`, actif si `criteres.promotionSeulement === true`.
- `filtre-stock` dans la barre : `PILULE`, actif si `criteres.enStockSeulement === true`.
- `filtre-promo` et `filtre-stock` dans le tiroir : même condition, forme
  `` `${PILULE} flex-1 justify-center` ``, soit
  `` className={`${PILULE} flex-1 justify-center ${actif ? PILULE_ON : PILULE_OFF}`} ``.
- chaque `filtre-marque-<slug>`, panneau et tiroir : `OPTION_MARQUE`, actif si
  `marquesSelectionnees.includes(marque.slug)`.
- chaque `filtre-taille-<t>`, panneau et tiroir : `OPTION_TAILLE`, actif si
  `taillesSelectionnees.includes(taille)`.
- chaque option du tiroir de tri : `OPTION_TRI`, actif si `tri === option.value`.

**Éléments sans état** — `className={CONSTANTE}` :
- `panneau-marques` : `` `${PANNEAU} ${PANNEAU_MARQUES}` `` ; `panneau-tailles` :
  `` `${PANNEAU} ${PANNEAU_TAILLES}` ``.
- `<label htmlFor="tri">` : `TRI_LIBELLE` ; `<select data-testid="tri">` : `TRI_SELECT`.
- `<div data-testid="pastilles">` : `PASTILLES` ; chaque bouton de pastille : `PASTILLE` ;
  `filtres-reinitialiser` : `TOUT_EFFACER`.
- `ouvrir-filtres` : `MOBILE_FILTRER` ; `ouvrir-tri` : `MOBILE_TRIER`.
- `tiroir-filtres` et `tiroir-tri` : `TIROIR`.
- dans chaque tiroir, la rangée qui contient le titre et le bouton Fermer :
  `TIROIR_ENTETE` ; le titre (`Filtrer` ou `Trier par`) : `TIROIR_TITRE` ; les
  intertitres `Marques`, `Tailles`, `Filtres` : `TIROIR_SECTION`.
- chaque bouton `aria-label="Fermer"` : `FERMER` ; le bouton `Appliquer les filtres` : `VALIDER`.

Dans le tiroir, les boutons de marque sont dans `<div className="mb-6 flex flex-wrap gap-2">`,
ceux de taille dans `<div className="mb-6 grid grid-cols-5 gap-2">`, et les deux
interrupteurs côte à côte dans `<div className="mb-6 flex gap-2">`. Les options du
tiroir de tri sont dans `<div className="flex flex-col gap-2.5">`.

## Trois ajouts, et seulement trois
1. Chaque `filtre-taille-<t>`, dans le panneau et dans le tiroir, reçoit
   `aria-pressed={taillesSelectionnees.includes(t)}`, comme les marques.
2. Chaque option du tiroir de tri reçoit `aria-pressed={tri === option.value}`.
3. Quand `ouvert` vaut `'tiroir'` ou `'tri'`, rendre **juste avant** le tiroir un
   fond cliquable qui ferme :
   `<div data-testid="tiroir-fond" aria-hidden="true" className={TIROIR_FOND} onClick={fermerPanneaux} />`.

Dans le tiroir de filtres, les interrupteurs Promotions et En stock ne contiennent
plus que leur texte : **supprime** les deux `<div>` qui dessinaient un curseur.
Les icônes : `<X aria-hidden size={14} className="text-[var(--vs-gris)]" />` dans
les pastilles, `<X aria-hidden size={18} />` dans les boutons Fermer ; les autres
icônes ne changent pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent. Les deux fichiers
`tests/FiltresBarre.test.tsx` et `tests/FiltresBarre-v2.test.tsx` sont verts.
__VICTO_FIN_0__
cat > tickets/096-entete-ligne.md <<'__VICTO_FIN_1__'
TICKET 096 — repère de test sur la rangée de l'en-tête

Modifie `src/components/ui/SiteHeader.tsx`. Un seul changement : la rangée en
grille de la barre noire reçoit un `data-testid`. Rien d'autre ne bouge.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports inchangés.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier que celui du ticket.
- **Garde le bloc d'imports actuel du fichier à l'identique**, ligne pour ligne.
- Ne change aucune classe, aucun texte, aucun autre attribut, aucune prop.

## Le changement
L'élément qui porte les classes `grid`, `h-20`, `grid-cols-[auto_1fr_auto]` et
`items-center` reçoit l'attribut `data-testid="entete-ligne"`. C'est le seul
élément de ce type dans le fichier. Il reste à l'intérieur de l'élément
`data-testid="entete"`, à la même place.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent ;
`tests/entete-v3.test.tsx` est vert.
__VICTO_FIN_1__
cat > tickets/manifest-liste-v2.tsv <<'__VICTO_FIN_2__'
095	src/components/catalogue/FiltresBarre.tsx	tests/FiltresBarre-v2.test.tsx	tickets/095-filtres-barre-v2.md	src/lib/catalogue.ts,src/lib/filtres.ts	
096	src/components/ui/SiteHeader.tsx	tests/entete-v3.test.tsx	tickets/096-entete-ligne.md		
__VICTO_FIN_2__
cat > tickets/tests/FiltresBarre-v2.test.tsx <<'__VICTO_FIN_3__'
import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { FiltresBarre } from '../src/components/catalogue/FiltresBarre';
import type { Marque } from '../src/lib/catalogue';
import type { Criteres } from '../src/lib/filtres';

// Contrat visuel du ticket 095 : mêmes chaînes que dans la spec.
const PILULE = 'flex h-[46px] items-center gap-2 rounded-full border-[1.5px] px-[18px] text-[15px] font-semibold';
const PILULE_OFF = 'border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]';
const PILULE_ON = 'border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]';
const PANNEAU = 'absolute left-0 top-[54px] z-20 rounded-[20px] border border-[var(--vs-ligne)] bg-[var(--vs-blanc)] p-3.5 shadow-[0_18px_40px_rgba(16,16,20,0.12)]';
const PANNEAU_MARQUES = 'flex w-[300px] flex-wrap gap-2';
const PANNEAU_TAILLES = 'grid w-[320px] grid-cols-5 gap-2';
const OPTION_MARQUE = 'h-[38px] rounded-full border-[1.5px] px-3.5 text-sm font-semibold';
const OPTION_TAILLE = 'h-11 rounded-xl border-[1.5px] text-sm font-bold';
const TRI_LIBELLE = 'text-[15px] text-[var(--vs-gris)]';
const TRI_SELECT = 'h-[46px] rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-4 text-[15px] font-semibold text-[var(--vs-noir)]';
const PASTILLES = 'mt-4 flex flex-wrap items-center gap-2';
const PASTILLE = 'flex h-[34px] items-center gap-1.5 rounded-full bg-[#F0F0EE] pl-3.5 pr-2 text-sm font-semibold text-[var(--vs-noir)]';
const TOUT_EFFACER = 'h-[34px] px-3 text-sm font-semibold text-[var(--vs-gris)] underline';
const MOBILE_FILTRER = 'flex h-[46px] flex-1 items-center justify-center gap-2 rounded-full border-[1.5px] border-[var(--vs-noir)] bg-[var(--vs-blanc)] text-[15px] font-bold text-[var(--vs-noir)]';
const MOBILE_TRIER = 'h-[46px] flex-1 rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[15px] font-semibold text-[var(--vs-noir)]';
const TIROIR_FOND = 'fixed inset-0 z-40 bg-[rgba(16,16,20,0.45)] lg:hidden';
const TIROIR = 'fixed inset-x-0 bottom-0 z-50 max-h-[85vh] overflow-y-auto rounded-t-[28px] bg-[var(--vs-blanc)] px-5 pb-7 pt-6 lg:hidden';
const FERMER = 'flex h-11 w-11 items-center justify-center rounded-full bg-[#F0F0EE] text-[var(--vs-noir)]';
const VALIDER = 'h-[54px] w-full rounded-full bg-[var(--vs-accent)] text-base font-extrabold text-[var(--vs-blanc)]';
const OPTION_TRI = 'h-[52px] w-full rounded-[14px] border-[1.5px] px-[18px] text-left text-base font-semibold';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
function porte(el: Element, ...attendues: string[]) {
  const reelles = classes(el);
  for (const chaine of attendues) {
    for (const k of chaine.split(' ')) expect(reelles, `classe ${k}`).toContain(k);
  }
}
function neportePas(el: Element, chaine: string) {
  const reelles = classes(el);
  for (const k of chaine.split(' ')) expect(reelles, `classe ${k}`).not.toContain(k);
}

const MARQUES: Marque[] = [
  { id: 'm1', nom: 'Nike', slug: 'nike' },
  { id: 'm2', nom: 'Lacoste', slug: 'lacoste' },
];
const TAILLES = ['40', '41', 'M'];

function poser(criteres: Criteres = {}) {
  render(
    <FiltresBarre
      marques={MARQUES}
      tailles={TAILLES}
      criteres={criteres}
      onChange={vi.fn()}
      tri="nouveautes"
      onTriChange={vi.fn()}
    />,
  );
}

describe('FiltresBarre v2 — pilules de la barre', () => {
  it('rend les quatre pilules inactives sans filtre', () => {
    poser();
    for (const id of ['bouton-marques', 'bouton-tailles', 'filtre-promo', 'filtre-stock']) {
      const el = screen.getByTestId(id);
      porte(el, PILULE, PILULE_OFF);
      neportePas(el, 'bg-[var(--vs-noir)]');
    }
  });

  it('noircit Promotions et En stock quand ils sont actifs', () => {
    poser({ promotionSeulement: true, enStockSeulement: true });
    for (const id of ['filtre-promo', 'filtre-stock']) {
      const el = screen.getByTestId(id);
      porte(el, PILULE, PILULE_ON);
      expect(el).toHaveAttribute('aria-pressed', 'true');
    }
  });

  it('noircit Marque et Taille dès qu\'une valeur est choisie', () => {
    poser({ marques: ['nike'], tailles: ['41'] });
    porte(screen.getByTestId('bouton-marques'), PILULE, PILULE_ON);
    porte(screen.getByTestId('bouton-tailles'), PILULE, PILULE_ON);
  });

  it('noircit Marque tant que son panneau est ouvert', () => {
    poser();
    fireEvent.click(screen.getByTestId('bouton-marques'));
    porte(screen.getByTestId('bouton-marques'), PILULE_ON);
    porte(screen.getByTestId('bouton-tailles'), PILULE_OFF);
  });
});

describe('FiltresBarre v2 — panneaux', () => {
  it('habille le panneau des marques et ses options', () => {
    poser({ marques: ['nike'] });
    fireEvent.click(screen.getByTestId('bouton-marques'));
    porte(screen.getByTestId('panneau-marques'), PANNEAU, PANNEAU_MARQUES);
    porte(screen.getByTestId('filtre-marque-nike'), OPTION_MARQUE, PILULE_ON);
    porte(screen.getByTestId('filtre-marque-lacoste'), OPTION_MARQUE, PILULE_OFF);
  });

  it('habille le panneau des tailles et marque la taille choisie', () => {
    poser({ tailles: ['41'] });
    fireEvent.click(screen.getByTestId('bouton-tailles'));
    porte(screen.getByTestId('panneau-tailles'), PANNEAU, PANNEAU_TAILLES);
    const choisie = screen.getByTestId('filtre-taille-41');
    porte(choisie, OPTION_TAILLE, PILULE_ON);
    expect(choisie).toHaveAttribute('aria-pressed', 'true');
    const libre = screen.getByTestId('filtre-taille-40');
    porte(libre, OPTION_TAILLE, PILULE_OFF);
    expect(libre).toHaveAttribute('aria-pressed', 'false');
  });
});

describe('FiltresBarre v2 — tri', () => {
  it('rend le libellé en gris et le sélecteur en pilule', () => {
    poser();
    porte(screen.getByText('Trier par', { selector: 'label' }), TRI_LIBELLE);
    porte(screen.getByTestId('tri'), TRI_SELECT);
  });
});

describe('FiltresBarre v2 — pastilles', () => {
  it('rend des pastilles visibles, avec une croix grise', () => {
    poser({ marques: ['nike'], tailles: ['41'], promotionSeulement: true, enStockSeulement: true });
    const zone = screen.getByTestId('pastilles');
    porte(zone, PASTILLES);
    for (const nom of ['Nike', 'Taille 41', 'Promotions', 'En stock']) {
      const p = within(zone).getByRole('button', { name: `Retirer le filtre ${nom}` });
      porte(p, PASTILLE);
      const croix = p.querySelector('svg.lucide-x');
      expect(croix).not.toBeNull();
      expect(croix?.getAttribute('aria-hidden')).toBe('true');
      expect(classes(croix as Element)).toContain('text-[var(--vs-gris)]');
    }
    porte(screen.getByTestId('filtres-reinitialiser'), TOUT_EFFACER);
  });
});

describe('FiltresBarre v2 — téléphone', () => {
  it('rend les deux boutons en pilules', () => {
    poser();
    porte(screen.getByTestId('ouvrir-filtres'), MOBILE_FILTRER);
    porte(screen.getByTestId('ouvrir-tri'), MOBILE_TRIER);
  });

  it('ouvre le tiroir de filtres par le bas, sur un fond qui ferme', () => {
    poser({ marques: ['nike'], promotionSeulement: true });
    expect(screen.queryByTestId('tiroir-fond')).toBeNull();
    fireEvent.click(screen.getByTestId('ouvrir-filtres'));
    const tiroir = screen.getByTestId('tiroir-filtres');
    porte(tiroir, TIROIR);
    porte(screen.getByTestId('tiroir-fond'), TIROIR_FOND);
    porte(within(tiroir).getByRole('button', { name: 'Fermer' }), FERMER);
    porte(within(tiroir).getByRole('button', { name: 'Appliquer les filtres' }), VALIDER);
    porte(within(tiroir).getByTestId('filtre-marque-nike'), OPTION_MARQUE, PILULE_ON);
    porte(within(tiroir).getByTestId('filtre-promo'), PILULE, 'flex-1 justify-center', PILULE_ON);
    porte(within(tiroir).getByTestId('filtre-stock'), PILULE, 'flex-1 justify-center', PILULE_OFF);
    fireEvent.click(screen.getByTestId('tiroir-fond'));
    expect(screen.queryByTestId('tiroir-filtres')).toBeNull();
    expect(screen.queryByTestId('tiroir-fond')).toBeNull();
  });

  it('marque le tri courant dans le tiroir de tri', () => {
    poser();
    fireEvent.click(screen.getByTestId('ouvrir-tri'));
    const tiroir = screen.getByTestId('tiroir-tri');
    porte(tiroir, TIROIR);
    const courant = within(tiroir).getByRole('button', { name: 'Nouveautés' });
    porte(courant, OPTION_TRI, PILULE_ON);
    expect(courant).toHaveAttribute('aria-pressed', 'true');
    porte(within(tiroir).getByRole('button', { name: 'Prix croissant' }), OPTION_TRI, PILULE_OFF);
  });
});

describe('FiltresBarre v2 — jetons', () => {
  const source = readFileSync('src/components/catalogue/FiltresBarre.tsx', 'utf8');
  const definis = new Set(
    Array.from(readFileSync('src/styles/tokens.css', 'utf8').matchAll(/(--vs-[a-z0-9-]+)\s*:/g), (m) => m[1] ?? ''),
  );

  it("n'utilise que des jetons définis dans tokens.css", () => {
    const inconnus = Array.from(source.matchAll(/var\((--vs-[a-z0-9-]+)\)/g), (m) => m[1] ?? '')
      .filter((j) => !definis.has(j));
    expect([...new Set(inconnus)]).toEqual([]);
  });

  it('ne garde ni ombre ni coin carré de la version précédente', () => {
    for (const k of ['rounded-md', 'shadow-sm', 'shadow-lg', 'ring-1']) expect(source).not.toContain(k);
  });
});
__VICTO_FIN_3__
cat > tickets/tests/entete-v3.test.tsx <<'__VICTO_FIN_4__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteHeader, type NavItem } from '../src/components/ui/SiteHeader';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const NAV: NavItem[] = [
  { label: 'Femme', href: '/femme' },
  { label: 'Homme', href: '/homme' },
  { label: 'Soldes', href: '/soldes', promo: true },
];

describe('en-tête — barre noire unique', () => {
  it('rend une bannière noire', () => {
    render(<SiteHeader navItems={NAV} />);
    const entete = screen.getByTestId('entete');
    expect(entete).toBe(screen.getByRole('banner'));
    for (const k of ['bg-[var(--vs-noir)]', 'text-[var(--vs-blanc)]']) expect(classes(entete)).toContain(k);
  });

  it('répartit logo, navigation et actions sur une seule ligne', () => {
    render(<SiteHeader navItems={NAV} />);
    const ligne = screen.getByTestId('entete-ligne');
    expect(screen.getByTestId('entete').contains(ligne)).toBe(true);
    for (const k of ['grid', 'h-20', 'grid-cols-[auto_1fr_auto]', 'items-center']) {
      expect(classes(ligne)).toContain(k);
    }
    expect(ligne.contains(screen.getByTestId('entete-marque'))).toBe(true);
    expect(ligne.contains(screen.getByRole('navigation', { name: 'Navigation principale' }))).toBe(true);
  });

  it('centre la navigation et la masque sur téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    const nav = screen.getByRole('navigation', { name: 'Navigation principale' });
    for (const k of ['hidden', 'justify-self-center', 'gap-8', 'lg:flex']) expect(classes(nav)).toContain(k);
  });

  it('colore en rouge clair la seule entrée promo', () => {
    render(<SiteHeader navItems={NAV} />);
    expect(classes(screen.getByRole('link', { name: 'Soldes' }))).toContain('text-[#FF5A74]');
    expect(classes(screen.getByRole('link', { name: 'Femme' }))).not.toContain('text-[#FF5A74]');
  });
});

describe('en-tête — recherche et actions', () => {
  it('propose un champ de recherche étiqueté', () => {
    render(<SiteHeader navItems={NAV} />);
    const champ = screen.getByLabelText('Rechercher un produit');
    expect(champ).toHaveAttribute('id', 'recherche-entete');
    expect(champ).toHaveAttribute('type', 'search');
    expect(champ).toHaveAttribute('placeholder', 'Rechercher');
  });

  it('réserve le bouton de menu au téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    const menu = screen.getByRole('button', { name: 'Ouvrir le menu' });
    expect(menu).toHaveAttribute('type', 'button');
    expect(classes(menu)).toContain('lg:hidden');
    expect(menu.querySelector('svg.lucide-menu')).not.toBeNull();
  });

  it('rend le compte et le panier avec leurs icônes lucide', () => {
    render(<SiteHeader navItems={NAV} cartCount={2} />);
    expect(screen.getByRole('button', { name: 'Mon compte' }).querySelector('svg.lucide-user')).not.toBeNull();
    const panier = screen.getByTestId('entete-panier');
    expect(panier.querySelector('svg.lucide-shopping-bag')).not.toBeNull();
    expect(classes(screen.getByTestId('entete-panier-compte'))).toContain('bg-[var(--vs-accent)]');
  });

  it("n'utilise que des icônes lucide", () => {
    const { container } = render(<SiteHeader navItems={NAV} cartCount={1} />);
    const svgs = Array.from(container.querySelectorAll('svg'));
    expect(svgs.length).toBeGreaterThanOrEqual(4);
    for (const s of svgs) {
      expect(s.classList.contains('lucide')).toBe(true);
      expect(s.getAttribute('aria-hidden')).toBe('true');
    }
  });
});

describe('en-tête — filet d’annonces', () => {
  it('reprend les trois messages sous la barre', () => {
    render(<SiteHeader navItems={NAV} />);
    const filet = screen.getByTestId('filet-annonce');
    expect(Array.from(filet.querySelectorAll('span')).map((s) => s.textContent)).toEqual([
      'Livraison offerte au Canada',
      'Retours gratuits 30 jours',
      'Authenticité garantie',
    ]);
  });

  it('se place après la barre', () => {
    render(<SiteHeader navItems={NAV} />);
    const entete = screen.getByTestId('entete');
    const filet = screen.getByTestId('filet-annonce');
    expect(entete.contains(filet)).toBe(false);
    expect(entete.compareDocumentPosition(filet) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  });

  it('porte les couleurs du filet et ne garde qu’un message sur téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    const filet = screen.getByTestId('filet-annonce');
    for (const k of ['bg-[var(--vs-surface)]', 'text-[var(--vs-gris)]', 'border-b', 'border-[var(--vs-ligne)]']) {
      expect(classes(filet)).toContain(k);
    }
    const messages = Array.from(filet.querySelectorAll('span'));
    expect(classes(messages[0] as Element)).not.toContain('hidden');
    for (const m of messages.slice(1)) {
      expect(classes(m)).toContain('hidden');
      expect(classes(m)).toContain('sm:inline');
    }
  });
});
__VICTO_FIN_4__
cat > tests/garde-jetons.test.ts <<'__VICTO_FIN_5__'
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';

// Garde permanente : tout var(--vs-…) employé dans src/ doit être défini dans le
// fichier généré par `npm run tokens`. Un jeton inventé donne une couleur vide,
// invisible pour jsdom : c'est ainsi que les pastilles du 093 sont devenues blanc
// sur blanc (--vs-principal, --vs-fond).
const JETONS = new Set(
  Array.from(readFileSync('src/styles/tokens.css', 'utf8').matchAll(/(--vs-[a-z0-9-]+)\s*:/g), (m) => m[1] ?? ''),
);

// Fichiers couverts par leur propre test en attendant leur ticket.
// FiltresBarre.tsx : tickets/tests/FiltresBarre-v2.test.tsx (ticket 095).
const EN_ATTENTE = new Set(['src/components/catalogue/FiltresBarre.tsx']);

function sources(dossier: string): string[] {
  return readdirSync(dossier).flatMap((nom) => {
    const chemin = join(dossier, nom);
    if (statSync(chemin).isDirectory()) return sources(chemin);
    return /\.(ts|tsx)$/.test(nom) ? [chemin.split('\\').join('/')] : [];
  });
}

describe('garde — jetons de couleur', () => {
  it('lit les jetons générés', () => {
    expect(JETONS.has('--vs-noir')).toBe(true);
  });

  it("n'emploie dans src/ que des jetons définis", () => {
    const inconnus = sources('src')
      .filter((f) => !EN_ATTENTE.has(f))
      .flatMap((f) =>
        Array.from(readFileSync(f, 'utf8').matchAll(/var\((--vs-[a-z0-9-]+)\)/g), (m) => m[1] ?? '')
          .filter((j) => !JETONS.has(j))
          .map((j) => `${f} : ${j}`),
      );
    expect([...new Set(inconnus)]).toEqual([]);
  });
});
__VICTO_FIN_5__
cat > outils/controle-lot.py <<'__VICTO_FIN_6__'
#!/usr/bin/env python3
"""Usage : python3 outils/controle-lot.py <dossier_de_tickets> [src/styles/tokens.css]

Contrôle d'un lot avant livraison : chaque piège déjà rencontré dans le projet
devient une règle vérifiée automatiquement sur les specs et les tests."""
import os, re, sys

racine = sys.argv[1]
specs = {f: open(os.path.join(racine, f)).read() for f in os.listdir(racine) if f.endswith('.md')}
dtests = os.path.join(racine, 'tests')
tests = {f: open(os.path.join(dtests, f)).read() for f in os.listdir(dtests)} if os.path.isdir(dtests) else {}
alertes = []
NAV_DOM = re.compile(r'\.(parentElement|parentNode|firstElementChild|lastElementChild|firstChild|lastChild|nextElementSibling|previousElementSibling|nextSibling|previousSibling)\b|\.(children|childNodes)\[')
def alerte(fichier, piege, detail): alertes.append((fichier, piege, detail))

for f, s in tests.items():
    for n, l in enumerate(s.splitlines(), 1):
        if l.strip().startswith(('//', 'it(', 'it.each', 'describe(')): continue
        # piège : toHaveTextContent normalise l'espace insécable (tickets 015, 019)
        if 'toHaveTextContent' in l and ('NB' in l or '\u00a0' in l):
            alerte(f, 'insécable', f'ligne {n} : toHaveTextContent avec une espace insécable')
        # piège : élément désigné par sa position dans le DOM, cassé par toute enveloppe
        # (parentElement : 090, 094 ; firstElementChild : réintroduit par le correctif du 090)
        nav = NAV_DOM.search(l)
        if nav:
            alerte(f, 'navigation DOM', f'ligne {n} : {nav.group(0)} — viser un data-testid ou closest()')
        # piège : apostrophe courbe dans un texte comparé exactement
        if '’' in l and ('.toBe(' in l or 'name:' in l):
            alerte(f, 'apostrophe', f'ligne {n} : apostrophe courbe dans une comparaison exacte')

# piège : accord en nombre décrit en prose — zéro au singulier (tickets 037, 083)
singuliers_zero = set()
for f, s in tests.items():
    for m in re.findall(r"['`]0 ([a-zéèàù]+)['`]", s): singuliers_zero.add(m)
for f, s in specs.items():
    for mot in singuliers_zero:
        produit_un_compteur = 'compteur' in s and (mot + 's') in s
        if produit_un_compteur and '> 1 ?' not in s:
            alerte(f, 'pluriel', f"les tests attendent « 0 {mot} » mais la spec ne donne pas le code exact `n > 1 ? …`")

for f, s in specs.items():
    cible_page = re.search(r"page\.tsx", s.split('\n', 3)[2] if s.count('\n') > 2 else s)
    # piège : une page Next avec un export nommé en plus du défaut (ticket 061)
    if cible_page and re.search(r'[Ee]xport nommé [`\w]', s) and 'Aucun export nommé' not in s:
        alerte(f, 'export de page', 'une page demande un export nommé : un seul export par défaut')
    # piège : exigence visuelle en prose, sans classe imposée (ticket 058)
    for mot in ['grand espacement', 'espacement intérieur', 'marges généreuses', 'bien espacé']:
        if mot in s:
            alerte(f, 'prose visuelle', f'« {mot} » sans classe imposée')
    # piège : icône dessinée à la main demandée au modèle (tickets 053, 059)
    if re.search(r'\bun camion\b|\bune flèche circulaire\b|tracé', s) and 'lucide' not in s:
        alerte(f, 'icône dessinée', 'icône décrite en mots : utiliser lucide-react')
    # piège : aria-current booléen rendu "false" par React (ticket 054)
    if 'aria-current' in s and "undefined" not in s:
        alerte(f, 'aria-current', "donner `aria-current={actif ? 'true' : undefined}`")
    # piège : fichier baril (tickets 021, 061)
    if re.search(r"from '@/components/(ui|accueil|catalogue)'", s):
        alerte(f, 'baril', 'import depuis un dossier')
    # piège : cible CSS confiée au modèle (ticket 010)
    if re.search(r"Crée `src/[^`]+\.css`", s):
        alerte(f, 'cible css', 'un livrable CSS : passer par un module TypeScript')

# piège : jetons de couleur laissés au modèle (ticket 093 : --vs-principal et
# --vs-fond inventés, pastilles blanc sur blanc, invisibles pour jsdom)
for f, s in specs.items():
    if 'var(--vs-*)' in s:
        alerte(f, 'jetons non listés', 'donner la liste fermée des jetons autorisés, pas « var(--vs-*) »')
chemin_jetons = sys.argv[2] if len(sys.argv) > 2 else os.path.join(racine, '..', 'src', 'styles', 'tokens.css')
if os.path.isfile(chemin_jetons):
    definis = set(re.findall(r'(--vs-[a-z0-9-]+)\s*:', open(chemin_jetons).read()))
    for f, s in list(specs.items()) + list(tests.items()):
        for j in sorted(set(re.findall(r'var\((--vs-[a-z0-9-]+)\)', s)) - definis):
            alerte(f, 'jeton inconnu', f'{j} absent de {os.path.basename(chemin_jetons)}')
else:
    print(f'  (jetons non vérifiés : {chemin_jetons} introuvable)')

for f, s in specs.items():
    # piège : code à trous « … » laissé au modèle (ticket 083)
    for bloc in re.findall(r"```[a-z]*\n(.*?)```", s, re.S):
        if '…' in bloc:
            alerte(f, 'code à trous', 'un bloc de code contient « … » : le modèle doit deviner')
            break

for f, piege, detail in sorted(alertes):
    print(f'  ✗ {f:34} [{piege}] {detail}')
print(f'  {len(alertes)} alerte(s) sur {len(specs)} specs et {len(tests)} tests')
sys.exit(1 if alertes else 0)
__VICTO_FIN_6__
cat > run.sh <<'__VICTO_FIN_7__'
#!/usr/bin/env bash
# =============================================================================
# VICTO STORE — harnais autonome
# Aucune action humaine entre les tickets.
#
# Par ticket :
#   1. branche auto/<id> partant de main
#   2. appel Aider non interactif (timeout dur)
#   3. porte de qualité : tsc --noEmit ET npm test
#   4. rouge -> on renvoie la sortie brute au modèle (max 3 tentatives)
#   5. vert  -> merge --no-ff dans main.  calé -> la branche reste isolée.
#
# Manifeste TSV : id  cible  tests  spec  [contexte]  [dépend_de]
#   contexte  : fichiers en lecture seule, séparés par des virgules
#   dépend_de : ids de tickets, séparés par des virgules. Si l'un d'eux n'a pas
#               été fusionné dans main par le harnais, le ticket est BLOQUÉ sans
#               appel au modèle — et, n'étant pas fusionné, bloque à son tour
#               ceux qui dépendent de lui (cascade).
#
# Sortie : VERT / CALÉ / TIMEOUT / TRICHE / BLOQUÉ / TEST_SUSPECT  par ticket.
# =============================================================================
set -uo pipefail

# ------------------------------------------------------------------- réglages
REPO="${REPO:-$PWD}"
MODEL="${MODEL:-ollama_chat/qwen3-coder-ctx}"
MANIFEST="${MANIFEST:-tickets/manifest.tsv}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"     # plafond de réflexions, en dur
AIDER_TIMEOUT="${AIDER_TIMEOUT:-2400}" # 40 min par appel (CPU : ~14 tok/s)
GIT_REMOTE="${GIT_REMOTE:-origin}"    # vide ("") = aucun push
RUN_BUILD="${RUN_BUILD:-1}"           # 0 = sauter npm run build dans la porte


export OLLAMA_API_BASE="${OLLAMA_API_BASE:-http://192.168.40.30:11434}"
export AIDER_NO_ANALYTICS=1

cd "$REPO" || { echo "Dépôt introuvable : $REPO"; exit 2; }

# Aider coupe par défaut un appel au modèle après 600 s puis le relance depuis
# zéro : un gros fichier généré sur CPU n'aboutit alors jamais. On aligne son
# délai sur celui du harnais, seulement si cette version d'Aider connaît l'option.
AIDER_DELAI=()
if aider --help 2>/dev/null | grep -q -- '--timeout'; then
  AIDER_DELAI=(--timeout "$((AIDER_TIMEOUT - 120))")
fi
RUN_ID="$(date +%Y%m%d-%H%M%S)"
LOGDIR=".logs/$RUN_ID"
mkdir -p "$LOGDIR"

log()  { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" | tee -a "$LOGDIR/run.log"; }
fail() { log "FATAL: $*"; exit 2; }

# ------------------------------------------------------------ pré-vérifications
command -v aider >/dev/null || fail "aider absent du PATH (pipx ensurepath + ~/.bashrc)"
command -v git   >/dev/null || fail "git absent"
[ -f "$MANIFEST" ] || fail "manifeste introuvable : $MANIFEST"
[ -f ".aider.model.settings.yml" ] || fail ".aider.model.settings.yml manquant (num_ctx → reload à froid)"

if ! git diff --quiet || ! git diff --cached --quiet; then
  fail "arbre de travail sale — commit ou stash avant de lancer le harnais"
fi

if ! curl -sf --max-time 5 "$OLLAMA_API_BASE/api/tags" >/dev/null; then
  fail "Ollama injoignable sur $OLLAMA_API_BASE"
fi
log "Ollama OK sur $OLLAMA_API_BASE — modèle : $MODEL"

# Le push doit être non interactif (clé SSH sans passphrase ou credential store),
# sinon le harnais resterait bloqué sur une demande de mot de passe.
if [ -n "$GIT_REMOTE" ]; then
  if ! git remote get-url "$GIT_REMOTE" >/dev/null 2>&1; then
    log "AVERTISSEMENT : remote '$GIT_REMOTE' inexistant — push désactivé"
    GIT_REMOTE=""
  elif ! GIT_TERMINAL_PROMPT=0 git ls-remote --exit-code "$GIT_REMOTE" >/dev/null 2>&1; then
    fail "remote '$GIT_REMOTE' injoignable ou demande une authentification interactive"
  else
    log "Remote OK : $(git remote get-url "$GIT_REMOTE")"
  fi
else
  log "Push distant désactivé (GIT_REMOTE vide)"
fi

git checkout -q main || fail "branche main introuvable"

# ------------------------------------------------------ porte de qualité
# 0 = vert. Toute la sortie va dans le log passé en $1.
run_gate() {
  local log="$1"
  : > "$log"
  echo "===== tsc --noEmit =====" >> "$log"
  if ! npm run --silent typecheck >> "$log" 2>&1; then return 1; fi
  printf '\n===== vitest run =====\n' >> "$log"
  if ! npm run --silent test >> "$log" 2>&1; then return 1; fi
  # Troisième barreau : l'application doit CONSTRUIRE. Sans lui, un projet peut
  # être vert partout et ne rien afficher (config PostCSS absente, import mort,
  # composant serveur invalide). C'est le seul contrôle qui voit la vraie appli.
  if [ "$RUN_BUILD" = "1" ] && grep -q '"build"' package.json; then
    printf '\n===== npm run build =====\n' >> "$log"
    if ! npm run --silent build >> "$log" 2>&1; then return 1; fi
  fi
  return 0
}

# Une erreur tsc qui pointe un fichier de tests/ SANS jamais nommer le fichier
# cible est impossible à corriger par le modèle : il n'a pas le droit d'y toucher.
# Inutile de brûler trois tentatives, on nomme le coupable tout de suite.
# Imports du fichier cible qui ne pointent vers aucun fichier réel.
# Le modèle n'a le droit de créer que sa cible : un module qu'il importe sans
# qu'il existe n'existera jamais. C'est la cause des échecs d'assemblage 021 et 061.
imports_inventes() {
  local f="$1" spec base ext
  [ -f "$f" ] || return 0
  grep -oE "from ['\"][^'\"]+['\"]" "$f" | sed -E "s/^from ['\"]//; s/['\"]$//" | sort -u |
  while read -r spec; do
    case "$spec" in
      @/*)       base="src/${spec#@/}" ;;
      ./*|../*)  base="$(dirname "$f")/$spec" ;;
      *)         continue ;;
    esac
    for ext in "" .ts .tsx /index.ts /index.tsx; do
      [ -f "$base$ext" ] && continue 2
    done
    echo "$spec"
  done
}

modules_existants() {
  find src -type f \( -name '*.ts' -o -name '*.tsx' \) ! -name '*.d.ts' ! -path 'src/app/*' |
    sed -E 's#^src/#@/#; s#\.(tsx|ts)$##' | sort
}

# Déclarations de types de tout le projet : un résumé exact des exports et des
# props, sans le code. Compact et toujours conforme à ce que le modèle a écrit.
DECL=".logs/decl"
generer_declarations() {
  rm -rf "$DECL"
  npx --no-install tsc -p tsconfig.json --noEmit false --declaration \
    --emitDeclarationOnly --outDir "$DECL" >/dev/null 2>&1 || true
}

# Ne renvoie au modèle que ce qui échoue : les erreurs TypeScript, sinon les
# assertions vitest en échec, sinon la fin du journal (erreur de build).
erreurs_utiles() {
  local log="$1" r
  r="$(grep -E 'error TS[0-9]+' "$log" | head -40)"
  if [ -n "$r" ]; then printf '%s\n' "$r"; return; fi
  r="$(grep -E '×|FAIL |AssertionError|Expected|Received|^[[:space:]]*[-+] |→ ' "$log" | grep -v '✓' | head -60)"
  if [ -n "$r" ]; then printf '%s\n' "$r"; return; fi
  tail -n 60 "$log"
}

gate_accuse_les_tests() {
  local log="$1" cible="$2"
  grep -qE '^tests/[^ ]+\([0-9]+,[0-9]+\): error' "$log" || return 1
  grep -q "$cible" "$log" && return 1
  return 0
}

# Première dépendance déclarée (6ᵉ colonne) qui n'a pas été fusionnée dans main.
# Critère unique : le commit de fusion que le harnais écrit au vert. Il vaut
# d'un run à l'autre, sans état à conserver.
dependance_absente() {
  local deps="$1" d IFS=','
  [ -n "$deps" ] || return 1
  for d in $deps; do
    d="${d//[[:space:]]/}"
    [ -n "$d" ] || continue
    if [ -z "$(git log main -1 --format=%h --fixed-strings --grep="feat($d): fusionné")" ]; then
      echo "$d"; return 0
    fi
  done
  return 1
}

# Empreinte d'un échec : les lignes renvoyées au modèle, sans couleurs ni durées.
# Deux empreintes égales d'affilée = la tentative suivante n'y changera rien.
empreinte_echec() {
  local esc=$'\x1b'
  erreurs_utiles "$1" |
    sed -E -e "s/${esc}\[[0-9;]*m//g" -e 's/[0-9]+([.,][0-9]+)? ?ms\b//g' -e 's/[[:space:]]+$//' |
    sort -u | md5sum | cut -d' ' -f1
}

# Un ticket dont les tests importent un module absent de main et différent de sa
# propre cible dépend d'un ticket qui a calé : il échouera à coup sûr.
ticket_bloque() {
  local test_src="$1" cible="$2" imp chemin
  [ -f "$test_src" ] || return 1
  while read -r imp; do
    [ -n "$imp" ] || continue   # test sans import relatif : rien à vérifier
    chemin="$(printf '%s' "$imp" | sed -E "s|.*from '\.\./||; s|'.*||")"
    case "$chemin" in
      "${cible%.*}"|"$cible") continue ;;
    esac
    if [ ! -e "$chemin.ts" ] && [ ! -e "$chemin.tsx" ] && [ ! -e "$chemin" ]; then
      echo "$chemin"; return 0
    fi
  done <<EOF
$(grep -oE "from '\.\./[^']+'" "$test_src" | sort -u)
EOF
  return 1
}

# ------------------------------------------------------------------ exécution
declare -a IDS=() STATUSES=() ATTEMPTS=()

while IFS= read -r LIGNE || [ -n "${LIGNE:-}" ]; do
  # Découpage sur un séparateur non blanc : avec IFS=tabulation, bash fusionne
  # deux tabulations consécutives et une colonne vide décalerait les suivantes.
  LIGNE="${LIGNE%$'\r'}"
  ID="" TARGET="" TESTFILE="" SPEC="" EXTRA="" DEPS=""
  IFS=$'\x1f' read -r ID TARGET TESTFILE SPEC EXTRA DEPS <<< "${LIGNE//$'\t'/$'\x1f'}"
  [ -z "${ID:-}" ] && continue
  case "$ID" in \#*) continue ;; esac

  BRANCH="auto/$ID"
  log "──────────────────────────────────────────────────────────────"
  log "TICKET $ID  →  $TARGET   (tests : $TESTFILE)"

  PENDING="tickets/tests/$(basename "$TESTFILE")"

  [ -f "$SPEC" ] || { log "spec introuvable : $SPEC"; IDS+=("$ID"); STATUSES+=("CALÉ"); ATTEMPTS+=(0); continue; }
  if [ ! -f "$PENDING" ] && [ ! -f "$TESTFILE" ]; then
    log "tests introuvables : ni $PENDING ni $TESTFILE"
    IDS+=("$ID"); STATUSES+=("CALÉ"); ATTEMPTS+=(0); continue
  fi

  # Dépendance déclarée non fusionnée : on saute avant même de créer la branche.
  if manque="$(dependance_absente "$DEPS")"; then
    log "  BLOQUÉ : dépend du ticket $manque, qui n'est pas fusionné dans main"
    IDS+=("$ID"); STATUSES+=("BLOQUÉ"); ATTEMPTS+=(0)
    continue
  fi
  [ -n "$DEPS" ] && log "  dépendances fusionnées : $DEPS"

  git checkout -q main
  git branch -q -D "$BRANCH" 2>/dev/null
  git checkout -q -b "$BRANCH"

  # Activation des tests du ticket : ils quittent la zone d'attente pour entrer
  # dans le périmètre de la porte. Un ticket ne voit donc que ses propres tests
  # et ceux des tickets déjà fusionnés — jamais ceux des tickets à venir.
  if [ -f "$PENDING" ]; then
    mkdir -p "$(dirname "$TESTFILE")"
    cp "$PENDING" "$TESTFILE"
    git add "$TESTFILE"
    git diff --cached --quiet || git commit -q -m "test($ID): activation des tests par le harnais"
    log "  tests activés : $PENDING → $TESTFILE"
  fi
  TEST_BASE="$(git rev-parse HEAD)"   # référence anti-triche

  # Dépendance manquante : on saute sans appeler le modèle.
  if manque="$(ticket_bloque "$PENDING" "$TARGET")"; then
    log "  BLOQUÉ : $manque est absent de main (ticket amont calé)"
    git checkout -q --force main
    IDS+=("$ID"); STATUSES+=("BLOQUÉ"); ATTEMPTS+=(0)
    continue
  fi

  # Contexte en lecture seule : les types et composants que le ticket consomme.
  # Sans ça le modèle devine les noms de champs — c'est l'origine des deux seules
  # erreurs réelles du modèle lors du premier build (image/imageUrl, badge en prop).
  READS=(--read "$TESTFILE")
  if [ -n "$EXTRA" ]; then
    generer_declarations
    OLDIFS="$IFS"; IFS=','
    for ctx in $EXTRA; do
      decl="$DECL/${ctx%.*}.d.ts"
      if [ -f "$decl" ]; then READS+=(--read "$decl")
      elif [ -f "$ctx" ]; then READS+=(--read "$ctx")
      fi
    done
    IFS="$OLDIFS"
    log "  contexte (déclarations de types) : $EXTRA"
  fi

  MSG="$(cat "$SPEC")"
  STATUS="CALÉ"
  attempt=1
  used=0
  EMPREINTE_PREC=""

  while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
    log "  tentative $attempt/$MAX_ATTEMPTS — appel du modèle…"
    timeout --signal=TERM --kill-after=60 "$AIDER_TIMEOUT" \
      aider \
        --model "$MODEL" \
        --edit-format whole \
        --yes-always \
        --no-auto-test \
        --no-stream \
        --no-check-update \
        --no-show-model-warnings \
        "${AIDER_DELAI[@]}" \
        "${READS[@]}" \
        --file "$TARGET" \
        --message "$MSG" \
        >> "$LOGDIR/$ID.aider.log" 2>&1 < /dev/null
    rc=$?
    used="$attempt"

    if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
      log "  TIMEOUT après ${AIDER_TIMEOUT}s"
      STATUS="TIMEOUT"; break
    fi

    # Garde-fou anti-triche : les tests sont passés en --read. On compare au
    # commit d'activation, pas à main, puisque c'est le harnais qui les a posés.
    if ! git diff --quiet "$TEST_BASE" HEAD -- "$TESTFILE"; then
      log "  TRICHE : le fichier de test a été modifié sur la branche"
      STATUS="TRICHE"; break
    fi

    INVENTES="$(imports_inventes "$TARGET")"
    if [ -n "$INVENTES" ]; then
      log "  IMPORTS INVENTÉS : $(printf '%s ' $INVENTES)"
      MSG="$(cat "$SPEC")

════════════════════════════════════════════════════════════
TENTATIVE PRÉCÉDENTE : IMPORTS INVENTÉS
Ton fichier $TARGET importe des modules qui N'EXISTENT PAS :
$INVENTES

Tu n'as le droit de créer AUCUN autre fichier que $TARGET : ces modules
n'existeront donc jamais. Retire ces imports. Tout ce qui n'est pas importé d'un
module réel doit être écrit dans $TARGET lui-même.

Voici la liste COMPLÈTE des modules qui existent. N'importe que parmi eux :
$(modules_existants)

Réécris $TARGET en entier."
      attempt=$((attempt + 1))
      continue
    fi

    GATELOG="$LOGDIR/$ID.gate.$attempt.log"
    if run_gate "$GATELOG"; then
      log "  porte VERTE"
      STATUS="VERT"; break
    fi

    if gate_accuse_les_tests "$GATELOG" "$TARGET"; then
      log "  TEST_SUSPECT : tsc n'accuse que des fichiers de tests, le modèle ne peut rien corriger"
      STATUS="TEST_SUSPECT"; break
    fi

    # Diagnostic d'un coup d'œil dans run.log : premières lignes utiles de l'échec.
    grep -E 'error TS|×|→' "$GATELOG" | sed -E "s/$(printf '\033')\[[0-9;]*m//g" | head -3 |
      while IFS= read -r l; do log "    | $l"; done

    EMPREINTE="$(empreinte_echec "$GATELOG")"
    if [ "$EMPREINTE" = "$EMPREINTE_PREC" ]; then
      log "  MÊME ÉCHEC qu'à la tentative précédente — arrêt, une relance n'y changera rien"
      STATUS="CALÉ"; break
    fi
    EMPREINTE_PREC="$EMPREINTE"

    [ "$attempt" -lt "$MAX_ATTEMPTS" ] && log "  porte ROUGE — relance avec la spec et les seuls échecs"
    MSG="$(cat "$SPEC")

════════════════════════════════════════════════════════════
TENTATIVE PRÉCÉDENTE : ROUGE
$TARGET contient ta dernière version. Garde tout ce qui fonctionne et corrige
UNIQUEMENT les échecs ci-dessous. Respecte à la lettre les imports et les exports
imposés par la spécification ci-dessus. Ne modifie aucun test.

Échecs :
$(erreurs_utiles "$GATELOG")"
    attempt=$((attempt + 1))
  done

  if [ "$STATUS" = "VERT" ]; then
    npm run --silent lint:fix >/dev/null 2>&1   # optionnel, après le vert
    git add -A
    git diff --cached --quiet || git commit -q -m "chore($ID): formatage post-porte"
    git checkout -q main
    git merge --no-ff -q "$BRANCH" -m "feat($ID): fusionné au vert par le harnais"
    log "  fusionné dans main"
    if [ -n "$GIT_REMOTE" ]; then
      if GIT_TERMINAL_PROMPT=0 git push -q "$GIT_REMOTE" main 2>>"$LOGDIR/$ID.git.log"; then
        log "  poussé sur $GIT_REMOTE/main"
      else
        log "  AVERTISSEMENT : push de main échoué (voir $LOGDIR/$ID.git.log)"
      fi
    fi
  else
    git checkout -q --force main
    log "  laissé isolé sur $BRANCH — main est intact"
    # On pousse quand même la branche calée : elle est relisible depuis le laptop.
    if [ -n "$GIT_REMOTE" ]; then
      GIT_TERMINAL_PROMPT=0 git push -q --force "$GIT_REMOTE" "$BRANCH" \
        2>>"$LOGDIR/$ID.git.log" && log "  branche calée poussée sur $GIT_REMOTE/$BRANCH"
    fi
  fi

  IDS+=("$ID"); STATUSES+=("$STATUS"); ATTEMPTS+=("$used")
done < "$MANIFEST"

# -------------------------------------------------------------------- rapport
echo | tee -a "$LOGDIR/run.log"
log "═══════════════ RAPPORT  ($RUN_ID) ═══════════════"
exit_code=0
i=0
while [ "$i" -lt "${#IDS[@]}" ]; do
  printf '  %-12s %-8s (tentatives : %s)\n' "${IDS[$i]}" "${STATUSES[$i]}" "${ATTEMPTS[$i]}" \
    | tee -a "$LOGDIR/run.log"
  [ "${STATUSES[$i]}" = "VERT" ] || exit_code=1
  i=$((i + 1))
done
log "logs : $LOGDIR"
log "main : $(git rev-parse --short HEAD) — $(git log -1 --pretty=%s)"

# Porte finale : l'état fusionné de main doit tenir debout dans son ensemble.
git checkout -q main
if run_gate "$LOGDIR/final.gate.log"; then
  log "PORTE FINALE VERTE sur main"
else
  log "PORTE FINALE ROUGE sur main — voir $LOGDIR/final.gate.log"
  exit_code=1
fi
exit "$exit_code"
__VICTO_FIN_7__
chmod +x run.sh
# Le harnais l'active au ticket 095. Jamais retiré s'il est suivi : après la
# fusion du 095 il est actif, et une relance du script ne doit pas l'effacer.
git ls-files --error-unmatch tests/FiltresBarre-v2.test.tsx >/dev/null 2>&1 || rm -f tests/FiltresBarre-v2.test.tsx
ok "specs, tests, manifeste et outillage écrits"

# ------------------------------------------------------------ nettoyage BarreAnnonce
BA=src/components/accueil/BarreAnnonce.tsx
if [ -e "$BA" ]; then
  encore="$(grep -rlw BarreAnnonce src --include='*.ts' --include='*.tsx' | grep -vx "$BA" || true)"
  [ -z "$encore" ] || annuler "BarreAnnonce est encore importé : $encore"
  git rm -q -- "$BA"
  for t in $(git ls-files -- 'tests/*BarreAnnonce*' 'tickets/tests/*BarreAnnonce*'); do git rm -q -- "$t"; done
  GARDE=tests/garde-sans-h1.test.tsx
  if [ -f "$GARDE" ] && grep -q BarreAnnonce "$GARDE"; then
    n="$(grep -c BarreAnnonce "$GARDE")"
    sed -i '/BarreAnnonce/d' "$GARDE"
    ok "garde-sans-h1 : $n ligne(s) BarreAnnonce retirée(s)"
  fi
  ok "BarreAnnonce retiré"
else
  ok "BarreAnnonce déjà retiré"
fi

# ------------------------------------------------------------ contrôle du lot
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/095-filtres-barre-v2.md tickets/096-entete-ligne.md "$CTL/"
cp tickets/tests/FiltresBarre-v2.test.tsx tickets/tests/entete-v3.test.tsx tests/garde-jetons.test.ts "$CTL/tests/"
python3 outils/controle-lot.py "$CTL" "$JETONS" || annuler "le contrôle du lot a levé une alerte"
rm -rf "$CTL"
ok "contrôle du lot : 0 alerte, jetons vérifiés sur $JETONS"

# ------------------------------------------------------------ base verte
bash -n run.sh || annuler "run.sh : erreur de syntaxe"
npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head -10; annuler "tsc rouge"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head -12; annuler "tests rouges"; }
ok "base verte (types et tests, garde des jetons comprise)"

# ------------------------------------------------------------ commit et vérification
git add -A -- tests tickets outils run.sh src
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "chore(lot): liste v2 — tickets 095-096, garde des jetons, retrait BarreAnnonce, harnais"
  ok "commit $(git rev-parse --short HEAD)"
}
restes="$(git ls-files -- src/components/accueil/BarreAnnonce.tsx 'tests/*BarreAnnonce*' 'tickets/tests/*BarreAnnonce*')"
[ -z "$restes" ] || mort "encore suivis par git après le commit : $restes"
grep -q BarreAnnonce tests/garde-sans-h1.test.tsx 2>/dev/null && mort "garde-sans-h1 cite encore BarreAnnonce"
ok "suppressions vérifiées dans HEAD"

if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else printf '  \033[33m!\033[0m push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert\n'; fi

cat <<'TXT'

Prêt :

    MANIFEST=tickets/manifest-liste-v2.tsv ./run.sh

Deux tickets. Le 095 réécrit un gros fichier : compte 30 à 60 minutes.
TXT
