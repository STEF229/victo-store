#!/usr/bin/env bash
# =============================================================================
# VICTO STORE — installation du dépôt applicatif.
#
# Une seule commande. Idempotent. Auto-vérifiant.
# Chaque bloc marqué [LEÇON] corrige une erreur constatée lors du premier build.
#
# Usage :  ./install.sh [depot_cible] [ip_lan]
#          ./install.sh ~/victo-store 192.168.40.32
# =============================================================================
set -uo pipefail

REPO="${1:-$HOME/victo-store}"
IP_LAN="${2:-192.168.40.32}"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
act()  { printf '  \033[33m→\033[0m %s\n' "$*"; }
etape(){ printf '\n\033[1m== %s\033[0m\n' "$*"; }
mort() { printf '  \033[31m✗\033[0m %s\n' "$*"; echo; echo "ARRÊT."; exit 1; }

etape "0/7  Pré-requis"
command -v node >/dev/null || mort "node absent"
command -v npm  >/dev/null || mort "npm absent"
command -v git  >/dev/null || mort "git absent"
command -v aider >/dev/null || mort "aider absent du PATH (pipx ensurepath, puis ~/.bashrc)"
NODE_MAJ="$(node -v | sed 's/v\([0-9]*\).*/\1/')"
[ "$NODE_MAJ" -ge 20 ] || mort "Node $NODE_MAJ trop ancien (20.19+ requis)"
ok "node $(node -v), npm $(npm -v), aider $(aider --version 2>/dev/null | head -1)"

# [LEÇON] L'identité git doit être globale : Aider commite lui-même, et un
# template LXC nu n'en a pas. Sans ça, le premier ticket échoue au commit.
git config --global user.name  >/dev/null 2>&1 || git config --global user.name "VICTO harnais"
git config --global user.email >/dev/null 2>&1 || git config --global user.email "harnais@victo.local"
ok "identité git configurée"

etape "1/7  Arborescence"
mkdir -p "$REPO"/{src/lib,src/components/ui,src/styles,src/app,tests,tickets/tests,public/img,.logs}
cd "$REPO" || mort "impossible d'entrer dans $REPO"
ok "$REPO"

etape "2/7  Dépendances"
# [LEÇON] Versions épinglées. @types/node est obligatoire dès le départ : un test
# qui lit un fichier avec node:fs échoue sinon, et le modèle ne peut pas corriger
# une erreur qui pointe un fichier de test.
cat > package.json <<'EOF'
{
  "name": "victo-store",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "typecheck": "tsc --noEmit",
    "test": "vitest run",
    "tokens": "node scripts/generer-tokens.mjs"
  },
  "dependencies": {
    "next": "15.5.0",
    "react": "19.1.0",
    "react-dom": "19.1.0"
  },
  "devDependencies": {
    "@tailwindcss/postcss": "4.1.11",
    "@testing-library/jest-dom": "6.6.3",
    "@testing-library/react": "16.1.0",
    "@types/node": "22.10.2",
    "@types/react": "19.1.0",
    "@types/react-dom": "19.1.0",
    "@vitejs/plugin-react": "4.3.4",
    "jsdom": "25.0.1",
    "tailwindcss": "4.1.11",
    "typescript": "5.6.3",
    "vitest": "2.1.9"
  }
}
EOF
ok "package.json (versions épinglées)"

etape "3/7  Configuration"
# [LEÇON] "types" restreint ce que TypeScript charge : omettre "node" exclut
# @types/node. [LEÇON] "paths" déclare l'alias @/ que le modèle utilise
# spontanément, c'est la convention Next — mieux vaut la servir que la combattre.
cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "jsx": "react-jsx",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noEmit": true,
    "skipLibCheck": true,
    "baseUrl": ".",
    "paths": { "@/*": ["./src/*"] },
    "types": ["node", "vitest/globals", "@testing-library/jest-dom"]
  },
  "include": ["src", "tests", "scripts", "vitest.setup.ts", "next.config.ts"],
  "exclude": ["node_modules", ".next"]
}
EOF
ok "tsconfig.json (types node + alias @/)"

# [LEÇON] L'alias doit exister des DEUX côtés : tsc et vitest résolvent
# séparément. Sans le bloc resolve, les tests cassent là où tsc passe.
cat > vitest.config.ts <<'EOF'
import { fileURLToPath } from 'node:url';
import react from '@vitejs/plugin-react';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: { '@': fileURLToPath(new URL('./src', import.meta.url)) },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./vitest.setup.ts'],
    include: ['tests/**/*.test.ts', 'tests/**/*.test.tsx'],
    reporters: ['basic'],
  },
});
EOF
cat > vitest.setup.ts <<'EOF'
import '@testing-library/jest-dom/vitest';
EOF
ok "vitest.config.ts (alias @/ + jsdom)"

# [LEÇON] SANS CE FICHIER, TAILWIND NE S'APPLIQUE JAMAIS. Next compile la CSS
# sans passer par Tailwind, la page s'affiche en HTML brut et rien ne le signale.
cat > postcss.config.mjs <<'EOF'
export default { plugins: { '@tailwindcss/postcss': {} } };
EOF
ok "postcss.config.mjs  ← la config dont l'absence tue tous les styles"

cat > next.config.ts <<EOF
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  allowedDevOrigins: ['$IP_LAN'],
};

export default nextConfig;
EOF
ok "next.config.ts (accès depuis $IP_LAN)"

cat > .aider.model.settings.yml <<'EOF'
- name: ollama_chat/qwen3-coder-ctx
  edit_format: whole
  use_repo_map: false
  extra_params:
    num_ctx: 16384
EOF
ok ".aider.model.settings.yml (num_ctx figé, pas de reload à froid)"

cat > .gitignore <<'EOF'
node_modules/
.logs/
.next/
.aider*
!.aider.model.settings.yml
.env
.env.*
!.env.example
EOF
cat > src/global.d.ts <<'EOF'
declare module '*.css';
EOF
ok ".gitignore, global.d.ts"

etape "4/7  Coquille applicative"
# [LEÇON] tokens.css est DÉRIVÉ de tokens.ts. Un script le régénère, il n'est
# jamais écrit à la main : deux sources de vérité finissent toujours par diverger.
mkdir -p scripts
cat > scripts/generer-tokens.mjs <<'EOF'
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';

const src = readFileSync('src/lib/tokens.ts', 'utf8');
const bloc = src.match(/TOKENS\s*=\s*\{([\s\S]*?)\}\s*as const/);
if (!bloc) {
  console.error('TOKENS introuvable dans src/lib/tokens.ts');
  process.exit(1);
}
const paires = [...bloc[1].matchAll(/["']?(--vs-[a-z-]+)["']?\s*:\s*(?:"([^"]*)"|'([^']*)')/g)]
  .map((m) => [m[1], m[2] !== undefined ? m[2] : m[3]]);
if (paires.length < 10) {
  console.error(`tokens incomplets : ${paires.length} trouvés`);
  process.exit(1);
}
mkdirSync('src/styles', { recursive: true });
writeFileSync(
  'src/styles/tokens.css',
  ':root {\n' + paires.map(([k, v]) => `  ${k}: ${v};`).join('\n') + '\n}\n',
);
console.log(`${paires.length} tokens → src/styles/tokens.css`);
EOF

# Fichier d'amorce : remplacé par le script dès que le ticket 010 est vert.
cat > src/styles/tokens.css <<'EOF'
:root {
  --vs-noir: #101014;
  --vs-blanc: #FFFFFF;
  --vs-surface: #F5F5F3;
  --vs-ligne: #E5E5E1;
  --vs-gris: #6B6B70;
  --vs-accent: #0B41CD;
  --vs-accent-fonce: #082F94;
  --vs-promo: #E4002B;
  --vs-font-display: 'Archivo', system-ui, sans-serif;
  --vs-maxw: 1220px;
  --vs-radius: 6px;
}
EOF

cat > src/app/globals.css <<'EOF'
@import "tailwindcss";
@import "../styles/tokens.css";

body {
  background: var(--vs-blanc);
  color: var(--vs-noir);
  font-family: var(--vs-font-display);
  -webkit-font-smoothing: antialiased;
}
EOF

# [LEÇON] suppressHydrationWarning : les extensions de navigateur (LanguageTool,
# Grammarly) injectent des attributs dans <html> et déclenchent une fausse alerte
# d'hydratation qui fait perdre du temps en diagnostic.
cat > src/app/layout.tsx <<'EOF'
import type { ReactNode } from 'react';
import './globals.css';

export const metadata = {
  title: 'VICTO STORE',
  description: 'Des grandes marques, au bon prix.',
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="fr" suppressHydrationWarning>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          href="https://fonts.googleapis.com/css2?family=Archivo:wght@400;500;600;700;800;900&display=swap"
          rel="stylesheet"
        />
      </head>
      <body>{children}</body>
    </html>
  );
}
EOF

cat > src/app/page.tsx <<'EOF'
export default function Accueil() {
  return <main className="p-10">VICTO STORE — voir /design</main>;
}
EOF

# [LEÇON] Visuels présents dès le départ : des 404 d'images font croire à un bug.
for f in pegasus chuck70 polo; do
  cat > "public/img/$f.svg" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 500">
  <rect width="400" height="500" fill="#F5F5F3"/>
  <text x="200" y="250" text-anchor="middle" font-family="Archivo, sans-serif"
        font-size="18" fill="#A6A6A0">$f</text>
</svg>
EOF
done
ok "layout, globals.css, page d'accueil, 3 visuels"

# [LEÇON] Test fumigène qui couvre React + jsdom + l'alias @/. S'il échoue, c'est
# la config, jamais le modèle — et on le sait AVANT de lancer la boucle.
cat > tests/smoke.test.tsx <<'EOF'
import { render, screen } from '@testing-library/react';
import { expect, it } from 'vitest';
import { readFileSync } from 'node:fs';

function Hello({ nom }: { nom: string }) {
  return <p>Bonjour {nom}</p>;
}

it('React et jsdom fonctionnent', () => {
  render(<Hello nom="VICTO" />);
  expect(screen.getByText('Bonjour VICTO')).toBeInTheDocument();
});

it('node:fs est typé et lisible', () => {
  expect(readFileSync('package.json', 'utf8')).toContain('victo-store');
});

it('Tailwind est branché sur PostCSS', () => {
  expect(readFileSync('postcss.config.mjs', 'utf8')).toContain('@tailwindcss/postcss');
});
EOF
ok "tests/smoke.test.tsx (React, node:fs, PostCSS)"

etape "5/7  Harnais et tickets"
if [ "$SRC_DIR" != "$REPO" ]; then
  for f in run.sh serve.sh; do
    cp "$SRC_DIR/$f" . || mort "$f introuvable dans $SRC_DIR"
  done
  cp "$SRC_DIR"/tickets/*.md          tickets/       || mort "tickets absents"
  cp "$SRC_DIR"/tickets/manifest.tsv  tickets/       || mort "manifeste absent"
  cp "$SRC_DIR"/tickets/tests/*       tickets/tests/ || mort "tests absents"
else
  act "kit déjà en place dans le dépôt, aucune copie"
fi
chmod +x run.sh serve.sh
for f in run.sh serve.sh tickets/manifest.tsv; do
  [ -f "$f" ] || mort "$f manquant"
done
[ "$(ls tickets/*.md 2>/dev/null | wc -l)" -ge 14 ] || mort "tickets incomplets"
[ "$(ls tickets/tests/* 2>/dev/null | wc -l)" -ge 14 ] || mort "tests incomplets"

# [LEÇON] Les tests attendent hors du périmètre de la porte. Un test dont le
# composant n'existe pas encore ferait échouer TOUS les autres tickets.
n=$(grep -vc '^#' tickets/manifest.tsv)
ok "run.sh, serve.sh, $n tickets, $(ls tickets/tests | wc -l) fichiers de tests en attente"

etape "6/7  Installation et porte"
npm install --no-fund --no-audit >/tmp/victo-npm.log 2>&1 || { tail -20 /tmp/victo-npm.log; mort "npm install a échoué"; }
ok "npm install"

npm run --silent typecheck || mort "tsc échoue sur la coquille — anomalie, signale-la"
ok "tsc --noEmit"
npm run --silent test || mort "vitest échoue sur le fumigène — c'est la config, pas le modèle"
ok "vitest (3 tests fumigènes)"
npm run --silent build >/tmp/victo-build.log 2>&1 || { tail -25 /tmp/victo-build.log; mort "next build échoue"; }
ok "next build"

# [LEÇON] Vérification que Tailwind produit VRAIMENT du CSS. C'est le contrôle
# qui manquait : la porte peut être verte et la page sans aucun style.
CSS="$(find .next -name '*.css' 2>/dev/null | head -1)"
[ -n "$CSS" ] || mort "aucune feuille CSS produite par le build"
grep -q -- '--vs-accent' "$CSS" || mort "les tokens ne sont pas dans le CSS compilé"
grep -qE 'display:flex|\.flex|padding' "$CSS" || mort "Tailwind ne compile pas les utilitaires"
ok "CSS compilé : tokens + utilitaires Tailwind présents"

etape "7/7  Dépôt git"
if [ ! -d .git ]; then
  git init -q -b main
  git add -A
  git commit -q -m "chore: squelette VICTO STORE (porte a 3 barreaux, 14 tickets)"
  ok "dépôt initialisé sur main"
else
  git add -A
  git diff --cached --quiet || git commit -q -m "chore: mise a jour du squelette"
  ok "dépôt existant mis à jour"
fi

cat <<EOF

════════════════════════════════════════════════════════════════
  INSTALLATION VALIDÉE — tout est vert avant le premier ticket.
════════════════════════════════════════════════════════════════

1. Dépôt distant (facultatif mais recommandé) :

     ssh-keygen -t ed25519 -C victo -N "" -f ~/.ssh/id_ed25519
     cat ~/.ssh/id_ed25519.pub     # → GitHub, Deploy key, écriture
     cd $REPO
     git remote add origin git@github.com:STEF229/victo-store.git
     GIT_TERMINAL_PROMPT=0 git push -u origin main

2. Prévisualisation en direct, dans son propre tmux :

     tmux new -s serve
     cd $REPO && ./serve.sh        # Ctrl-b d pour détacher

3. La boucle, dans un autre tmux :

     tmux new -s ds
     cd $REPO && ./run.sh          # ajouter GIT_REMOTE="" si pas de distant

   Snapshot Proxmox de la LXC avant, par précaution.

4. Le site :  http://$IP_LAN:3000/design

Compte 2 à 4 h pour les 14 tickets. La page se met à jour seule à
chaque fusion. Statuts possibles : VERT, CALÉ, TIMEOUT, TRICHE,
BLOQUÉ (dépendance amont calée), TEST_SUSPECT (erreur dans MES
tests, pas dans le code du modèle — dans ce cas, envoie-moi le log).
EOF
