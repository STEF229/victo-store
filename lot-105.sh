#!/usr/bin/env bash
# VICTO STORE — lot 105 : corrections de l'en-tête et des cartes.
#   ancien test tests/finitions-SiteHeader.test.tsx assoupli (« Mon compte » par son étiquette) ;
#   102m repris de sa branche (« Mon compte » → lien /compte) si l'en-tête n'a pas bougé depuis,
#        après la porte complète ; sinon relancé par le modèle ;
#   105b l'en-tête marque la rubrique de la page en cours ;  105c le cœur reste dans sa carte.
# Usage :  cd ~/victo-store && bash lot-105.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
info(){ printf '  \033[33m!\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }
annuler(){ rm -f tests/zz-prevol-*; git checkout -q -f main 2>/dev/null || true; git reset -q --hard HEAD; git clean -fdq -- tests tickets
           git branch -q -D verif/102m 2>/dev/null || true; mort "$*  — rien n'a été modifié"; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
modifies="$(git ls-files -m -- '*.tsbuildinfo')"
[ -z "$modifies" ] || git checkout -q -- $modifies
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase=merges || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
ok "main à jour ($(git rev-parse --short HEAD))"

# ------------------------------------------------------------ ce que les specs supposent
SH=src/components/ui/SiteHeader.tsx; PC=src/components/ui/ProductCard.tsx; FT=tests/finitions-SiteHeader.test.tsx
fusionne(){ git log main -1 --format=%h --fixed-strings --grep="feat($1): fusionné" | grep -q .; }
grep -q "'use client'" "$SH" || mort "$SH n'est pas un composant client : usePathname y est impossible"
[ "$(grep -cF "className={item.promo ? 'text-[#FF5A74]' : undefined}" "$SH")" = 1 ] || mort "$SH : le lien de navigation n'est pas celui attendu (spec 105b)"
grep -q 'aria-current' "$SH" && mort "$SH marque déjà la page active : lot déjà passé ?"
[ "$(grep -cF 'className="absolute top-2 right-2 bg-white rounded-full w-11 h-11 flex items-center justify-center ml-4"' "$PC")" = 1 ] || mort "$PC : le bouton du cœur n'est pas celui attendu (spec 105c)"
[ -f "$FT" ] || mort "$FT absent"
[ -f tickets/manifest-102.tsv ] && grep -qP '^102m\t' tickets/manifest-102.tsv && [ -f tickets/tests/entete-compte.test.tsx ] || mort "ticket 102m introuvable (manifest-102 ou son test)"
ok "en-tête, carte produit et ticket 102m conformes aux specs"
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
mkdir -p tickets/tests
cat > 'tickets/105b-entete-page-active.md' <<'__VICTO_FIN_0__'
TICKET 105b — l'en-tête marque la rubrique de la page en cours

Modifie `src/components/ui/SiteHeader.tsx`. Le fichier actuel est correct et testé :
les liens de la navigation principale indiquent la page active, rien d'autre ne change.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Aucun autre élément, aucune autre classe de l'en-tête ne change.

## Les quatre changements
1. Si elle n'y est pas déjà, ajoute à la suite des imports existants :
   `import { usePathname } from 'next/navigation';`
2. Au-dessus du composant `SiteHeader`, ajoute cette fonction locale, non exportée,
   recopiée telle quelle (un lien peut être en solde, actif, les deux, ou aucun) :
   ```tsx
   function classeLien(promo: boolean | undefined, actif: boolean): string | undefined {
     if (promo && actif) return 'text-[#FF5A74] font-extrabold underline decoration-2 underline-offset-[10px]';
     if (promo) return 'text-[#FF5A74]';
     if (actif) return 'font-extrabold underline decoration-2 underline-offset-[10px]';
     return undefined;
   }
   ```
3. Au début du corps de `SiteHeader`, ajoute exactement :
   `const chemin: string | null = usePathname();`
4. Dans `<nav aria-label="Navigation principale" …>`, remplace le `navItems.map(…)` actuel
   par exactement :
   ```tsx
   {navItems.map((item) => {
     const actif = chemin !== null && (chemin === item.href || chemin.startsWith(`${item.href}/`));
     return (
       <a key={item.href} href={item.href} aria-current={actif ? 'page' : undefined} className={classeLien(item.promo, actif)}>
         {item.label}
       </a>
     );
   })}
   ```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/entete-v3.test.tsx`
et `tests/finitions-SiteHeader.test.tsx`.
__VICTO_FIN_0__
cat > 'tickets/105c-carte-coeur.md' <<'__VICTO_FIN_1__'
TICKET 105c — le cœur de la carte produit reste dans sa carte

Modifie `src/components/ui/ProductCard.tsx`. Le bouton « Ajouter aux favoris » est en
`absolute top-2 right-2`, mais aucun de ses ancêtres dans la carte n'est positionné :
sur une page, tous les cœurs remontent au coin de l'écran, par-dessus l'en-tête.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Le bouton garde exactement ses classes et son comportement. Aucune autre ligne ne change.

## Le changement
L'élément qui enveloppe **à la fois** le lien `<a>` de la carte et le bouton
« Ajouter aux favoris » (le `<div>` juste au-dessus du bouton) reçoit la classe
`relative` : ajoute `relative` au début de son `className` (s'il n'en a pas, donne-lui
`className="relative"`).

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > 'tickets/manifest-105.tsv' <<'__VICTO_FIN_2__'
105b	src/components/ui/SiteHeader.tsx	tests/entete-page-active.test.tsx	tickets/105b-entete-page-active.md	src/lib/navigation.ts		
105c	src/components/ui/ProductCard.tsx	tests/carte-coeur-position.test.tsx	tickets/105c-carte-coeur.md			
__VICTO_FIN_2__
cat > 'tickets/tests/carte-coeur-position.test.tsx' <<'__VICTO_FIN_3__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ProductCard } from '../src/components/ui/ProductCard';
import type { Produit } from '../src/lib/catalogue';

const P: Produit = {
  id: 'p1', slug: 'air-zoom-pegasus-41', nom: 'Air Zoom Pegasus 41', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12900, variantes: [{ id: 'v1', taille: '42', sku: 'NK-42', stock: 5 }],
};
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('ProductCard — position du cœur', () => {
  it('garde le cœur dans le coin de sa propre carte', () => {
    render(<ProductCard produit={P} />);
    const coeur = screen.getByRole('button', { name: 'Ajouter aux favoris' });
    expect(classes(coeur)).toContain('absolute');
    const ancre = coeur.closest('.relative');
    expect(ancre, 'un ancêtre positionné dans la carte').not.toBeNull();
    expect(ancre?.contains(screen.getByTestId('carte-nom'))).toBe(true);
  });
});
__VICTO_FIN_3__
cat > 'tickets/tests/entete-page-active.test.tsx' <<'__VICTO_FIN_4__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { SiteHeader } from '../src/components/ui/SiteHeader';
import { NAV } from '../src/lib/navigation';

const etat = vi.hoisted(() => ({ chemin: null as string | null }));
vi.mock('next/navigation', async (original) => ({
  ...(await original<typeof import('next/navigation')>()),
  usePathname: () => etat.chemin,
}));

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const lien = (libelle: string) => within(screen.getByRole('navigation', { name: 'Navigation principale' })).getByRole('link', { name: libelle });
const href = (libelle: string) => NAV.find((i) => i.label === libelle)?.href ?? '';
const actifs = () => within(screen.getByRole('navigation', { name: 'Navigation principale' }))
  .queryAllByRole('link').filter((a: HTMLElement) => a.getAttribute('aria-current') === 'page').map((a: HTMLElement) => a.textContent);
const poser = (chemin: string | null) => { etat.chemin = chemin; render(<SiteHeader navItems={NAV} />); };
const TRAIT = ['font-extrabold', 'underline', 'decoration-2', 'underline-offset-[10px]'];

describe('en-tête — rubrique de la page en cours', () => {
  it('marque la rubrique ouverte, et elle seule', () => {
    poser(href('Femme'));
    expect(actifs()).toEqual(['Femme']);
    for (const k of TRAIT) expect(classes(lien('Femme')), `Femme : ${k}`).toContain(k);
    expect(classes(lien('Homme'))).not.toContain('underline');
  });

  it('reste marquée sur une page de la rubrique', () => {
    poser(`${href('Marques')}/nike`);
    expect(actifs()).toEqual(['Marques']);
  });

  it('garde le rouge des soldes, avec le trait quand on y est', () => {
    poser(href('Soldes'));
    for (const k of ['text-[#FF5A74]', ...TRAIT]) expect(classes(lien('Soldes')), `Soldes : ${k}`).toContain(k);
  });

  it('garde les soldes en rouge, sans trait, ailleurs', () => {
    poser(href('Femme'));
    expect(classes(lien('Soldes'))).toContain('text-[#FF5A74]');
    expect(classes(lien('Soldes'))).not.toContain('underline');
  });

  it('ne marque rien hors des rubriques, ni sans chemin', () => {
    poser('/produits/air-zoom-pegasus-41');
    expect(actifs()).toEqual([]);
  });

  it('ne marque rien quand le chemin est inconnu', () => {
    poser(null);
    expect(actifs()).toEqual([]);
  });
});
__VICTO_FIN_4__
TESTS=(carte-coeur-position.test.tsx entete-page-active.test.tsx)
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done

# ------------------------------------------------------------ ancien test des icônes : « Mon compte » par son étiquette
python3 - <<'PYT' || annuler "le test des icônes de l'en-tête n'est ni celui attendu ni sa version assouplie : à regarder avant le lot"
import json, subprocess, sys
ancien = json.loads('"  it.each([\\n    [\'Ouvrir le menu\', \'lucide-menu\'],\\n    [\'Rechercher\', \'lucide-search\'],\\n    [\'Mon compte\', \'lucide-user\'],\\n  ])(\'le bouton \\u00ab %s \\u00bb porte l\\u2019ic\\u00f4ne %s\', (nom, classe) => {\\n    render(<SiteHeader navItems={NAV} />);\\n    expect(screen.getByRole(\'button\', { name: nom }).querySelector(`svg.${classe}`)).not.toBeNull();\\n  });"'); nouveau = json.loads('"  it.each([\\n    [\'Ouvrir le menu\', \'lucide-menu\'],\\n    [\'Rechercher\', \'lucide-search\'],\\n  ])(\'le bouton \\u00ab %s \\u00bb porte l\\u2019ic\\u00f4ne %s\', (nom, classe) => {\\n    render(<SiteHeader navItems={NAV} />);\\n    expect(screen.getByRole(\'button\', { name: nom }).querySelector(`svg.${classe}`)).not.toBeNull();\\n  });\\n\\n  // \\u00ab Mon compte \\u00bb est cherch\\u00e9 par son \\u00e9tiquette : bouton avant le 102m, lien vers /compte apr\\u00e8s.\\n  it(\'\\u00ab Mon compte \\u00bb porte l\\u2019ic\\u00f4ne lucide-user\', () => {\\n    render(<SiteHeader navItems={NAV} />);\\n    expect(screen.getByLabelText(\'Mon compte\').querySelector(\'svg.lucide-user\')).not.toBeNull();\\n  });"')
touches, deja = [], []
for f in subprocess.run(['git', 'ls-files', '*.test.ts', '*.test.tsx'], capture_output=True, text=True).stdout.split():
    s = open(f, encoding='utf-8').read()
    if ancien in s: open(f, 'w', encoding='utf-8').write(s.replace(ancien, nouveau)); touches.append(f)
    elif nouveau in s: deja.append(f)
sys.exit(0 if 'tests/finitions-SiteHeader.test.tsx' in touches + deja else 1)
PYT
restes="$(git ls-files '*.test.ts' '*.test.tsx' | xargs grep -nE "\['Mon compte', 'lucide-user'\]|getByRole\(['\"]button['\"],[[:space:]]*\{[[:space:]]*name:[[:space:]]*['\"]Mon compte['\"]" 2>/dev/null || true)"
[ -z "$restes" ] || { echo "$restes"; annuler "un test cherche encore « Mon compte » comme un bouton"; }
ok "ancien test des icônes assoupli : « Mon compte » trouvé par son étiquette"
ok "$(wc -l < tickets/manifest-105.tsv) tickets écrits, manifeste tickets/manifest-105.tsv"

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/105*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-105.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
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
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges après assouplissement de l'ancien test"; }
ok "base verte"
git add -A -- tickets tests
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "chore(tickets): lot 105 — page active, cœur des cartes, test des icônes assoupli"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi


# ------------------------------------------------------------ 102m : reprendre le code du modèle, si c'est sûr
RELANCE_102M=0
if fusionne 102m; then
  ok "102m déjà fusionné"
else
  git rev-parse -q --verify auto/102m >/dev/null || GIT_TERMINAL_PROMPT=0 git fetch -q origin auto/102m:auto/102m 2>/dev/null || true
  if ! git rev-parse -q --verify auto/102m >/dev/null; then
    info "branche auto/102m introuvable : le 102m sera relancé"; RELANCE_102M=1
  elif [ "$(git diff --name-only main...auto/102m | sort | tr '\n' ' ')" != "$SH tests/entete-compte.test.tsx " ]; then
    info "auto/102m touche d'autres fichiers que l'en-tête : le 102m sera relancé"; RELANCE_102M=1
  elif ! git diff --quiet "$(git merge-base main auto/102m)" main -- "$SH"; then
    info "l'en-tête a changé sur main depuis la branche : le 102m sera relancé sur la version actuelle"; RELANCE_102M=1
  else
    git checkout -q -b verif/102m main
    git checkout auto/102m -- "$SH"
    cp tickets/tests/entete-compte.test.tsx tests/entete-compte.test.tsx
    git add -- "$SH" tests/entete-compte.test.tsx
    git commit -q -m "chore(102m): code du modèle repris de auto/102m"
    PORTE=/tmp/victo-porte-102m.log; : > "$PORTE"; vert=1
    npm run --silent typecheck >>"$PORTE" 2>&1 || vert=0
    [ "$vert" = 1 ] && { npm run --silent test >>"$PORTE" 2>&1 || vert=0; }
    [ "$vert" = 1 ] && grep -q '"build"' package.json && { npm run --silent build >>"$PORTE" 2>&1 || vert=0; }
    git checkout -q main
    if [ "$vert" = 1 ]; then
      git merge --no-ff -q verif/102m -m "feat(102m): fusionné au vert par le harnais"
      { npm run --silent typecheck && npm run --silent test && { ! grep -q '"build"' package.json || npm run --silent build; }; } >/tmp/victo-apres.log 2>&1 \
        || { grep -E "error TS|FAIL|×|→" /tmp/victo-apres.log | head; git reset -q --hard HEAD~1; git branch -q -D verif/102m; mort "main rouge après la fusion du 102m : fusion annulée"; }
      git branch -q -D verif/102m auto/102m
      GIT_TERMINAL_PROMPT=0 git push -q origin --delete auto/102m 2>/dev/null || true
      ok "102m : code du modèle vert (tsc, tests, build), fusionné — « Mon compte » mène à /compte"
    else
      info "102m : porte ROUGE avec le code de la branche. Échecs :"
      grep -E "error TS|×|→" "$PORTE" | sed -E 's/\x1b\[[0-9;]*m//g' | sort -u | head -6 | sed 's/^/      /'
      git branch -q -D verif/102m; RELANCE_102M=1
    fi
  fi
fi
if [ "$RELANCE_102M" = 1 ]; then
  { grep -P '^102m\t' tickets/manifest-102.tsv; awk -F'\t' 'BEGIN{OFS="\t"} $1=="105b"{$6="102m"} {print}' tickets/manifest-105.tsv; } > /tmp/victo-m105 && mv /tmp/victo-m105 tickets/manifest-105.tsv
  git add tickets/manifest-105.tsv; git commit -q -m "chore(tickets): lot 105 — 102m relancé avant la page active"
  ok "manifeste : 102m, puis 105b (qui en dépend), et 105c"
fi
[ -z "$(git status --porcelain)" ] || mort "arbre sale en fin de script : $(git status --porcelain | head -3)"
GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log || info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-105.tsv ./run.sh\n\nTickets : %s. Compte %s.\n' "$(cut -f1 tickets/manifest-105.tsv | tr '\n' ' ')" "$([ "$RELANCE_102M" = 1 ] && echo 'environ une heure' || echo '30 à 45 minutes')"
