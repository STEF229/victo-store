#!/usr/bin/env bash
# VICTO STORE — lot 101 : les deux dettes de la liste.
#   101a  TiroirsFiltres : bouton « Voir N produits » (prop facultative ; sans elle, texte inchangé)
#   101b  FiltresBarre   : transmet le nombre au tiroir
#   101c  VueCatalogue   : donne au tiroir le nombre affiché par le compteur
#   101d  /boutique      : réécrite avec VueCatalogue ; son ancien test, qui vérifiait
#                          l'ancien panneau de filtres, est retiré
# Usage :  cd ~/victo-store && bash lot-101.sh
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
C=src/components/catalogue
fusionne(){ git log main -1 --format=%h --fixed-strings --grep="feat($1): fusionné" | grep -q .; }
for d in 095b 095c; do fusionne "$d" || mort "$d n'est pas fusionné"; done
[ "$(grep -c 'Appliquer les filtres' $C/TiroirsFiltres.tsx)" = 1 ] || mort "TiroirsFiltres : le texte « Appliquer les filtres » n'est pas unique"
grep -q "interface TiroirsFiltresProps" $C/TiroirsFiltres.tsx || mort "TiroirsFiltres : interface des props introuvable"
grep -q "interface FiltresBarreProps" $C/FiltresBarre.tsx && grep -q "<TiroirsFiltres" $C/FiltresBarre.tsx || mort "FiltresBarre ne ressemble pas à la version du 095c"
grep -q "const n = resultats.length;" $C/VueCatalogue.tsx && grep -q "onTriChange={changerTri}" $C/VueCatalogue.tsx || mort "VueCatalogue ne ressemble pas à la version attendue (const n = resultats.length, onTriChange={changerTri})"
grep -q "nombreResultats" $C/TiroirsFiltres.tsx $C/FiltresBarre.tsx $C/VueCatalogue.tsx && mort "nombreResultats existe déjà : lot déjà passé ?"
[ -f src/app/boutique/page.tsx ] || mort "src/app/boutique/page.tsx absent"
# Seules les vraies importations comptent : un test qui lit le fichier (readFileSync) n'en dépend pas.
autres="$(grep -rlE "from ['\"][^'\"]*app/boutique/page['\"]" src tests | grep -vx tests/boutique-page.test.tsx || true)"
[ -z "$autres" ] || mort "l'ancienne page boutique est importée ailleurs : $(echo $autres)"
grep -qE "export function listerProduits" src/lib/donnees.ts || mort "listerProduits absent de donnees.ts"
ok "tiroir, barre, vue catalogue et page boutique conformes aux specs"

trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
mkdir -p tickets/tests
cat > 'tickets/101a-tiroir-voir-n.md' <<'__VICTO_FIN_0__'
TICKET 101a — le tiroir mobile annonce « Voir N produits »

Modifie `src/components/catalogue/TiroirsFiltres.tsx`. Le fichier actuel est
correct et testé : tu ajoutes une prop facultative, rien d'autre ne change.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Garde le bloc d'imports actuel à l'identique. Aucune classe ne change.

## Les trois changements
1. Dans `interface TiroirsFiltresProps`, ajoute, après `onFermer`, exactement :
   `nombreResultats?: number | undefined;`
2. Lis cette prop avec les autres, puis, avant le `return`, ajoute exactement :
   ```tsx
   const libelleValider =
     nombreResultats === undefined
       ? 'Appliquer les filtres'
       : `Voir ${nombreResultats} ${nombreResultats > 1 ? 'produits' : 'produit'}`;
   ```
3. Le bouton de classe `VALIDER` affiche `{libelleValider}` au lieu du texte fixe
   `Appliquer les filtres`. Ses autres attributs ne changent pas.

Sans la prop, le bouton garde donc son texte actuel.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont
`tests/TiroirsFiltres.test.tsx` (comportement existant).
__VICTO_FIN_0__
cat > 'tickets/101b-barre-voir-n.md' <<'__VICTO_FIN_1__'
TICKET 101b — la barre de filtres transmet le nombre de résultats au tiroir

Modifie `src/components/catalogue/FiltresBarre.tsx`. Le fichier actuel est correct
et testé : tu ajoutes une prop facultative et tu la transmets, rien d'autre.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Garde le bloc d'imports actuel à l'identique. Aucune classe, aucun texte, aucun
  `data-testid` ne change.

## Les deux changements
1. Dans `interface FiltresBarreProps`, ajoute, après `onTriChange`, exactement :
   `nombreResultats?: number | undefined;`
   et lis cette prop avec les autres.
2. Sur l'élément `<TiroirsFiltres …>`, ajoute l'attribut
   `nombreResultats={nombreResultats}`. Ses autres attributs ne changent pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont
`tests/FiltresBarre.test.tsx` et `tests/FiltresBarre-v3.test.tsx` (comportement existant).
__VICTO_FIN_1__
cat > 'tickets/101c-vue-voir-n.md' <<'__VICTO_FIN_2__'
TICKET 101c — la page de liste donne le nombre de résultats au tiroir

Modifie `src/components/catalogue/VueCatalogue.tsx`. Un seul changement.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Garde le bloc d'imports actuel à l'identique. Aucune autre ligne ne change.

## Le changement
Le composant calcule déjà `const n = resultats.length;` (c'est le nombre affiché par
le compteur). Sur l'élément `<FiltresBarre …>`, ajoute, après
`onTriChange={changerTri}`, l'attribut `nombreResultats={n}`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont
`tests/VueCatalogue-v2.test.tsx` (comportement existant).
__VICTO_FIN_2__
cat > 'tickets/101d-page-boutique.md' <<'__VICTO_FIN_3__'
TICKET 101d — /boutique rejoint les autres pages de liste

Écris `src/app/boutique/page.tsx` en entier, à partir de zéro. La page n'utilise
plus l'ancien panneau de filtres : elle affiche toute la sélection avec
`VueCatalogue`, comme les pages Femme, Homme, Chaussures et Soldes.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut `PageBoutique`.** Aucun export nommé.
- Composant serveur : **pas** de `'use client'`.

## Fichier
Taille attendue : ~15 lignes.
```tsx
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { listerProduits } from '@/lib/donnees';

export default function PageBoutique() {
  return (
    <VueCatalogue
      titre="Boutique"
      description="Toute la sélection, toutes marques confondues, au bon prix."
      produits={listerProduits()}
    />
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_3__
cat > 'tickets/manifest-101.tsv' <<'__VICTO_FIN_4__'
101a	src/components/catalogue/TiroirsFiltres.tsx	tests/TiroirsFiltres-nombre.test.tsx	tickets/101a-tiroir-voir-n.md			
101b	src/components/catalogue/FiltresBarre.tsx	tests/FiltresBarre-nombre.test.tsx	tickets/101b-barre-voir-n.md	src/components/catalogue/TiroirsFiltres.tsx	101a	
101c	src/components/catalogue/VueCatalogue.tsx	tests/VueCatalogue-nombre.test.tsx	tickets/101c-vue-voir-n.md	src/components/catalogue/FiltresBarre.tsx	101b	
101d	src/app/boutique/page.tsx	tests/page-boutique.test.tsx	tickets/101d-page-boutique.md	src/components/catalogue/VueCatalogue.tsx		neuf
__VICTO_FIN_4__
cat > 'tickets/tests/FiltresBarre-nombre.test.tsx' <<'__VICTO_FIN_5__'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { FiltresBarre } from '../src/components/catalogue/FiltresBarre';

function poser(nombreResultats?: number) {
  const base = { marques: [], tailles: [], criteres: {}, onChange: vi.fn(), tri: 'nouveautes' as const, onTriChange: vi.fn() };
  render(nombreResultats === undefined ? <FiltresBarre {...base} /> : <FiltresBarre {...base} nombreResultats={nombreResultats} />);
  fireEvent.click(screen.getByTestId('ouvrir-filtres'));
  return screen.getByTestId('tiroir-filtres');
}

describe('FiltresBarre — nombre de résultats', () => {
  it('le transmet au tiroir mobile', () => {
    const tiroir = poser(5);
    expect(within(tiroir).getByRole('button', { name: 'Voir 5 produits' })).toBeInTheDocument();
  });

  it('laisse le texte par défaut sans nombre', () => {
    const tiroir = poser();
    expect(within(tiroir).getByRole('button', { name: 'Appliquer les filtres' })).toBeInTheDocument();
  });
});
__VICTO_FIN_5__
cat > 'tickets/tests/TiroirsFiltres-nombre.test.tsx' <<'__VICTO_FIN_6__'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { VALIDER } from '../src/components/catalogue/filtres-affichage';
import { TiroirsFiltres } from '../src/components/catalogue/TiroirsFiltres';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
function poser(nombreResultats?: number) {
  const onFermer = vi.fn();
  const base = {
    vue: 'filtres' as const, marques: [], tailles: [], criteres: {}, tri: 'nouveautes' as const,
    onMarque: vi.fn(), onTaille: vi.fn(), onPromo: vi.fn(), onStock: vi.fn(), onTri: vi.fn(), onFermer,
  };
  render(nombreResultats === undefined ? <TiroirsFiltres {...base} /> : <TiroirsFiltres {...base} nombreResultats={nombreResultats} />);
  return onFermer;
}

describe('TiroirsFiltres — Voir N produits', () => {
  it('annonce le nombre de résultats, accordé', () => {
    poser(8);
    const bouton = screen.getByRole('button', { name: 'Voir 8 produits' });
    for (const k of VALIDER.split(' ')) expect(classes(bouton), `classe ${k}`).toContain(k);
  });

  it('accorde au singulier jusqu’à un, zéro compris', () => {
    poser(1);
    expect(screen.getByRole('button', { name: 'Voir 1 produit' })).toBeInTheDocument();
  });

  it('dit « Voir 0 produit » quand rien ne correspond', () => {
    poser(0);
    expect(screen.getByRole('button', { name: 'Voir 0 produit' })).toBeInTheDocument();
  });

  it('garde « Appliquer les filtres » sans nombre, et ferme toujours', () => {
    const onFermer = poser();
    fireEvent.click(screen.getByRole('button', { name: 'Appliquer les filtres' }));
    expect(onFermer).toHaveBeenCalledTimes(1);
  });
});
__VICTO_FIN_6__
cat > 'tickets/tests/VueCatalogue-nombre.test.tsx' <<'__VICTO_FIN_7__'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { VueCatalogue } from '../src/components/catalogue/VueCatalogue';
import type { Marque, Produit } from '../src/lib/catalogue';

const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const LACOSTE: Marque = { id: 'm2', nom: 'Lacoste', slug: 'lacoste' };
const P = (id: string, marque: Marque): Produit => ({
  id, slug: `p-${id}`, nom: `Produit ${id}`, marque, imageUrl: '/img/x.svg', prixCents: 5000,
  variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 2 }],
});
const HUIT = [P('a', NIKE), P('b', NIKE), P('c', LACOSTE), P('d', NIKE), P('e', LACOSTE), P('f', NIKE), P('g', LACOSTE), P('h', NIKE)];

describe('VueCatalogue — Voir N produits', () => {
  it('annonce dans le tiroir le même nombre que le compteur', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    fireEvent.click(screen.getByTestId('ouvrir-filtres'));
    const tiroir = screen.getByTestId('tiroir-filtres');
    expect(within(tiroir).getByRole('button', { name: 'Voir 8 produits' })).toBeInTheDocument();
    fireEvent.click(within(tiroir).getByTestId('filtre-marque-lacoste'));
    expect(screen.getByTestId('compteur').textContent).toBe('3 produits');
    expect(within(screen.getByTestId('tiroir-filtres')).getByRole('button', { name: 'Voir 3 produits' })).toBeInTheDocument();
  });
});
__VICTO_FIN_7__
cat > 'tickets/tests/page-boutique.test.tsx' <<'__VICTO_FIN_8__'
import { readFileSync } from 'node:fs';
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageBoutique from '../src/app/boutique/page';
import { listerProduits } from '../src/lib/donnees';

describe('page boutique', () => {
  it('affiche toute la sélection avec la vue des listes', () => {
    render(<PageBoutique />);
    const n = listerProduits().length;
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByTestId('liste-titre').textContent).toBe('Boutique');
    expect(screen.getByTestId('compteur').textContent).toBe(`${n} ${n > 1 ? 'produits' : 'produit'}`);
    expect(screen.getByTestId('filtres-barre')).toBeInTheDocument();
    expect(screen.queryByTestId('filtres')).toBeNull();
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('n’utilise plus l’ancien panneau de filtres', () => {
    const source = readFileSync('src/app/boutique/page.tsx', 'utf8');
    expect(source).toContain('VueCatalogue');
    expect(source).not.toContain('FiltresPanneau');
    expect(source).not.toMatch(/export (function|const) /);
  });
});
__VICTO_FIN_8__
TESTS=(FiltresBarre-nombre.test.tsx TiroirsFiltres-nombre.test.tsx VueCatalogue-nombre.test.tsx page-boutique.test.tsx)
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
for f in tests/boutique-page.test.tsx tickets/tests/boutique-page.test.tsx; do
  if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then git rm -q -- "$f"; ok "$f retiré (il vérifiait l'ancien panneau de filtres)"; fi
done
ok "4 specs, 4 tests en attente et le manifeste écrits"

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/101*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-101.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
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
  git commit -q -m "chore(tickets): lot 101 — « Voir N produits » et /boutique alignée"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git ls-files tests/boutique-page.test.tsx tickets/tests/boutique-page.test.tsx)" ] || mort "l'ancien test de la boutique est encore suivi"
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-101.tsv ./run.sh\n\nQuatre tickets : 101a → 101b → 101c enchaînés ; 101d en parallèle. Compte environ une heure.\n'
