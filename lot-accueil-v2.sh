#!/usr/bin/env bash
# VICTO STORE — lot « accueil v2 », fidèle à la maquette validée.
# Nettoie l'ancienne page d'accueil, écrit specs, tests et visuels provisoires,
# vérifie la base (types, tests, build), commite et pousse.
# Usage :  cd ~/victo-store && bash lot-accueil-v2.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"

ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }

pgrep -f 'run\.sh' >/dev/null 2>&1 && mort "le harnais tourne encore : attends la fin du run"
git checkout -q main
[ -z "$(git status --porcelain -- . ':!lot-accueil-v2.sh')" ] || mort "arbre sale : commit ou stash d'abord"
git pull -q --ff-only 2>/dev/null || true
ok "sur main, à jour"

# --- 1. Retrait de l'ancienne page d'accueil (lot 041-045), qu'elle ait tourné ou non
for f in \
  src/components/accueil/Hero.tsx src/components/accueil/BandeauMarques.tsx \
  src/components/accueil/TuilesCategories.tsx src/components/accueil/Reassurance.tsx \
  tests/Hero.test.tsx tests/BandeauMarques.test.tsx tests/TuilesCategories.test.tsx \
  tests/Reassurance.test.tsx tests/accueil-page.test.tsx \
  tickets/041-hero.md tickets/042-bandeau-marques.md tickets/043-tuiles-categories.md \
  tickets/044-reassurance.md tickets/045-page-accueil.md tickets/manifest-accueil.tsv \
  tickets/tests/Hero.test.tsx tickets/tests/BandeauMarques.test.tsx \
  tickets/tests/TuilesCategories.test.tsx tickets/tests/Reassurance.test.tsx \
  tickets/tests/accueil-page.test.tsx; do
  git rm -q --ignore-unmatch -- "$f" >/dev/null 2>&1 || true
  rm -f -- "$f"
done
ok "ancienne page d'accueil retirée"

# La page redevient une amorce neutre : l'ancienne importait des composants supprimés.
mkdir -p src/app
cat > src/app/page.tsx <<'PAGE'
export default function Accueil() {
  return <main className="p-10">VICTO STORE — page d'accueil en construction</main>;
}
PAGE
ok "src/app/page.tsx remis en amorce"

mkdir -p tickets/tests src/components/accueil public/img/accueil
cat > 'tickets/040-grille-classes.md' <<'FIN_VICTO_00'
TICKET 040 — grille de produits : colonnes responsives

Modifie `src/components/catalogue/GrilleProduits.tsx`. La grille actuelle n'a
**aucune** classe de colonnes : elle s'affiche sur une seule colonne et chaque
carte occupe toute la largeur. C'est le seul défaut à corriger.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée aucun autre fichier.
- Couleurs via les tokens `var(--vs-*)` uniquement. Cobalt `--vs-accent` pour les
  actions, rouge `--vs-promo` réservé aux remises.
- **Aucun fichier baril nexiste** : nimporte jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres, dans une chaîne littérale.
  Tailwind ne génère que les classes quil lit dans le code source ; une classe
  construite dynamiquement (`grid-cols-${n}`) ne sera jamais produite. Les tests
  vérifient la présence des classes imposées. Tu peux en **ajouter** d autres,
  jamais en retirer.
- Accès aux tableaux : `tableau[0]` a le type `T | undefined`. Nutilise ni `!`
  ni `as` ; préfère `.map`, `.filter`, `.slice` ou une constante nommée.
- Les `data-testid` sont un contrat testé.

## Classes imposées sur le `<ul data-testid="grille">`
```
grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3
```
Suivies de la `className` reçue en prop. Exemple exact :
```tsx
<ul data-testid="grille" className={`grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 ${className}`}>
```

## Ne change rien d'autre
Le comportement existant est déjà testé par `tests/GrilleProduits.test.tsx`, qui
doit continuer à passer : même `data-testid`, même message quand la liste est
vide, un `<li>` par produit avec `key={produit.id}`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_00
cat > 'tickets/050-prix-remise.md' <<'FIN_VICTO_01'
TICKET 050 — Price : option pour masquer le pourcentage de remise

Modifie `src/components/ui/Price.tsx`. La carte produit de la maquette affiche la
remise dans une pastille sur la photo ; elle doit pouvoir demander à `Price` de ne
pas la répéter à côté du prix.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée ni ne modifie aucun autre fichier
  que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres dans une chaîne littérale.
  Tailwind ne génère que les classes qu'il lit dans le code ; une classe construite
  par interpolation n'existera jamais. Les tests vérifient leur présence. Tu peux en
  ajouter, jamais en retirer.
- Couleurs : tokens `var(--vs-*)` en priorité (`--vs-noir`, `--vs-blanc`,
  `--vs-surface`, `--vs-ligne`, `--vs-gris`, `--vs-accent` cobalt, `--vs-promo`
  rouge). Seules ces teintes décoratives sont autorisées en valeur directe :
  `#1E1E26` `#C70026` `#E9E4DA` `#D9D2C4` `#EEF1F8` `#B5B5BA` `#FFD3DB`.
- Toute icône `<svg>` porte `aria-hidden="true"`. Toute image purement décorative
  porte `alt=""`.
- Accès aux tableaux : `t[0]` a le type `T | undefined`. Pas de `!`, pas de `as` ;
  utilise `.map`, `.filter`, `.slice` ou des constantes nommées.
- `'use client'` en première ligne **seulement** si le composant a un état ou un effet.
## Changement unique
Ajoute la prop optionnelle `afficherRemise?: boolean`, **par défaut `true`**.
Quand elle vaut `false`, l'élément `data-testid="prix-remise"` n'est **pas rendu**.
Tout le reste est inchangé : prix courant, prix barré, `data-promo`, formats.

Les tests existants de `tests/Price.test.tsx` doivent continuer à passer.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_01
cat > 'tickets/051-carte-produit.md' <<'FIN_VICTO_02'
TICKET 051 — ProductCard : style de la maquette

Modifie `src/components/ui/ProductCard.tsx`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée ni ne modifie aucun autre fichier
  que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres dans une chaîne littérale.
  Tailwind ne génère que les classes qu'il lit dans le code ; une classe construite
  par interpolation n'existera jamais. Les tests vérifient leur présence. Tu peux en
  ajouter, jamais en retirer.
- Couleurs : tokens `var(--vs-*)` en priorité (`--vs-noir`, `--vs-blanc`,
  `--vs-surface`, `--vs-ligne`, `--vs-gris`, `--vs-accent` cobalt, `--vs-promo`
  rouge). Seules ces teintes décoratives sont autorisées en valeur directe :
  `#1E1E26` `#C70026` `#E9E4DA` `#D9D2C4` `#EEF1F8` `#B5B5BA` `#FFD3DB`.
- Toute icône `<svg>` porte `aria-hidden="true"`. Toute image purement décorative
  porte `alt=""`.
- Accès aux tableaux : `t[0]` a le type `T | undefined`. Pas de `!`, pas de `as` ;
  utilise `.map`, `.filter`, `.slice` ou des constantes nommées.
- `'use client'` en première ligne **seulement** si le composant a un état ou un effet.
## Contrats existants à conserver absolument
`tests/ProductCard.test.tsx` doit continuer à passer. En particulier :
`article` avec `data-testid="carte-produit"` et `data-produit-id` ; **un seul**
`<a>` (vers `hrefProduit(produit)`) ; **une seule** image accessible, `<img>` avec
un `alt` contenant la marque et le nom ; `carte-marque` ; `carte-nom` ; le
composant `Badge` (qui porte `data-testid="badge"`) **uniquement** si
`produit.badge` est fourni.

## Nouveautés
1. Ajoute `'use client';` en première ligne : la carte gagne un état.
2. Le visuel est enveloppé dans `<div data-testid="carte-visuel">` aux classes
   imposées `relative overflow-hidden rounded-[20px] bg-[var(--vs-surface)]`.
   L'`<img>` porte les classes imposées `h-full w-full object-cover` et le
   conteneur a un ratio 4/5 (`aspect-[4/5]`).
3. **Pastille de remise**, seulement si le produit est en promotion
   (`estEnPromotion`) : un `<span data-testid="prix-remise">` en haut à gauche du
   visuel, fond `var(--vs-promo)`, texte blanc, forme pilule. Son texte est
   **exactement** `−N %` : signe moins U+2212 (`'\u2212'`), la valeur de
   `remisePourcent(produit)`, espace insécable U+00A0 (`'\u00A0'`), puis `%`.
   Ce n'est **pas** le composant `Badge` : un simple `<span>`.
4. Rends le prix avec `<Price amount={produit.prixCents} compareAt={produit.prixCompareCents} afficherRemise={false} />`,
   pour qu'il n'y ait qu'**un seul** `prix-remise` dans la carte.
5. **Bouton favori** en haut à droite du visuel :
   `<button type="button" aria-label="Ajouter aux favoris" aria-pressed={favori}>`,
   rond, fond blanc, 44 px, contenant un cœur en `<svg aria-hidden="true">`. Un clic
   bascule `favori` (`useState(false)`). Il est **hors** du lien.
6. Le `Badge` de `produit.badge`, s'il existe, se place sous la pastille de remise.

## Bloc d'imports exact
```tsx
'use client';

import { useState } from 'react';
import { Badge } from '@/components/ui/Badge';
import { Price } from '@/components/ui/Price';
import { estEnPromotion, hrefProduit, remisePourcent, type Produit } from '@/lib/catalogue';
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_02
cat > 'tickets/052-barre-annonce.md' <<'FIN_VICTO_03'
TICKET 052 — barre d'annonce

Crée `src/components/accueil/BarreAnnonce.tsx`, export `BarreAnnonce`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée ni ne modifie aucun autre fichier
  que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres dans une chaîne littérale.
  Tailwind ne génère que les classes qu'il lit dans le code ; une classe construite
  par interpolation n'existera jamais. Les tests vérifient leur présence. Tu peux en
  ajouter, jamais en retirer.
- Couleurs : tokens `var(--vs-*)` en priorité (`--vs-noir`, `--vs-blanc`,
  `--vs-surface`, `--vs-ligne`, `--vs-gris`, `--vs-accent` cobalt, `--vs-promo`
  rouge). Seules ces teintes décoratives sont autorisées en valeur directe :
  `#1E1E26` `#C70026` `#E9E4DA` `#D9D2C4` `#EEF1F8` `#B5B5BA` `#FFD3DB`.
- Toute icône `<svg>` porte `aria-hidden="true"`. Toute image purement décorative
  porte `alt=""`.
- Accès aux tableaux : `t[0]` a le type `T | undefined`. Pas de `!`, pas de `as` ;
  utilise `.map`, `.filter`, `.slice` ou des constantes nommées.
- `'use client'` en première ligne **seulement** si le composant a un état ou un effet.
## Contrat
- Racine `<div data-testid="barre-annonce">` aux classes imposées
  `bg-[var(--vs-noir)] text-[var(--vs-blanc)]`, hauteur 40 px, texte 13 px gras.
- Une `<ul>` aux classes imposées `flex items-center justify-center gap-7`,
  contenant trois `<li>` dont le texte est **exactement**, dans l'ordre :
  `Livraison offerte au Canada`, `Retours gratuits 30 jours`,
  `Authenticité garantie`.
- Le 2e et le 3e `<li>` portent les classes imposées `hidden sm:flex` : sur
  téléphone, seul le premier message reste.
- **Aucun séparateur** : ni point, ni barre, ni caractère décoratif. L'espacement
  `gap-7` suffit. Le texte de chaque `<li>` doit être exactement le message, rien d'autre.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_03
cat > 'tickets/053-en-tete.md' <<'FIN_VICTO_04'
TICKET 053 — SiteHeader : style de la maquette

Modifie `src/components/ui/SiteHeader.tsx`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée ni ne modifie aucun autre fichier
  que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres dans une chaîne littérale.
  Tailwind ne génère que les classes qu'il lit dans le code ; une classe construite
  par interpolation n'existera jamais. Les tests vérifient leur présence. Tu peux en
  ajouter, jamais en retirer.
- Couleurs : tokens `var(--vs-*)` en priorité (`--vs-noir`, `--vs-blanc`,
  `--vs-surface`, `--vs-ligne`, `--vs-gris`, `--vs-accent` cobalt, `--vs-promo`
  rouge). Seules ces teintes décoratives sont autorisées en valeur directe :
  `#1E1E26` `#C70026` `#E9E4DA` `#D9D2C4` `#EEF1F8` `#B5B5BA` `#FFD3DB`.
- Toute icône `<svg>` porte `aria-hidden="true"`. Toute image purement décorative
  porte `alt=""`.
- Accès aux tableaux : `t[0]` a le type `T | undefined`. Pas de `!`, pas de `as` ;
  utilise `.map`, `.filter`, `.slice` ou des constantes nommées.
- `'use client'` en première ligne **seulement** si le composant a un état ou un effet.
## Contrats existants à conserver absolument
`tests/SiteHeader.test.tsx` doit continuer à passer : rôle `banner` ; lien de
marque `data-testid="entete-marque"` vers `/` contenant `VICTO` ; **une seule**
`<nav aria-label="Navigation principale">` avec **un seul** lien par entrée ;
`data-testid="entete-panier"` vers `/panier`, `data-cart-count`, `aria-label`
`Panier, N article` ou `Panier, N articles` ; pastille
`data-testid="entete-panier-compte"` **seulement** si le panier n'est pas vide.

## Nouveautés
1. Exporte le type :
   ```ts
   export interface NavItem { label: string; href: string; promo?: boolean }
   ```
   Le `<a>` d'une entrée `promo: true` porte **lui-même** la classe imposée
   `text-[var(--vs-promo)]` ; les autres `<a>` ne l'ont pas. Le texte du lien est
   directement `label`, sans `<span>` intermédiaire.
2. Disposition en trois zones : un conteneur aux classes imposées
   `grid grid-cols-3 items-center`, qui contient dans l'ordre la navigation, la
   marque centrée, puis les actions alignées à droite.
3. La `<nav>` porte les classes imposées `hidden lg:flex`.
4. Trois boutons, tous `type="button"`, icône `<svg aria-hidden="true">`, 44 px :
   - `aria-label="Ouvrir le menu"`, classe imposée `lg:hidden`, placé dans la zone
     de gauche ; il n'ouvre rien pour l'instant et ne rend **aucune** autre liste de
     liens ;
   - `aria-label="Rechercher"` et `aria-label="Mon compte"`, dans la zone de droite,
     avant le lien panier.
5. Le lien panier contient une icône de sac `<svg aria-hidden="true">` ; la pastille
   de compte porte la classe imposée `bg-[var(--vs-accent)]`, texte blanc, ronde.
6. Marque : `VICTO STORE`, 26 px, graisse 900, lettres espacées.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_04
cat > 'tickets/054-carrousel.md' <<'FIN_VICTO_05'
TICKET 054 — carrousel d'accueil

Crée `src/components/accueil/Carrousel.tsx`, export `Carrousel`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée ni ne modifie aucun autre fichier
  que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres dans une chaîne littérale.
  Tailwind ne génère que les classes qu'il lit dans le code ; une classe construite
  par interpolation n'existera jamais. Les tests vérifient leur présence. Tu peux en
  ajouter, jamais en retirer.
- Couleurs : tokens `var(--vs-*)` en priorité (`--vs-noir`, `--vs-blanc`,
  `--vs-surface`, `--vs-ligne`, `--vs-gris`, `--vs-accent` cobalt, `--vs-promo`
  rouge). Seules ces teintes décoratives sont autorisées en valeur directe :
  `#1E1E26` `#C70026` `#E9E4DA` `#D9D2C4` `#EEF1F8` `#B5B5BA` `#FFD3DB`.
- Toute icône `<svg>` porte `aria-hidden="true"`. Toute image purement décorative
  porte `alt=""`.
- Accès aux tableaux : `t[0]` a le type `T | undefined`. Pas de `!`, pas de `as` ;
  utilise `.map`, `.filter`, `.slice` ou des constantes nommées.
- `'use client'` en première ligne **seulement** si le composant a un état ou un effet.
## Bloc d'imports exact
```tsx
'use client';

import { useEffect, useState } from 'react';
```

## Props
```ts
{ intervalleMs?: number; auto?: boolean }
```
Défauts : `intervalleMs = 5000`, `auto = true`.

## Données — à recopier telles quelles en tête de fichier
```ts
const DIAPOS = [
  {
    surTitre: 'Nouvelle saison',
    titre: 'Des grandes marques, au bon prix.',
    texte: 'Les marques que vous aimez, à moitié prix. Neuf, authentique, expédié du Québec.',
    image: '/img/accueil/photo-1.svg',
    fond: 'bg-[var(--vs-noir)] text-[var(--vs-blanc)]',
    actions: [
      { label: 'Découvrir la boutique', href: '/boutique', principale: true },
      { label: 'Voir les soldes', href: '/soldes', principale: false },
    ],
  },
  {
    surTitre: 'Soldes d’automne',
    titre: 'Jusqu’à −50 % sur les sneakers.',
    texte: 'Nike, Adidas, New Balance, Converse. Stocks limités, pointures qui partent vite.',
    image: '/img/accueil/photo-2.svg',
    fond: 'bg-[var(--vs-promo)] text-[var(--vs-blanc)]',
    actions: [{ label: 'Profiter des soldes', href: '/soldes', principale: true }],
  },
  {
    surTitre: 'Arrivages',
    titre: 'Le denim et le polo, réinventés.',
    texte: 'Levi’s et Lacoste rejoignent la sélection. Les classiques, sans le prix des classiques.',
    image: '/img/accueil/photo-3.svg',
    fond: 'bg-[#E9E4DA] text-[var(--vs-noir)]',
    actions: [{ label: 'Voir les nouveautés', href: '/nouveautes', principale: true }],
  },
] as const;
```
Les classes de `fond` sont écrites en toutes lettres ici justement pour que Tailwind
les voie : applique-les telles quelles avec `className={diapo.fond}`.

## État et défilement
- `const [index, setIndex] = useState(0);`
- Si `auto` vaut `true`, un `useEffect` installe
  `setInterval(() => setIndex((i) => (i + 1) % DIAPOS.length), intervalleMs)` et le
  nettoie avec `clearInterval` dans sa fonction de retour. Ses dépendances sont
  `[auto, intervalleMs]`.
- Suivante : `(i + 1) % 3`. Précédente : `(i + 2) % 3` (on boucle).

## Structure et contrat
- Racine `<section data-testid="carrousel" aria-label="À la une" aria-roledescription="carrousel">`
  aux classes imposées `relative overflow-hidden`.
- Piste `<div data-testid="carrousel-piste">` aux classes imposées
  `flex transition-transform duration-700 ease-in-out`, avec
  `style={{ transform: \`translateX(-${index * 100}%)\` }}`.
- Une diapositive par entrée : `<div data-testid={\`diapo-${n}\`}>` aux classes
  imposées `w-full shrink-0`, plus `diapo.fond`. Elle porte
  `aria-hidden={n !== index}` et `inert={n !== index}`.
- Contenu d'une diapositive, sur deux colonnes en grand écran (conteneur aux
  classes imposées `grid grid-cols-1 items-center gap-10 lg:grid-cols-2`) :
  - le sur-titre dans un `<span>` en petites capitales espacées ;
  - le titre : **`<h1>` pour la diapositive 0 uniquement**, `<h2>` pour les
    autres. Classes imposées sur les deux : `text-5xl font-black tracking-tight lg:text-7xl` ;
  - le texte dans un `<p>` ;
  - les actions dans un conteneur aux classes imposées `flex flex-wrap gap-4`, chacune
    `<a href>` en pilule (`rounded-full`), hauteur 54 px. Une action `principale`
    a un fond contrasté (blanc sur fond sombre ou rouge, cobalt sur fond sable) ; une
    action secondaire a une simple bordure ;
  - l'image : `<img src={diapo.image} alt="">` aux classes imposées
    `h-[520px] w-full rounded-[28px] object-cover`.
- **Commandes**, hors de la piste :
  - `<button type="button" aria-label="Diapositive précédente">` et
    `<button type="button" aria-label="Diapositive suivante">`, ronds, 48 px, avec
    une flèche `<svg aria-hidden="true">` ;
  - trois points : `<button type="button" aria-label="Aller à la diapositive 1">`
    (puis 2, 3), qui appellent `setIndex(n)`. Le point actif porte
    `aria-current="true"` et une largeur de 36 px ; les autres n'ont **pas du tout**
    l'attribut et font 8 px. Écris-le exactement ainsi, sinon React rendrait
    `aria-current="false"` sur les points inactifs :
    `aria-current={n === index ? 'true' : undefined}`. Hauteur 8 px, forme pilule.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_05
cat > 'tickets/055-bande-marques.md' <<'FIN_VICTO_06'
TICKET 055 — bande des marques qui défile

Crée `src/components/accueil/BandeMarques.tsx`, export `BandeMarques`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée ni ne modifie aucun autre fichier
  que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres dans une chaîne littérale.
  Tailwind ne génère que les classes qu'il lit dans le code ; une classe construite
  par interpolation n'existera jamais. Les tests vérifient leur présence. Tu peux en
  ajouter, jamais en retirer.
- Couleurs : tokens `var(--vs-*)` en priorité (`--vs-noir`, `--vs-blanc`,
  `--vs-surface`, `--vs-ligne`, `--vs-gris`, `--vs-accent` cobalt, `--vs-promo`
  rouge). Seules ces teintes décoratives sont autorisées en valeur directe :
  `#1E1E26` `#C70026` `#E9E4DA` `#D9D2C4` `#EEF1F8` `#B5B5BA` `#FFD3DB`.
- Toute icône `<svg>` porte `aria-hidden="true"`. Toute image purement décorative
  porte `alt=""`.
- Accès aux tableaux : `t[0]` a le type `T | undefined`. Pas de `!`, pas de `as` ;
  utilise `.map`, `.filter`, `.slice` ou des constantes nommées.
- `'use client'` en première ligne **seulement** si le composant a un état ou un effet.
## Bloc d'imports exact
```tsx
import { hrefMarque, type Marque } from '@/lib/catalogue';
```

## Props
```ts
{ marques: Marque[] }
```

## Principe
Une bande infinie : la liste des marques est rendue **deux fois** côte à côte, et
l'ensemble glisse de la moitié de sa largeur en boucle. Quand la première copie est
sortie, la seconde est exactement à sa place, d'où l'illusion d'un défilement sans fin.

## Contrat
- Racine `<section data-testid="bande-marques" aria-label="Nos marques">` aux
  classes imposées `overflow-hidden border-b border-[var(--vs-ligne)]`, hauteur 96 px.
- **En tout début de la section**, l'animation, exactement :
  ```tsx
  <style>{'@keyframes vs-defile{from{transform:translateX(0)}to{transform:translateX(-50%)}}'}</style>
  ```
- Piste `<div data-testid="bande-piste">` aux classes imposées
  `flex w-max items-center animate-[vs-defile_38s_linear_infinite] motion-reduce:animate-none`.
- Dans la piste, deux `<ul>` identiques, classes `flex items-center gap-16 pr-16` :
  - la **première** est normale ;
  - la **seconde** porte `aria-hidden="true"`, et chacun de ses liens
    `tabIndex={-1}` : c'est une copie visuelle, ni lue ni atteignable au clavier.
- Chaque `<li>` contient `<a href={hrefMarque(m)}>` au texte `m.nom` en
  capitales (`uppercase`), 26 px, graisse 900, suivi d'une étoile décorative
  `<span aria-hidden="true">✦</span>` en `var(--vs-promo)`.
- Itère avec `.map` et `key={m.id}` ; pour la copie, `key={\`copie-${m.id}\`}`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_06
cat > 'tickets/056-bonnes-affaires.md' <<'FIN_VICTO_07'
TICKET 056 — section des bonnes affaires

Crée `src/components/accueil/SectionBonnesAffaires.tsx`, export `SectionBonnesAffaires`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée ni ne modifie aucun autre fichier
  que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres dans une chaîne littérale.
  Tailwind ne génère que les classes qu'il lit dans le code ; une classe construite
  par interpolation n'existera jamais. Les tests vérifient leur présence. Tu peux en
  ajouter, jamais en retirer.
- Couleurs : tokens `var(--vs-*)` en priorité (`--vs-noir`, `--vs-blanc`,
  `--vs-surface`, `--vs-ligne`, `--vs-gris`, `--vs-accent` cobalt, `--vs-promo`
  rouge). Seules ces teintes décoratives sont autorisées en valeur directe :
  `#1E1E26` `#C70026` `#E9E4DA` `#D9D2C4` `#EEF1F8` `#B5B5BA` `#FFD3DB`.
- Toute icône `<svg>` porte `aria-hidden="true"`. Toute image purement décorative
  porte `alt=""`.
- Accès aux tableaux : `t[0]` a le type `T | undefined`. Pas de `!`, pas de `as` ;
  utilise `.map`, `.filter`, `.slice` ou des constantes nommées.
- `'use client'` en première ligne **seulement** si le composant a un état ou un effet.
## Bloc d'imports exact
```tsx
import { ProductCard } from '@/components/ui/ProductCard';
import type { Produit } from '@/lib/catalogue';
```

## Props
```ts
{ produits: Produit[] }
```

## Contrat
- Racine `<section data-testid="bonnes-affaires">`.
- En-tête aux classes imposées `flex items-end justify-between gap-4`, contenant :
  - un bloc avec `<span>` au texte exact `Prix cassés`, en petites capitales, couleur
    `var(--vs-promo)`, puis `<h2>` au texte exact
    `Les bonnes affaires du moment`, 48 px, graisse 900 ;
  - `<a href="/soldes">Tout voir</a>` en pilule bordée de `var(--vs-noir)`.
- Rail `<ul data-testid="rail">` aux classes imposées
  `flex gap-4 overflow-x-auto snap-x snap-mandatory md:grid md:grid-cols-4 md:gap-5 md:overflow-visible`.
  Sur téléphone, les cartes défilent au doigt ; en grand écran, quatre colonnes.
- Un `<li>` par produit, `key={p.id}`, aux classes imposées
  `w-[250px] shrink-0 snap-start md:w-auto`, contenant `<ProductCard produit={p} />`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_07
cat > 'tickets/057-mosaique.md' <<'FIN_VICTO_08'
TICKET 057 — mosaïque des catégories

Crée `src/components/accueil/MosaiqueCategories.tsx`, export `MosaiqueCategories`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée ni ne modifie aucun autre fichier
  que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres dans une chaîne littérale.
  Tailwind ne génère que les classes qu'il lit dans le code ; une classe construite
  par interpolation n'existera jamais. Les tests vérifient leur présence. Tu peux en
  ajouter, jamais en retirer.
- Couleurs : tokens `var(--vs-*)` en priorité (`--vs-noir`, `--vs-blanc`,
  `--vs-surface`, `--vs-ligne`, `--vs-gris`, `--vs-accent` cobalt, `--vs-promo`
  rouge). Seules ces teintes décoratives sont autorisées en valeur directe :
  `#1E1E26` `#C70026` `#E9E4DA` `#D9D2C4` `#EEF1F8` `#B5B5BA` `#FFD3DB`.
- Toute icône `<svg>` porte `aria-hidden="true"`. Toute image purement décorative
  porte `alt=""`.
- Accès aux tableaux : `t[0]` a le type `T | undefined`. Pas de `!`, pas de `as` ;
  utilise `.map`, `.filter`, `.slice` ou des constantes nommées.
- `'use client'` en première ligne **seulement** si le composant a un état ou un effet.
## Bloc d'imports exact
Aucun import.

## Données — à recopier telles quelles
```ts
const TUILES = [
  { titre: 'Femme', href: '/femme', image: '/img/accueil/photo-8.svg',
    classes: 'col-span-2 lg:col-span-1 lg:row-span-2 bg-[#1E1E26] text-[var(--vs-blanc)]' },
  { titre: 'Homme', href: '/homme', image: '/img/accueil/photo-9.svg',
    classes: 'bg-[#E9E4DA] text-[var(--vs-noir)]' },
  { titre: 'Chaussures', href: '/chaussures', image: '/img/accueil/photo-10.svg',
    classes: 'bg-[#EEF1F8] text-[var(--vs-noir)]' },
] as const;
```

## Contrat
- Racine `<section data-testid="categories">` contenant `<h2>` au texte exact
  `Par catégorie`, 48 px, graisse 900, puis une `<ul>`.
- `<ul>` aux classes imposées
  `grid grid-cols-2 gap-4 lg:h-[640px] lg:grid-cols-3 lg:grid-rows-2`.
- Trois `<li>` générés depuis `TUILES` avec `.map` et `key={t.href}`. Chaque
  `<li>` porte `className={t.classes}` **plus** les classes imposées
  `relative overflow-hidden rounded-[28px]`, et contient un unique
  `<a href={t.href}>` qui remplit la tuile et renferme :
  - `<img src={t.image} alt="">` aux classes imposées
    `absolute inset-0 h-full w-full object-cover` ;
  - le titre dans un `<span>`, 36 px, graisse 900, en bas à gauche ;
  - un rond de 48 px avec une flèche `<svg aria-hidden="true">`, en bas à droite.
  Le texte accessible du lien est donc **uniquement** le titre.
- Empilement : le `<a>` porte `relative flex h-full min-h-[190px] flex-col justify-end p-7`.
  L'image étant en position absolue, le titre et le rond fléché doivent porter la
  classe `relative` pour passer **au-dessus** de la photo ; sinon elle les masque.
- Un quatrième `<li>`, écrit à la main après les trois autres, aux classes imposées
  `col-span-2 relative overflow-hidden rounded-[28px] bg-[var(--vs-promo)] text-[var(--vs-blanc)]`,
  contenant `<a href="/soldes">` avec `<span>Soldes</span>` en petites capitales,
  puis `<span>Jusqu’à −50 %</span>` en 44 px graisse 900, et le rond fléché blanc.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_08
cat > 'tickets/058-infolettre.md' <<'FIN_VICTO_09'
TICKET 058 — bandeau d'inscription à l'infolettre

Crée `src/components/accueil/Infolettre.tsx`, export `Infolettre`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée ni ne modifie aucun autre fichier
  que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres dans une chaîne littérale.
  Tailwind ne génère que les classes qu'il lit dans le code ; une classe construite
  par interpolation n'existera jamais. Les tests vérifient leur présence. Tu peux en
  ajouter, jamais en retirer.
- Couleurs : tokens `var(--vs-*)` en priorité (`--vs-noir`, `--vs-blanc`,
  `--vs-surface`, `--vs-ligne`, `--vs-gris`, `--vs-accent` cobalt, `--vs-promo`
  rouge). Seules ces teintes décoratives sont autorisées en valeur directe :
  `#1E1E26` `#C70026` `#E9E4DA` `#D9D2C4` `#EEF1F8` `#B5B5BA` `#FFD3DB`.
- Toute icône `<svg>` porte `aria-hidden="true"`. Toute image purement décorative
  porte `alt=""`.
- Accès aux tableaux : `t[0]` a le type `T | undefined`. Pas de `!`, pas de `as` ;
  utilise `.map`, `.filter`, `.slice` ou des constantes nommées.
- `'use client'` en première ligne **seulement** si le composant a un état ou un effet.
## Bloc d'imports exact
```tsx
'use client';

import { useState, type FormEvent } from 'react';
```

## Contrat
- Racine `<section data-testid="infolettre">` ; à l'intérieur, un bloc aux classes
  imposées `grid grid-cols-1 items-center gap-8 rounded-[28px] bg-[var(--vs-accent)] text-[var(--vs-blanc)] lg:grid-cols-2`,
  avec un grand espacement intérieur.
- Colonne de gauche : `<h2>−10 % sur votre première commande.</h2>`, 40 px,
  graisse 900 ; puis `<p>Les arrivages et les ventes privées, avant tout le monde.</p>`.
- Colonne de droite, tant que l'inscription n'est pas faite :
  `<form data-testid="infolettre-formulaire" noValidate onSubmit={envoyer}>` aux classes
  imposées `flex flex-col gap-3 sm:flex-row`, contenant :
  - `<label htmlFor="infolettre-courriel" className="sr-only">Votre courriel</label>`
  - `<input id="infolettre-courriel" type="email" placeholder="Votre courriel">`
    contrôlé par `useState('')`, en pilule, fond blanc, hauteur 56 px ;
  - `<button type="submit">Recevoir le code</button>` en pilule, fond
    `var(--vs-noir)`, texte blanc.
- `envoyer(e: FormEvent<HTMLFormElement>)` commence **toujours** par
  `e.preventDefault()`. Puis :
  - si la valeur ne contient pas `@` : afficher sous le formulaire
    `<p role="alert">Entrez une adresse courriel valide.</p>` ;
  - sinon : remplacer le formulaire par
    `<p data-testid="infolettre-merci">Merci, votre code arrive par courriel.</p>`.
- Aucun envoi réseau : c'est une maquette fonctionnelle, le branchement viendra plus tard.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_09
cat > 'tickets/059-reassurance.md' <<'FIN_VICTO_10'
TICKET 059 — bloc de réassurance

Crée `src/components/accueil/Reassurance.tsx`, export `Reassurance`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée ni ne modifie aucun autre fichier
  que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres dans une chaîne littérale.
  Tailwind ne génère que les classes qu'il lit dans le code ; une classe construite
  par interpolation n'existera jamais. Les tests vérifient leur présence. Tu peux en
  ajouter, jamais en retirer.
- Couleurs : tokens `var(--vs-*)` en priorité (`--vs-noir`, `--vs-blanc`,
  `--vs-surface`, `--vs-ligne`, `--vs-gris`, `--vs-accent` cobalt, `--vs-promo`
  rouge). Seules ces teintes décoratives sont autorisées en valeur directe :
  `#1E1E26` `#C70026` `#E9E4DA` `#D9D2C4` `#EEF1F8` `#B5B5BA` `#FFD3DB`.
- Toute icône `<svg>` porte `aria-hidden="true"`. Toute image purement décorative
  porte `alt=""`.
- Accès aux tableaux : `t[0]` a le type `T | undefined`. Pas de `!`, pas de `as` ;
  utilise `.map`, `.filter`, `.slice` ou des constantes nommées.
- `'use client'` en première ligne **seulement** si le composant a un état ou un effet.
## Bloc d'imports exact
Aucun import.

## Données — à recopier telles quelles
```ts
const ENGAGEMENTS = [
  { titre: 'Livraison offerte au Canada', texte: 'Expédiée du Québec sous 48 heures.', icone: 'camion' },
  { titre: 'Retours gratuits 30 jours', texte: 'Une taille qui ne va pas ? On l’échange.', icone: 'retour' },
  { titre: 'Paiement sécurisé', texte: 'Vos données de carte ne transitent jamais par nos serveurs.', icone: 'cadenas' },
] as const;
```

## Contrat
- Racine `<section data-testid="reassurance">` avec une bordure haute
  `var(--vs-ligne)`, contenant une `<ul>` aux classes imposées
  `grid grid-cols-1 gap-8 sm:grid-cols-3 lg:gap-12`.
- Un `<li>` par engagement (`.map`, `key={e.titre}`), en ligne : un carré arrondi
  de 52 px fond `var(--vs-surface)` contenant l'icône, puis `<h3>` au texte
  `e.titre` et `<p>` au texte `e.texte` en `var(--vs-gris)`.
- Icônes : trois `<svg aria-hidden="true">` en trait (`fill="none"`,
  `stroke="currentColor"`), choisies selon `e.icone` avec des `if` ou une
  table de correspondance : un camion, une flèche circulaire de retour, un cadenas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_10
cat > 'tickets/060-pied.md' <<'FIN_VICTO_11'
TICKET 060 — SiteFooter : style de la maquette

Modifie `src/components/ui/SiteFooter.tsx`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée ni ne modifie aucun autre fichier
  que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres dans une chaîne littérale.
  Tailwind ne génère que les classes qu'il lit dans le code ; une classe construite
  par interpolation n'existera jamais. Les tests vérifient leur présence. Tu peux en
  ajouter, jamais en retirer.
- Couleurs : tokens `var(--vs-*)` en priorité (`--vs-noir`, `--vs-blanc`,
  `--vs-surface`, `--vs-ligne`, `--vs-gris`, `--vs-accent` cobalt, `--vs-promo`
  rouge). Seules ces teintes décoratives sont autorisées en valeur directe :
  `#1E1E26` `#C70026` `#E9E4DA` `#D9D2C4` `#EEF1F8` `#B5B5BA` `#FFD3DB`.
- Toute icône `<svg>` porte `aria-hidden="true"`. Toute image purement décorative
  porte `alt=""`.
- Accès aux tableaux : `t[0]` a le type `T | undefined`. Pas de `!`, pas de `as` ;
  utilise `.map`, `.filter`, `.slice` ou des constantes nommées.
- `'use client'` en première ligne **seulement** si le composant a un état ou un effet.
## Contrats existants à conserver absolument
`tests/SiteFooter.test.tsx` doit continuer à passer : `<footer data-testid="pied">`
de premier niveau ; un `<h2>` et une liste de liens par colonne ;
`pied-mentions` exactement `© <annee> VICTO STORE` ; `pied-slogan` exactement
`Des grandes marques, au bon prix.`.

## Nouveautés
1. Le `<footer>` porte les classes imposées `bg-[var(--vs-noir)] text-[var(--vs-blanc)]`.
2. En haut : la marque `VICTO STORE` (26 px, 900) et le slogan à gauche, les
   colonnes à droite, titres de colonnes en petites capitales `#B5B5BA`, liens blancs.
3. Au-dessus des mentions, un filigrane décoratif :
   `<p aria-hidden="true" data-testid="pied-filigrane">VICTO</p>` aux classes
   imposées `select-none text-[200px] font-black leading-none text-[#1E1E26]`.
4. Les mentions, séparées par une bordure haute fine, en `#B5B5BA`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_11
cat > 'tickets/061-page-accueil.md' <<'FIN_VICTO_12'
TICKET 061 — page d'accueil, assemblage final

Remplace entièrement `src/app/page.tsx`. Export nommé `AccueilPage`, plus
`export default AccueilPage;` en fin de fichier (Next.js l'exige pour une route ;
seule exception à la règle des exports nommés).

## Règles absolues
- TypeScript strict. **Ne modifie aucun test.** Ne crée aucun autre fichier.
- **Aucun fichier baril n'existe.** Pas de `'use client'` : la page n'a aucun état,
  ce sont ses composants qui en ont.
- Classes imposées en toutes lettres, jamais construites dynamiquement.

## Bloc d'imports exact

Recopie ce bloc tel quel, sans rien ajouter ni retirer.

```tsx
import { BandeMarques } from '@/components/accueil/BandeMarques';
import { BarreAnnonce } from '@/components/accueil/BarreAnnonce';
import { Carrousel } from '@/components/accueil/Carrousel';
import { Infolettre } from '@/components/accueil/Infolettre';
import { MosaiqueCategories } from '@/components/accueil/MosaiqueCategories';
import { Reassurance } from '@/components/accueil/Reassurance';
import { SectionBonnesAffaires } from '@/components/accueil/SectionBonnesAffaires';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader, type NavItem } from '@/components/ui/SiteHeader';
import { estEnPromotion } from '@/lib/catalogue';
import { listerMarques, listerProduits } from '@/lib/donnees';
```

## Signatures des composants

Tu n'as pas besoin de lire leur code :

```ts
BarreAnnonce()
SiteHeader({ navItems: NavItem[]; cartCount?: number })   // NavItem = { label; href; promo? }
Carrousel({ intervalleMs?: number; auto?: boolean })
BandeMarques({ marques: Marque[] })
SectionBonnesAffaires({ produits: Produit[] })
MosaiqueCategories()
Infolettre()
Reassurance()
SiteFooter({ colonnes: Array<{ titre: string; liens: Array<{ label: string; href: string }> }>; annee?: number })
```

## Données — en tête de fichier, sous les imports

```ts
const NAV: NavItem[] = [
  { label: 'Femme', href: '/femme' },
  { label: 'Homme', href: '/homme' },
  { label: 'Chaussures', href: '/chaussures' },
  { label: 'Marques', href: '/marques' },
  { label: 'Soldes', href: '/soldes', promo: true },
];

const COLONNES_PIED = [
  { titre: 'Boutique', liens: [
    { label: 'Femme', href: '/femme' },
    { label: 'Homme', href: '/homme' },
    { label: 'Soldes', href: '/soldes' },
  ] },
  { titre: 'Aide', liens: [
    { label: 'Livraison', href: '/livraison' },
    { label: 'Retours', href: '/retours' },
    { label: 'Contact', href: '/contact' },
  ] },
];
```

Dans le composant, **exactement** :

```ts
const bonnesAffaires = listerProduits().filter(estEnPromotion).slice(0, 4);
```

## Structure, dans cet ordre exact

```tsx
<>
  <BarreAnnonce />
  <SiteHeader navItems={NAV} cartCount={0} />
  <main>
    <Carrousel />
    <BandeMarques marques={listerMarques()} />
    <div className="mx-auto max-w-[1440px] px-5 py-24 lg:px-20">
      <SectionBonnesAffaires produits={bonnesAffaires} />
    </div>
    <div className="mx-auto max-w-[1440px] px-5 pb-24 lg:px-20">
      <MosaiqueCategories />
    </div>
    <div className="mx-auto max-w-[1440px] px-5 pb-24 lg:px-20">
      <Infolettre />
    </div>
    <div className="mx-auto max-w-[1440px] px-5 py-14 lg:px-20">
      <Reassurance />
    </div>
  </main>
  <SiteFooter colonnes={COLONNES_PIED} annee={2026} />
</>
```

Recopie cette structure telle quelle : les classes des `<div>` d'enveloppe sont
imposées et testées. Un seul `<h1>` existe sur la page, celui de la première
diapositive du carrousel ; n'en ajoute aucun.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_12
cat > 'tickets/manifest-accueil-v2.tsv' <<'FIN_VICTO_13'
# id	cible	tests	spec	contexte_lecture_seule
050	src/components/ui/Price.tsx	tests/accueil2-Price.test.tsx	tickets/050-prix-remise.md	
051	src/components/ui/ProductCard.tsx	tests/accueil2-ProductCard.test.tsx	tickets/051-carte-produit.md	src/components/ui/Price.tsx,src/components/ui/Badge.tsx,src/lib/catalogue.ts
052	src/components/accueil/BarreAnnonce.tsx	tests/accueil2-BarreAnnonce.test.tsx	tickets/052-barre-annonce.md	
053	src/components/ui/SiteHeader.tsx	tests/accueil2-SiteHeader.test.tsx	tickets/053-en-tete.md	
054	src/components/accueil/Carrousel.tsx	tests/accueil2-Carrousel.test.tsx	tickets/054-carrousel.md	
055	src/components/accueil/BandeMarques.tsx	tests/accueil2-BandeMarques.test.tsx	tickets/055-bande-marques.md	src/lib/catalogue.ts
056	src/components/accueil/SectionBonnesAffaires.tsx	tests/accueil2-BonnesAffaires.test.tsx	tickets/056-bonnes-affaires.md	src/components/ui/ProductCard.tsx
057	src/components/accueil/MosaiqueCategories.tsx	tests/accueil2-Mosaique.test.tsx	tickets/057-mosaique.md	
058	src/components/accueil/Infolettre.tsx	tests/accueil2-Infolettre.test.tsx	tickets/058-infolettre.md	
059	src/components/accueil/Reassurance.tsx	tests/accueil2-Reassurance.test.tsx	tickets/059-reassurance.md	
060	src/components/ui/SiteFooter.tsx	tests/accueil2-SiteFooter.test.tsx	tickets/060-pied.md	
061	src/app/page.tsx	tests/accueil2-page.test.tsx	tickets/061-page-accueil.md	
FIN_VICTO_13
cat > 'tickets/tests/GrilleProduits.classes.test.tsx' <<'FIN_VICTO_14'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { GrilleProduits } from '../src/components/catalogue/GrilleProduits';
import type { Produit } from '../src/lib/catalogue';

const P = (id: string): Produit => ({
  id,
  slug: `p-${id}`,
  nom: `Produit ${id}`,
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.svg',
  prixCents: 9900,
  variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 2 }],
});

function classes(el: Element): string[] {
  return el.className.split(/\s+/).filter(Boolean);
}

describe('GrilleProduits — mise en page', () => {
  it.each(['grid', 'grid-cols-1', 'gap-6', 'sm:grid-cols-2', 'lg:grid-cols-3'])(
    'porte la classe %s',
    (c) => {
      render(<GrilleProduits produits={[P('a'), P('b')]} />);
      expect(classes(screen.getByTestId('grille'))).toContain(c);
    },
  );

  it('conserve la classe fournie en prop', () => {
    render(<GrilleProduits produits={[P('a')]} className="perso" />);
    expect(classes(screen.getByTestId('grille'))).toContain('perso');
  });
});
FIN_VICTO_14
cat > 'tickets/tests/accueil2-BandeMarques.test.tsx' <<'FIN_VICTO_15'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { BandeMarques } from '../src/components/accueil/BandeMarques';
import type { Marque } from '../src/lib/catalogue';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const MARQUES: Marque[] = [
  { id: 'm1', nom: 'Nike', slug: 'nike' },
  { id: 'm2', nom: 'New Balance', slug: 'new-balance' },
  { id: 'm3', nom: "Levi's", slug: 'levis' },
];

describe('BandeMarques', () => {
  it('rend une région étiquetée', () => {
    render(<BandeMarques marques={MARQUES} />);
    const s = screen.getByTestId('bande-marques');
    expect(s).toHaveAttribute('aria-label', 'Nos marques');
    for (const k of ['overflow-hidden', 'border-b', 'border-[var(--vs-ligne)]']) expect(classes(s)).toContain(k);
  });

  it('anime la piste en boucle, sauf mouvement réduit', () => {
    render(<BandeMarques marques={MARQUES} />);
    const p = screen.getByTestId('bande-piste');
    for (const k of ['flex', 'w-max', 'items-center', 'animate-[vs-defile_38s_linear_infinite]', 'motion-reduce:animate-none']) {
      expect(classes(p)).toContain(k);
    }
  });

  it('déclare l’animation', () => {
    const { container } = render(<BandeMarques marques={MARQUES} />);
    const style = container.querySelector('style');
    expect(style?.textContent).toContain('@keyframes vs-defile');
    expect(style?.textContent).toContain('translateX(-50%)');
  });

  it('expose chaque marque une seule fois aux lecteurs d’écran', () => {
    render(<BandeMarques marques={MARQUES} />);
    const liens = screen.getAllByRole('link');
    expect(liens).toHaveLength(3);
    expect(screen.getByRole('link', { name: 'Nike' })).toHaveAttribute('href', '/marques/nike');
    expect(screen.getByRole('link', { name: 'New Balance' })).toHaveAttribute('href', '/marques/new-balance');
  });

  it('duplique la liste pour la boucle, copie masquée et hors tabulation', () => {
    const { container } = render(<BandeMarques marques={MARQUES} />);
    const listes = Array.from(screen.getByTestId('bande-piste').querySelectorAll('ul'));
    expect(listes).toHaveLength(2);
    expect(listes[0]?.getAttribute('aria-hidden')).toBeNull();
    expect(listes[1]?.getAttribute('aria-hidden')).toBe('true');
    const copies = Array.from((listes[1] as Element).querySelectorAll('a'));
    expect(copies).toHaveLength(3);
    for (const a of copies) expect(a.getAttribute('tabindex')).toBe('-1');
    expect(container.querySelectorAll('a')).toHaveLength(6);
  });
});
FIN_VICTO_15
cat > 'tickets/tests/accueil2-BarreAnnonce.test.tsx' <<'FIN_VICTO_16'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { BarreAnnonce } from '../src/components/accueil/BarreAnnonce';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);

describe('BarreAnnonce', () => {
  it('porte les couleurs imposées', () => {
    render(<BarreAnnonce />);
    const barre = screen.getByTestId('barre-annonce');
    for (const c of ['bg-[var(--vs-noir)]', 'text-[var(--vs-blanc)]']) expect(classes(barre)).toContain(c);
  });

  it('affiche les trois messages dans l’ordre', () => {
    render(<BarreAnnonce />);
    const items = Array.from(screen.getByTestId('barre-annonce').querySelectorAll('li'));
    expect(items.map((li) => li.textContent?.trim())).toEqual([
      'Livraison offerte au Canada',
      'Retours gratuits 30 jours',
      'Authenticité garantie',
    ]);
  });

  it('centre la liste', () => {
    render(<BarreAnnonce />);
    const ul = screen.getByTestId('barre-annonce').querySelector('ul');
    expect(ul).not.toBeNull();
    for (const c of ['flex', 'items-center', 'justify-center', 'gap-7']) {
      expect(classes(ul as Element)).toContain(c);
    }
  });

  it('ne garde que le premier message sur téléphone', () => {
    render(<BarreAnnonce />);
    const items = Array.from(screen.getByTestId('barre-annonce').querySelectorAll('li'));
    expect(classes(items[0] as Element)).not.toContain('hidden');
    for (const li of items.slice(1)) {
      expect(classes(li)).toContain('hidden');
      expect(classes(li)).toContain('sm:flex');
    }
  });
});
FIN_VICTO_16
cat > 'tickets/tests/accueil2-BonnesAffaires.test.tsx' <<'FIN_VICTO_17'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SectionBonnesAffaires } from '../src/components/accueil/SectionBonnesAffaires';
import type { Produit } from '../src/lib/catalogue';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const P = (id: string): Produit => ({
  id,
  slug: `p-${id}`,
  nom: `Produit ${id}`,
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.svg',
  prixCents: 8000,
  prixCompareCents: 10000,
  variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 2 }],
});
const QUATRE = [P('a'), P('b'), P('c'), P('d')];

describe('SectionBonnesAffaires — en-tête', () => {
  it('titre la section', () => {
    render(<SectionBonnesAffaires produits={QUATRE} />);
    expect(screen.getByRole('heading', { level: 2 }).textContent).toBe('Les bonnes affaires du moment');
    expect(screen.getByText('Prix cassés')).toBeInTheDocument();
  });

  it('aligne le titre et le lien « Tout voir »', () => {
    render(<SectionBonnesAffaires produits={QUATRE} />);
    const lien = screen.getByRole('link', { name: 'Tout voir' });
    expect(lien).toHaveAttribute('href', '/soldes');
    const entete = lien.closest('.justify-between');
    expect(entete).not.toBeNull();
    for (const k of ['flex', 'items-end', 'justify-between', 'gap-4']) expect(classes(entete as Element)).toContain(k);
    expect((entete as Element).contains(screen.getByRole('heading', { level: 2 }))).toBe(true);
  });
});

describe('SectionBonnesAffaires — rail', () => {
  it('rend une carte par produit', () => {
    render(<SectionBonnesAffaires produits={QUATRE} />);
    expect(screen.getByTestId('rail').querySelectorAll(':scope > li')).toHaveLength(4);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(4);
  });

  it.each([
    'flex', 'gap-4', 'overflow-x-auto', 'snap-x', 'snap-mandatory',
    'md:grid', 'md:grid-cols-4', 'md:gap-5', 'md:overflow-visible',
  ])('le rail porte %s', (k) => {
    render(<SectionBonnesAffaires produits={QUATRE} />);
    expect(classes(screen.getByTestId('rail'))).toContain(k);
  });

  it('dimensionne chaque élément du rail', () => {
    render(<SectionBonnesAffaires produits={QUATRE} />);
    for (const li of Array.from(screen.getByTestId('rail').querySelectorAll(':scope > li'))) {
      for (const k of ['w-[250px]', 'shrink-0', 'snap-start', 'md:w-auto']) expect(classes(li)).toContain(k);
    }
  });
});
FIN_VICTO_17
cat > 'tickets/tests/accueil2-Carrousel.test.tsx' <<'FIN_VICTO_18'
import { act, fireEvent, render, screen, within } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { Carrousel } from '../src/components/accueil/Carrousel';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const active = () =>
  [0, 1, 2].filter((n) => screen.getByTestId(`diapo-${n}`).getAttribute('aria-hidden') === 'false');

afterEach(() => {
  vi.useRealTimers();
});

describe('Carrousel — structure', () => {
  it('rend une région étiquetée', () => {
    render(<Carrousel auto={false} />);
    const c = screen.getByTestId('carrousel');
    expect(c.tagName).toBe('SECTION');
    expect(c).toHaveAttribute('aria-label', 'À la une');
    expect(c).toHaveAttribute('aria-roledescription', 'carrousel');
    for (const k of ['relative', 'overflow-hidden']) expect(classes(c)).toContain(k);
  });

  it('rend trois diapositives dans une piste animée', () => {
    render(<Carrousel auto={false} />);
    const piste = screen.getByTestId('carrousel-piste');
    for (const k of ['flex', 'transition-transform', 'duration-700', 'ease-in-out']) {
      expect(classes(piste)).toContain(k);
    }
    for (const n of [0, 1, 2]) {
      const d = screen.getByTestId(`diapo-${n}`);
      expect(piste.contains(d)).toBe(true);
      expect(classes(d)).toContain('w-full');
      expect(classes(d)).toContain('shrink-0');
    }
  });

  it('ne rend qu’un seul titre de niveau 1, sur la première diapositive', () => {
    render(<Carrousel auto={false} />);
    const h1 = screen.getAllByRole('heading', { level: 1, hidden: true });
    expect(h1).toHaveLength(1);
    expect(h1[0]?.textContent).toBe('Des grandes marques, au bon prix.');
    expect(screen.getByTestId('diapo-0').contains(h1[0] as Element)).toBe(true);
  });

  it('impose la taille des titres', () => {
    render(<Carrousel auto={false} />);
    const titres = [
      ...screen.getAllByRole('heading', { level: 1, hidden: true }),
      ...screen.getAllByRole('heading', { level: 2, hidden: true }),
    ];
    expect(titres).toHaveLength(3);
    for (const t of titres) {
      for (const k of ['text-5xl', 'font-black', 'tracking-tight', 'lg:text-7xl']) expect(classes(t)).toContain(k);
    }
  });

  it('affiche les trois visuels décoratifs', () => {
    const { container } = render(<Carrousel auto={false} />);
    const imgs = Array.from(container.querySelectorAll('img'));
    expect(imgs.map((i) => i.getAttribute('src'))).toEqual([
      '/img/accueil/photo-1.svg',
      '/img/accueil/photo-2.svg',
      '/img/accueil/photo-3.svg',
    ]);
    for (const i of imgs) {
      expect(i.getAttribute('alt')).toBe('');
      for (const k of ['h-[520px]', 'w-full', 'rounded-[28px]', 'object-cover']) expect(classes(i)).toContain(k);
    }
  });
});

describe('Carrousel — actions des diapositives', () => {
  it.each([
    [0, 'Découvrir la boutique', '/boutique'],
    [0, 'Voir les soldes', '/soldes'],
    [1, 'Profiter des soldes', '/soldes'],
    [2, 'Voir les nouveautés', '/nouveautes'],
  ])('la diapositive %i propose « %s »', (n, nom, href) => {
    render(<Carrousel auto={false} />);
    const lien = within(screen.getByTestId(`diapo-${n}`)).getByRole('link', { name: nom, hidden: true });
    expect(lien).toHaveAttribute('href', href);
  });
});

describe('Carrousel — navigation', () => {
  it('démarre sur la première diapositive', () => {
    render(<Carrousel auto={false} />);
    expect(active()).toEqual([0]);
  });

  it('avance et recule en boucle', () => {
    render(<Carrousel auto={false} />);
    fireEvent.click(screen.getByRole('button', { name: 'Diapositive suivante' }));
    expect(active()).toEqual([1]);
    expect(screen.getByTestId('carrousel-piste').style.transform).toContain('-100%');
    fireEvent.click(screen.getByRole('button', { name: 'Diapositive précédente' }));
    fireEvent.click(screen.getByRole('button', { name: 'Diapositive précédente' }));
    expect(active()).toEqual([2]);
    fireEvent.click(screen.getByRole('button', { name: 'Diapositive suivante' }));
    expect(active()).toEqual([0]);
  });

  it('va directement à une diapositive par ses points', () => {
    render(<Carrousel auto={false} />);
    const point3 = screen.getByRole('button', { name: 'Aller à la diapositive 3' });
    expect(point3).not.toHaveAttribute('aria-current');
    fireEvent.click(point3);
    expect(active()).toEqual([2]);
    expect(point3).toHaveAttribute('aria-current', 'true');
    expect(screen.getByRole('button', { name: 'Aller à la diapositive 1' })).not.toHaveAttribute('aria-current');
  });
});

describe('Carrousel — défilement automatique', () => {
  it('passe seul à la diapositive suivante', () => {
    vi.useFakeTimers();
    render(<Carrousel />);
    expect(active()).toEqual([0]);
    act(() => {
      vi.advanceTimersByTime(5000);
    });
    expect(active()).toEqual([1]);
    act(() => {
      vi.advanceTimersByTime(10000);
    });
    expect(active()).toEqual([0]);
  });

  it('respecte l’intervalle fourni', () => {
    vi.useFakeTimers();
    render(<Carrousel intervalleMs={1000} />);
    act(() => {
      vi.advanceTimersByTime(1000);
    });
    expect(active()).toEqual([1]);
  });

  it('ne bouge pas quand auto vaut false', () => {
    vi.useFakeTimers();
    render(<Carrousel auto={false} />);
    act(() => {
      vi.advanceTimersByTime(20000);
    });
    expect(active()).toEqual([0]);
  });
});
FIN_VICTO_18
cat > 'tickets/tests/accueil2-Infolettre.test.tsx' <<'FIN_VICTO_19'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Infolettre } from '../src/components/accueil/Infolettre';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const champ = () => screen.getByLabelText('Votre courriel');
const envoyer = () => fireEvent.submit(screen.getByTestId('infolettre-formulaire'));

describe('Infolettre — présentation', () => {
  it('rend le bandeau cobalt sur deux colonnes', () => {
    render(<Infolettre />);
    const bloc = screen.getByRole('heading', { level: 2 }).closest('.rounded-\\[28px\\]');
    expect(bloc).not.toBeNull();
    for (const k of ['grid', 'grid-cols-1', 'items-center', 'gap-8', 'rounded-[28px]', 'bg-[var(--vs-accent)]', 'text-[var(--vs-blanc)]', 'lg:grid-cols-2']) {
      expect(classes(bloc as Element)).toContain(k);
    }
  });

  it('étiquette le champ de courriel', () => {
    render(<Infolettre />);
    expect(champ()).toHaveAttribute('type', 'email');
    expect(champ()).toHaveAttribute('id', 'infolettre-courriel');
  });

  it('propose le bouton d’envoi', () => {
    render(<Infolettre />);
    expect(screen.getByRole('button', { name: 'Recevoir le code' })).toHaveAttribute('type', 'submit');
  });

  it('dispose le formulaire', () => {
    render(<Infolettre />);
    const f = screen.getByTestId('infolettre-formulaire');
    for (const k of ['flex', 'flex-col', 'gap-3', 'sm:flex-row']) expect(classes(f)).toContain(k);
  });
});

describe('Infolettre — comportement', () => {
  it('refuse une adresse sans arobase', () => {
    render(<Infolettre />);
    fireEvent.change(champ(), { target: { value: 'pas-une-adresse' } });
    envoyer();
    expect(screen.getByRole('alert').textContent).toBe('Entrez une adresse courriel valide.');
    expect(screen.queryByTestId('infolettre-merci')).toBeNull();
  });

  it('refuse un champ vide', () => {
    render(<Infolettre />);
    envoyer();
    expect(screen.getByRole('alert')).toBeInTheDocument();
  });

  it('remercie après une adresse valide', () => {
    render(<Infolettre />);
    fireEvent.change(champ(), { target: { value: 'moi@exemple.com' } });
    envoyer();
    expect(screen.getByTestId('infolettre-merci').textContent).toBe('Merci, votre code arrive par courriel.');
    expect(screen.queryByTestId('infolettre-formulaire')).toBeNull();
    expect(screen.queryByRole('alert')).toBeNull();
  });
});
FIN_VICTO_19
cat > 'tickets/tests/accueil2-Mosaique.test.tsx' <<'FIN_VICTO_20'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { MosaiqueCategories } from '../src/components/accueil/MosaiqueCategories';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);

describe('MosaiqueCategories', () => {
  it('titre la section', () => {
    render(<MosaiqueCategories />);
    expect(screen.getByTestId('categories')).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 2 }).textContent).toBe('Par catégorie');
  });

  it.each(['grid', 'grid-cols-2', 'gap-4', 'lg:h-[640px]', 'lg:grid-cols-3', 'lg:grid-rows-2'])(
    'la grille porte %s',
    (k) => {
      render(<MosaiqueCategories />);
      const ul = screen.getByTestId('categories').querySelector('ul');
      expect(classes(ul as Element)).toContain(k);
    },
  );

  it('rend quatre tuiles dans l’ordre', () => {
    render(<MosaiqueCategories />);
    const hrefs = screen.getAllByRole('link').map((a) => a.getAttribute('href'));
    expect(hrefs).toEqual(['/femme', '/homme', '/chaussures', '/soldes']);
  });

  it.each(['Femme', 'Homme', 'Chaussures'])('le lien %s ne porte que son titre', (titre) => {
    render(<MosaiqueCategories />);
    expect(screen.getByRole('link', { name: titre })).toBeInTheDocument();
  });

  it('étend la tuile Femme sur deux rangées en grand écran', () => {
    render(<MosaiqueCategories />);
    const li = screen.getByRole('link', { name: 'Femme' }).closest('li') as Element;
    for (const k of ['col-span-2', 'lg:col-span-1', 'lg:row-span-2', 'relative', 'overflow-hidden', 'rounded-[28px]']) {
      expect(classes(li)).toContain(k);
    }
  });

  it('étend la tuile Soldes sur deux colonnes, en rouge', () => {
    render(<MosaiqueCategories />);
    const lien = screen.getAllByRole('link').find((a) => a.getAttribute('href') === '/soldes');
    const li = lien?.closest('li') as Element;
    for (const k of ['col-span-2', 'rounded-[28px]', 'bg-[var(--vs-promo)]']) expect(classes(li)).toContain(k);
  });

  it('remplit trois tuiles d’une photo décorative', () => {
    const { container } = render(<MosaiqueCategories />);
    const imgs = Array.from(container.querySelectorAll('img'));
    expect(imgs.map((i) => i.getAttribute('src'))).toEqual([
      '/img/accueil/photo-8.svg',
      '/img/accueil/photo-9.svg',
      '/img/accueil/photo-10.svg',
    ]);
    for (const i of imgs) {
      expect(i.getAttribute('alt')).toBe('');
      for (const k of ['absolute', 'inset-0', 'h-full', 'w-full', 'object-cover']) expect(classes(i)).toContain(k);
    }
  });
});
FIN_VICTO_20
cat > 'tickets/tests/accueil2-Price.test.tsx' <<'FIN_VICTO_21'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Price } from '../src/components/ui/Price';

describe('Price — option afficherRemise', () => {
  it('affiche la remise par défaut', () => {
    render(<Price amount={12600} compareAt={18000} />);
    expect(screen.getByTestId('prix-remise')).toBeInTheDocument();
  });

  it('masque la remise quand afficherRemise vaut false', () => {
    render(<Price amount={12600} compareAt={18000} afficherRemise={false} />);
    expect(screen.queryByTestId('prix-remise')).toBeNull();
  });

  it('garde le prix barré et la promotion quand la remise est masquée', () => {
    render(<Price amount={12600} compareAt={18000} afficherRemise={false} />);
    expect(screen.getByTestId('prix-compare')).toBeInTheDocument();
    expect(screen.getByTestId('prix')).toHaveAttribute('data-promo', 'true');
  });
});
FIN_VICTO_21
cat > 'tickets/tests/accueil2-ProductCard.test.tsx' <<'FIN_VICTO_22'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ProductCard } from '../src/components/ui/ProductCard';
import type { Produit } from '../src/lib/catalogue';

const NB = '\u00A0';
const MOINS = '\u2212';
const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);

const PROMO: Produit = {
  id: 'p1',
  slug: 'air-zoom-pegasus-41',
  nom: 'Air Zoom Pegasus 41',
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.svg',
  prixCents: 12600,
  prixCompareCents: 18000,
  variantes: [{ id: 'v1', taille: '41', sku: 'PEG-41', stock: 4 }],
};
const { prixCompareCents: _retire, ...PLEIN_TARIF } = PROMO;

describe('ProductCard — visuel', () => {
  it.each(['relative', 'overflow-hidden', 'rounded-[20px]', 'bg-[var(--vs-surface)]'])(
    'le visuel porte %s',
    (c) => {
      render(<ProductCard produit={PROMO} />);
      expect(classes(screen.getByTestId('carte-visuel'))).toContain(c);
    },
  );

  it('contient l’image, qui remplit le visuel', () => {
    render(<ProductCard produit={PROMO} />);
    const img = screen.getByRole('img');
    expect(screen.getByTestId('carte-visuel').contains(img)).toBe(true);
    for (const c of ['h-full', 'w-full', 'object-cover']) expect(classes(img)).toContain(c);
  });
});

describe('ProductCard — pastille de remise', () => {
  it('affiche la remise exacte sur le visuel', () => {
    render(<ProductCard produit={PROMO} />);
    const pastille = screen.getByTestId('prix-remise');
    expect(pastille.textContent).toBe(`${MOINS}30${NB}%`);
    expect(screen.getByTestId('carte-visuel').contains(pastille)).toBe(true);
  });

  it('n’affiche la remise qu’une seule fois', () => {
    render(<ProductCard produit={PROMO} />);
    expect(screen.getAllByTestId('prix-remise')).toHaveLength(1);
  });

  it('garde le prix barré sous le visuel', () => {
    render(<ProductCard produit={PROMO} />);
    expect(screen.getByTestId('prix-compare')).toBeInTheDocument();
  });

  it('n’affiche aucune pastille hors promotion', () => {
    render(<ProductCard produit={PLEIN_TARIF} />);
    expect(screen.queryByTestId('prix-remise')).toBeNull();
  });

  it('ne confond pas la pastille avec le badge', () => {
    render(<ProductCard produit={PROMO} />);
    expect(screen.queryByTestId('badge')).toBeNull();
  });
});

describe('ProductCard — favori', () => {
  it('propose un bouton favori hors du lien', () => {
    render(<ProductCard produit={PROMO} />);
    const bouton = screen.getByRole('button', { name: 'Ajouter aux favoris' });
    expect(bouton).toHaveAttribute('type', 'button');
    expect(bouton.closest('a')).toBeNull();
  });

  it('bascule l’état favori', () => {
    render(<ProductCard produit={PROMO} />);
    const bouton = screen.getByRole('button', { name: 'Ajouter aux favoris' });
    expect(bouton).toHaveAttribute('aria-pressed', 'false');
    fireEvent.click(bouton);
    expect(bouton).toHaveAttribute('aria-pressed', 'true');
    fireEvent.click(bouton);
    expect(bouton).toHaveAttribute('aria-pressed', 'false');
  });

  it('garde un seul lien dans la carte', () => {
    render(<ProductCard produit={PROMO} />);
    expect(screen.getAllByRole('link')).toHaveLength(1);
  });
});
FIN_VICTO_22
cat > 'tickets/tests/accueil2-Reassurance.test.tsx' <<'FIN_VICTO_23'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Reassurance } from '../src/components/accueil/Reassurance';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);

describe('Reassurance', () => {
  it('rend trois engagements', () => {
    render(<Reassurance />);
    expect(screen.getByTestId('reassurance').querySelectorAll('li')).toHaveLength(3);
  });

  it('affiche les titres dans l’ordre', () => {
    render(<Reassurance />);
    expect(screen.getAllByRole('heading', { level: 3 }).map((h) => h.textContent)).toEqual([
      'Livraison offerte au Canada',
      'Retours gratuits 30 jours',
      'Paiement sécurisé',
    ]);
  });

  it('affiche les textes', () => {
    render(<Reassurance />);
    expect(screen.getByText('Expédiée du Québec sous 48 heures.')).toBeInTheDocument();
    expect(screen.getByText('Vos données de carte ne transitent jamais par nos serveurs.')).toBeInTheDocument();
  });

  it.each(['grid', 'grid-cols-1', 'gap-8', 'sm:grid-cols-3', 'lg:gap-12'])('la liste porte %s', (k) => {
    render(<Reassurance />);
    const ul = screen.getByTestId('reassurance').querySelector('ul');
    expect(classes(ul as Element)).toContain(k);
  });

  it('illustre chaque engagement d’une icône décorative', () => {
    render(<Reassurance />);
    const svgs = Array.from(screen.getByTestId('reassurance').querySelectorAll('svg'));
    expect(svgs).toHaveLength(3);
    for (const s of svgs) expect(s.getAttribute('aria-hidden')).toBe('true');
  });
});
FIN_VICTO_23
cat > 'tickets/tests/accueil2-SiteFooter.test.tsx' <<'FIN_VICTO_24'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteFooter } from '../src/components/ui/SiteFooter';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const COLONNES = [{ titre: 'Aide', liens: [{ label: 'Contact', href: '/contact' }] }];

describe('SiteFooter — style de la maquette', () => {
  it('passe sur fond noir', () => {
    render(<SiteFooter colonnes={COLONNES} annee={2026} />);
    const pied = screen.getByTestId('pied');
    for (const k of ['bg-[var(--vs-noir)]', 'text-[var(--vs-blanc)]']) expect(classes(pied)).toContain(k);
  });

  it('affiche le filigrane décoratif', () => {
    render(<SiteFooter colonnes={COLONNES} annee={2026} />);
    const f = screen.getByTestId('pied-filigrane');
    expect(f.textContent).toBe('VICTO');
    expect(f).toHaveAttribute('aria-hidden', 'true');
    for (const k of ['select-none', 'text-[200px]', 'font-black', 'leading-none', 'text-[#1E1E26]']) {
      expect(classes(f)).toContain(k);
    }
  });

  it('garde la marque et les mentions', () => {
    render(<SiteFooter colonnes={COLONNES} annee={2026} />);
    expect(screen.getByTestId('pied').textContent).toContain('VICTO STORE');
    expect(screen.getByTestId('pied-mentions').textContent).toBe('© 2026 VICTO STORE');
  });
});
FIN_VICTO_24
cat > 'tickets/tests/accueil2-SiteHeader.test.tsx' <<'FIN_VICTO_25'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteHeader, type NavItem } from '../src/components/ui/SiteHeader';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const NAV: NavItem[] = [
  { label: 'Femme', href: '/femme' },
  { label: 'Homme', href: '/homme' },
  { label: 'Soldes', href: '/soldes', promo: true },
];

describe('SiteHeader — disposition', () => {
  it('répartit l’en-tête en trois zones', () => {
    render(<SiteHeader navItems={NAV} />);
    const zones = screen.getByTestId('entete-marque').closest('.grid-cols-3');
    expect(zones).not.toBeNull();
    for (const c of ['grid', 'grid-cols-3', 'items-center']) expect(classes(zones as Element)).toContain(c);
  });

  it('masque la navigation sur téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    const nav = screen.getByRole('navigation', { name: 'Navigation principale' });
    for (const c of ['hidden', 'lg:flex']) expect(classes(nav)).toContain(c);
  });
});

describe('SiteHeader — actions', () => {
  it.each(['Ouvrir le menu', 'Rechercher', 'Mon compte'])('propose le bouton %s', (nom) => {
    render(<SiteHeader navItems={NAV} />);
    expect(screen.getByRole('button', { name: nom })).toHaveAttribute('type', 'button');
  });

  it('réserve le bouton de menu au téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    expect(classes(screen.getByRole('button', { name: 'Ouvrir le menu' }))).toContain('lg:hidden');
  });

  it('colore la pastille du panier en cobalt', () => {
    render(<SiteHeader navItems={NAV} cartCount={2} />);
    expect(classes(screen.getByTestId('entete-panier-compte'))).toContain('bg-[var(--vs-accent)]');
  });
});

describe('SiteHeader — entrée promo', () => {
  it('colore en rouge seulement l’entrée marquée promo', () => {
    render(<SiteHeader navItems={NAV} />);
    expect(classes(screen.getByRole('link', { name: 'Soldes' }))).toContain('text-[var(--vs-promo)]');
    expect(classes(screen.getByRole('link', { name: 'Femme' }))).not.toContain('text-[var(--vs-promo)]');
  });
});
FIN_VICTO_25
cat > 'tickets/tests/accueil2-page.test.tsx' <<'FIN_VICTO_26'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { AccueilPage } from '../src/app/page';
import { estEnPromotion } from '../src/lib/catalogue';
import { MARQUES, PRODUITS } from '../src/lib/donnees';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);

describe('page d’accueil — structure', () => {
  it('rend l’en-tête, le contenu et le pied', () => {
    render(<AccueilPage />);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByRole('main')).toBeInTheDocument();
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('n’a qu’un seul titre de niveau 1', () => {
    render(<AccueilPage />);
    expect(screen.getAllByRole('heading', { level: 1 })).toHaveLength(1);
  });

  it('enchaîne les sections dans l’ordre de la maquette', () => {
    render(<AccueilPage />);
    const ids = ['barre-annonce', 'carrousel', 'bande-marques', 'bonnes-affaires', 'categories', 'infolettre', 'reassurance', 'pied'];
    const blocs = ids.map((id) => screen.getByTestId(id));
    for (let i = 1; i < blocs.length; i++) {
      const avant = blocs[i - 1] as Element;
      const apres = blocs[i] as Element;
      expect(avant.compareDocumentPosition(apres) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    }
  });

  it('place la barre d’annonce avant l’en-tête', () => {
    render(<AccueilPage />);
    const barre = screen.getByTestId('barre-annonce');
    expect(barre.compareDocumentPosition(screen.getByRole('banner')) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  });
});

describe('page d’accueil — contenu', () => {
  it('propose cinq entrées de navigation, Soldes en rouge', () => {
    render(<AccueilPage />);
    const nav = screen.getByRole('navigation', { name: 'Navigation principale' });
    const liens = Array.from(nav.querySelectorAll('a'));
    expect(liens.map((a) => a.textContent)).toEqual(['Femme', 'Homme', 'Chaussures', 'Marques', 'Soldes']);
    expect(classes(liens[4] as Element)).toContain('text-[var(--vs-promo)]');
  });

  it('fait défiler toutes les marques', () => {
    render(<AccueilPage />);
    const listes = screen.getByTestId('bande-piste').querySelectorAll('ul');
    expect(listes[0]?.querySelectorAll('li')).toHaveLength(MARQUES.length);
  });

  it('présente quatre bonnes affaires, toutes en promotion', () => {
    render(<AccueilPage />);
    const attendu = Math.min(4, PRODUITS.filter(estEnPromotion).length);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(attendu);
    expect(screen.getAllByTestId('prix-remise')).toHaveLength(attendu);
  });
});

describe('page d’accueil — enveloppes', () => {
  it.each(['bonnes-affaires', 'categories', 'infolettre', 'reassurance'])(
    'centre la section %s dans la largeur de la maquette',
    (id) => {
      render(<AccueilPage />);
      const env = screen.getByTestId(id).parentElement as Element;
      for (const k of ['mx-auto', 'max-w-[1440px]', 'px-5', 'lg:px-20']) expect(classes(env)).toContain(k);
    },
  );
});
FIN_VICTO_26

if [ -f tests/GrilleProduits.classes.test.tsx ]; then
  rm -f tickets/040-grille-classes.md tickets/tests/GrilleProduits.classes.test.tsx
  ok "ticket 040 déjà fusionné, non repris"
else
  { head -1 tickets/manifest-accueil-v2.tsv; printf '%s\n' '040	src/components/catalogue/GrilleProduits.tsx	tests/GrilleProduits.classes.test.tsx	tickets/040-grille-classes.md	'; tail -n +2 tickets/manifest-accueil-v2.tsv; } > tickets/.m && mv tickets/.m tickets/manifest-accueil-v2.tsv
  ok "ticket 040 (grille 3 colonnes de la boutique) ajouté en tête"
fi
cat > 'public/img/accueil/photo-1.svg' <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 1000" preserveAspectRatio="xMidYMid slice">
  <rect width="800" height="1000" fill="#1E1E26"/>
  <text x="48" y="952" font-family="Archivo, sans-serif" font-size="22" letter-spacing="3" fill="#8A8A92">PHOTO 1 — SNEAKER BLANCHE EN STUDIO</text>
</svg>
SVG
cat > 'public/img/accueil/photo-2.svg' <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 1000" preserveAspectRatio="xMidYMid slice">
  <rect width="800" height="1000" fill="#C70026"/>
  <text x="48" y="952" font-family="Archivo, sans-serif" font-size="22" letter-spacing="3" fill="#FFB3C0">PHOTO 2 — PAIRE DE SNEAKERS COLORÉES</text>
</svg>
SVG
cat > 'public/img/accueil/photo-3.svg' <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 1000" preserveAspectRatio="xMidYMid slice">
  <rect width="800" height="1000" fill="#D9D2C4"/>
  <text x="48" y="952" font-family="Archivo, sans-serif" font-size="22" letter-spacing="3" fill="#7D7668">PHOTO 3 — TENUE DENIM, LUMIÈRE NATURELLE</text>
</svg>
SVG
cat > 'public/img/accueil/photo-8.svg' <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 1000" preserveAspectRatio="xMidYMid slice">
  <rect width="800" height="1000" fill="#1E1E26"/>
  <text x="48" y="952" font-family="Archivo, sans-serif" font-size="22" letter-spacing="3" fill="#8A8A92">PHOTO 8 — PORTRAIT FEMME</text>
</svg>
SVG
cat > 'public/img/accueil/photo-9.svg' <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 1000" preserveAspectRatio="xMidYMid slice">
  <rect width="800" height="1000" fill="#E9E4DA"/>
  <text x="48" y="952" font-family="Archivo, sans-serif" font-size="22" letter-spacing="3" fill="#7D7668">PHOTO 9 — PORTRAIT HOMME</text>
</svg>
SVG
cat > 'public/img/accueil/photo-10.svg' <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 1000" preserveAspectRatio="xMidYMid slice">
  <rect width="800" height="1000" fill="#EEF1F8"/>
  <text x="48" y="952" font-family="Archivo, sans-serif" font-size="22" letter-spacing="3" fill="#8A8FA0">PHOTO 10 — SNEAKERS AU SOL</text>
</svg>
SVG
ok "$(grep -vc '^#' tickets/manifest-accueil-v2.tsv) tickets, $(ls tickets/tests/accueil2-*.test.tsx | wc -l) tests, 6 visuels provisoires"

echo "== porte de qualité sur la base nettoyée"
npm run --silent typecheck || mort "tsc échoue après nettoyage — envoie-moi la sortie"
ok "tsc"
npm run --silent test >/tmp/victo-test.log 2>&1 || { tail -30 /tmp/victo-test.log; mort "tests rouges après nettoyage — envoie-moi la sortie"; }
ok "tests"
npm run --silent build >/tmp/victo-build.log 2>&1 || { tail -30 /tmp/victo-build.log; mort "build rouge — envoie-moi la sortie"; }
ok "build"

git add -A -- src tests tickets public
git commit -q -m "chore: lot accueil v2 fidele a la maquette (tickets 050-061)"
GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/dev/null && ok "poussé sur GitHub" || echo "  push ignoré"

cat <<'TXT'

Prêt. Une seule commande :

    MANIFEST=tickets/manifest-accueil-v2.tsv ./run.sh

Page : http://192.168.40.32:3000/  —  compte 1 h 30 à 2 h 30.
Photos : remplace plus tard les fichiers de public/img/accueil/ par les tiennes,
même nom, et adapte l'extension dans Carrousel.tsx et MosaiqueCategories.tsx.
TXT
