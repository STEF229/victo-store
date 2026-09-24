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
