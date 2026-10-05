#!/usr/bin/env bash
# VICTO STORE — lot 114 : la bascule. Le site lit le catalogue de chargerCatalogue() (Medusa avec
#   CATALOGUE_SOURCE=medusa, démonstration sinon). 114a fournisseur CatalogueProvider ; 114k le gabarit
#   le charge ; 114b tailles ; 114c arbre (type Medusa, Survêtements) ; 114d-e photos de Medusa relayées
#   par la boutique (/medusa-images) ; 114f-j menu, recherche, panier, favoris, filtres ; 114l-y les pages.
# Hors tickets : les anciens tests des pages devenues asynchrones sont convertis (render(await Page())).
# Usage :  cd ~/victo-store && bash lot-114.sh
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
for d in 113d 113e 108h 108i 108j; do fusionne "$d" || mort "$d n'est pas fusionné : le lot 114 s'appuie dessus"; done
[ ! -e src/components/catalogue/CatalogueProvider.tsx ] || mort "CatalogueProvider existe déjà : lot déjà passé ?"
L=src/app/layout.tsx
[ "$(grep -c '<FavorisProvider>' $L)" = 1 ] && [ "$(grep -c '</FavorisProvider>' $L)" = 1 ] || mort "$L : le bloc <FavorisProvider> n'est pas unique (ticket 114k)"
[ "$(grep -c 'export default function RootLayout(' $L)" = 1 ] || mort "$L : « export default function RootLayout( » introuvable (ticket 114k)"
grep -q "CatalogueProvider" $L && mort "$L utilise déjà CatalogueProvider : lot déjà passé ?"
python3 - <<'VERIF' || mort "un fichier ne correspond pas aux specs (détail ci-dessus) : rien n'a été modifié"
import json, sys
table = json.loads(r'''[["src/lib/donnees.ts", "export function taillesCatalogue(): string[] {\n  const vues = new Set<string>();\n  for (const p of PRODUITS) for (const v of p.variantes) vues.add(v.taille);", "export function taillesCatalogue(): string[] {\n  return taillesDe(PRODUITS);\n}\n\n/** Les tailles présentes dans une liste de produits : pointures croissantes, puis S, M, L, XL. */\nexport function taillesDe(produits: Produit[]): string[] {\n  const vues = new Set<string>();\n  for (const p of produits) for (const v of p.variantes) vues.add(v.taille);", 1], ["src/lib/arbre-categories.ts", "feuille('vestes', 'Vestes')] },", "feuille('vestes', 'Vestes'), feuille('survetements', 'Survêtements')] },", 1], ["src/lib/arbre-categories.ts", "TYPES_DEMO[p.slug] === type", "(p.type ?? TYPES_DEMO[p.slug]) === type", 2], ["src/components/navigation/NavigationPrincipale.tsx", "import { listerMarques, listerProduits } from '@/lib/donnees';", "import { useCatalogue } from '@/components/catalogue/CatalogueProvider';", 1], ["src/components/navigation/NavigationPrincipale.tsx", "function PanneauMega({ panneau }: { panneau: Panneau }) {\n  if (panneau === 'marques') {", "function PanneauMega({ panneau }: { panneau: Panneau }) {\n  const catalogue = useCatalogue();\n  if (panneau === 'marques') {", 1], ["src/components/navigation/NavigationPrincipale.tsx", "{listerMarques().map((m) => (", "{catalogue.marques.map((m) => (", 1], ["src/components/navigation/NavigationPrincipale.tsx", "produitsDe(listerProduits(), panneau, [])", "produitsDe(catalogue.produits, panneau, [])", 1], ["src/components/recherche/ChampRecherche.tsx", "import { listerMarques, listerProduits } from '@/lib/donnees';", "import { useCatalogue } from '@/components/catalogue/CatalogueProvider';", 1], ["src/components/recherche/ChampRecherche.tsx", "  const [terme, setTerme] = useState('');", "  const catalogue = useCatalogue();\n  const [terme, setTerme] = useState('');", 1], ["src/components/recherche/ChampRecherche.tsx", "rechercherProduits(listerProduits(), terme)", "rechercherProduits(catalogue.produits, terme)", 1], ["src/components/recherche/ChampRecherche.tsx", "marquesCorrespondantes(listerMarques(), terme)", "marquesCorrespondantes(catalogue.marques, terme)", 1], ["src/components/panier/VuePanier.tsx", "import { trouverProduit } from '@/lib/donnees';", "import { useCatalogue } from '@/components/catalogue/CatalogueProvider';", 1], ["src/components/panier/VuePanier.tsx", "  const panier = usePanier();", "  const panier = usePanier();\n  const catalogue = useCatalogue();", 1], ["src/components/panier/VuePanier.tsx", "detaillerPanier(panier.lignes, trouverProduit)", "detaillerPanier(panier.lignes, (slug) => catalogue.produits.find((p) => p.slug === slug))", 1], ["src/app/compte/favoris/page.tsx", "import { trouverProduit } from '@/lib/donnees';", "import { useCatalogue } from '@/components/catalogue/CatalogueProvider';", 1], ["src/app/compte/favoris/page.tsx", "  const favoris = useFavoris();\n  const produits = favoris.favoris.flatMap((slug) => {\n    const p = trouverProduit(slug);", "  const favoris = useFavoris();\n  const catalogue = useCatalogue();\n  const produits = favoris.favoris.flatMap((slug) => {\n    const p = catalogue.produits.find((x) => x.slug === slug);", 1], ["src/components/catalogue/VueCatalogue.tsx", "import { taillesCatalogue } from '@/lib/donnees';", "import { useCatalogue } from '@/components/catalogue/CatalogueProvider';\nimport { taillesDe } from '@/lib/donnees';", 1], ["src/components/catalogue/VueCatalogue.tsx", "  const [criteres, setCriteres] = useState<Criteres>({});", "  const catalogue = useCatalogue();\n  const [criteres, setCriteres] = useState<Criteres>({});", 1], ["src/components/catalogue/VueCatalogue.tsx", "tailles={taillesCatalogue()}", "tailles={taillesDe(catalogue.produits)}", 1], ["src/app/boutique/page.tsx", "import { listerProduits } from '@/lib/donnees';", "import { chargerCatalogue } from '@/lib/catalogue-source';", 1], ["src/app/boutique/page.tsx", "export default function PageBoutique() {\n  return (", "export default async function PageBoutique() {\n  const { produits } = await chargerCatalogue();\n  return (", 1], ["src/app/boutique/page.tsx", "produits={listerProduits()}", "produits={produits}", 1], ["src/app/chaussures/page.tsx", "import { listerProduits } from '@/lib/donnees';", "import { chargerCatalogue } from '@/lib/catalogue-source';", 1], ["src/app/chaussures/page.tsx", "export default function PageChaussures() {\n  return (", "export default async function PageChaussures() {\n  const { produits } = await chargerCatalogue();\n  return (", 1], ["src/app/chaussures/page.tsx", "produits={listerProduits().filter(", "produits={produits.filter(", 1], ["src/app/chaussures/page.tsx", "sousCategories(listerProduits(), 'chaussures', [])", "sousCategories(produits, 'chaussures', [])", 1], ["src/app/femme/page.tsx", "import { listerProduits } from '@/lib/donnees';", "import { chargerCatalogue } from '@/lib/catalogue-source';", 1], ["src/app/femme/page.tsx", "export default function PageFemme() {\n  return (", "export default async function PageFemme() {\n  const { produits } = await chargerCatalogue();\n  return (", 1], ["src/app/femme/page.tsx", "produits={listerProduits().filter(", "produits={produits.filter(", 1], ["src/app/femme/page.tsx", "sousCategories(listerProduits(), 'femme', [])", "sousCategories(produits, 'femme', [])", 1], ["src/app/homme/page.tsx", "import { listerProduits } from '@/lib/donnees';", "import { chargerCatalogue } from '@/lib/catalogue-source';", 1], ["src/app/homme/page.tsx", "export default function PageHomme() {\n  return (", "export default async function PageHomme() {\n  const { produits } = await chargerCatalogue();\n  return (", 1], ["src/app/homme/page.tsx", "produits={listerProduits().filter(", "produits={produits.filter(", 1], ["src/app/homme/page.tsx", "sousCategories(listerProduits(), 'homme', [])", "sousCategories(produits, 'homme', [])", 1], ["src/app/soldes/page.tsx", "import { listerProduits } from '@/lib/donnees';", "import { chargerCatalogue } from '@/lib/catalogue-source';", 1], ["src/app/soldes/page.tsx", "export default function PageSoldes() {\n  return (", "export default async function PageSoldes() {\n  const { produits } = await chargerCatalogue();\n  return (", 1], ["src/app/soldes/page.tsx", "produits={listerProduits().filter(estEnPromotion)}", "produits={produits.filter(estEnPromotion)}", 1], ["src/app/marques/page.tsx", "import { MARQUES, PRODUITS } from '@/lib/donnees';", "import { chargerCatalogue } from '@/lib/catalogue-source';", 1], ["src/app/marques/page.tsx", "export default function PageMarques() {\n  const resumes = resumerMarques(MARQUES, PRODUITS);", "export default async function PageMarques() {\n  const { produits, marques } = await chargerCatalogue();\n  const resumes = resumerMarques(marques, produits);", 1], ["src/app/marques/[slug]/page.tsx", "import { produitsDeMarque, trouverMarque } from '@/lib/donnees';", "import { chargerCatalogue } from '@/lib/catalogue-source';", 1], ["src/app/marques/[slug]/page.tsx", "  const marque = trouverMarque(slug);", "  const catalogue = await chargerCatalogue();\n  const marque = catalogue.marques.find((m) => m.slug === slug);", 1], ["src/app/marques/[slug]/page.tsx", "produits={produitsDeMarque(slug)}", "produits={catalogue.produits.filter((p) => p.marque.slug === slug)}", 1], ["src/app/page.tsx", "import { listerMarques, listerProduits } from '@/lib/donnees';", "import { chargerCatalogue } from '@/lib/catalogue-source';", 1], ["src/app/page.tsx", "export function AccueilPage() {\n  const bonnesAffaires = listerProduits().filter(estEnPromotion).slice(0, 4);", "export async function AccueilPage() {\n  const catalogue = await chargerCatalogue();\n  const bonnesAffaires = catalogue.produits.filter(estEnPromotion).slice(0, 4);", 1], ["src/app/page.tsx", "<BandeMarques marques={listerMarques()} />", "<BandeMarques marques={catalogue.marques} />", 1], ["src/app/produits/[slug]/page.tsx", "import { listerProduits, trouverProduit } from '@/lib/donnees';", "import { chargerCatalogue } from '@/lib/catalogue-source';", 1], ["src/app/produits/[slug]/page.tsx", "  const produit = trouverProduit(slug);", "  const catalogue = await chargerCatalogue();\n  const produit = catalogue.produits.find((p) => p.slug === slug);", 1], ["src/app/produits/[slug]/page.tsx", "produitsSimilaires(produit, listerProduits())", "produitsSimilaires(produit, catalogue.produits)", 1], ["src/app/recherche/page.tsx", "import { listerMarques, listerProduits } from '@/lib/donnees';", "import { chargerCatalogue } from '@/lib/catalogue-source';", 1], ["src/app/recherche/page.tsx", "  const resultats = rechercherProduits(listerProduits(), terme);", "  const catalogue = await chargerCatalogue();\n  const resultats = rechercherProduits(catalogue.produits, terme);", 1], ["src/app/recherche/page.tsx", "{listerMarques().map((m) => (", "{catalogue.marques.map((m) => (", 1], ["src/app/recherche/page.tsx", "produits={listerProduits().slice(0, 4)}", "produits={catalogue.produits.slice(0, 4)}", 1], ["src/components/catalogue/PageSousCategorie.tsx", "import { listerProduits } from '@/lib/donnees';", "import type { Produit } from '@/lib/catalogue';\nimport { listerProduits } from '@/lib/donnees';", 1], ["src/components/catalogue/PageSousCategorie.tsx", "export function PageSousCategorie({ rubrique, chemin }: { rubrique: Rubrique; chemin: string[] }) {", "export function PageSousCategorie({ rubrique, chemin, produits }: { rubrique: Rubrique; chemin: string[]; produits?: Produit[] | undefined }) {", 1], ["src/components/catalogue/PageSousCategorie.tsx", "  const tous = listerProduits();", "  const tous = produits ?? listerProduits();", 1], ["src/app/femme/[...chemin]/page.tsx", "import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';", "import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';\nimport { chargerCatalogue } from '@/lib/catalogue-source';", 1], ["src/app/femme/[...chemin]/page.tsx", "  return <PageSousCategorie rubrique=\"femme\" chemin={chemin} />;", "  const { produits } = await chargerCatalogue();\n  return <PageSousCategorie rubrique=\"femme\" chemin={chemin} produits={produits} />;", 1], ["src/app/homme/[...chemin]/page.tsx", "import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';", "import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';\nimport { chargerCatalogue } from '@/lib/catalogue-source';", 1], ["src/app/homme/[...chemin]/page.tsx", "  return <PageSousCategorie rubrique=\"homme\" chemin={chemin} />;", "  const { produits } = await chargerCatalogue();\n  return <PageSousCategorie rubrique=\"homme\" chemin={chemin} produits={produits} />;", 1], ["src/app/chaussures/[...chemin]/page.tsx", "import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';", "import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';\nimport { chargerCatalogue } from '@/lib/catalogue-source';", 1], ["src/app/chaussures/[...chemin]/page.tsx", "  return <PageSousCategorie rubrique=\"chaussures\" chemin={chemin} />;", "  const { produits } = await chargerCatalogue();\n  return <PageSousCategorie rubrique=\"chaussures\" chemin={chemin} produits={produits} />;", 1], ["src/lib/medusa/convertir.ts", "const enCents = (montant: number) => Math.round(montant * 100);", "/**\n * Les photos téléversées dans Medusa (adresse finissant par /static/fichier.jpg) sont servies par la\n * boutique elle-même, à /medusa-images/fichier.jpg, relayées vers Medusa (next.config.ts) : elles s'affichent partout,\n * tunnel compris. Les autres adresses ne changent pas.\n */\nexport function imageLocale(url: string): string {\n  return url.includes('/static/') ? url.replace(/^.*?\\/static\\//, '/medusa-images/') : url;\n}\n\nconst enCents = (montant: number) => Math.round(montant * 100);", 1], ["src/lib/medusa/convertir.ts", "const images = (p.images ?? []).map((i) => i.url);", "const images = (p.images ?? []).map((i) => imageLocale(i.url));", 1], ["src/lib/medusa/convertir.ts", "imageUrl: p.thumbnail ?? images.find(() => true) ?? IMAGE_ABSENTE,", "imageUrl: (p.thumbnail ? imageLocale(p.thumbnail) : undefined) ?? images.find(() => true) ?? IMAGE_ABSENTE,", 1], ["next.config.ts", "  allowedDevOrigins: ['192.168.40.32'],\n};", "  allowedDevOrigins: ['192.168.40.32'],\n  // Les photos téléversées dans Medusa, servies par la boutique : elles s'affichent aussi à travers le tunnel.\n  async rewrites() {\n    return [{ source: '/medusa-images/:chemin*', destination: `${process.env.MEDUSA_URL ?? 'http://192.168.40.40:9000'}/static/:chemin*` }];\n  },\n};", 1]]''')
ko = 0
for f, avant, apres, n in table:
    try: s = open(f, encoding='utf-8').read()
    except FileNotFoundError: print(f"  ✗ {f} introuvable"); ko += 1; continue
    if apres in s: print(f"  ✗ {f} : déjà modifié (lot déjà passé ?)"); ko += 1; continue
    c = s.count(avant)
    if c != n: print(f"  ✗ {f} : « {avant.splitlines()[0][:80]} » trouvé {c} fois, attendu {n}"); ko += 1
sys.exit(1 if ko else 0)
VERIF
ok "les 65 textes à remplacer sont dans tes fichiers, au bon nombre d'occurrences"
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR

# ------------------------------------------------------------ anciens tests des pages devenues asynchrones
# render(<Page />) devient render(await Page()) : valable avant ET après la bascule ; la base verte le prouve.
cat > /tmp/victo-convertir-tests.py <<'__VICTO_CODEMOD__'
# Convertit les anciens tests des pages devenues asynchrones : render(<Page />) → render(await Page()).
# Cette forme fonctionne avant ET après la bascule (await sur un élément le renvoie tel quel).
import re, subprocess, sys
PAGES = r"(?:boutique|chaussures|femme|homme|soldes|marques)/page|page"
IMPORT = re.compile(r"^import\s+(?:(\w+)\s*(?:,\s*\{([^}]*)\})?|\{([^}]*)\})\s+from\s+['\"](?:\.\./)+src/app/(" + PAGES + r")['\"];?\s*$", re.M)
def noms_importes(source):
    noms = set()
    for defaut, nommes1, nommes2, _ in IMPORT.findall(source):
        if defaut: noms.add(defaut)
        for bloc in (nommes1, nommes2):
            for n in bloc.split(','):
                n = n.strip().split(' as ')[-1].strip()
                if n: noms.add(n)
    return noms
def convertir(source):
    noms = noms_importes(source)
    if not noms: return source, 0
    total = 0
    for n in noms:
        source, k = re.subn(r"render\(\s*<" + re.escape(n) + r"\s*/>\s*\)", f"render(await {n}())", source); total += k
    if total:
        source = re.sub(r"^(\s*(?:it|test)(?:\.only|\.skip)?\(\s*(['\"`]).*?\2\s*,\s*)\(\)\s*=>", r"\1async () =>", source, flags=re.M)
    return source, total
if __name__ == '__main__':
    fichiers = subprocess.run(['git', 'ls-files', '*.test.ts', '*.test.tsx'], capture_output=True, text=True, check=True).stdout.split()
    for f in fichiers:
        s = open(f, encoding='utf-8').read()
        s2, k = convertir(s)
        if k:
            open(f, 'w', encoding='utf-8').write(s2); print(f"  ✓ {f} : {k} affichage(s) de page converti(s)")
__VICTO_CODEMOD__
python3 /tmp/victo-convertir-tests.py || annuler "conversion des anciens tests impossible"
git add -u -- tests tickets/tests src 2>/dev/null || true

mkdir -p tickets/tests
cat > 'tickets/114a-catalogue-provider.md' <<'__VICTO_FIN_0__'
TICKET 114a — le catalogue transmis aux composants du navigateur

Crée `src/components/catalogue/CatalogueProvider.tsx` : un fournisseur (`CatalogueProvider`) et son
crochet (`useCatalogue`). Le serveur charge le catalogue (ticket 114k) et le transmet ; sans
fournisseur, `useCatalogue()` renvoie les données de démonstration.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier. Recopie le fichier tel quel.

## Fichier complet
Taille attendue : ~20 lignes.
```tsx
'use client';

import { createContext, useContext, type ReactNode } from 'react';
import type { Catalogue } from '@/lib/catalogue-source';
import { listerMarques, listerProduits } from '@/lib/donnees';

// Sans fournisseur (tests, aperçus), les données de démonstration : les composants marchent toujours.
const Contexte = createContext<Catalogue>({ produits: listerProduits(), marques: listerMarques(), source: 'demo' });

/** Transmet aux composants du navigateur le catalogue chargé par le serveur (layout.tsx). */
export function CatalogueProvider({ valeur, children }: { valeur: Catalogue; children: ReactNode }) {
  return <Contexte.Provider value={valeur}>{children}</Contexte.Provider>;
}

/** Le catalogue du site : Medusa ou démonstration, selon CATALOGUE_SOURCE. */
export function useCatalogue(): Catalogue {
  return useContext(Contexte);
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_0__
cat > 'tickets/114b-lib-donnees.md' <<'__VICTO_FIN_1__'
TICKET 114b — les tailles se calculent sur n’importe quelle liste de produits

Modifie `src/lib/donnees.ts`. `taillesDe(produits)` fait le calcul de `taillesCatalogue()` sur la liste reçue (celle de Medusa ou de la démonstration) ; `taillesCatalogue()` l'appelle, son résultat ne change pas.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
export function taillesCatalogue(): string[] {
  const vues = new Set<string>();
  for (const p of PRODUITS) for (const v of p.variantes) vues.add(v.taille);
```
Après :
```tsx
export function taillesCatalogue(): string[] {
  return taillesDe(PRODUITS);
}

/** Les tailles présentes dans une liste de produits : pointures croissantes, puis S, M, L, XL. */
export function taillesDe(produits: Produit[]): string[] {
  const vues = new Set<string>();
  for (const p of produits) for (const v of p.variantes) vues.add(v.taille);
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > 'tickets/114c-lib-arbre-categories.md' <<'__VICTO_FIN_2__'
TICKET 114c — l’arbre lit le vrai type du produit, et gagne Survêtements

Modifie `src/lib/arbre-categories.ts`. Le type d'un produit vient d'abord de Medusa (`p.type`), sinon du classement de démonstration ; Survêtements rejoint les vêtements, comme dans Medusa.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
feuille('vestes', 'Vestes')] },
```
Après :
```tsx
feuille('vestes', 'Vestes'), feuille('survetements', 'Survêtements')] },
```

## Remplacement 2 (chacune des **deux** occurrences)
Avant :
```tsx
TYPES_DEMO[p.slug] === type
```
Après :
```tsx
(p.type ?? TYPES_DEMO[p.slug]) === type
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_2__
cat > 'tickets/114d-lib-medusa-convertir.md' <<'__VICTO_FIN_3__'
TICKET 114d — les photos de Medusa passent par la boutique

Modifie `src/lib/medusa/convertir.ts`. Les adresses des photos de Medusa sont réécrites vers `/medusa-images/…` (fonction `imageLocale`, exportée).

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
const enCents = (montant: number) => Math.round(montant * 100);
```
Après :
```tsx
/**
 * Les photos téléversées dans Medusa (adresse finissant par /static/fichier.jpg) sont servies par la
 * boutique elle-même, à /medusa-images/fichier.jpg, relayées vers Medusa (next.config.ts) : elles s'affichent partout,
 * tunnel compris. Les autres adresses ne changent pas.
 */
export function imageLocale(url: string): string {
  return url.includes('/static/') ? url.replace(/^.*?\/static\//, '/medusa-images/') : url;
}

const enCents = (montant: number) => Math.round(montant * 100);
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
const images = (p.images ?? []).map((i) => i.url);
```
Après :
```tsx
const images = (p.images ?? []).map((i) => imageLocale(i.url));
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
imageUrl: p.thumbnail ?? images.find(() => true) ?? IMAGE_ABSENTE,
```
Après :
```tsx
imageUrl: (p.thumbnail ? imageLocale(p.thumbnail) : undefined) ?? images.find(() => true) ?? IMAGE_ABSENTE,
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_3__
cat > 'tickets/114e-next.config.md' <<'__VICTO_FIN_4__'
TICKET 114e — la boutique relaie les photos de Medusa

Modifie `next.config.ts`. Une règle de réécriture relaie `/medusa-images/…` vers le dossier `/static/` de Medusa (adresse prise dans `MEDUSA_URL`).

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
  allowedDevOrigins: ['192.168.40.32'],
};
```
Après :
```tsx
  allowedDevOrigins: ['192.168.40.32'],
  // Les photos téléversées dans Medusa, servies par la boutique : elles s'affichent aussi à travers le tunnel.
  async rewrites() {
    return [{ source: '/medusa-images/:chemin*', destination: `${process.env.MEDUSA_URL ?? 'http://192.168.40.40:9000'}/static/:chemin*` }];
  },
};
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_4__
cat > 'tickets/114f-components-navigation-NavigationPrincipale.md' <<'__VICTO_FIN_5__'
TICKET 114f — le méga-menu lit le catalogue du site

Modifie `src/components/navigation/NavigationPrincipale.tsx`. Les marques et le nombre de produits viennent de `useCatalogue()` (Medusa ou démonstration), plus des données écrites dans le code.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerMarques, listerProduits } from '@/lib/donnees';
```
Après :
```tsx
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
function PanneauMega({ panneau }: { panneau: Panneau }) {
  if (panneau === 'marques') {
```
Après :
```tsx
function PanneauMega({ panneau }: { panneau: Panneau }) {
  const catalogue = useCatalogue();
  if (panneau === 'marques') {
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
{listerMarques().map((m) => (
```
Après :
```tsx
{catalogue.marques.map((m) => (
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
produitsDe(listerProduits(), panneau, [])
```
Après :
```tsx
produitsDe(catalogue.produits, panneau, [])
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_5__
cat > 'tickets/114g-components-recherche-ChampRecherche.md' <<'__VICTO_FIN_6__'
TICKET 114g — les suggestions de recherche lisent le catalogue du site

Modifie `src/components/recherche/ChampRecherche.tsx`. Les suggestions cherchent dans `useCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerMarques, listerProduits } from '@/lib/donnees';
```
Après :
```tsx
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const [terme, setTerme] = useState('');
```
Après :
```tsx
  const catalogue = useCatalogue();
  const [terme, setTerme] = useState('');
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
rechercherProduits(listerProduits(), terme)
```
Après :
```tsx
rechercherProduits(catalogue.produits, terme)
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
marquesCorrespondantes(listerMarques(), terme)
```
Après :
```tsx
marquesCorrespondantes(catalogue.marques, terme)
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_6__
cat > 'tickets/114h-components-panier-VuePanier.md' <<'__VICTO_FIN_7__'
TICKET 114h — le panier retrouve ses produits dans le catalogue du site

Modifie `src/components/panier/VuePanier.tsx`. Chaque ligne du panier retrouve son produit dans `useCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { trouverProduit } from '@/lib/donnees';
```
Après :
```tsx
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const panier = usePanier();
```
Après :
```tsx
  const panier = usePanier();
  const catalogue = useCatalogue();
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
detaillerPanier(panier.lignes, trouverProduit)
```
Après :
```tsx
detaillerPanier(panier.lignes, (slug) => catalogue.produits.find((p) => p.slug === slug))
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_7__
cat > 'tickets/114i-app-compte-favoris.md' <<'__VICTO_FIN_8__'
TICKET 114i — les favoris retrouvent leurs produits dans le catalogue du site

Modifie `src/app/compte/favoris/page.tsx`. Chaque favori retrouve son produit dans `useCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { trouverProduit } from '@/lib/donnees';
```
Après :
```tsx
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const favoris = useFavoris();
  const produits = favoris.favoris.flatMap((slug) => {
    const p = trouverProduit(slug);
```
Après :
```tsx
  const favoris = useFavoris();
  const catalogue = useCatalogue();
  const produits = favoris.favoris.flatMap((slug) => {
    const p = catalogue.produits.find((x) => x.slug === slug);
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_8__
cat > 'tickets/114j-components-catalogue-VueCatalogue.md' <<'__VICTO_FIN_9__'
TICKET 114j — les filtres proposent les tailles du catalogue du site

Modifie `src/components/catalogue/VueCatalogue.tsx`. Les tailles proposées par le filtre viennent de `useCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
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
__VICTO_FIN_9__
cat > 'tickets/114k-layout.md' <<'__VICTO_FIN_10__'
TICKET 114k — le gabarit du site charge le catalogue

Modifie `src/app/layout.tsx`. Le serveur charge le catalogue une fois par page et le transmet aux
composants du navigateur.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Ne change ni les métadonnées, ni `<html>`, ni `<body>`, ni l'ordre des fournisseurs existants.

## Les quatre changements
1. Ajoute, à la suite des imports existants :
   ```tsx
   import { CatalogueProvider } from '@/components/catalogue/CatalogueProvider';
   import { chargerCatalogue } from '@/lib/catalogue-source';
   ```
2. La fonction `RootLayout` devient asynchrone : `export default function RootLayout(` devient
   `export default async function RootLayout(` (ses paramètres ne changent pas).
3. Première ligne de son corps, avant le `return` : `const catalogue = await chargerCatalogue();`
4. Entoure **tout** l'élément `<FavorisProvider>…</FavorisProvider>` (avec ce qu'il contient) par
   `<CatalogueProvider valeur={catalogue}>` et `</CatalogueProvider>`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les tests `layout-*`.
__VICTO_FIN_10__
cat > 'tickets/114l-app-boutique.md' <<'__VICTO_FIN_11__'
TICKET 114l — la boutique lit le catalogue du site

Modifie `src/app/boutique/page.tsx`. La page devient asynchrone et lit `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerProduits } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
export default function PageBoutique() {
  return (
```
Après :
```tsx
export default async function PageBoutique() {
  const { produits } = await chargerCatalogue();
  return (
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
produits={listerProduits()}
```
Après :
```tsx
produits={produits}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_11__
cat > 'tickets/114m-app-chaussures.md' <<'__VICTO_FIN_12__'
TICKET 114m — la page Chaussures lit le catalogue du site

Modifie `src/app/chaussures/page.tsx`. La page devient asynchrone et lit `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerProduits } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
export default function PageChaussures() {
  return (
```
Après :
```tsx
export default async function PageChaussures() {
  const { produits } = await chargerCatalogue();
  return (
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
produits={listerProduits().filter(
```
Après :
```tsx
produits={produits.filter(
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
sousCategories(listerProduits(), 'chaussures', [])
```
Après :
```tsx
sousCategories(produits, 'chaussures', [])
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_12__
cat > 'tickets/114n-app-femme.md' <<'__VICTO_FIN_13__'
TICKET 114n — la page Femme lit le catalogue du site

Modifie `src/app/femme/page.tsx`. La page devient asynchrone et lit `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerProduits } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
export default function PageFemme() {
  return (
```
Après :
```tsx
export default async function PageFemme() {
  const { produits } = await chargerCatalogue();
  return (
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
produits={listerProduits().filter(
```
Après :
```tsx
produits={produits.filter(
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
sousCategories(listerProduits(), 'femme', [])
```
Après :
```tsx
sousCategories(produits, 'femme', [])
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_13__
cat > 'tickets/114o-app-homme.md' <<'__VICTO_FIN_14__'
TICKET 114o — la page Homme lit le catalogue du site

Modifie `src/app/homme/page.tsx`. La page devient asynchrone et lit `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerProduits } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
export default function PageHomme() {
  return (
```
Après :
```tsx
export default async function PageHomme() {
  const { produits } = await chargerCatalogue();
  return (
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
produits={listerProduits().filter(
```
Après :
```tsx
produits={produits.filter(
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
sousCategories(listerProduits(), 'homme', [])
```
Après :
```tsx
sousCategories(produits, 'homme', [])
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_14__
cat > 'tickets/114p-app-soldes.md' <<'__VICTO_FIN_15__'
TICKET 114p — la page Soldes lit le catalogue du site

Modifie `src/app/soldes/page.tsx`. La page devient asynchrone et lit `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerProduits } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
export default function PageSoldes() {
  return (
```
Après :
```tsx
export default async function PageSoldes() {
  const { produits } = await chargerCatalogue();
  return (
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
produits={listerProduits().filter(estEnPromotion)}
```
Après :
```tsx
produits={produits.filter(estEnPromotion)}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_15__
cat > 'tickets/114q-app-marques.md' <<'__VICTO_FIN_16__'
TICKET 114q — la page Marques lit le catalogue du site

Modifie `src/app/marques/page.tsx`. La page devient asynchrone et lit `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { MARQUES, PRODUITS } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
export default function PageMarques() {
  const resumes = resumerMarques(MARQUES, PRODUITS);
```
Après :
```tsx
export default async function PageMarques() {
  const { produits, marques } = await chargerCatalogue();
  const resumes = resumerMarques(marques, produits);
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_16__
cat > 'tickets/114r-app-marques-slug.md' <<'__VICTO_FIN_17__'
TICKET 114r — la page d’une marque lit le catalogue du site

Modifie `src/app/marques/[slug]/page.tsx`. La marque et ses produits viennent de `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { produitsDeMarque, trouverMarque } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const marque = trouverMarque(slug);
```
Après :
```tsx
  const catalogue = await chargerCatalogue();
  const marque = catalogue.marques.find((m) => m.slug === slug);
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
produits={produitsDeMarque(slug)}
```
Après :
```tsx
produits={catalogue.produits.filter((p) => p.marque.slug === slug)}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_17__
cat > 'tickets/114s-app-accueil.md' <<'__VICTO_FIN_18__'
TICKET 114s — l’accueil lit le catalogue du site

Modifie `src/app/page.tsx`. La page devient asynchrone et lit `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerMarques, listerProduits } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
export function AccueilPage() {
  const bonnesAffaires = listerProduits().filter(estEnPromotion).slice(0, 4);
```
Après :
```tsx
export async function AccueilPage() {
  const catalogue = await chargerCatalogue();
  const bonnesAffaires = catalogue.produits.filter(estEnPromotion).slice(0, 4);
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
<BandeMarques marques={listerMarques()} />
```
Après :
```tsx
<BandeMarques marques={catalogue.marques} />
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_18__
cat > 'tickets/114t-app-produits-slug.md' <<'__VICTO_FIN_19__'
TICKET 114t — la fiche produit lit le catalogue du site

Modifie `src/app/produits/[slug]/page.tsx`. Le produit et les produits similaires viennent de `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerProduits, trouverProduit } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const produit = trouverProduit(slug);
```
Après :
```tsx
  const catalogue = await chargerCatalogue();
  const produit = catalogue.produits.find((p) => p.slug === slug);
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
produitsSimilaires(produit, listerProduits())
```
Après :
```tsx
produitsSimilaires(produit, catalogue.produits)
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_19__
cat > 'tickets/114u-app-recherche.md' <<'__VICTO_FIN_20__'
TICKET 114u — la recherche lit le catalogue du site

Modifie `src/app/recherche/page.tsx`. Les résultats, les marques et les suggestions viennent de `chargerCatalogue()`.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerMarques, listerProduits } from '@/lib/donnees';
```
Après :
```tsx
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const resultats = rechercherProduits(listerProduits(), terme);
```
Après :
```tsx
  const catalogue = await chargerCatalogue();
  const resultats = rechercherProduits(catalogue.produits, terme);
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
{listerMarques().map((m) => (
```
Après :
```tsx
{catalogue.marques.map((m) => (
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
produits={listerProduits().slice(0, 4)}
```
Après :
```tsx
produits={catalogue.produits.slice(0, 4)}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_20__
cat > 'tickets/114v-components-catalogue-PageSousCategorie.md' <<'__VICTO_FIN_21__'
TICKET 114v — la page de sous-catégorie reçoit les produits de sa route

Modifie `src/components/catalogue/PageSousCategorie.tsx`. Une prop facultative `produits` (passée par les routes) ; sans elle, les données de démonstration, comme avant.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { listerProduits } from '@/lib/donnees';
```
Après :
```tsx
import type { Produit } from '@/lib/catalogue';
import { listerProduits } from '@/lib/donnees';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
export function PageSousCategorie({ rubrique, chemin }: { rubrique: Rubrique; chemin: string[] }) {
```
Après :
```tsx
export function PageSousCategorie({ rubrique, chemin, produits }: { rubrique: Rubrique; chemin: string[]; produits?: Produit[] | undefined }) {
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
  const tous = listerProduits();
```
Après :
```tsx
  const tous = produits ?? listerProduits();
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_21__
cat > 'tickets/114w-app-femme-routes.md' <<'__VICTO_FIN_22__'
TICKET 114w — les sous-catégories de Femme lisent le catalogue du site

Modifie `src/app/femme/[...chemin]/page.tsx`. La route charge le catalogue et le passe à la page de sous-catégorie.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';
```
Après :
```tsx
import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  return <PageSousCategorie rubrique="femme" chemin={chemin} />;
```
Après :
```tsx
  const { produits } = await chargerCatalogue();
  return <PageSousCategorie rubrique="femme" chemin={chemin} produits={produits} />;
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_22__
cat > 'tickets/114x-app-homme-routes.md' <<'__VICTO_FIN_23__'
TICKET 114x — les sous-catégories de Homme lisent le catalogue du site

Modifie `src/app/homme/[...chemin]/page.tsx`. La route charge le catalogue et le passe à la page de sous-catégorie.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';
```
Après :
```tsx
import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  return <PageSousCategorie rubrique="homme" chemin={chemin} />;
```
Après :
```tsx
  const { produits } = await chargerCatalogue();
  return <PageSousCategorie rubrique="homme" chemin={chemin} produits={produits} />;
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_23__
cat > 'tickets/114y-app-chaussures-routes.md' <<'__VICTO_FIN_24__'
TICKET 114y — les sous-catégories de Chaussures lisent le catalogue du site

Modifie `src/app/chaussures/[...chemin]/page.tsx`. La route charge le catalogue et le passe à la page de sous-catégorie.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';
```
Après :
```tsx
import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';
import { chargerCatalogue } from '@/lib/catalogue-source';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  return <PageSousCategorie rubrique="chaussures" chemin={chemin} />;
```
Après :
```tsx
  const { produits } = await chargerCatalogue();
  return <PageSousCategorie rubrique="chaussures" chemin={chemin} produits={produits} />;
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_24__
cat > 'tickets/manifest-114.tsv' <<'__VICTO_FIN_25__'
114a	src/components/catalogue/CatalogueProvider.tsx	tests/catalogue-provider.test.tsx	tickets/114a-catalogue-provider.md			
114b	src/lib/donnees.ts	tests/donnees-tailles.test.ts	tickets/114b-lib-donnees.md			
114c	src/lib/arbre-categories.ts	tests/arbre-type-medusa.test.ts	tickets/114c-lib-arbre-categories.md			
114d	src/lib/medusa/convertir.ts	tests/medusa-images.test.ts	tickets/114d-lib-medusa-convertir.md			
114e	next.config.ts	tests/next-config-images.test.ts	tickets/114e-next.config.md			
114f	src/components/navigation/NavigationPrincipale.tsx	tests/navigation-catalogue.test.tsx	tickets/114f-components-navigation-NavigationPrincipale.md	src/components/catalogue/CatalogueProvider.tsx	114a	
114g	src/components/recherche/ChampRecherche.tsx	tests/recherche-catalogue.test.tsx	tickets/114g-components-recherche-ChampRecherche.md	src/components/catalogue/CatalogueProvider.tsx	114a	
114h	src/components/panier/VuePanier.tsx	tests/bascule-components-panier-VuePanier.test.ts	tickets/114h-components-panier-VuePanier.md	src/components/catalogue/CatalogueProvider.tsx	114a	
114i	src/app/compte/favoris/page.tsx	tests/bascule-app-compte-favoris.test.ts	tickets/114i-app-compte-favoris.md	src/components/catalogue/CatalogueProvider.tsx	114a	
114j	src/components/catalogue/VueCatalogue.tsx	tests/bascule-components-catalogue-VueCatalogue.test.ts	tickets/114j-components-catalogue-VueCatalogue.md	src/components/catalogue/CatalogueProvider.tsx	114a,114b	
114k	src/app/layout.tsx	tests/bascule-layout.test.ts	tickets/114k-layout.md	src/components/catalogue/CatalogueProvider.tsx,src/lib/catalogue-source.ts	114a	
114l	src/app/boutique/page.tsx	tests/bascule-app-boutique.test.ts	tickets/114l-app-boutique.md			
114m	src/app/chaussures/page.tsx	tests/bascule-app-chaussures.test.ts	tickets/114m-app-chaussures.md			
114n	src/app/femme/page.tsx	tests/bascule-app-femme.test.ts	tickets/114n-app-femme.md			
114o	src/app/homme/page.tsx	tests/bascule-app-homme.test.ts	tickets/114o-app-homme.md			
114p	src/app/soldes/page.tsx	tests/bascule-app-soldes.test.ts	tickets/114p-app-soldes.md			
114q	src/app/marques/page.tsx	tests/bascule-app-marques.test.ts	tickets/114q-app-marques.md			
114r	src/app/marques/[slug]/page.tsx	tests/bascule-app-marques-slug.test.ts	tickets/114r-app-marques-slug.md			
114s	src/app/page.tsx	tests/bascule-app-accueil.test.ts	tickets/114s-app-accueil.md			
114t	src/app/produits/[slug]/page.tsx	tests/bascule-app-produits-slug.test.ts	tickets/114t-app-produits-slug.md			
114u	src/app/recherche/page.tsx	tests/bascule-app-recherche.test.ts	tickets/114u-app-recherche.md			
114v	src/components/catalogue/PageSousCategorie.tsx	tests/bascule-components-catalogue-PageSousCategorie.test.ts	tickets/114v-components-catalogue-PageSousCategorie.md			
114w	src/app/femme/[...chemin]/page.tsx	tests/bascule-app-femme-routes.test.ts	tickets/114w-app-femme-routes.md		114v	
114x	src/app/homme/[...chemin]/page.tsx	tests/bascule-app-homme-routes.test.ts	tickets/114x-app-homme-routes.md		114v	
114y	src/app/chaussures/[...chemin]/page.tsx	tests/bascule-app-chaussures-routes.test.ts	tickets/114y-app-chaussures-routes.md		114v	
__VICTO_FIN_25__
cat > 'tickets/tests/arbre-type-medusa.test.ts' <<'__VICTO_FIN_26__'
import { describe, expect, it } from 'vitest';
import { ARBRE, produitsDe, sousCategories } from '../src/lib/arbre-categories';
import type { Produit } from '../src/lib/catalogue';

const P = (slug: string, type: string | undefined, categorie: Produit['categorie'] = 'chaussures'): Produit => ({
  id: slug, slug, nom: slug, marque: { id: 'm', nom: 'M', slug: 'm' }, imageUrl: '/x.svg', prixCents: 1, variantes: [], genre: 'homme',
  ...(categorie ? { categorie } : {}), ...(type ? { type } : {}),
});

describe('arbre — le type vient de Medusa', () => {
  it('classe un produit par son type Medusa', () => {
    const liste = [P('medusa-course', 'course'), P('medusa-basket', 'basket'), P('survet', 'survetements', 'vetements')];
    expect(produitsDe(liste, 'chaussures', ['course']).map((p) => p.slug)).toEqual(['medusa-course']);
    expect(produitsDe(liste, 'homme', ['chaussures', 'basket']).map((p) => p.slug)).toEqual(['medusa-basket']);
    expect(produitsDe(liste, 'homme', ['vetements', 'survetements']).map((p) => p.slug)).toEqual(['survet']);
  });

  it('garde le classement de démonstration pour les produits sans type', () => {
    expect(produitsDe([P('air-zoom-pegasus-41', undefined)], 'chaussures', ['course']).map((p) => p.slug)).toEqual(['air-zoom-pegasus-41']);
  });

  it('ajoute Survêtements aux vêtements', () => {
    const vetements = ARBRE.homme.enfants.find((e) => e.slug === 'vetements');
    expect(vetements?.enfants.map((e) => e.slug)).toContain('survetements');
    expect(sousCategories([], 'femme', ['vetements']).map((e) => e.libelle)).toContain('Survêtements');
  });
});
__VICTO_FIN_26__
cat > 'tickets/tests/bascule-app-accueil.test.ts' <<'__VICTO_FIN_27__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "export async function AccueilPage() {\n  const catalogue = await chargerCatalogue();\n  const bonnesAffaires = catalogue.produits.filter(estEnPromotion).slice(0, 4);", "<BandeMarques marques={catalogue.marques} />"];

describe("bascule — src/app/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_27__
cat > 'tickets/tests/bascule-app-boutique.test.ts' <<'__VICTO_FIN_28__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/boutique/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "export default async function PageBoutique() {\n  const { produits } = await chargerCatalogue();\n  return (", "produits={produits}"];

describe("bascule — src/app/boutique/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_28__
cat > 'tickets/tests/bascule-app-chaussures-routes.test.ts' <<'__VICTO_FIN_29__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/chaussures/[...chemin]/page.tsx", 'utf8');
const ATTENDUS = ["import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';\nimport { chargerCatalogue } from '@/lib/catalogue-source';", "  const { produits } = await chargerCatalogue();\n  return <PageSousCategorie rubrique=\"chaussures\" chemin={chemin} produits={produits} />;"];

describe("bascule — src/app/chaussures/[...chemin]/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_29__
cat > 'tickets/tests/bascule-app-chaussures.test.ts' <<'__VICTO_FIN_30__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/chaussures/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "export default async function PageChaussures() {\n  const { produits } = await chargerCatalogue();\n  return (", "produits={produits.filter(", "sousCategories(produits, 'chaussures', [])"];

describe("bascule — src/app/chaussures/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_30__
cat > 'tickets/tests/bascule-app-compte-favoris.test.ts' <<'__VICTO_FIN_31__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/compte/favoris/page.tsx", 'utf8');
const ATTENDUS = ["import { useCatalogue } from '@/components/catalogue/CatalogueProvider';", "  const favoris = useFavoris();\n  const catalogue = useCatalogue();\n  const produits = favoris.favoris.flatMap((slug) => {\n    const p = catalogue.produits.find((x) => x.slug === slug);"];

describe("bascule — src/app/compte/favoris/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_31__
cat > 'tickets/tests/bascule-app-femme-routes.test.ts' <<'__VICTO_FIN_32__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/femme/[...chemin]/page.tsx", 'utf8');
const ATTENDUS = ["import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';\nimport { chargerCatalogue } from '@/lib/catalogue-source';", "  const { produits } = await chargerCatalogue();\n  return <PageSousCategorie rubrique=\"femme\" chemin={chemin} produits={produits} />;"];

describe("bascule — src/app/femme/[...chemin]/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_32__
cat > 'tickets/tests/bascule-app-femme.test.ts' <<'__VICTO_FIN_33__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/femme/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "export default async function PageFemme() {\n  const { produits } = await chargerCatalogue();\n  return (", "produits={produits.filter(", "sousCategories(produits, 'femme', [])"];

describe("bascule — src/app/femme/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_33__
cat > 'tickets/tests/bascule-app-homme-routes.test.ts' <<'__VICTO_FIN_34__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/homme/[...chemin]/page.tsx", 'utf8');
const ATTENDUS = ["import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';\nimport { chargerCatalogue } from '@/lib/catalogue-source';", "  const { produits } = await chargerCatalogue();\n  return <PageSousCategorie rubrique=\"homme\" chemin={chemin} produits={produits} />;"];

describe("bascule — src/app/homme/[...chemin]/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_34__
cat > 'tickets/tests/bascule-app-homme.test.ts' <<'__VICTO_FIN_35__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/homme/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "export default async function PageHomme() {\n  const { produits } = await chargerCatalogue();\n  return (", "produits={produits.filter(", "sousCategories(produits, 'homme', [])"];

describe("bascule — src/app/homme/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_35__
cat > 'tickets/tests/bascule-app-marques-slug.test.ts' <<'__VICTO_FIN_36__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/marques/[slug]/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "  const catalogue = await chargerCatalogue();\n  const marque = catalogue.marques.find((m) => m.slug === slug);", "produits={catalogue.produits.filter((p) => p.marque.slug === slug)}"];

describe("bascule — src/app/marques/[slug]/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_36__
cat > 'tickets/tests/bascule-app-marques.test.ts' <<'__VICTO_FIN_37__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/marques/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "export default async function PageMarques() {\n  const { produits, marques } = await chargerCatalogue();\n  const resumes = resumerMarques(marques, produits);"];

describe("bascule — src/app/marques/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_37__
cat > 'tickets/tests/bascule-app-produits-slug.test.ts' <<'__VICTO_FIN_38__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/produits/[slug]/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "  const catalogue = await chargerCatalogue();\n  const produit = catalogue.produits.find((p) => p.slug === slug);", "produitsSimilaires(produit, catalogue.produits)"];

describe("bascule — src/app/produits/[slug]/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_38__
cat > 'tickets/tests/bascule-app-recherche.test.ts' <<'__VICTO_FIN_39__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/recherche/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "  const catalogue = await chargerCatalogue();\n  const resultats = rechercherProduits(catalogue.produits, terme);", "{catalogue.marques.map((m) => (", "produits={catalogue.produits.slice(0, 4)}"];

describe("bascule — src/app/recherche/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_39__
cat > 'tickets/tests/bascule-app-soldes.test.ts' <<'__VICTO_FIN_40__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/soldes/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "export default async function PageSoldes() {\n  const { produits } = await chargerCatalogue();\n  return (", "produits={produits.filter(estEnPromotion)}"];

describe("bascule — src/app/soldes/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_40__
cat > 'tickets/tests/bascule-components-catalogue-PageSousCategorie.test.ts' <<'__VICTO_FIN_41__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/components/catalogue/PageSousCategorie.tsx", 'utf8');
const ATTENDUS = ["import type { Produit } from '@/lib/catalogue';\nimport { listerProduits } from '@/lib/donnees';", "export function PageSousCategorie({ rubrique, chemin, produits }: { rubrique: Rubrique; chemin: string[]; produits?: Produit[] | undefined }) {", "  const tous = produits ?? listerProduits();"];

describe("bascule — src/components/catalogue/PageSousCategorie.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
  });
});
__VICTO_FIN_41__
cat > 'tickets/tests/bascule-components-catalogue-VueCatalogue.test.ts' <<'__VICTO_FIN_42__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/components/catalogue/VueCatalogue.tsx", 'utf8');
const ATTENDUS = ["import { useCatalogue } from '@/components/catalogue/CatalogueProvider';\nimport { taillesDe } from '@/lib/donnees';", "  const catalogue = useCatalogue();\n  const [criteres, setCriteres] = useState<Criteres>({});", "tailles={taillesDe(catalogue.produits)}"];

describe("bascule — src/components/catalogue/VueCatalogue.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
  });
});
__VICTO_FIN_42__
cat > 'tickets/tests/bascule-components-panier-VuePanier.test.ts' <<'__VICTO_FIN_43__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/components/panier/VuePanier.tsx", 'utf8');
const ATTENDUS = ["import { useCatalogue } from '@/components/catalogue/CatalogueProvider';", "  const panier = usePanier();\n  const catalogue = useCatalogue();", "detaillerPanier(panier.lignes, (slug) => catalogue.produits.find((p) => p.slug === slug))"];

describe("bascule — src/components/panier/VuePanier.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
__VICTO_FIN_43__
cat > 'tickets/tests/bascule-layout.test.ts' <<'__VICTO_FIN_44__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync('src/app/layout.tsx', 'utf8');

describe('bascule — le gabarit charge le catalogue', () => {
  it('charge le catalogue côté serveur', () => {
    expect(SOURCE).toContain("import { CatalogueProvider } from '@/components/catalogue/CatalogueProvider';");
    expect(SOURCE).toContain("import { chargerCatalogue } from '@/lib/catalogue-source';");
    expect(SOURCE).toMatch(/export default async function RootLayout\(/);
    expect(SOURCE).toContain('const catalogue = await chargerCatalogue();');
  });

  it('l’entoure autour des fournisseurs existants', () => {
    const ouvre = SOURCE.indexOf('<CatalogueProvider valeur={catalogue}>');
    const favoris = SOURCE.indexOf('<FavorisProvider>');
    expect(ouvre).toBeGreaterThan(-1);
    expect(favoris).toBeGreaterThan(ouvre);
    expect(SOURCE.indexOf('</CatalogueProvider>')).toBeGreaterThan(SOURCE.indexOf('</FavorisProvider>'));
  });
});
__VICTO_FIN_44__
cat > 'tickets/tests/catalogue-provider.test.tsx' <<'__VICTO_FIN_45__'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { CatalogueProvider, useCatalogue } from '../src/components/catalogue/CatalogueProvider';
import { listerProduits } from '../src/lib/donnees';

function Temoin() {
  const c = useCatalogue();
  return <p data-testid="temoin">{`${c.source} ${c.produits.length} ${c.marques.map((m) => m.nom).join(',')}`}</p>;
}
const MARQUE = { id: 'pcat_x', nom: 'Marque Medusa', slug: 'marque-medusa' };
const PRODUIT = { id: 'prod_x', slug: 'produit-medusa', nom: 'Produit Medusa', marque: MARQUE, imageUrl: '/x.svg', prixCents: 1000, variantes: [] };

describe('catalogue du site — fournisseur', () => {
  it('donne la démonstration sans fournisseur', () => {
    render(<Temoin />);
    expect(screen.getByTestId('temoin').textContent?.startsWith(`demo ${listerProduits().length} `)).toBe(true);
  });

  it('donne le catalogue transmis par le serveur', () => {
    render(<CatalogueProvider valeur={{ produits: [PRODUIT], marques: [MARQUE], source: 'medusa' }}><Temoin /></CatalogueProvider>);
    expect(screen.getByTestId('temoin').textContent).toBe('medusa 1 Marque Medusa');
  });
});
__VICTO_FIN_45__
cat > 'tickets/tests/donnees-tailles.test.ts' <<'__VICTO_FIN_46__'
import { describe, expect, it } from 'vitest';
import type { Produit } from '../src/lib/catalogue';
import * as donnees from '../src/lib/donnees';

// Import par espace de noms : avant le ticket, taillesDe n'existe pas, et le test échoue sans planter.
const avec = (...tailles: string[]): Produit => ({
  id: 'p', slug: 'p', nom: 'P', marque: { id: 'm', nom: 'M', slug: 'm' }, imageUrl: '/x.svg', prixCents: 1,
  variantes: tailles.map((t) => ({ id: t, taille: t, sku: t, stock: 1 })),
});

describe('tailles d’une liste de produits', () => {
  it('range les pointures, puis S, M, L, XL, sans doublon', () => {
    expect(typeof donnees.taillesDe).toBe('function');
    expect(donnees.taillesDe([avec('42', 'M', '40'), avec('L', '40', 'S')])).toEqual(['40', '42', 'S', 'M', 'L']);
    expect(donnees.taillesDe([])).toEqual([]);
  });

  it('donne le même résultat qu’avant pour la démonstration', () => {
    expect(typeof donnees.taillesDe).toBe('function');
    expect(donnees.taillesCatalogue()).toEqual(donnees.taillesDe(donnees.listerProduits()));
  });
});
__VICTO_FIN_46__
cat > 'tickets/tests/medusa-images.test.ts' <<'__VICTO_FIN_47__'
import { describe, expect, it } from 'vitest';
import * as convertir from '../src/lib/medusa/convertir';
import type { ProduitMedusa } from '../src/lib/medusa/convertir';

// Import par espace de noms : avant le ticket, imageLocale n'existe pas, et le test échoue sans planter.
const P: ProduitMedusa = { id: 'p', title: 'P', subtitle: 'Nike', handle: 'p', description: null, thumbnail: null };

describe('photos de Medusa', () => {
  it('fait passer les photos téléversées par la boutique', () => {
    expect(typeof convertir.imageLocale).toBe('function');
    expect(convertir.imageLocale('http://localhost:9000/static/1728-pegasus.png')).toBe('/medusa-images/1728-pegasus.png');
    expect(convertir.imageLocale('/static/a/b.jpg')).toBe('/medusa-images/a/b.jpg');
    expect(convertir.imageLocale('https://exemple.ca/vignette.jpg')).toBe('https://exemple.ca/vignette.jpg');
  });

  it('l’applique à la vignette et aux images du produit', () => {
    const p = convertir.convertirProduit({ ...P, thumbnail: 'http://localhost:9000/static/v.png', images: [{ url: 'http://localhost:9000/static/a.png' }] }, []);
    expect([p.imageUrl, p.images]).toEqual(['/medusa-images/v.png', ['/medusa-images/a.png']]);
    expect(convertir.convertirProduit(P, []).imageUrl).toBe(convertir.IMAGE_ABSENTE);
  });
});
__VICTO_FIN_47__
cat > 'tickets/tests/navigation-catalogue.test.tsx' <<'__VICTO_FIN_48__'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { CatalogueProvider } from '../src/components/catalogue/CatalogueProvider';
import { NavigationPrincipale } from '../src/components/navigation/NavigationPrincipale';
import { NAV } from '../src/lib/navigation';

const MARQUE = { id: 'pcat_x', nom: 'Marque Medusa', slug: 'marque-medusa' };
const P = (slug: string) => ({ id: slug, slug, nom: slug, marque: MARQUE, imageUrl: '/x.svg', prixCents: 1000, variantes: [], genre: 'homme' as const, categorie: 'chaussures' as const });
const ouvrir = (nom: string) => fireEvent.mouseEnter(within(screen.getByRole('navigation', { name: 'Navigation principale' })).getByRole('link', { name: nom }));

describe('méga-menu — catalogue du site', () => {
  it('montre les marques et les nombres du catalogue fourni', () => {
    render(<CatalogueProvider valeur={{ produits: [P('a'), P('b'), P('c')], marques: [MARQUE], source: 'medusa' }}><NavigationPrincipale navItems={NAV} /></CatalogueProvider>);
    ouvrir('Marques');
    expect(within(screen.getByRole('region', { name: 'Sous-catégories de Marques' })).getByRole('link', { name: 'Marque Medusa' })).toHaveAttribute('href', '/marques/marque-medusa');
    ouvrir('Homme');
    expect(within(screen.getByRole('region', { name: 'Sous-catégories de Homme' })).getByRole('link', { name: /^Tout voir Homme \(3 produits\)/ })).toBeInTheDocument();
  });
});
__VICTO_FIN_48__
cat > 'tickets/tests/next-config-images.test.ts' <<'__VICTO_FIN_49__'
// @vitest-environment node
import { describe, expect, it } from 'vitest';
import config from '../next.config';

describe('next.config — photos de Medusa', () => {
  it('relaie /medusa-images vers le dossier static de Medusa', async () => {
    expect(config.rewrites).toBeTypeOf('function');
    const regles = config.rewrites ? await config.rewrites() : [];
    const liste = Array.isArray(regles) ? regles : [...regles.beforeFiles, ...regles.afterFiles, ...regles.fallback];
    const regle = liste.find((r) => r.source === '/medusa-images/:chemin*');
    expect(regle?.destination.endsWith('/static/:chemin*')).toBe(true);
    expect(config.allowedDevOrigins).toEqual(['192.168.40.32']);
  });
});
__VICTO_FIN_49__
cat > 'tickets/tests/recherche-catalogue.test.tsx' <<'__VICTO_FIN_50__'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { CatalogueProvider } from '../src/components/catalogue/CatalogueProvider';
import { ChampRecherche } from '../src/components/recherche/ChampRecherche';

const MARQUE = { id: 'pcat_x', nom: 'Zorblax', slug: 'zorblax' };
const P = { id: 'prod_x', slug: 'chaussure-zorblax', nom: 'Chaussure Zorblax', marque: MARQUE, imageUrl: '/x.svg', prixCents: 12900, variantes: [] };

describe('recherche — catalogue du site', () => {
  it('suggère les produits et les marques du catalogue fourni', () => {
    render(<CatalogueProvider valeur={{ produits: [P], marques: [MARQUE], source: 'medusa' }}><ChampRecherche /></CatalogueProvider>);
    fireEvent.change(screen.getByLabelText('Rechercher un produit'), { target: { value: 'zorblax' } });
    const zone = screen.getByTestId('suggestions-recherche');
    expect(zone.textContent).toContain('Chaussure Zorblax');
    expect(screen.getByRole('link', { name: 'Zorblax' })).toHaveAttribute('href', '/marques/zorblax');
  });
});
__VICTO_FIN_50__
TESTS=(arbre-type-medusa.test.ts bascule-app-accueil.test.ts bascule-app-boutique.test.ts bascule-app-chaussures-routes.test.ts bascule-app-chaussures.test.ts bascule-app-compte-favoris.test.ts bascule-app-femme-routes.test.ts bascule-app-femme.test.ts bascule-app-homme-routes.test.ts bascule-app-homme.test.ts bascule-app-marques-slug.test.ts bascule-app-marques.test.ts bascule-app-produits-slug.test.ts bascule-app-recherche.test.ts bascule-app-soldes.test.ts bascule-components-catalogue-PageSousCategorie.test.ts bascule-components-catalogue-VueCatalogue.test.ts bascule-components-panier-VuePanier.test.ts bascule-layout.test.ts catalogue-provider.test.tsx donnees-tailles.test.ts medusa-images.test.ts navigation-catalogue.test.tsx next-config-images.test.ts recherche-catalogue.test.tsx)
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
ok "25 specs, 25 tests en attente et le manifeste écrits"

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/114*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-114.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
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
  git commit -q -m "chore(tickets): lot 114 — bascule ; anciens tests des pages convertis"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-114.tsv ./run.sh\n\n25 tickets courts : compte trois heures et demie à quatre heures, un run de nuit.\nRien ne change à l affichage tant que CATALOGUE_SOURCE=demo ; avec medusa, le site affiche Medusa.\n'
