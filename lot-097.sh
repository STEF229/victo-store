#!/usr/bin/env bash
# VICTO STORE — ticket 097 : pagination conforme au style de la liste.
# Avant livraison, le nouveau test passe un PRÉ-VOL sur le dépôt réel : exécuté
# contre l'actuel Pagination.tsx, il doit échouer sur des assertions, jamais
# planter (TypeError, ReferenceError…) — un plantage serait une erreur du test.
# Usage :  cd ~/victo-store && bash lot-097.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }
annuler(){ rm -f "$PREVOL"; git reset -q --hard HEAD; git clean -fdq -- tests tickets; mort "$*  — rien n'a été modifié"; }
PREVOL=tests/zz-prevol-Pagination-v2.test.tsx

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
modifies="$(git ls-files -m -- '*.tsbuildinfo')"
[ -z "$modifies" ] || git checkout -q -- $modifies
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
ok "main à jour ($(git rev-parse --short HEAD))"

grep -q "Page suivante" src/components/catalogue/Pagination.tsx 2>/dev/null || mort "Pagination.tsx absent ou inattendu"
[ -f tests/Pagination.test.tsx ] || mort "tests/Pagination.test.tsx absent : le comportement ne serait plus vérifié"
grep -q -- '--vs-gris' src/styles/tokens.css || mort "jetons introuvables"
ok "cible, test de comportement et jetons présents"
mkdir -p tickets/tests
cat > tickets/097-pagination-v2.md <<'__VICTO_FIN_0__'
TICKET 097 — pagination conforme au style de la liste

Écris `src/components/catalogue/Pagination.tsx` en entier, export nommé
`Pagination`, à partir de zéro.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Icônes `lucide-react` uniquement, avec `aria-hidden`.
- Chaque `className` est écrit **exactement** comme ci-dessous, sans rien ajouter :
  ni `hover:`, ni `focus:`, ni `rounded-md`, ni autre couleur.

## Bloc d'imports exact
```tsx
'use client';

import { ChevronLeft, ChevronRight } from 'lucide-react';
```

## Props (inchangées)
```ts
interface PaginationProps {
  page: number;
  pages: number;
  onChange: (page: number) => void;
  className?: string;
}
```
Paramètre par défaut : `className = ''`.

## Comportement
- `pages <= 1` : le composant renvoie `null`.
- Page précédente : désactivée si `page <= 1` ; sinon, au clic, `onChange(page - 1)`.
- Page suivante : désactivée si `page >= pages` ; sinon, au clic, `onChange(page + 1)`.
- Numéros de page : affichés **seulement si `pages <= 7`**, un bouton par page de 1 à
  `pages`. Au clic sur un numéro différent de `page` : `onChange(numéro)`. Au clic
  sur le numéro de la page courante : rien.

## Rendu
Taille attendue : ~70 lignes.

```tsx
<nav
  aria-label="Pagination"
  data-testid="pagination"
  className={`mt-12 flex flex-col items-center gap-3.5 ${className}`}
>
  <div className="flex items-center gap-2">
    {/* bouton précédent */}
    {/* numéros, seulement si pages <= 7 */}
    {/* bouton suivant */}
  </div>
  <span data-testid="pagination-etat" className="text-sm text-[var(--vs-gris)]">
    Page {page} sur {pages}
  </span>
</nav>
```

**Bouton précédent**, avec exactement ces attributs, et pour seul contenu
`<ChevronLeft aria-hidden size={18} />` :
```tsx
type="button"
aria-label="Page précédente"
disabled={page <= 1}
className={page <= 1
  ? 'flex h-[46px] w-[46px] items-center justify-center rounded-full border-[1.5px] cursor-not-allowed border-[var(--vs-ligne)] text-[#B5B5BA]'
  : 'flex h-[46px] w-[46px] items-center justify-center rounded-full border-[1.5px] border-[var(--vs-noir)] text-[var(--vs-noir)]'}
```

**Bouton suivant** : identique, avec `aria-label="Page suivante"`,
`disabled={page >= pages}`, la même alternative de `className` avec la condition
`page >= pages`, et pour seul contenu `<ChevronRight aria-hidden size={18} />`.

**Chaque numéro** `n`, dans l'ordre croissant, avec une `key` égale à `n`, pour
contenu le nombre `{n}` et exactement ces attributs :
```tsx
type="button"
aria-label={`Page ${n}`}
aria-current={n === page ? 'page' : undefined}
className={n === page
  ? 'flex h-[46px] min-w-[46px] items-center justify-center rounded-full border-[1.5px] px-3 text-[15px] font-semibold border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]'
  : 'flex h-[46px] min-w-[46px] items-center justify-center rounded-full border-[1.5px] px-3 text-[15px] font-semibold border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]'}
```
La liste des numéros se construit sans accès par index, par exemple avec
`Array.from({ length: pages }, (_, i) => i + 1).map((n) => (...))`.

Les trois commentaires `{/* … */}` du bloc de rendu indiquent seulement où placer
les éléments : ne les recopie pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont
`tests/Pagination.test.tsx` (comportement existant, à conserver).
__VICTO_FIN_0__
cat > tickets/tests/Pagination-v2.test.tsx <<'__VICTO_FIN_1__'
import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { Pagination } from '../src/components/catalogue/Pagination';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const nom = (el: Element) => el.getAttribute('aria-label') ?? el.getAttribute('data-testid') ?? el.tagName;
function porte(el: Element, chaine: string) {
  const reelles = classes(el);
  for (const k of chaine.split(' ')) expect(reelles, `${nom(el)} : classe ${k} manquante`).toContain(k);
}

const ROND = 'flex h-[46px] w-[46px] items-center justify-center rounded-full border-[1.5px]';
const ROND_ACTIF = 'border-[var(--vs-noir)] text-[var(--vs-noir)]';
const ROND_INACTIF = 'cursor-not-allowed border-[var(--vs-ligne)] text-[#B5B5BA]';
const NUMERO = 'flex h-[46px] min-w-[46px] items-center justify-center rounded-full border-[1.5px] px-3 text-[15px] font-semibold';
const NUMERO_ON = 'border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]';
const NUMERO_OFF = 'border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]';

const bouton = (n: string) => screen.getByRole('button', { name: n });

describe('Pagination v2 — disposition', () => {
  it('centre la pagination sous la grille, avec sa marge', () => {
    render(<Pagination page={1} pages={3} onChange={() => {}} className="classe-appelant" />);
    const nav = screen.getByTestId('pagination');
    porte(nav, 'mt-12 flex flex-col items-center gap-3.5 classe-appelant');
    porte(screen.getByTestId('pagination-etat'), 'text-sm text-[var(--vs-gris)]');
    expect(within(nav).getAllByRole('button').map((b: HTMLElement) => nom(b))).toEqual([
      'Page précédente', 'Page 1', 'Page 2', 'Page 3', 'Page suivante',
    ]);
  });
});

describe('Pagination v2 — flèches', () => {
  it('grise la flèche désactivée et marque la flèche active', () => {
    render(<Pagination page={1} pages={3} onChange={() => {}} />);
    const prec = bouton('Page précédente');
    const suiv = bouton('Page suivante');
    porte(prec, ROND);
    porte(prec, ROND_INACTIF);
    porte(suiv, ROND);
    porte(suiv, ROND_ACTIF);
    expect(classes(suiv)).not.toContain('text-[#B5B5BA]');
  });

  it('ne contient que des chevrons lucide, cachés aux lecteurs d’écran', () => {
    render(<Pagination page={2} pages={3} onChange={() => {}} />);
    for (const [n, icone] of [['Page précédente', 'lucide-chevron-left'], ['Page suivante', 'lucide-chevron-right']] as const) {
      const b = bouton(n);
      expect(b.textContent).toBe('');
      const svg = b.querySelector(`svg.${icone}`);
      expect(svg, `${n} : icône ${icone}`).not.toBeNull();
      expect(svg?.getAttribute('aria-hidden')).toBe('true');
    }
  });

  it('inverse les états sur la dernière page', () => {
    render(<Pagination page={3} pages={3} onChange={() => {}} />);
    porte(bouton('Page précédente'), ROND_ACTIF);
    porte(bouton('Page suivante'), ROND_INACTIF);
    expect(bouton('Page suivante')).toBeDisabled();
  });
});

describe('Pagination v2 — numéros', () => {
  it('noircit la page courante et la signale', () => {
    render(<Pagination page={2} pages={3} onChange={() => {}} />);
    const courante = bouton('Page 2');
    porte(courante, NUMERO);
    porte(courante, NUMERO_ON);
    expect(courante).toHaveAttribute('aria-current', 'page');
    expect(courante.textContent).toBe('2');
    for (const n of ['Page 1', 'Page 3']) {
      porte(bouton(n), NUMERO);
      porte(bouton(n), NUMERO_OFF);
      expect(bouton(n)).not.toHaveAttribute('aria-current');
    }
  });

  it('va à la page cliquée, sauf la page courante', () => {
    const onChange = vi.fn();
    render(<Pagination page={2} pages={3} onChange={onChange} />);
    fireEvent.click(bouton('Page 2'));
    expect(onChange).not.toHaveBeenCalled();
    fireEvent.click(bouton('Page 3'));
    expect(onChange).toHaveBeenCalledWith(3);
  });

  it('montre sept numéros au plus, et aucun au-delà', () => {
    const { unmount } = render(<Pagination page={1} pages={7} onChange={() => {}} />);
    expect(bouton('Page 7')).toBeInTheDocument();
    unmount();
    render(<Pagination page={1} pages={8} onChange={() => {}} />);
    expect(screen.queryByRole('button', { name: 'Page 1' })).toBeNull();
    expect(screen.getAllByRole('button')).toHaveLength(2);
    expect(screen.getByTestId('pagination-etat').textContent).toBe('Page 1 sur 8');
  });
});

describe('Pagination v2 — source', () => {
  it('ne garde rien de l’ancien style', () => {
    const source = readFileSync('src/components/catalogue/Pagination.tsx', 'utf8');
    for (const k of ['rounded-md', 'hover:', 'focus:', 'var(--vs-surface)', 'var(--vs-accent)']) {
      expect(source, `reste de l'ancien style : ${k}`).not.toContain(k);
    }
  });
});
__VICTO_FIN_1__
cat > tickets/manifest-097.tsv <<'__VICTO_FIN_2__'
097	src/components/catalogue/Pagination.tsx	tests/Pagination-v2.test.tsx	tickets/097-pagination-v2.md			neuf
__VICTO_FIN_2__
git ls-files --error-unmatch tests/Pagination-v2.test.tsx >/dev/null 2>&1 || rm -f tests/Pagination-v2.test.tsx
ok "spec, test en attente et manifeste écrits"

# ------------------------------------------------------------ contrôle et budget
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/097-pagination-v2.md "$CTL/"; cp tickets/tests/Pagination-v2.test.tsx "$CTL/tests/"
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
car=$(( $(wc -m < tickets/097-pagination-v2.md) + $(wc -m < tickets/tests/Pagination-v2.test.tsx) ))
budget=$(( car / 3 + 2000 + 70 * 40 / 3 ))
[ "$budget" -lt 14000 ] || annuler "budget trop élevé ($budget jetons)"
ok "contrôle : 0 alerte ; budget ≈ $budget jetons"

# ------------------------------------------------------------ pré-vol du test
cp tickets/tests/Pagination-v2.test.tsx "$PREVOL"
npx --no-install vitest run "$PREVOL" > /tmp/victo-prevol.log 2>&1 || true
rm -f "$PREVOL"
sed -i -E 's/\x1b\[[0-9;]*m//g' /tmp/victo-prevol.log
grep -qE "Tests +[0-9]+ (failed|passed)" /tmp/victo-prevol.log || { tail -15 /tmp/victo-prevol.log; annuler "pré-vol : le test ne s'est pas exécuté"; }
if grep -qE "TypeError|ReferenceError|SyntaxError|is not a function|Cannot read propert|is not defined" /tmp/victo-prevol.log; then
  grep -nE "TypeError|ReferenceError|SyntaxError|is not a function|Cannot read propert|is not defined" /tmp/victo-prevol.log | head -5
  annuler "pré-vol : le test PLANTE sur le code actuel — c'est le test qui est faux"
fi
ok "pré-vol : $(grep -oE 'Tests +[0-9]+ (failed|passed)[^(]*' /tmp/victo-prevol.log | head -1 | tr -s ' ') sur l'ancien code, aucun plantage"

# ------------------------------------------------------------ base verte, commit
npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head; annuler "tsc rouge"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges"; }
ok "base verte"
git add -A -- tickets tests
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "chore(tickets): 097 — pagination conforme au style de la liste"; ok "commit $(git rev-parse --short HEAD)"; }
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else printf '  \033[33m!\033[0m push refusé (voir /tmp/victo-push.log)\n'; fi

cat <<'TXT'

Prêt :

    MANIFEST=tickets/manifest-097.tsv ./run.sh

Un ticket, fichier court : 10 à 20 minutes.
TXT
