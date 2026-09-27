#!/usr/bin/env bash
# VICTO STORE — rattrapage du 100c (ligne du panier), puis de la vue et de la page panier.
#
# Cause : le test cherchait le prix barré avec getByText(formatPrice(…)). formatPrice
# met une espace insécable, que getByText normalise dans la page mais pas dans le
# motif : le test ne pouvait jamais passer. Le code du modèle n'est pas en cause.
#   1. test corrigé (lecture par textContent) ; le contrôle refuse désormais ByText + formatPrice ;
#   2. le code du modèle, resté sur auto/100c, passe la porte complète avec ce test :
#      vert → fusionné, restent 100e et 100f ; rouge → 100c repart avec eux.
# Usage :  cd ~/victo-store && bash rattrapage-100.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
info(){ printf '  \033[33m!\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }
annuler(){ git checkout -q -f main; git reset -q --hard "$DEPART"; git clean -fdq -- tests tickets outils
           git branch -q -D verif/100c 2>/dev/null || true; mort "$*  — rien n'a été modifié"; }
CIBLE=src/components/panier/LignePanier.tsx
T=tests/LignePanier.test.tsx
TT=tickets/tests/LignePanier.test.tsx

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
modifies="$(git ls-files -m -- '*.tsbuildinfo')"
[ -z "$modifies" ] || git checkout -q -- $modifies
if [ -f "$CIBLE" ] && ! git ls-files --error-unmatch "$CIBLE" >/dev/null 2>&1; then
  [ -s "$CIBLE" ] && mort "$CIBLE existe hors suivi git et n'est pas vide : je n'y touche pas"
  rm -f "$CIBLE"; ok "cible vide laissée par le run retirée du disque"
fi
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase=merges || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
DEPART="$(git rev-parse HEAD)"
ok "main à jour ($(git rev-parse --short HEAD))"

fusionne(){ git log main -1 --format=%h --fixed-strings --grep="feat($1): fusionné" | grep -q .; }
for d in 100a 100b 100d; do fusionne "$d" || mort "$d n'est pas fusionné : ce rattrapage suppose le run du 27 septembre"; done
fusionne 100f && mort "100f est déjà fusionné : rien à rattraper"
[ -f tickets/manifest-100.tsv ] || mort "tickets/manifest-100.tsv absent"
SAUVETAGE=0
if ! fusionne 100c; then
  git rev-parse -q --verify auto/100c >/dev/null || GIT_TERMINAL_PROMPT=0 git fetch -q origin auto/100c:auto/100c \
    || mort "branche auto/100c introuvable, ni en local ni sur GitHub"
  touches="$(git diff --name-only main...auto/100c | sort | tr '\n' ' ')"
  [ "$touches" = "$CIBLE $T " ] || mort "auto/100c ne contient pas ce que le journal décrivait : $touches"
  git show "auto/100c:$T" | cmp -s - "$TT" || mort "le test de auto/100c diffère du test en attente : branche suspecte"
  SAUVETAGE=1
  ok "auto/100c : ligne du modèle à sa place, test intact"
else
  ok "100c déjà fusionné : restent la vue et la page"
fi
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
cat > tickets/tests/LignePanier.test.tsx <<'__VICTO_FIN_0__'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { LignePanier } from '../src/components/panier/LignePanier';
import { hrefProduit, type Produit } from '../src/lib/catalogue';
import { formatPrice } from '../src/lib/formatPrice';
import type { LigneDetaillee } from '../src/lib/panier-detail';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
function porte(el: Element, chaine: string) {
  const nom = el.getAttribute('aria-label') ?? el.getAttribute('data-testid') ?? el.textContent;
  for (const k of chaine.split(' ')) expect(classes(el), `${nom} : classe ${k} manquante`).toContain(k);
}
const SIMPLE: Produit = {
  id: 'p1', slug: 'pegasus', nom: 'Pegasus', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12600, categorie: 'chaussures',
  variantes: [{ id: 'v42', taille: '42', sku: 'peg-42', stock: 2 }],
};
const PROMO: Produit = { ...SIMPLE, prixCompareCents: 18000 };
function ligne(produit: Produit, quantite: number): LigneDetaillee {
  const variante = { id: 'v42', taille: '42', sku: 'peg-42', stock: 2 };
  return { slug: produit.slug, sku: 'peg-42', quantite, produit, variante, totalCents: produit.prixCents * quantite, economieCents: 0 };
}
function poser(l: LigneDetaillee) {
  const onQuantite = vi.fn();
  const onRetirer = vi.fn();
  render(<ul><LignePanier ligne={l} onQuantite={onQuantite} onRetirer={onRetirer} /></ul>);
  return { onQuantite, onRetirer };
}
const bouton = (nom: string) => screen.getByRole('button', { name: nom });
// Le prix barré est lu par textContent : formatPrice met une espace insécable, que
// getByText normalise dans la page mais pas dans le motif cherché.
const prixBarre = () => screen.getByTestId('ligne-panier').querySelector('s');

describe('LignePanier — contenu', () => {
  it('affiche marque, nom, pointure, prix remisé, prix barré et total', () => {
    poser(ligne(PROMO, 2));
    expect(screen.getByText('Nike')).toBeInTheDocument();
    expect(screen.getByTestId('ligne-pointure').textContent).toBe('Pointure 42');
    expect(screen.getByTestId('ligne-prix').textContent).toBe(formatPrice(12600));
    porte(screen.getByTestId('ligne-prix'), 'text-[var(--vs-promo)]');
    expect(prixBarre()?.textContent).toBe(formatPrice(18000));
    expect(screen.getByTestId('ligne-total').textContent).toBe(formatPrice(25200));
    expect(screen.getByTestId('ligne-quantite').textContent).toBe('2');
  });

  it('affiche un prix simple hors promotion', () => {
    poser(ligne(SIMPLE, 1));
    porte(screen.getByTestId('ligne-prix'), 'text-[var(--vs-noir)]');
    expect(prixBarre()).toBeNull();
  });

  it('relie l’image et le nom à la fiche produit', () => {
    poser(ligne(SIMPLE, 1));
    const liens = screen.getAllByRole('link');
    expect(liens.map((l: HTMLElement) => l.getAttribute('href'))).toEqual([hrefProduit(SIMPLE), hrefProduit(SIMPLE)]);
    expect(screen.getAllByRole('link', { name: 'Pegasus' })).toHaveLength(2);
  });

  it('signale un stock bas', () => {
    poser(ligne(SIMPLE, 1));
    expect(screen.getByTestId('ligne-stock-bas').textContent).toBe('Plus que 2 paires en 42');
  });
});

describe('LignePanier — actions', () => {
  it('bloque la baisse à 1 et la hausse au stock', () => {
    const { unmount } = render(<ul><LignePanier ligne={ligne(SIMPLE, 1)} onQuantite={() => {}} onRetirer={() => {}} /></ul>);
    expect(bouton('Diminuer la quantité')).toBeDisabled();
    porte(bouton('Diminuer la quantité'), 'text-[#B5B5BA]');
    expect(bouton('Augmenter la quantité')).not.toBeDisabled();
    unmount();
    poser(ligne(SIMPLE, 2));
    expect(bouton('Augmenter la quantité')).toBeDisabled();
    expect(bouton('Diminuer la quantité')).not.toBeDisabled();
  });

  it('remonte la nouvelle quantité, le stock et le retrait', () => {
    const f = poser(ligne(SIMPLE, 2));
    fireEvent.click(bouton('Diminuer la quantité'));
    expect(f.onQuantite).toHaveBeenCalledWith('peg-42', 1, 2);
    fireEvent.click(bouton('Retirer'));
    expect(f.onRetirer).toHaveBeenCalledWith('peg-42');
  });
});
__VICTO_FIN_0__
cat > outils/controle-lot.py <<'__VICTO_FIN_1__'
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
        # piège : className lu dans un test — sur un SVG ce n'est pas une chaîne (ticket 095c)
        if '.className' in l:
            alerte(f, 'className', f"ligne {n} : lire getAttribute('class'), className d'un SVG n'est pas une chaîne")
        # piège : prix cherché par texte — formatPrice met une espace insécable que
        # getByText normalise dans la page mais pas dans le motif (ticket 100c)
        if 'ByText(' in l and 'formatPrice' in l:
            alerte(f, 'insécable', f'ligne {n} : prix cherché par ByText ; lire .textContent et comparer à formatPrice')
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
    # piège : noUncheckedIndexedAccess cité sans dire comment accéder aux tableaux (ticket 098a)
    if 'noUncheckedIndexedAccess' in s and 'accès par index' not in s:
        alerte(f, 'accès par index', "dire comment lire un tableau : .find, .map, .filter, jamais t[i]")

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
__VICTO_FIN_1__
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"; cp tickets/100c-ligne-panier.md "$CTL/"; cp "$TT" "$CTL/tests/"
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head; annuler "tsc rouge sur main"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges sur main"; }
git add -- "$TT" outils/controle-lot.py
git diff --cached --quiet && ok "test et contrôle déjà à jour" || {
  git commit -q -m "fix(tests): 100c — prix barré lu par textContent ; le contrôle refuse ByText + formatPrice"
  ok "test corrigé et règle ajoutée au contrôle"; }

# ------------------------------------------------------------ porte sur le code du modèle
IDS="100e 100f"
if [ "$SAUVETAGE" = 1 ]; then
  git checkout -q -b verif/100c auto/100c
  git show "main:$TT" > "$T"
  PORTE=/tmp/victo-porte-100c.log; : > "$PORTE"; vert=1
  npm run --silent typecheck >>"$PORTE" 2>&1 || vert=0
  [ "$vert" = 1 ] && { npm run --silent test >>"$PORTE" 2>&1 || vert=0; }
  [ "$vert" = 1 ] && grep -q '"build"' package.json && { npm run --silent build >>"$PORTE" 2>&1 || vert=0; }
  if [ "$vert" = 1 ]; then
    git add -- "$T"; git commit -q -m "test(100c): test corrigé par le superviseur (espace insécable)"
    git checkout -q main
    git merge --no-ff -q verif/100c -m "feat(100c): fusionné au vert par le harnais" || annuler "fusion impossible"
    { npm run --silent typecheck && npm run --silent test && { ! grep -q '"build"' package.json || npm run --silent build; }; } >/tmp/victo-apres.log 2>&1 \
      || { grep -E "error TS|FAIL|×|→" /tmp/victo-apres.log | head; annuler "main rouge après la fusion de la ligne"; }
    ok "ligne du modèle : porte verte, fusionnée dans main (tsc, tests, build)"
    git branch -q -D verif/100c auto/100c
    GIT_TERMINAL_PROMPT=0 git push -q origin --delete auto/100c 2>/dev/null || true
  else
    info "ligne du modèle : porte ROUGE, rien n'est fusionné. Échecs :"
    grep -E "error TS|×|→" "$PORTE" | sed -E 's/\x1b\[[0-9;]*m//g' | head -6 | sed 's/^/      /'
    git checkout -q -f main; git branch -q -D verif/100c
    IDS="100c 100e 100f"
  fi
fi

# ------------------------------------------------------------ manifeste de relance
: > tickets/manifest-rattrapage-100.tsv
for id in $IDS; do grep -P "^$id\t" tickets/manifest-100.tsv >> tickets/manifest-rattrapage-100.tsv; done
[ "$(wc -l < tickets/manifest-rattrapage-100.tsv)" -eq "$(echo $IDS | wc -w)" ] || annuler "manifeste de relance incomplet"
git add tickets/manifest-rattrapage-100.tsv
git diff --cached --quiet || git commit -q -m "chore(tickets): relance du lot 100 ($IDS)"
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale en fin de script : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-rattrapage-100.tsv ./run.sh\n\nTickets : %s. Compte %s.\n' "$IDS" "$([ "$IDS" = '100e 100f' ] && echo '25 à 40 minutes' || echo '45 minutes à une heure')"
