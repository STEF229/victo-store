#!/usr/bin/env bash
# VICTO STORE — installation du lot catalogue (tickets 030 à 037).
# À lancer depuis le dossier du lot, avec le dépôt en argument.
set -euo pipefail
REPO="${1:-$HOME/victo-store}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ -d "$REPO/.git" ] || { echo "Dépôt introuvable : $REPO"; exit 1; }
cd "$REPO"
git checkout -q --force main
[ -z "$(git status --porcelain)" ] || { echo "Arbre sale, commit ou stash d'abord"; exit 1; }

mkdir -p src/components/catalogue src/app/boutique tickets/tests
cp "$SRC"/tickets/*.md                tickets/
cp "$SRC"/tickets/manifest-catalogue.tsv tickets/
cp "$SRC"/tickets/tests/*             tickets/tests/

echo "==> vérification de la base"
npm run --silent typecheck
npm run --silent test
echo "==> base verte, $(grep -vc '^#' tickets/manifest-catalogue.tsv) tickets prêts"

git add -A
git commit -q -m "chore: lot catalogue (tickets 030-037)"
git remote get-url origin >/dev/null 2>&1 && GIT_TERMINAL_PROMPT=0 git push -q origin main || true

cat <<'TXT'

Lancement :
    tmux attach -t ds     (ou tmux new -s ds)
    cd ~/victo-store && MANIFEST=tickets/manifest-catalogue.tsv ./run.sh

La page sera sur http://192.168.40.32:3000/boutique une fois le 037 vert.
TXT
