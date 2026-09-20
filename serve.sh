#!/usr/bin/env bash
# VICTO STORE — serveur de prévisualisation suivant main.
#
# Tourne en continu dans son propre tmux. Surveille le SHA de main et relance
# `next dev` dès qu'un ticket est fusionné par le harnais. Tu gardes le
# navigateur ouvert, la page se met à jour toute seule à chaque ticket vert.
#
# Usage :  tmux new -s serve  puis  ./serve.sh
set -uo pipefail

REPO="${REPO:-$PWD}"
PORT="${PORT:-3000}"
HOTE="${HOTE:-0.0.0.0}"
INTERVALLE="${INTERVALLE:-10}"

cd "$REPO" || exit 2
DEV_PID=""

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

arreter() {
  [ -n "$DEV_PID" ] || return 0
  log "arrêt du serveur (pid $DEV_PID)"
  kill "$DEV_PID" 2>/dev/null
  wait "$DEV_PID" 2>/dev/null
  DEV_PID=""
}

demarrer() {
  log "démarrage sur http://$HOTE:$PORT"
  npm run dev -- -H "$HOTE" -p "$PORT" &
  DEV_PID=$!
}

trap 'arreter; exit 0' INT TERM

# On travaille sur une copie du dépôt : le harnais change de branche en
# permanence dans ~/victo-store, et un serveur qui suit ces bascules afficherait
# du code de branche calée. Ici on ne voit que main.
MIROIR="${MIROIR:-$HOME/victo-preview}"
if [ ! -d "$MIROIR/.git" ]; then
  log "création du miroir $MIROIR"
  git clone -q "$REPO" "$MIROIR" -b main
  ln -sfn "$REPO/node_modules" "$MIROIR/node_modules"
fi
cd "$MIROIR"

SHA=""
while true; do
  git fetch -q origin main 2>/dev/null || git fetch -q "$REPO" main 2>/dev/null
  NOUVEAU="$(git rev-parse FETCH_HEAD 2>/dev/null || git rev-parse origin/main)"

  if [ "$NOUVEAU" != "$SHA" ]; then
    log "main a bougé : ${SHA:0:7} → ${NOUVEAU:0:7}"
    arreter
    git reset -q --hard "$NOUVEAU"
    SHA="$NOUVEAU"
    log "$(git log -1 --pretty='%s')"
    demarrer
  fi

  sleep "$INTERVALLE"
done
