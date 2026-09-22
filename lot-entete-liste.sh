#!/usr/bin/env bash
# VICTO STORE — lot « en-tête et page de liste » (tickets 090 à 094).
# Usage :  cd ~/victo-store && bash lot-entete-liste.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
git checkout -q main
[ -z "$(git status --porcelain -- . ':!lot-entete-liste.sh')" ] || mort "arbre sale : commit ou stash d'abord"
git pull -q --ff-only 2>/dev/null || true
[ -f src/components/catalogue/VueCatalogue.tsx ] || mort "VueCatalogue manque : termine d'abord le rattrapage 083-088"
[ -d node_modules/lucide-react ] || mort "lucide-react manque : lance d'abord lot-finitions.sh"
grep -q 'imports_inventes' run.sh || mort "harnais trop ancien : installe le run.sh a jour"
ok "base complète : VueCatalogue, lucide, harnais à jour"

# La barre d'annonce devient le filet de l'en-tête : le composant disparaît.
for f in src/components/accueil/BarreAnnonce.tsx tests/accueil2-BarreAnnonce.test.tsx \
         tickets/052-barre-annonce.md tickets/tests/accueil2-BarreAnnonce.test.tsx \
         tests/accueil2-SiteHeader.test.tsx tickets/tests/accueil2-SiteHeader.test.tsx \
         tests/accueil2-page.test.tsx tickets/tests/accueil2-page.test.tsx \
         tests/VueCatalogue.test.tsx tickets/tests/VueCatalogue.test.tsx; do
  git rm -q --ignore-unmatch -- "$f" >/dev/null 2>&1 || true
  rm -f -- "$f"
done
ok "BarreAnnonce et les tests remplacés ont été retirés"

# La garde sans-h1 référence BarreAnnonce : on la régénère sans lui.
if [ -f tests/garde-sans-h1.test.tsx ]; then
  python3 - <<'PYEOF'
import re
p = 'tests/garde-sans-h1.test.tsx'
s = open(p).read()
s = re.sub(r"import \{ BarreAnnonce \}[^\n]*\n", "", s)
s = re.sub(r"\s*\['BarreAnnonce', <BarreAnnonce />\],", "", s)
open(p, 'w').write(s)
PYEOF
  grep -q BarreAnnonce tests/garde-sans-h1.test.tsx && mort "la garde référence encore BarreAnnonce" || true
  ok "garde sans-h1 mise à jour"
fi

mkdir -p tickets/tests
cat > 'tickets/090-entete-v3.md' <<'FIN_VICTO_00'
TICKET 090 — en-tête : barre noire unique

Réécris `src/components/ui/SiteHeader.tsx` d'après la maquette validée : **une
seule barre noire** contenant le logo, la navigation centrée, la recherche et les
actions, suivie d'un **filet clair** reprenant les arguments de vente. L'ancienne
rangée blanche et l'ancien composant `BarreAnnonce` disparaissent.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  `page.tsx` qui n'a **qu'un export par défaut**.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** Les déclarations de types des modules utilisés
  te sont fournies en lecture seule.
- Icônes : **`lucide-react` uniquement**, chacune avec `aria-hidden`.
- Classes imposées en toutes lettres, jamais construites par interpolation.
- Couleurs : tokens `var(--vs-*)`. Teintes décoratives autorisées telles quelles :
  `#1E1E26` `#2A2A30` `#FF5A74` `#F0F0EE` `#E9E4DA` `#EEF1F8`.
- **Aucun `<h1>`** sauf dans un composant qui porte explicitement le titre de page.
- Accès aux tableaux : pas de `!`, pas de `as` ; `.map`, `.filter`, constantes nommées.
- Les tests existants du fichier modifié doivent rester verts.
## Contrats existants à conserver
`tests/SiteHeader.test.tsx` doit rester vert : rôle `banner` ; lien
`data-testid="entete-marque"` vers `/` contenant `VICTO` ; une seule
`<nav aria-label="Navigation principale">` avec un lien par entrée ;
`data-testid="entete-panier"` vers `/panier` avec `data-cart-count` et
`aria-label` `Panier, N article` ou `Panier, N articles` ; pastille
`data-testid="entete-panier-compte"` uniquement si le panier n'est pas vide.
Le type `NavItem` (avec `promo?: boolean`) reste exporté.

## Bloc d'imports exact
```tsx
import { Menu, Search, ShoppingBag, User } from 'lucide-react';
```

## Structure exacte — recopie ce rendu

```tsx
return (
  <>
    <header data-testid="entete" className="bg-[var(--vs-noir)] text-[var(--vs-blanc)]">
      <div className="grid h-20 grid-cols-[auto_1fr_auto] items-center gap-6 px-5 lg:px-12">
        <div className="flex items-center gap-2">
          <button type="button" aria-label="Ouvrir le menu" className="flex h-11 w-11 items-center justify-center lg:hidden">
            <Menu aria-hidden size={22} />
          </button>
          <a href="/" data-testid="entete-marque" className="text-[23px] font-black tracking-[0.1em] whitespace-nowrap">
            VICTO STORE
          </a>
        </div>

        <nav aria-label="Navigation principale" className="hidden justify-self-center gap-8 text-[15px] font-semibold lg:flex">
          {navItems.map((item) => (
            <a key={item.href} href={item.href} className={item.promo ? 'text-[#FF5A74]' : undefined}>
              {item.label}
            </a>
          ))}
        </nav>

        <div className="flex items-center justify-self-end gap-2">
          <label htmlFor="recherche-entete" className="sr-only">Rechercher un produit</label>
          <div className="hidden h-11 w-[250px] items-center gap-2 rounded-full border border-[#2A2A30] bg-[#1E1E26] px-4 lg:flex">
            <Search aria-hidden size={17} />
            <input
              id="recherche-entete"
              type="search"
              placeholder="Rechercher"
              className="h-10 min-w-0 flex-1 border-none bg-transparent text-sm text-[var(--vs-blanc)] outline-none"
            />
          </div>
          <button type="button" aria-label="Mon compte" className="hidden h-11 w-11 items-center justify-center lg:flex">
            <User aria-hidden size={21} />
          </button>
          <a href="/panier" data-testid="entete-panier" data-cart-count={cartCount} aria-label={libellePanier}
             className="relative flex h-11 w-11 items-center justify-center">
            <ShoppingBag aria-hidden size={21} />
            {cartCount > 0 && (
              <span data-testid="entete-panier-compte"
                    className="absolute right-0 top-1 flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-[var(--vs-accent)] px-1 text-[11px] font-extrabold">
                {cartCount}
              </span>
            )}
          </a>
        </div>
      </div>
    </header>

    <div data-testid="filet-annonce"
         className="flex h-9 items-center justify-center gap-6 border-b border-[var(--vs-ligne)] bg-[var(--vs-surface)] text-[12.5px] font-semibold text-[var(--vs-gris)]">
      <span>Livraison offerte au Canada</span>
      <span className="hidden sm:inline">Retours gratuits 30 jours</span>
      <span className="hidden sm:inline">Authenticité garantie</span>
    </div>
  </>
);
```

`libellePanier` garde sa formule actuelle : `Panier, N article` quand `N <= 1`,
`Panier, N articles` au-delà. `cartCount` vaut `0` par défaut.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_00
cat > 'tickets/091-accueil-sans-barre.md' <<'FIN_VICTO_01'
TICKET 091 — page d'accueil : retirer la barre d'annonce

Modifie `src/app/page.tsx`. Le composant `BarreAnnonce` n'existe plus : son
contenu est passé dans le filet de `SiteHeader`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  `page.tsx` qui n'a **qu'un export par défaut**.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** Les déclarations de types des modules utilisés
  te sont fournies en lecture seule.
- Icônes : **`lucide-react` uniquement**, chacune avec `aria-hidden`.
- Classes imposées en toutes lettres, jamais construites par interpolation.
- Couleurs : tokens `var(--vs-*)`. Teintes décoratives autorisées telles quelles :
  `#1E1E26` `#2A2A30` `#FF5A74` `#F0F0EE` `#E9E4DA` `#EEF1F8`.
- **Aucun `<h1>`** sauf dans un composant qui porte explicitement le titre de page.
- Accès aux tableaux : pas de `!`, pas de `as` ; `.map`, `.filter`, constantes nommées.
- Les tests existants du fichier modifié doivent rester verts.
## Changements, et rien d'autre
1. Retire la ligne `import { BarreAnnonce } from '@/components/accueil/BarreAnnonce';`.
2. Retire `<BarreAnnonce />` du rendu. La page commence donc par `<SiteHeader …>`.

Tout le reste du fichier est inchangé : mêmes constantes `NAV` et `COLONNES_PIED`,
même sélection `listerProduits().filter(estEnPromotion).slice(0, 4)`, mêmes
sections dans le même ordre, mêmes classes d'enveloppe, un seul export par défaut.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_01
cat > 'tickets/092-grille-colonnes.md' <<'FIN_VICTO_02'
TICKET 092 — grille : quatre colonnes possibles

Modifie `src/components/catalogue/GrilleProduits.tsx`. Les pages de liste passent
à quatre colonnes en grand écran ; l'accueil reste à trois.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  `page.tsx` qui n'a **qu'un export par défaut**.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** Les déclarations de types des modules utilisés
  te sont fournies en lecture seule.
- Icônes : **`lucide-react` uniquement**, chacune avec `aria-hidden`.
- Classes imposées en toutes lettres, jamais construites par interpolation.
- Couleurs : tokens `var(--vs-*)`. Teintes décoratives autorisées telles quelles :
  `#1E1E26` `#2A2A30` `#FF5A74` `#F0F0EE` `#E9E4DA` `#EEF1F8`.
- **Aucun `<h1>`** sauf dans un composant qui porte explicitement le titre de page.
- Accès aux tableaux : pas de `!`, pas de `as` ; `.map`, `.filter`, constantes nommées.
- Les tests existants du fichier modifié doivent rester verts.
## Changement unique
Ajoute la prop `colonnes?: 3 | 4`, **par défaut `3`**, et applique la classe
correspondante. Écris la correspondance en clair, jamais par interpolation :
```ts
const COLONNES = { 3: 'lg:grid-cols-3', 4: 'lg:grid-cols-4' } as const;
```
Les classes de base restent imposées : `grid grid-cols-1 gap-6 sm:grid-cols-2`,
suivies de la classe de colonnes puis de la `className` reçue.

Le reste est inchangé : `data-testid="grille"`, un `<li>` par produit avec
`key={produit.id}`, et le message `Aucun produit ne correspond à ces filtres.`
dans `<p data-testid="grille-vide">` quand la liste est vide.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_02
cat > 'tickets/093-filtres-barre.md' <<'FIN_VICTO_03'
TICKET 093 — barre de filtres

Crée `src/components/catalogue/FiltresBarre.tsx`, export `FiltresBarre`. Elle
remplace la colonne de cases à cocher par une barre horizontale : deux menus
déroulants, deux interrupteurs, le tri, et les filtres actifs en pastilles
retirables. Sur téléphone, un tiroir qui monte du bas.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  `page.tsx` qui n'a **qu'un export par défaut**.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** Les déclarations de types des modules utilisés
  te sont fournies en lecture seule.
- Icônes : **`lucide-react` uniquement**, chacune avec `aria-hidden`.
- Classes imposées en toutes lettres, jamais construites par interpolation.
- Couleurs : tokens `var(--vs-*)`. Teintes décoratives autorisées telles quelles :
  `#1E1E26` `#2A2A30` `#FF5A74` `#F0F0EE` `#E9E4DA` `#EEF1F8`.
- **Aucun `<h1>`** sauf dans un composant qui porte explicitement le titre de page.
- Accès aux tableaux : pas de `!`, pas de `as` ; `.map`, `.filter`, constantes nommées.
- Les tests existants du fichier modifié doivent rester verts.
## Bloc d'imports exact
```tsx
'use client';

import { ChevronDown, SlidersHorizontal, X } from 'lucide-react';
import { useState } from 'react';
import type { Marque } from '@/lib/catalogue';
import type { Criteres, Tri } from '@/lib/filtres';
```

## Props
```ts
{ marques: Marque[]; tailles: string[]; criteres: Criteres;
  onChange: (criteres: Criteres) => void; tri: Tri; onTriChange: (tri: Tri) => void }
```
Composant **contrôlé** pour les critères et le tri ; il ne garde en état interne que
l'ouverture des panneaux :
```ts
const [ouvert, setOuvert] = useState<null | 'marques' | 'tailles' | 'tiroir' | 'tri'>(null);
```

## Contrat
Racine `<div data-testid="filtres-barre">`.

### Barre, en grand écran
Conteneur `<div data-testid="barre-bureau">` aux classes imposées
`hidden flex-wrap items-center gap-3 lg:flex`. Chaque bouton à panneau est dans son
propre conteneur `relative`, pour que le panneau se positionne dessous.
- `<button type="button" data-testid="bouton-marques" aria-expanded={…}>` dont le
  texte est `Marque` sans sélection, et `Marque (N)` avec N marques choisies, suivi
  de `<ChevronDown aria-hidden size={16} />`.
  Ouvert, il affiche `<div data-testid="panneau-marques">` contenant un
  `<button type="button" data-testid={\`filtre-marque-${m.slug}\`} aria-pressed={…}>`
  par marque, texte = `m.nom`.
- `<button type="button" data-testid="bouton-tailles">` de la même façon : `Taille`
  ou `Taille (N)`, panneau `data-testid="panneau-tailles"` avec un
  `data-testid={\`filtre-taille-${t}\`}` par taille.
- `<button type="button" data-testid="filtre-promo" aria-pressed={…}>Promotions</button>`
  et `<button type="button" data-testid="filtre-stock" aria-pressed={…}>En stock</button>`.
- Tri : `<label htmlFor="tri">Trier par</label>` et
  `<select id="tri" data-testid="tri">` avec exactement, dans cet ordre, les valeurs
  `nouveautes` `prix-croissant` `prix-decroissant` `remise` et les libellés
  `Nouveautés` `Prix croissant` `Prix décroissant` `Meilleures remises`.
  Son conteneur porte les classes imposées `ml-auto flex items-center gap-2`.

Un seul panneau ouvert à la fois : ouvrir l'un ferme l'autre. Recliquer sur le
bouton d'un panneau ouvert le ferme.

### Pastilles des filtres actifs
Rendues **seulement** s'il y a au moins un filtre actif, dans
`<div data-testid="pastilles">` : un `<button type="button">` par filtre, avec
`aria-label` `Retirer le filtre <texte>` et `<X aria-hidden size={14} />`. Textes :
le nom de la marque, `Taille <valeur>`, `Promotions`, `En stock`. Puis
`<button type="button" data-testid="filtres-reinitialiser">Tout effacer</button>`,
qui appelle `onChange({})`.

### Téléphone
Conteneur `<div data-testid="barre-mobile">` aux classes imposées
`flex items-center gap-3 lg:hidden` contenant :
- `<button type="button" data-testid="ouvrir-filtres">` avec
  `<SlidersHorizontal aria-hidden size={17} />` et le texte `Filtrer` ou
  `Filtrer (N)`, N étant le nombre total de filtres actifs ;
- `<button type="button" data-testid="ouvrir-tri">Trier</button>`.

Quand `ouvert` vaut `'tiroir'`, rendre `<div data-testid="tiroir-filtres" role="dialog" aria-label="Filtrer">`
contenant les **mêmes** boutons de marque et de taille (mêmes `data-testid`), les
deux interrupteurs, un bouton `aria-label="Fermer"` et un bouton de validation.
Quand `ouvert` vaut `'tri'`, rendre `<div data-testid="tiroir-tri" role="dialog" aria-label="Trier">`
avec un bouton par option de tri.

**Attention** : les `data-testid` des boutons de marque et de taille doivent rester
uniques dans le DOM. Le tiroir n'est rendu que lorsqu'il est ouvert, et la barre du
haut est masquée par CSS, pas retirée : n'ouvre donc jamais le tiroir et un panneau
en même temps, et ne rends le tiroir que pour la valeur d'état correspondante.

## Comportement des critères
Cocher ajoute, décocher retire, dans un **nouvel** objet `Criteres` complet, sans
muter celui reçu. Un tableau vidé est transmis vide. Les interrupteurs basculent
`promotionSeulement` et `enStockSeulement`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_03
cat > 'tickets/094-vue-catalogue-v2.md' <<'FIN_VICTO_04'
TICKET 094 — vue de catalogue : barre de filtres

Modifie `src/components/catalogue/VueCatalogue.tsx` d'après la maquette validée :
la colonne de filtres disparaît, la barre passe au-dessus, la grille occupe toute la
largeur en quatre colonnes.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  `page.tsx` qui n'a **qu'un export par défaut**.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** Les déclarations de types des modules utilisés
  te sont fournies en lecture seule.
- Icônes : **`lucide-react` uniquement**, chacune avec `aria-hidden`.
- Classes imposées en toutes lettres, jamais construites par interpolation.
- Couleurs : tokens `var(--vs-*)`. Teintes décoratives autorisées telles quelles :
  `#1E1E26` `#2A2A30` `#FF5A74` `#F0F0EE` `#E9E4DA` `#EEF1F8`.
- **Aucun `<h1>`** sauf dans un composant qui porte explicitement le titre de page.
- Accès aux tableaux : pas de `!`, pas de `as` ; `.map`, `.filter`, constantes nommées.
- Les tests existants du fichier modifié doivent rester verts.
## Bloc d'imports exact
```tsx
'use client';

import { useMemo, useState } from 'react';
import { FiltresBarre } from '@/components/catalogue/FiltresBarre';
import { GrilleProduits } from '@/components/catalogue/GrilleProduits';
import { Pagination } from '@/components/catalogue/Pagination';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import type { Produit } from '@/lib/catalogue';
import { taillesCatalogue } from '@/lib/donnees';
import { filtrerProduits, paginer, trierProduits, type Criteres, type Tri } from '@/lib/filtres';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```
`FiltresPanneau` et `TriSelect` ne sont plus utilisés ici : le tri vit dans la barre.

## Props, état et calcul — inchangés
`{ titre: string; description?: string; produits: Produit[] }`, mêmes états,
même `useMemo`, même pagination à 6 par page, mêmes gestionnaires qui remettent
`page` à 1 :
```ts
const changerCriteres = (c: Criteres) => { setCriteres(c); setPage(1); };
const changerTri = (t: Tri) => { setTri(t); setPage(1); };
```
Compteur inchangé, et **zéro au singulier** :
```ts
const n = resultats.length;
const libelle = \`\${n} \${n > 1 ? 'produits' : 'produit'}\`;
```
Les marques proposées restent celles présentes dans `produits`, sans doublon.

## Structure exacte — recopie ce rendu
```tsx
return (
  <>
    <SiteHeader navItems={NAV} cartCount={0} />
    <main className="mx-auto max-w-[1440px] px-5 py-12 lg:px-12">
      <div className="flex items-end justify-between gap-8">
        <div>
          <h1 data-testid="liste-titre" className="text-5xl font-black tracking-tight lg:text-6xl">{titre}</h1>
          {description && (
            <p data-testid="liste-description" className="mt-3 max-w-2xl text-lg text-[var(--vs-gris)]">{description}</p>
          )}
        </div>
        <p data-testid="compteur" className="whitespace-nowrap text-[15px] text-[var(--vs-gris)]">{libelle}</p>
      </div>
      <div className="mt-8">
        <FiltresBarre
          marques={marques}
          tailles={taillesCatalogue()}
          criteres={criteres}
          onChange={changerCriteres}
          tri={tri}
          onTriChange={changerTri}
        />
      </div>
      <div className="mt-8">
        <GrilleProduits produits={pagine.items} colonnes={4} />
      </div>
      <Pagination page={pagine.page} pages={pagine.pages} onChange={setPage} />
    </main>
    <SiteFooter colonnes={COLONNES_PIED} annee={2026} />
  </>
);
```
N'ajoute aucune enveloppe supplémentaire et aucun autre titre.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_04
cat > 'tickets/manifest-entete-liste.tsv' <<'FIN_VICTO_05'
# id	cible	tests	spec	contexte_lecture_seule
090	src/components/ui/SiteHeader.tsx	tests/entete-v3.test.tsx	tickets/090-entete-v3.md	src/lib/navigation.ts
091	src/app/page.tsx	tests/accueil3-page.test.tsx	tickets/091-accueil-sans-barre.md	src/components/ui/SiteHeader.tsx
092	src/components/catalogue/GrilleProduits.tsx	tests/grille-colonnes.test.tsx	tickets/092-grille-colonnes.md	src/lib/catalogue.ts
093	src/components/catalogue/FiltresBarre.tsx	tests/FiltresBarre.test.tsx	tickets/093-filtres-barre.md	src/lib/catalogue.ts,src/lib/filtres.ts
094	src/components/catalogue/VueCatalogue.tsx	tests/VueCatalogue-v2.test.tsx	tickets/094-vue-catalogue-v2.md	src/components/catalogue/FiltresBarre.tsx,src/components/catalogue/GrilleProduits.tsx,src/components/catalogue/Pagination.tsx,src/components/ui/SiteFooter.tsx,src/components/ui/SiteHeader.tsx,src/lib/catalogue.ts,src/lib/donnees.ts,src/lib/filtres.ts,src/lib/navigation.ts
FIN_VICTO_05
cat > 'tickets/tests/FiltresBarre.test.tsx' <<'FIN_VICTO_06'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { FiltresBarre } from '../src/components/catalogue/FiltresBarre';
import type { Marque } from '../src/lib/catalogue';
import type { Criteres } from '../src/lib/filtres';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const MARQUES: Marque[] = [
  { id: 'm1', nom: 'Nike', slug: 'nike' },
  { id: 'm2', nom: 'Lacoste', slug: 'lacoste' },
];
const TAILLES = ['40', '41', 'M'];

function poser(criteres: Criteres = {}, onChange = vi.fn(), onTriChange = vi.fn()) {
  render(
    <FiltresBarre
      marques={MARQUES}
      tailles={TAILLES}
      criteres={criteres}
      onChange={onChange}
      tri="nouveautes"
      onTriChange={onTriChange}
    />,
  );
  return { onChange, onTriChange };
}

describe('FiltresBarre — barre', () => {
  it('rend la barre horizontale, masquée sur téléphone', () => {
    poser();
    const barre = screen.getByTestId('barre-bureau');
    for (const k of ['hidden', 'flex-wrap', 'items-center', 'gap-3', 'lg:flex']) expect(classes(barre)).toContain(k);
  });

  it('ferme les panneaux au départ', () => {
    poser();
    expect(screen.queryByTestId('panneau-marques')).toBeNull();
    expect(screen.queryByTestId('panneau-tailles')).toBeNull();
    expect(screen.getByTestId('bouton-marques').textContent).toContain('Marque');
  });

  it('ouvre le panneau des marques et le referme', () => {
    poser();
    fireEvent.click(screen.getByTestId('bouton-marques'));
    expect(screen.getByTestId('panneau-marques')).toBeInTheDocument();
    expect(screen.getByTestId('filtre-marque-nike')).toBeInTheDocument();
    fireEvent.click(screen.getByTestId('bouton-marques'));
    expect(screen.queryByTestId('panneau-marques')).toBeNull();
  });

  it('n’ouvre qu’un panneau à la fois', () => {
    poser();
    fireEvent.click(screen.getByTestId('bouton-marques'));
    fireEvent.click(screen.getByTestId('bouton-tailles'));
    expect(screen.queryByTestId('panneau-marques')).toBeNull();
    expect(screen.getByTestId('panneau-tailles')).toBeInTheDocument();
    expect(screen.getByTestId('filtre-taille-41')).toBeInTheDocument();
  });

  it('compte les sélections dans le libellé des boutons', () => {
    poser({ marques: ['nike'], tailles: ['40', '41'] });
    expect(screen.getByTestId('bouton-marques').textContent).toContain('Marque (1)');
    expect(screen.getByTestId('bouton-tailles').textContent).toContain('Taille (2)');
  });
});

describe('FiltresBarre — critères', () => {
  it('ajoute une marque', () => {
    const { onChange } = poser();
    fireEvent.click(screen.getByTestId('bouton-marques'));
    fireEvent.click(screen.getByTestId('filtre-marque-nike'));
    expect(onChange.mock.calls[0]?.[0].marques).toEqual(['nike']);
  });

  it('retire une marque déjà choisie', () => {
    const { onChange } = poser({ marques: ['nike', 'lacoste'] });
    fireEvent.click(screen.getByTestId('bouton-marques'));
    fireEvent.click(screen.getByTestId('filtre-marque-nike'));
    expect(onChange.mock.calls[0]?.[0].marques).toEqual(['lacoste']);
  });

  it('ajoute une taille', () => {
    const { onChange } = poser();
    fireEvent.click(screen.getByTestId('bouton-tailles'));
    fireEvent.click(screen.getByTestId('filtre-taille-M'));
    expect(onChange.mock.calls[0]?.[0].tailles).toEqual(['M']);
  });

  it('bascule les deux interrupteurs', () => {
    const { onChange } = poser();
    fireEvent.click(screen.getByTestId('filtre-promo'));
    expect(onChange.mock.calls[0]?.[0].promotionSeulement).toBe(true);
    fireEvent.click(screen.getByTestId('filtre-stock'));
    expect(onChange.mock.calls[1]?.[0].enStockSeulement).toBe(true);
  });

  it('ne mute pas l’objet reçu', () => {
    const criteres = { marques: ['nike'] };
    poser(criteres);
    fireEvent.click(screen.getByTestId('bouton-marques'));
    fireEvent.click(screen.getByTestId('filtre-marque-lacoste'));
    expect(criteres.marques).toEqual(['nike']);
  });

  it('remonte le tri', () => {
    const { onTriChange } = poser();
    fireEvent.change(screen.getByTestId('tri'), { target: { value: 'remise' } });
    expect(onTriChange).toHaveBeenCalledWith('remise');
  });

  it('propose les quatre tris dans l’ordre', () => {
    poser();
    const options = within(screen.getByTestId('tri')).getAllByRole('option') as HTMLOptionElement[];
    expect(options.map((o) => o.value)).toEqual(['nouveautes', 'prix-croissant', 'prix-decroissant', 'remise']);
    expect(options.map((o) => o.textContent)).toEqual([
      'Nouveautés', 'Prix croissant', 'Prix décroissant', 'Meilleures remises',
    ]);
  });
});

describe('FiltresBarre — pastilles', () => {
  it('n’affiche rien sans filtre actif', () => {
    poser();
    expect(screen.queryByTestId('pastilles')).toBeNull();
  });

  it('affiche une pastille par filtre actif', () => {
    poser({ marques: ['nike'], tailles: ['41'], promotionSeulement: true, enStockSeulement: true });
    const p = screen.getByTestId('pastilles');
    expect(within(p).getByRole('button', { name: 'Retirer le filtre Nike' })).toBeInTheDocument();
    expect(within(p).getByRole('button', { name: 'Retirer le filtre Taille 41' })).toBeInTheDocument();
    expect(within(p).getByRole('button', { name: 'Retirer le filtre Promotions' })).toBeInTheDocument();
    expect(within(p).getByRole('button', { name: 'Retirer le filtre En stock' })).toBeInTheDocument();
  });

  it('retire un filtre depuis sa pastille', () => {
    const { onChange } = poser({ marques: ['nike', 'lacoste'] });
    fireEvent.click(screen.getByRole('button', { name: 'Retirer le filtre Nike' }));
    expect(onChange.mock.calls[0]?.[0].marques).toEqual(['lacoste']);
  });

  it('efface tout', () => {
    const { onChange } = poser({ marques: ['nike'], promotionSeulement: true });
    fireEvent.click(screen.getByTestId('filtres-reinitialiser'));
    expect(onChange).toHaveBeenCalledWith({});
  });
});

describe('FiltresBarre — téléphone', () => {
  it('propose les deux boutons, réservés au téléphone', () => {
    poser();
    const zone = screen.getByTestId('barre-mobile');
    for (const k of ['flex', 'items-center', 'gap-3', 'lg:hidden']) expect(classes(zone)).toContain(k);
    expect(screen.getByTestId('ouvrir-tri').textContent).toBe('Trier');
  });

  it('compte les filtres actifs sur le bouton', () => {
    poser({ marques: ['nike'], tailles: ['41'], promotionSeulement: true });
    expect(screen.getByTestId('ouvrir-filtres').textContent).toContain('Filtrer (3)');
  });

  it('ouvre et ferme le tiroir de filtres', () => {
    poser();
    expect(screen.queryByTestId('tiroir-filtres')).toBeNull();
    fireEvent.click(screen.getByTestId('ouvrir-filtres'));
    const tiroir = screen.getByTestId('tiroir-filtres');
    expect(tiroir).toHaveAttribute('role', 'dialog');
    expect(within(tiroir).getByTestId('filtre-marque-nike')).toBeInTheDocument();
    fireEvent.click(within(tiroir).getByRole('button', { name: 'Fermer' }));
    expect(screen.queryByTestId('tiroir-filtres')).toBeNull();
  });

  it('ouvre le tiroir de tri', () => {
    poser();
    fireEvent.click(screen.getByTestId('ouvrir-tri'));
    const tiroir = screen.getByTestId('tiroir-tri');
    expect(within(tiroir).getByRole('button', { name: 'Meilleures remises' })).toBeInTheDocument();
  });

  it('ne rend jamais deux fois le même filtre', () => {
    poser();
    fireEvent.click(screen.getByTestId('ouvrir-filtres'));
    expect(screen.getAllByTestId('filtre-marque-nike')).toHaveLength(1);
  });
});
FIN_VICTO_06
cat > 'tickets/tests/VueCatalogue-v2.test.tsx' <<'FIN_VICTO_07'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
// Dépendance déclarée pour le harnais : sans la barre de filtres, ce ticket est BLOQUÉ.
import { FiltresBarre as _dependance } from '../src/components/catalogue/FiltresBarre';
import { VueCatalogue } from '../src/components/catalogue/VueCatalogue';
import type { Marque, Produit } from '../src/lib/catalogue';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const LACOSTE: Marque = { id: 'm2', nom: 'Lacoste', slug: 'lacoste' };
const P = (id: string, marque: Marque, prix: number): Produit => ({
  id, slug: `p-${id}`, nom: `Produit ${id}`, marque,
  imageUrl: '/img/pegasus.svg', prixCents: prix,
  variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 2 }],
});
const HUIT = [
  P('a', NIKE, 5000), P('b', NIKE, 6000), P('c', LACOSTE, 7000), P('d', NIKE, 8000),
  P('e', LACOSTE, 9000), P('f', NIKE, 10000), P('g', LACOSTE, 11000), P('h', NIKE, 12000),
];

describe('VueCatalogue — nouvelle disposition', () => {
  it('rend en-tête, titre, description et pied', () => {
    render(<VueCatalogue titre="Soldes" description="Une description." produits={HUIT} />);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByTestId('liste-titre').textContent).toBe('Soldes');
    expect(screen.getByTestId('liste-description').textContent).toBe('Une description.');
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('remplace la colonne de filtres par la barre', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    expect(screen.getByTestId('filtres-barre')).toBeInTheDocument();
    expect(screen.queryByTestId('filtres')).toBeNull();
  });

  it('affiche la grille sur quatre colonnes', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    expect(classes(screen.getByTestId('grille'))).toContain('lg:grid-cols-4');
  });

  it('impose la taille du titre', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    for (const k of ['text-5xl', 'font-black', 'tracking-tight', 'lg:text-6xl']) {
      expect(classes(screen.getByTestId('liste-titre'))).toContain(k);
    }
  });

  it('aligne le compteur avec le titre', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    const rangee = screen.getByTestId('compteur').parentElement as Element;
    for (const k of ['flex', 'items-end', 'justify-between', 'gap-8']) expect(classes(rangee)).toContain(k);
    expect(rangee.contains(screen.getByTestId('liste-titre'))).toBe(true);
  });
});

describe('VueCatalogue — contenu', () => {
  it('compte les produits et en montre six par page', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    expect(screen.getByTestId('compteur').textContent).toBe('8 produits');
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(6);
    fireEvent.click(screen.getByRole('button', { name: 'Page suivante' }));
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(2);
  });

  it('filtre par marque depuis la barre et revient à la première page', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    fireEvent.click(screen.getByRole('button', { name: 'Page suivante' }));
    fireEvent.click(screen.getByTestId('bouton-marques'));
    fireEvent.click(screen.getByTestId('filtre-marque-lacoste'));
    expect(screen.getByTestId('compteur').textContent).toBe('3 produits');
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(3);
  });

  it('ne propose que les marques présentes', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    fireEvent.click(screen.getByTestId('bouton-marques'));
    expect(screen.getByTestId('filtre-marque-nike')).toBeInTheDocument();
    expect(screen.queryByTestId('filtre-marque-adidas')).toBeNull();
  });

  it('trie par prix croissant', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    fireEvent.change(screen.getByTestId('tri'), { target: { value: 'prix-croissant' } });
    expect(screen.getAllByTestId('carte-nom').map((e) => e.textContent)).toEqual(
      [...HUIT].sort((a, b) => a.prixCents - b.prixCents).slice(0, 6).map((p) => p.nom),
    );
  });

  it('accorde le compteur et gère la liste vide', () => {
    const { unmount } = render(<VueCatalogue titre="Nike" produits={[P('z', NIKE, 9000)]} />);
    expect(screen.getByTestId('compteur').textContent).toBe('1 produit');
    unmount();
    render(<VueCatalogue titre="Marque introuvable" produits={[]} />);
    expect(screen.getByTestId('compteur').textContent).toBe('0 produit');
    expect(screen.getByTestId('grille-vide')).toBeInTheDocument();
  });
});
FIN_VICTO_07
cat > 'tickets/tests/accueil3-page.test.tsx' <<'FIN_VICTO_08'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import AccueilPage from '../src/app/page';
import { estEnPromotion } from '../src/lib/catalogue';
import { MARQUES, PRODUITS } from '../src/lib/donnees';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);

describe('page d’accueil', () => {
  it('commence par l’en-tête, sans barre d’annonce séparée', () => {
    render(<AccueilPage />);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByTestId('filet-annonce')).toBeInTheDocument();
    expect(screen.queryByTestId('barre-annonce')).toBeNull();
  });

  it('rend le contenu principal et le pied', () => {
    render(<AccueilPage />);
    expect(screen.getByRole('main')).toBeInTheDocument();
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('n’a qu’un seul titre de niveau 1', () => {
    render(<AccueilPage />);
    expect(screen.getAllByRole('heading', { level: 1 })).toHaveLength(1);
  });

  it('enchaîne les sections dans l’ordre de la maquette', () => {
    render(<AccueilPage />);
    const ids = ['carrousel', 'bande-marques', 'bonnes-affaires', 'categories', 'infolettre', 'reassurance', 'pied'];
    const blocs = ids.map((id) => screen.getByTestId(id));
    for (let i = 1; i < blocs.length; i++) {
      const avant = blocs[i - 1] as Element;
      const apres = blocs[i] as Element;
      expect(avant.compareDocumentPosition(apres) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    }
  });

  it('garde les cinq entrées de navigation, Soldes en rouge', () => {
    render(<AccueilPage />);
    const nav = screen.getByRole('navigation', { name: 'Navigation principale' });
    const liens = Array.from(nav.querySelectorAll('a'));
    expect(liens.map((a) => a.textContent)).toEqual(['Femme', 'Homme', 'Chaussures', 'Marques', 'Soldes']);
    expect(classes(liens[4] as Element)).toContain('text-[#FF5A74]');
  });

  it('garde les marques et les quatre bonnes affaires', () => {
    render(<AccueilPage />);
    expect(screen.getByTestId('bande-piste').querySelectorAll('ul')[0]?.querySelectorAll('li')).toHaveLength(MARQUES.length);
    const attendu = Math.min(4, PRODUITS.filter(estEnPromotion).length);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(attendu);
  });
});
FIN_VICTO_08
cat > 'tickets/tests/entete-v3.test.tsx' <<'FIN_VICTO_09'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteHeader, type NavItem } from '../src/components/ui/SiteHeader';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const NAV: NavItem[] = [
  { label: 'Femme', href: '/femme' },
  { label: 'Homme', href: '/homme' },
  { label: 'Soldes', href: '/soldes', promo: true },
];

describe('en-tête — barre noire unique', () => {
  it('rend une bannière noire', () => {
    render(<SiteHeader navItems={NAV} />);
    const entete = screen.getByTestId('entete');
    expect(entete).toBe(screen.getByRole('banner'));
    for (const k of ['bg-[var(--vs-noir)]', 'text-[var(--vs-blanc)]']) expect(classes(entete)).toContain(k);
  });

  it('répartit logo, navigation et actions sur une seule ligne', () => {
    render(<SiteHeader navItems={NAV} />);
    const ligne = screen.getByTestId('entete-marque').parentElement as Element;
    for (const k of ['grid', 'h-20', 'grid-cols-[auto_1fr_auto]', 'items-center']) {
      expect(classes(ligne)).toContain(k);
    }
    expect(ligne.contains(screen.getByRole('navigation', { name: 'Navigation principale' }))).toBe(true);
  });

  it('centre la navigation et la masque sur téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    const nav = screen.getByRole('navigation', { name: 'Navigation principale' });
    for (const k of ['hidden', 'justify-self-center', 'gap-8', 'lg:flex']) expect(classes(nav)).toContain(k);
  });

  it('colore en rouge clair la seule entrée promo', () => {
    render(<SiteHeader navItems={NAV} />);
    expect(classes(screen.getByRole('link', { name: 'Soldes' }))).toContain('text-[#FF5A74]');
    expect(classes(screen.getByRole('link', { name: 'Femme' }))).not.toContain('text-[#FF5A74]');
  });
});

describe('en-tête — recherche et actions', () => {
  it('propose un champ de recherche étiqueté', () => {
    render(<SiteHeader navItems={NAV} />);
    const champ = screen.getByLabelText('Rechercher un produit');
    expect(champ).toHaveAttribute('id', 'recherche-entete');
    expect(champ).toHaveAttribute('type', 'search');
    expect(champ).toHaveAttribute('placeholder', 'Rechercher');
  });

  it('réserve le bouton de menu au téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    const menu = screen.getByRole('button', { name: 'Ouvrir le menu' });
    expect(menu).toHaveAttribute('type', 'button');
    expect(classes(menu)).toContain('lg:hidden');
    expect(menu.querySelector('svg.lucide-menu')).not.toBeNull();
  });

  it('rend le compte et le panier avec leurs icônes lucide', () => {
    render(<SiteHeader navItems={NAV} cartCount={2} />);
    expect(screen.getByRole('button', { name: 'Mon compte' }).querySelector('svg.lucide-user')).not.toBeNull();
    const panier = screen.getByTestId('entete-panier');
    expect(panier.querySelector('svg.lucide-shopping-bag')).not.toBeNull();
    expect(classes(screen.getByTestId('entete-panier-compte'))).toContain('bg-[var(--vs-accent)]');
  });

  it("n'utilise que des icônes lucide", () => {
    const { container } = render(<SiteHeader navItems={NAV} cartCount={1} />);
    const svgs = Array.from(container.querySelectorAll('svg'));
    expect(svgs.length).toBeGreaterThanOrEqual(4);
    for (const s of svgs) {
      expect(s.classList.contains('lucide')).toBe(true);
      expect(s.getAttribute('aria-hidden')).toBe('true');
    }
  });
});

describe('en-tête — filet d’annonces', () => {
  it('reprend les trois messages sous la barre', () => {
    render(<SiteHeader navItems={NAV} />);
    const filet = screen.getByTestId('filet-annonce');
    expect(Array.from(filet.querySelectorAll('span')).map((s) => s.textContent)).toEqual([
      'Livraison offerte au Canada',
      'Retours gratuits 30 jours',
      'Authenticité garantie',
    ]);
  });

  it('se place après la barre', () => {
    render(<SiteHeader navItems={NAV} />);
    const entete = screen.getByTestId('entete');
    const filet = screen.getByTestId('filet-annonce');
    expect(entete.contains(filet)).toBe(false);
    expect(entete.compareDocumentPosition(filet) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  });

  it('porte les couleurs du filet et ne garde qu’un message sur téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    const filet = screen.getByTestId('filet-annonce');
    for (const k of ['bg-[var(--vs-surface)]', 'text-[var(--vs-gris)]', 'border-b', 'border-[var(--vs-ligne)]']) {
      expect(classes(filet)).toContain(k);
    }
    const messages = Array.from(filet.querySelectorAll('span'));
    expect(classes(messages[0] as Element)).not.toContain('hidden');
    for (const m of messages.slice(1)) {
      expect(classes(m)).toContain('hidden');
      expect(classes(m)).toContain('sm:inline');
    }
  });
});
FIN_VICTO_09
cat > 'tickets/tests/grille-colonnes.test.tsx' <<'FIN_VICTO_10'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { GrilleProduits } from '../src/components/catalogue/GrilleProduits';
import type { Produit } from '../src/lib/catalogue';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const P = (id: string): Produit => ({
  id, slug: `p-${id}`, nom: `Produit ${id}`,
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.svg', prixCents: 9900,
  variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 2 }],
});

describe('GrilleProduits — nombre de colonnes', () => {
  it('reste à trois colonnes par défaut', () => {
    render(<GrilleProduits produits={[P('a')]} />);
    const g = classes(screen.getByTestId('grille'));
    expect(g).toContain('lg:grid-cols-3');
    expect(g).not.toContain('lg:grid-cols-4');
  });

  it('passe à quatre colonnes sur demande', () => {
    render(<GrilleProduits produits={[P('a')]} colonnes={4} />);
    const g = classes(screen.getByTestId('grille'));
    expect(g).toContain('lg:grid-cols-4');
    expect(g).not.toContain('lg:grid-cols-3');
  });

  it('garde les classes de base dans les deux cas', () => {
    for (const c of [3, 4] as const) {
      const { unmount } = render(<GrilleProduits produits={[P('a')]} colonnes={c} />);
      for (const k of ['grid', 'grid-cols-1', 'gap-6', 'sm:grid-cols-2']) {
        expect(classes(screen.getByTestId('grille'))).toContain(k);
      }
      unmount();
    }
  });
});
FIN_VICTO_10
ok "5 tickets et 5 tests en attente"

echo "== porte de qualité"
npm run --silent typecheck || mort "tsc rouge : un test retiré était peut-être encore importé"
ok "tsc"
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×" /tmp/victo-test.log | head -15; mort "tests rouges"; }
ok "tests"
npm run --silent build >/tmp/victo-build.log 2>&1 || { tail -20 /tmp/victo-build.log; mort "build rouge"; }
ok "build"

git add -A -- src tests tickets
git commit -q -m "chore: lot en-tete et page de liste (tickets 090-094)"
GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/dev/null && ok "poussé sur GitHub" || true

cat <<'TXT'

Prêt. Une seule commande :

    MANIFEST=tickets/manifest-entete-liste.tsv ./run.sh

Cinq tickets, compte 45 minutes à 1 h 15.
TXT
