#!/usr/bin/env bash
# VICTO STORE — lot 112 : accueil mobile, nouveaux éléments.
#   112a pastilles des rubriques (Femme, Homme, Chaussures, Marques, Soldes), téléphone et tablette
#   112b placées sur l'accueil, avant les bonnes affaires   112c photo en fond du carrousel sur téléphone
# Remplacements EXACTS relevés dans tes fichiers ; rien ne change sur grand écran.
# Usage :  cd ~/victo-store && bash lot-112.sh
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
for d in 110a 110b; do fusionne "$d" || mort "$d n'est pas fusionné : le lot 112 s'appuie dessus"; done
[ ! -e src/components/accueil/RubriquesRapides.tsx ] || mort "RubriquesRapides existe déjà : lot déjà passé ?"
grep -qF "export const NAV" src/lib/navigation.ts || true
# ------------------------------------------------------------ chaque texte « avant », mot pour mot
python3 - <<'VERIF' || mort "un fichier ne correspond pas aux specs (détail ci-dessus) : rien n'a été modifié"
import json, sys
table = json.loads(r'''[["src/app/page.tsx", "import { MosaiqueCategories } from '@/components/accueil/MosaiqueCategories';", "import { MosaiqueCategories } from '@/components/accueil/MosaiqueCategories';\nimport { RubriquesRapides } from '@/components/accueil/RubriquesRapides';", 1], ["src/app/page.tsx", "          <SectionBonnesAffaires produits={bonnesAffaires} />", "          <RubriquesRapides items={NAV} />\n          <SectionBonnesAffaires produits={bonnesAffaires} />", 1], ["src/components/accueil/Carrousel.tsx", "className=\"grid grid-cols-1 items-center gap-10 lg:grid-cols-2 max-sm:gap-0 max-sm:px-5 max-sm:pb-14 max-sm:pt-7\"", "className=\"grid grid-cols-1 items-center gap-10 lg:grid-cols-2 max-sm:gap-0 max-sm:px-5 max-sm:pb-14 max-sm:pt-7 max-sm:relative max-sm:min-h-[300px] max-sm:items-end max-sm:overflow-hidden\"", 1], ["src/components/accueil/Carrousel.tsx", "              <div>\n                <span className=\"text-sm font-bold tracking-wider uppercase\">", "              <div className=\"max-sm:relative max-sm:z-10 max-sm:text-[var(--vs-blanc)]\">\n                <span className=\"text-sm font-bold tracking-wider uppercase\">", 1], ["src/components/accueil/Carrousel.tsx", "              <div className=\"max-sm:hidden\">\n                <img src={diapo.image} alt=\"\" className=\"h-[520px] w-full rounded-[28px] object-cover\" />\n              </div>", "              <div className=\"max-sm:absolute max-sm:inset-0\">\n                <img src={diapo.image} alt=\"\" className=\"h-[520px] w-full rounded-[28px] object-cover max-sm:h-full max-sm:rounded-none\" />\n                <span aria-hidden=\"true\" data-testid=\"carrousel-degrade\" className=\"absolute inset-0 hidden bg-[linear-gradient(180deg,rgba(16,16,20,0.05)_25%,rgba(16,16,20,0.72)_100%)] max-sm:block\" />\n              </div>", 1]]''')
ko = 0
for f, avant, apres, n in table:
    try: s = open(f, encoding='utf-8').read()
    except FileNotFoundError: print(f"  ✗ {f} introuvable"); ko += 1; continue
    if apres in s: print(f"  ✗ {f} : déjà modifié (lot déjà passé ?)"); ko += 1; continue
    c = s.count(avant)
    if c != n: print(f"  ✗ {f} : « {avant.splitlines()[0][:80]} » trouvé {c} fois, attendu {n}"); ko += 1
sys.exit(1 if ko else 0)
VERIF
ok "les 5 textes à remplacer sont dans tes fichiers, au bon nombre d'occurrences"
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR

# ------------------------------------------------------------ mon test du lot 110 : l'image n'est plus masquée sur téléphone
python3 - <<'AJUSTE' || annuler "ajustement du test du carrousel impossible"
import os
avant_titre = "  it('masque la description, l’image et les flèches sur téléphone', () => {"
apres_titre = "  it('masque la description et les flèches sur téléphone', () => {"
ligne = "    expect(classes(container.querySelector('img')?.closest('div') ?? null)).toContain('max-sm:hidden');\n"
for p in ['tests/mobile-carrousel.test.tsx', 'tickets/tests/mobile-carrousel.test.tsx']:
    if not os.path.exists(p): continue
    s = open(p, encoding='utf-8').read()
    s2 = s.replace(ligne, '').replace(avant_titre, apres_titre)
    if s2 != s: open(p, 'w', encoding='utf-8').write(s2); print(f"  ✓ {p} : assertion sur l'image retirée (remplacée par le test du 112c)")
AJUSTE
git add -- tests/mobile-carrousel.test.tsx tickets/tests/mobile-carrousel.test.tsx 2>/dev/null || true

mkdir -p tickets/tests
cat > 'tickets/112a-rubriques-rapides.md' <<'__VICTO_FIN_0__'
TICKET 112a — pastilles des rubriques sous le carrousel

Crée `src/components/accueil/RubriquesRapides.tsx`, export nommé `RubriquesRapides`. Une ligne de
pastilles rondes (Femme, Homme, Chaussures, Marques, Soldes) qui défile du doigt, sur téléphone et
tablette seulement (`lg:hidden`). Composant serveur : pas de `'use client'`.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Recopie le fichier tel quel. Lire `TEINTES[item.href]` est permis : c'est un `Record`, et `??`
  donne la teinte par défaut.

## Fichier complet
Taille attendue : ~25 lignes.
```tsx
import Link from 'next/link';
import type { NavItem } from '@/components/ui/SiteHeader';

const TEINTES: Record<string, string> = {
  '/femme': 'bg-[#EEF1F8]',
  '/homme': 'bg-[#F0F0EE]',
  '/chaussures': 'bg-[#E9E4DA]',
  '/marques': 'bg-[#D9D2C4]',
  '/soldes': 'bg-[#FFD3DB]',
};

/** Accès rapide aux rubriques, sous le carrousel : téléphone et tablette seulement. */
export function RubriquesRapides({ items }: { items: NavItem[] }) {
  return (
    <nav aria-label="Rubriques" className="-mx-5 mb-10 flex gap-3 overflow-x-auto px-5 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden lg:hidden">
      {items.map((item) => (
        <Link key={item.href} href={item.href} className="flex w-[72px] shrink-0 flex-col items-center gap-2">
          <span aria-hidden="true" className={`h-[68px] w-[68px] rounded-full ring-1 ring-[var(--vs-ligne)] ${TEINTES[item.href] ?? 'bg-[var(--vs-surface)]'}`} />
          <span className={`text-[13px] font-bold ${item.promo ? 'text-[var(--vs-promo)]' : 'text-[var(--vs-noir)]'}`}>{item.label}</span>
        </Link>
      ))}
    </nav>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_0__
cat > 'tickets/112b-accueil-rubriques.md' <<'__VICTO_FIN_1__'
TICKET 112b — l'accueil affiche les pastilles des rubriques

Modifie `src/app/page.tsx`. Les pastilles des rubriques (ticket 112a) s'affichent juste avant les bonnes affaires, dans le même bloc ; elles sont masquées sur grand écran.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { MosaiqueCategories } from '@/components/accueil/MosaiqueCategories';
```
Après :
```tsx
import { MosaiqueCategories } from '@/components/accueil/MosaiqueCategories';
import { RubriquesRapides } from '@/components/accueil/RubriquesRapides';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
          <SectionBonnesAffaires produits={bonnesAffaires} />
```
Après :
```tsx
          <RubriquesRapides items={NAV} />
          <SectionBonnesAffaires produits={bonnesAffaires} />
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > 'tickets/112c-carrousel-photo.md' <<'__VICTO_FIN_2__'
TICKET 112c — le carrousel montre sa photo en fond sur téléphone

Modifie `src/components/accueil/Carrousel.tsx`. Sur téléphone, la photo de la diapositive remplit le bandeau (300 px au moins), sous un dégradé sombre ; le texte, posé en bas et en blanc, reste lisible. Rien ne change au-dessus de 640 px (le dégradé y est masqué).

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="grid grid-cols-1 items-center gap-10 lg:grid-cols-2 max-sm:gap-0 max-sm:px-5 max-sm:pb-14 max-sm:pt-7"
```
Après :
```tsx
className="grid grid-cols-1 items-center gap-10 lg:grid-cols-2 max-sm:gap-0 max-sm:px-5 max-sm:pb-14 max-sm:pt-7 max-sm:relative max-sm:min-h-[300px] max-sm:items-end max-sm:overflow-hidden"
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
              <div>
                <span className="text-sm font-bold tracking-wider uppercase">
```
Après :
```tsx
              <div className="max-sm:relative max-sm:z-10 max-sm:text-[var(--vs-blanc)]">
                <span className="text-sm font-bold tracking-wider uppercase">
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
              <div className="max-sm:hidden">
                <img src={diapo.image} alt="" className="h-[520px] w-full rounded-[28px] object-cover" />
              </div>
```
Après :
```tsx
              <div className="max-sm:absolute max-sm:inset-0">
                <img src={diapo.image} alt="" className="h-[520px] w-full rounded-[28px] object-cover max-sm:h-full max-sm:rounded-none" />
                <span aria-hidden="true" data-testid="carrousel-degrade" className="absolute inset-0 hidden bg-[linear-gradient(180deg,rgba(16,16,20,0.05)_25%,rgba(16,16,20,0.72)_100%)] max-sm:block" />
              </div>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_2__
cat > 'tickets/manifest-112.tsv' <<'__VICTO_FIN_3__'
112a	src/components/accueil/RubriquesRapides.tsx	tests/rubriques-rapides.test.tsx	tickets/112a-rubriques-rapides.md			
112b	src/app/page.tsx	tests/accueil-rubriques.test.ts	tickets/112b-accueil-rubriques.md		112a	
112c	src/components/accueil/Carrousel.tsx	tests/carrousel-photo.test.tsx	tickets/112c-carrousel-photo.md			
__VICTO_FIN_3__
cat > 'tickets/tests/accueil-rubriques.test.ts' <<'__VICTO_FIN_4__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('accueil — pastilles des rubriques', () => {
  it('les affiche juste avant les bonnes affaires', () => {
    const s = readFileSync('src/app/page.tsx', 'utf8');
    expect(s).toContain("import { RubriquesRapides } from '@/components/accueil/RubriquesRapides';");
    const pastilles = s.indexOf('<RubriquesRapides items={NAV} />');
    expect(pastilles).toBeGreaterThan(-1);
    expect(pastilles).toBeLessThan(s.indexOf('<SectionBonnesAffaires'));
    expect(pastilles).toBeGreaterThan(s.indexOf('<BandeMarques'));
  });
});
__VICTO_FIN_4__
cat > 'tickets/tests/carrousel-photo.test.tsx' <<'__VICTO_FIN_5__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Carrousel } from '../src/components/accueil/Carrousel';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('carrousel — photo en fond sur téléphone', () => {
  it('étend la photo à tout le bandeau, sous un dégradé', () => {
    const { container } = render(<Carrousel auto={false} />);
    const image = container.querySelector('img');
    for (const k of ['max-sm:absolute', 'max-sm:inset-0']) expect(classes(image?.closest('div') ?? null), k).toContain(k);
    for (const k of ['h-[520px]', 'max-sm:h-full', 'max-sm:rounded-none']) expect(classes(image), k).toContain(k);
    const degrades = screen.getAllByTestId('carrousel-degrade');
    expect(degrades.length).toBeGreaterThan(0);
    for (const k of ['hidden', 'max-sm:block', 'absolute', 'inset-0']) expect(classes(degrades.find(() => true) ?? null), k).toContain(k);
  });

  it('pose le texte en blanc, au-dessus de la photo', () => {
    render(<Carrousel auto={false} />);
    const texte = screen.getByRole('heading', { level: 1 }).closest('div');
    for (const k of ['max-sm:relative', 'max-sm:z-10', 'max-sm:text-[var(--vs-blanc)]']) expect(classes(texte), k).toContain(k);
    const bandeau = texte?.closest('.grid') ?? null;
    for (const k of ['max-sm:min-h-[300px]', 'max-sm:items-end', 'max-sm:overflow-hidden']) expect(classes(bandeau), k).toContain(k);
  });
});
__VICTO_FIN_5__
cat > 'tickets/tests/rubriques-rapides.test.tsx' <<'__VICTO_FIN_6__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { RubriquesRapides } from '../src/components/accueil/RubriquesRapides';
import { NAV } from '../src/lib/navigation';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('pastilles des rubriques', () => {
  it('propose chaque rubrique, sur téléphone et tablette seulement', () => {
    render(<RubriquesRapides items={NAV} />);
    const nav = screen.getByRole('navigation', { name: 'Rubriques' });
    for (const k of ['lg:hidden', 'overflow-x-auto', '[scrollbar-width:none]']) expect(classes(nav), k).toContain(k);
    expect(within(nav).getAllByRole('link').map((l: HTMLElement) => l.getAttribute('href'))).toEqual(NAV.map((n) => n.href));
  });

  it('colore chaque pastille, et met les soldes en rouge', () => {
    render(<RubriquesRapides items={NAV} />);
    const femme = screen.getByRole('link', { name: 'Femme' });
    expect(classes(femme.querySelector('[aria-hidden="true"]'))).toContain('bg-[#EEF1F8]');
    expect(classes(screen.getByText('Soldes'))).toContain('text-[var(--vs-promo)]');
    expect(classes(screen.getByText('Homme'))).toContain('text-[var(--vs-noir)]');
  });

  it('donne une teinte neutre à une rubrique inconnue', () => {
    render(<RubriquesRapides items={[{ label: 'Nouveautés', href: '/nouveautes' }]} />);
    expect(classes(screen.getByRole('link', { name: 'Nouveautés' }).querySelector('[aria-hidden="true"]'))).toContain('bg-[var(--vs-surface)]');
  });
});
__VICTO_FIN_6__
TESTS=(accueil-rubriques.test.ts carrousel-photo.test.tsx rubriques-rapides.test.tsx)
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
ok "3 specs, 3 tests en attente et le manifeste écrits"

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/112*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-112.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
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
  git commit -q -m "chore(tickets): lot 112 — accueil mobile ; test du carrousel ajusté"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-112.tsv ./run.sh\n\nTrois tickets courts. Compte environ 45 minutes ; le 112b attend le 112a.\n'
