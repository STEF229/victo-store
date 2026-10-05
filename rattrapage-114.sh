#!/usr/bin/env bash
# VICTO STORE — rattrapage du 114j (filtres : tailles du catalogue du site).
# Cause : la spec remplaçait UNE ligne d'import par DEUX ; le modèle n'a écrit que la seconde
# (import de taillesDe) et a oublié l'import de useCatalogue → « Cannot find name 'useCatalogue' ».
# Le reste de son code est juste. Ce script reprend son code (auto/114j), y ajoute exactement la ligne
# prévue par la spec, et lui fait passer la porte complète (tsc, tests, build) : vert → fusionné ;
# rouge → le 114j est relancé, avec une spec qui insiste sur les deux lignes.
# Usage :  cd ~/victo-store && bash rattrapage-114.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
info(){ printf '  \033[33m!\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }
annuler(){ git checkout -q -f main; git reset -q --hard "$DEPART"; git clean -fdq -- tests tickets
           git branch -q -D verif/114j 2>/dev/null || true; mort "$*  — rien n'a été modifié"; }
CIBLE=src/components/catalogue/VueCatalogue.tsx; T=tests/bascule-components-catalogue-VueCatalogue.test.ts; TT=tickets/tests/bascule-components-catalogue-VueCatalogue.test.ts
IMPORT="import { useCatalogue } from '@/components/catalogue/CatalogueProvider';"

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
modifies="$(git ls-files -m -- '*.tsbuildinfo')"
[ -z "$modifies" ] || git checkout -q -- $modifies
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase=merges || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
DEPART="$(git rev-parse HEAD)"
ok "main à jour ($(git rev-parse --short HEAD))"
fusionne(){ git log main -1 --format=%h --fixed-strings --grep="feat($1): fusionné" | grep -q .; }
fusionne 114j && { ok "114j déjà fusionné : rien à faire"; exit 0; }
for d in 114a 114b; do fusionne "$d" || mort "$d n'est pas fusionné : le 114j s'appuie dessus"; done

SAUVETAGE=0
git rev-parse -q --verify auto/114j >/dev/null || GIT_TERMINAL_PROMPT=0 git fetch -q origin auto/114j:auto/114j 2>/dev/null || true
if git rev-parse -q --verify auto/114j >/dev/null \
   && [ "$(git diff --name-only main...auto/114j | sort | tr '\n' ' ')" = "$CIBLE $T " ] \
   && git show "auto/114j:$CIBLE" | grep -qF "const catalogue = useCatalogue();" \
   && git show "auto/114j:$CIBLE" | grep -qF "import { taillesDe } from '@/lib/donnees';" \
   && ! git show "auto/114j:$CIBLE" | grep -qF "$IMPORT"; then
  SAUVETAGE=1; ok "auto/114j : code du modèle conforme, seul l'import de useCatalogue manque"
else
  info "auto/114j absente ou différente de l'attendu : le 114j sera relancé"
fi
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR

if [ "$SAUVETAGE" = 1 ]; then
  git checkout -q -b verif/114j main
  git checkout auto/114j -- "$CIBLE"
  python3 - "$CIBLE" <<'PY'
import sys
p = sys.argv[1]; s = open(p, encoding='utf-8').read()
ligne = "import { taillesDe } from '@/lib/donnees';"
assert s.count(ligne) == 1
s = s.replace(ligne, "import { useCatalogue } from '@/components/catalogue/CatalogueProvider';\n" + ligne)
open(p, 'w', encoding='utf-8').write(s)
PY
  mkdir -p tests; git show "main:$TT" > "$T"
  git add -- "$CIBLE" "$T"; git commit -q -m "chore(114j): code du modèle repris de auto/114j ; import de useCatalogue ajouté comme le prévoit la spec"
  PORTE=/tmp/victo-porte-114j.log; : > "$PORTE"; vert=1
  npm run --silent typecheck >>"$PORTE" 2>&1 || vert=0
  [ "$vert" = 1 ] && { npm run --silent test >>"$PORTE" 2>&1 || vert=0; }
  [ "$vert" = 1 ] && grep -q '"build"' package.json && { npm run --silent build >>"$PORTE" 2>&1 || vert=0; }
  git checkout -q main
  if [ "$vert" = 1 ]; then
    git merge --no-ff -q verif/114j -m "feat(114j): fusionné au vert par le harnais" || annuler "fusion impossible"
    { npm run --silent typecheck && npm run --silent test && { ! grep -q '"build"' package.json || npm run --silent build; }; } >/tmp/victo-apres.log 2>&1 \
      || { grep -E "error TS|FAIL|×|→" /tmp/victo-apres.log | head; annuler "main rouge après la fusion"; }
    git branch -q -D verif/114j auto/114j
    GIT_TERMINAL_PROMPT=0 git push -q origin --delete auto/114j 2>/dev/null || true
    trap - ERR
    GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log && ok "poussé sur GitHub" || info "push refusé (voir /tmp/victo-push.log)"
    ok "114j : porte verte (tsc, tests, build), fusionné — le lot 114 est complet"
    exit 0
  fi
  info "porte ROUGE, rien n'est fusionné. Échecs :"
  grep -E "error TS|×|→" "$PORTE" | sed -E 's/\x1b\[[0-9;]*m//g' | sort -u | head -6 | sed 's/^/      /'
  git branch -q -D verif/114j auto/114j
  GIT_TERMINAL_PROMPT=0 git push -q origin --delete auto/114j 2>/dev/null || true
fi

# ------------------------------------------------------------ relance du 114j, spec plus explicite
cat > tickets/114j-components-catalogue-VueCatalogue.md <<'__VICTO_SPEC__'
TICKET 114j — les filtres proposent les tailles du catalogue du site

Modifie `src/components/catalogue/VueCatalogue.tsx`. Les tailles proposées par le filtre viennent de `useCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique) — attention : l'« après » fait DEUX lignes, écris les deux
Avant :
```tsx
import { taillesCatalogue } from '@/lib/donnees';
```
Après :
```tsx
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
import { taillesDe } from '@/lib/donnees';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const [criteres, setCriteres] = useState<Criteres>({});
```
Après :
```tsx
  const catalogue = useCatalogue();
  const [criteres, setCriteres] = useState<Criteres>({});
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
tailles={taillesCatalogue()}
```
Après :
```tsx
tailles={taillesDe(catalogue.produits)}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_SPEC__
grep -P '^114j\t' tickets/manifest-114.tsv > tickets/manifest-rattrapage-114.tsv || annuler "114j absent du manifeste du lot 114"
git add tickets/114j-components-catalogue-VueCatalogue.md tickets/manifest-rattrapage-114.tsv
git diff --cached --quiet || git commit -q -m "chore(tickets): relance du 114j, spec explicite sur les deux lignes d'import"
trap - ERR
GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log && ok "poussé sur GitHub" || info "push refusé (voir /tmp/victo-push.log)"
printf '\nÀ relancer :\n\n    MANIFEST=tickets/manifest-rattrapage-114.tsv ./run.sh\n'
