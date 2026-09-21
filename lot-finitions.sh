#!/usr/bin/env bash
# VICTO STORE — lot « finitions de l'accueil » (tickets 070 à 075).
# Installe lucide-react en vérifiant sa compatibilité, pose une garde permanente
# contre les <h1> dans les composants, écrit les tickets, vérifie la base.
# Usage :  cd ~/victo-store && bash lot-finitions.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
git checkout -q main
[ -z "$(git status --porcelain -- . ':!lot-finitions.sh')" ] || mort "arbre sale : commit ou stash d'abord"
git pull -q --ff-only 2>/dev/null || true
ok "sur main, à jour"

# --- 1. lucide-react : version compatible React 19, vérifiée sur npm, épinglée
if [ ! -d node_modules/lucide-react ]; then
  V="$(npm view lucide-react version 2>/dev/null)" || mort "npm injoignable"
  PEER="$(npm view "lucide-react@$V" peerDependencies.react 2>/dev/null)"
  printf '%s' "$PEER" | grep -q '19' || mort "lucide-react@$V ne déclare pas React 19 ($PEER) — envoie-moi ce message"
  npm install --save-exact --no-fund --no-audit "lucide-react@$V" >/tmp/victo-npm.log 2>&1 \
    || { tail -15 /tmp/victo-npm.log; mort "installation de lucide-react impossible"; }
  ok "lucide-react@$V installé et épinglé (compatible : $PEER)"
else
  ok "lucide-react déjà présent : $(node -p "require('./node_modules/lucide-react/package.json').version")"
fi

# --- 2. Les icônes et la convention de classes dont dépendent les tests existent
mkdir -p .logs
cat > .logs/verif-lucide.mjs <<'MJS'
import * as L from 'lucide-react';
import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';

const noms = ['Menu', 'Search', 'User', 'ShoppingBag', 'Heart', 'ChevronLeft', 'ChevronRight', 'ArrowUpRight', 'Truck', 'RotateCcw', 'Lock'];
const absents = noms.filter((n) => !L[n]);
if (absents.length) {
  console.error('icônes absentes : ' + absents.join(', '));
  process.exit(1);
}
const attendu = {
  Search: 'lucide-search',
  ShoppingBag: 'lucide-shopping-bag',
  ArrowUpRight: 'lucide-arrow-up-right',
  RotateCcw: 'lucide-rotate-ccw',
  ChevronLeft: 'lucide-chevron-left',
  Heart: 'lucide-heart',
};
for (const [nom, classe] of Object.entries(attendu)) {
  const html = renderToStaticMarkup(createElement(L[nom], { 'aria-hidden': true, fill: 'none' }));
  const m = html.match(/class="([^"]*)"/);
  const classes = m ? m[1].split(/\s+/) : [];
  if (!classes.includes('lucide') || !classes.includes(classe)) {
    console.error('convention de classe inattendue pour ' + nom + ' : ' + html.slice(0, 160));
    process.exit(2);
  }
  if (!html.includes('aria-hidden="true"')) {
    console.error('aria-hidden absent pour ' + nom);
    process.exit(3);
  }
}
console.log('ok');
MJS
node .logs/verif-lucide.mjs || mort "lucide-react ne correspond pas à ce que les tests attendent — envoie-moi ce message"
ok "11 icônes présentes, convention « lucide lucide-<nom> » et aria-hidden confirmés"

mkdir -p tickets/tests
cat > 'tickets/070-entete-icones.md' <<'FIN_VICTO_00'
TICKET 070 — SiteHeader : icônes lucide

Modifie `src/components/ui/SiteHeader.tsx`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Icônes : uniquement `lucide-react`.** Plus aucun `<svg>` dessiné à la main dans
  ce composant. Chaque icône reçoit `aria-hidden` et une taille explicite
  (`size={20}` par exemple). Importe **exactement** les noms indiqués, ils ont été
  vérifiés sur ta version installée.
- **Aucun `<h1>`** dans un composant, sauf le carrousel qui porte le titre de la page.
- Classes imposées en toutes lettres ; les tests les vérifient. Tu peux en
  ajouter, jamais en retirer.
- **Les tests existants de ce composant doivent rester verts** : tu modifies un
  composant déjà en production, tu ne le réécris pas de zéro.
## Import à ajouter
```tsx
import { Menu, Search, ShoppingBag, User } from 'lucide-react';
```

## Changement
Remplace chaque icône dessinée à la main :
- bouton `Ouvrir le menu` → `<Menu aria-hidden size={22} />`
- bouton `Rechercher` → `<Search aria-hidden size={21} />`
- bouton `Mon compte` → `<User aria-hidden size={21} />`
- lien panier → `<ShoppingBag aria-hidden size={21} />`

Rien d'autre ne change : disposition, pastille, libellés, attributs.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_00
cat > 'tickets/071-carte-icones.md' <<'FIN_VICTO_01'
TICKET 071 — ProductCard : cœur lucide

Modifie `src/components/ui/ProductCard.tsx`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Icônes : uniquement `lucide-react`.** Plus aucun `<svg>` dessiné à la main dans
  ce composant. Chaque icône reçoit `aria-hidden` et une taille explicite
  (`size={20}` par exemple). Importe **exactement** les noms indiqués, ils ont été
  vérifiés sur ta version installée.
- **Aucun `<h1>`** dans un composant, sauf le carrousel qui porte le titre de la page.
- Classes imposées en toutes lettres ; les tests les vérifient. Tu peux en
  ajouter, jamais en retirer.
- **Les tests existants de ce composant doivent rester verts** : tu modifies un
  composant déjà en production, tu ne le réécris pas de zéro.
## Import à ajouter
```tsx
import { Heart } from 'lucide-react';
```

## Changement
Dans le bouton `Ajouter aux favoris`, remplace le cœur dessiné à la main par :
```tsx
<Heart aria-hidden size={18} fill={favori ? 'currentColor' : 'none'} />
```
Le cœur est vide au repos, plein quand le produit est en favori. Rien d'autre ne change.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_01
cat > 'tickets/072-carrousel-icones.md' <<'FIN_VICTO_02'
TICKET 072 — Carrousel : flèches lucide

Modifie `src/components/accueil/Carrousel.tsx`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Icônes : uniquement `lucide-react`.** Plus aucun `<svg>` dessiné à la main dans
  ce composant. Chaque icône reçoit `aria-hidden` et une taille explicite
  (`size={20}` par exemple). Importe **exactement** les noms indiqués, ils ont été
  vérifiés sur ta version installée.
- **Aucun `<h1>`** dans un composant, sauf le carrousel qui porte le titre de la page.
- Classes imposées en toutes lettres ; les tests les vérifient. Tu peux en
  ajouter, jamais en retirer.
- **Les tests existants de ce composant doivent rester verts** : tu modifies un
  composant déjà en production, tu ne le réécris pas de zéro.
## Import à ajouter
```tsx
import { ChevronLeft, ChevronRight } from 'lucide-react';
```

## Changement
- bouton `Diapositive précédente` → `<ChevronLeft aria-hidden size={20} />`
- bouton `Diapositive suivante` → `<ChevronRight aria-hidden size={20} />`

Rien d'autre ne change. Le `<h1>` de la première diapositive reste en place :
c'est le seul composant qui a le droit d'en avoir un.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_02
cat > 'tickets/073-mosaique-icones.md' <<'FIN_VICTO_03'
TICKET 073 — MosaiqueCategories : flèches lucide

Modifie `src/components/accueil/MosaiqueCategories.tsx`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Icônes : uniquement `lucide-react`.** Plus aucun `<svg>` dessiné à la main dans
  ce composant. Chaque icône reçoit `aria-hidden` et une taille explicite
  (`size={20}` par exemple). Importe **exactement** les noms indiqués, ils ont été
  vérifiés sur ta version installée.
- **Aucun `<h1>`** dans un composant, sauf le carrousel qui porte le titre de la page.
- Classes imposées en toutes lettres ; les tests les vérifient. Tu peux en
  ajouter, jamais en retirer.
- **Les tests existants de ce composant doivent rester verts** : tu modifies un
  composant déjà en production, tu ne le réécris pas de zéro.
## Import à ajouter
```tsx
import { ArrowUpRight } from 'lucide-react';
```

## Changement
Dans les **quatre** tuiles, la flèche du rond devient
`<ArrowUpRight aria-hidden size={20} />`. Le rond qui l'entoure garde ses classes
et sa couleur. Rien d'autre ne change.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_03
cat > 'tickets/074-reassurance-icones.md' <<'FIN_VICTO_04'
TICKET 074 — Reassurance : icônes lucide

Modifie `src/components/accueil/Reassurance.tsx`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Icônes : uniquement `lucide-react`.** Plus aucun `<svg>` dessiné à la main dans
  ce composant. Chaque icône reçoit `aria-hidden` et une taille explicite
  (`size={20}` par exemple). Importe **exactement** les noms indiqués, ils ont été
  vérifiés sur ta version installée.
- **Aucun `<h1>`** dans un composant, sauf le carrousel qui porte le titre de la page.
- Classes imposées en toutes lettres ; les tests les vérifient. Tu peux en
  ajouter, jamais en retirer.
- **Les tests existants de ce composant doivent rester verts** : tu modifies un
  composant déjà en production, tu ne le réécris pas de zéro.
## Import à ajouter
```tsx
import { Lock, RotateCcw, Truck } from 'lucide-react';
```

## Changement
Les trois icônes deviennent, dans l'ordre des engagements :
`<Truck aria-hidden size={24} />`, `<RotateCcw aria-hidden size={24} />`,
`<Lock aria-hidden size={24} />`. Le carré arrondi qui les entoure est inchangé.
Supprime la logique qui choisissait un tracé selon `e.icone` si elle n'est plus
utile ; garde la constante `ENGAGEMENTS`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_04
cat > 'tickets/075-infolettre-mise-en-page.md' <<'FIN_VICTO_05'
TICKET 075 — Infolettre : marges et disposition

Modifie `src/components/accueil/Infolettre.tsx`. Le bandeau actuel n'a aucune
marge intérieure : le titre touche le bord, le champ occupe toute la hauteur et le
message d'erreur s'affiche à droite du bouton au lieu d'en dessous.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Icônes : uniquement `lucide-react`.** Plus aucun `<svg>` dessiné à la main dans
  ce composant. Chaque icône reçoit `aria-hidden` et une taille explicite
  (`size={20}` par exemple). Importe **exactement** les noms indiqués, ils ont été
  vérifiés sur ta version installée.
- **Aucun `<h1>`** dans un composant, sauf le carrousel qui porte le titre de la page.
- Classes imposées en toutes lettres ; les tests les vérifient. Tu peux en
  ajouter, jamais en retirer.
- **Les tests existants de ce composant doivent rester verts** : tu modifies un
  composant déjà en production, tu ne le réécris pas de zéro.
## Classes imposées

| élément | classes à porter |
|---|---|
| le bloc cobalt (celui qui porte déjà `rounded-[28px]`) | ajouter `p-8 sm:p-12 lg:p-16` |
| le `<h2>` | `text-3xl font-black tracking-tight lg:text-4xl` |
| le `<p>` sous le titre | `mt-3 text-base text-[var(--vs-blanc)]/80` |
| le `<form>` | garder `flex flex-col gap-3 sm:flex-row`, ajouter `sm:items-center` |
| l'`<input>` | `h-14 w-full min-w-0 flex-1 rounded-full bg-[var(--vs-blanc)] px-6 text-[var(--vs-noir)]` |
| le `<button>` | `h-14 shrink-0 whitespace-nowrap rounded-full bg-[var(--vs-noir)] px-8 font-bold text-[var(--vs-blanc)]` |

## Structure de la colonne de droite
Le formulaire et le message d'erreur sont enveloppés ensemble, l'erreur **sous**
le formulaire et **hors** de lui :
```tsx
<div className="flex flex-col gap-3">
  <form …>…</form>
  {erreur && <p role="alert" className="text-sm font-semibold">Entrez une adresse courriel valide.</p>}
</div>
```
Après une inscription réussie, ce bloc est remplacé par le message de remerciement,
comme aujourd'hui. Les textes ne changent pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_05
cat > 'tickets/manifest-finitions.tsv' <<'FIN_VICTO_06'
# id	cible	tests	spec	contexte_lecture_seule
070	src/components/ui/SiteHeader.tsx	tests/finitions-SiteHeader.test.tsx	tickets/070-entete-icones.md	
071	src/components/ui/ProductCard.tsx	tests/finitions-ProductCard.test.tsx	tickets/071-carte-icones.md	
072	src/components/accueil/Carrousel.tsx	tests/finitions-Carrousel.test.tsx	tickets/072-carrousel-icones.md	
073	src/components/accueil/MosaiqueCategories.tsx	tests/finitions-Mosaique.test.tsx	tickets/073-mosaique-icones.md	
074	src/components/accueil/Reassurance.tsx	tests/finitions-Reassurance.test.tsx	tickets/074-reassurance-icones.md	
075	src/components/accueil/Infolettre.tsx	tests/finitions-Infolettre.test.tsx	tickets/075-infolettre-mise-en-page.md	
FIN_VICTO_06
cat > 'tickets/tests/finitions-Carrousel.test.tsx' <<'FIN_VICTO_07'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Carrousel } from '../src/components/accueil/Carrousel';

describe('Carrousel — flèches lucide', () => {
  it('utilise les chevrons lucide', () => {
    render(<Carrousel auto={false} />);
    expect(screen.getByRole('button', { name: 'Diapositive précédente' }).querySelector('svg.lucide-chevron-left')).not.toBeNull();
    expect(screen.getByRole('button', { name: 'Diapositive suivante' }).querySelector('svg.lucide-chevron-right')).not.toBeNull();
  });

  it('ne contient plus aucune icône dessinée à la main', () => {
    const { container } = render(<Carrousel auto={false} />);
    for (const s of Array.from(container.querySelectorAll('svg'))) {
      expect(s.classList.contains('lucide')).toBe(true);
    }
  });
});
FIN_VICTO_07
cat > 'tickets/tests/finitions-Infolettre.test.tsx' <<'FIN_VICTO_08'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Infolettre } from '../src/components/accueil/Infolettre';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const bloc = () => screen.getByRole('heading', { level: 2 }).closest('.rounded-\\[28px\\]') as Element;

describe('Infolettre — marges', () => {
  it.each(['p-8', 'sm:p-12', 'lg:p-16'])('le bandeau porte %s', (k) => {
    render(<Infolettre />);
    expect(classes(bloc())).toContain(k);
  });

  it.each(['text-3xl', 'font-black', 'tracking-tight', 'lg:text-4xl'])('le titre porte %s', (k) => {
    render(<Infolettre />);
    expect(classes(screen.getByRole('heading', { level: 2 }))).toContain(k);
  });
});

describe('Infolettre — champ et bouton', () => {
  it.each(['h-14', 'w-full', 'min-w-0', 'flex-1', 'rounded-full', 'bg-[var(--vs-blanc)]', 'px-6'])(
    'le champ porte %s',
    (k) => {
      render(<Infolettre />);
      expect(classes(screen.getByLabelText('Votre courriel'))).toContain(k);
    },
  );

  it.each(['h-14', 'shrink-0', 'whitespace-nowrap', 'rounded-full', 'bg-[var(--vs-noir)]', 'px-8'])(
    'le bouton porte %s',
    (k) => {
      render(<Infolettre />);
      expect(classes(screen.getByRole('button', { name: 'Recevoir le code' }))).toContain(k);
    },
  );

  it('aligne champ et bouton sur une ligne en grand écran', () => {
    render(<Infolettre />);
    expect(classes(screen.getByTestId('infolettre-formulaire'))).toContain('sm:items-center');
  });
});

describe('Infolettre — message d’erreur', () => {
  it('affiche l’erreur sous le formulaire, hors de lui', () => {
    render(<Infolettre />);
    const form = screen.getByTestId('infolettre-formulaire');
    fireEvent.submit(form);
    const alerte = screen.getByRole('alert');
    expect(form.contains(alerte)).toBe(false);
    expect(form.compareDocumentPosition(alerte) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(form.parentElement?.contains(alerte)).toBe(true);
  });
});
FIN_VICTO_08
cat > 'tickets/tests/finitions-Mosaique.test.tsx' <<'FIN_VICTO_09'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { MosaiqueCategories } from '../src/components/accueil/MosaiqueCategories';

describe('MosaiqueCategories — flèches lucide', () => {
  it('place une flèche lucide dans chacune des quatre tuiles', () => {
    render(<MosaiqueCategories />);
    const liens = screen.getAllByRole('link');
    expect(liens).toHaveLength(4);
    for (const a of liens) expect(a.querySelector('svg.lucide-arrow-up-right')).not.toBeNull();
  });

  it('ne contient plus aucune icône dessinée à la main', () => {
    const { container } = render(<MosaiqueCategories />);
    for (const s of Array.from(container.querySelectorAll('svg'))) {
      expect(s.classList.contains('lucide')).toBe(true);
    }
  });
});
FIN_VICTO_09
cat > 'tickets/tests/finitions-ProductCard.test.tsx' <<'FIN_VICTO_10'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ProductCard } from '../src/components/ui/ProductCard';
import type { Produit } from '../src/lib/catalogue';

const P: Produit = {
  id: 'p1',
  slug: 'p-1',
  nom: 'Produit 1',
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.svg',
  prixCents: 8000,
  prixCompareCents: 10000,
  variantes: [{ id: 'v1', taille: '41', sku: 'S-41', stock: 2 }],
};

describe('ProductCard — cœur lucide', () => {
  it('utilise l’icône lucide du cœur', () => {
    render(<ProductCard produit={P} />);
    const bouton = screen.getByRole('button', { name: 'Ajouter aux favoris' });
    expect(bouton.querySelector('svg.lucide-heart')).not.toBeNull();
  });

  it('remplit le cœur quand le produit est en favori', () => {
    render(<ProductCard produit={P} />);
    const bouton = screen.getByRole('button', { name: 'Ajouter aux favoris' });
    const coeur = () => bouton.querySelector('svg.lucide-heart') as Element;
    expect(coeur().getAttribute('fill')).toBe('none');
    fireEvent.click(bouton);
    expect(coeur().getAttribute('fill')).toBe('currentColor');
  });

  it('ne contient plus aucune icône dessinée à la main', () => {
    const { container } = render(<ProductCard produit={P} />);
    for (const s of Array.from(container.querySelectorAll('svg'))) {
      expect(s.classList.contains('lucide')).toBe(true);
    }
  });
});
FIN_VICTO_10
cat > 'tickets/tests/finitions-Reassurance.test.tsx' <<'FIN_VICTO_11'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Reassurance } from '../src/components/accueil/Reassurance';

describe('Reassurance — icônes lucide', () => {
  it('utilise camion, retour et cadenas, dans cet ordre', () => {
    render(<Reassurance />);
    const items = Array.from(screen.getByTestId('reassurance').querySelectorAll('li'));
    expect(items).toHaveLength(3);
    expect(items[0]?.querySelector('svg.lucide-truck')).not.toBeNull();
    expect(items[1]?.querySelector('svg.lucide-rotate-ccw')).not.toBeNull();
    expect(items[2]?.querySelector('svg.lucide-lock')).not.toBeNull();
  });

  it('ne contient plus aucune icône dessinée à la main', () => {
    const { container } = render(<Reassurance />);
    for (const s of Array.from(container.querySelectorAll('svg'))) {
      expect(s.classList.contains('lucide')).toBe(true);
    }
  });
});
FIN_VICTO_11
cat > 'tickets/tests/finitions-SiteHeader.test.tsx' <<'FIN_VICTO_12'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteHeader } from '../src/components/ui/SiteHeader';

const NAV = [{ label: 'Femme', href: '/femme' }];

describe('SiteHeader — icônes lucide', () => {
  it.each([
    ['Ouvrir le menu', 'lucide-menu'],
    ['Rechercher', 'lucide-search'],
    ['Mon compte', 'lucide-user'],
  ])('le bouton « %s » porte l’icône %s', (nom, classe) => {
    render(<SiteHeader navItems={NAV} />);
    expect(screen.getByRole('button', { name: nom }).querySelector(`svg.${classe}`)).not.toBeNull();
  });

  it('le panier porte un sac', () => {
    render(<SiteHeader navItems={NAV} cartCount={2} />);
    expect(screen.getByTestId('entete-panier').querySelector('svg.lucide-shopping-bag')).not.toBeNull();
  });

  it('ne contient plus aucune icône dessinée à la main', () => {
    const { container } = render(<SiteHeader navItems={NAV} cartCount={2} />);
    const svgs = Array.from(container.querySelectorAll('svg'));
    expect(svgs.length).toBeGreaterThanOrEqual(4);
    for (const s of svgs) {
      expect(s.classList.contains('lucide')).toBe(true);
      expect(s.getAttribute('aria-hidden')).toBe('true');
    }
  });
});
FIN_VICTO_12
cat > 'tests/garde-sans-h1.test.tsx' <<'FIN_GARDE'
import { render } from '@testing-library/react';
import type { ReactElement } from 'react';
import { describe, expect, it } from 'vitest';
import { BandeMarques } from '../src/components/accueil/BandeMarques';
import { BarreAnnonce } from '../src/components/accueil/BarreAnnonce';
import { Infolettre } from '../src/components/accueil/Infolettre';
import { MosaiqueCategories } from '../src/components/accueil/MosaiqueCategories';
import { Reassurance } from '../src/components/accueil/Reassurance';
import { SectionBonnesAffaires } from '../src/components/accueil/SectionBonnesAffaires';
import { ProductCard } from '../src/components/ui/ProductCard';
import { SiteFooter } from '../src/components/ui/SiteFooter';
import { SiteHeader } from '../src/components/ui/SiteHeader';
import type { Produit } from '../src/lib/catalogue';

// Garde permanente : un composant ne porte jamais le titre de la page.
// Seul le carrousel a un <h1>, et la page en vérifie l'unicité.
const P: Produit = {
  id: 'p1', slug: 'p-1', nom: 'Produit 1',
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.svg', prixCents: 8000, prixCompareCents: 10000,
  variantes: [{ id: 'v1', taille: '41', sku: 'S-41', stock: 2 }],
};

const CAS: Array<[string, ReactElement]> = [
  ['BarreAnnonce', <BarreAnnonce />],
  ['SiteHeader', <SiteHeader navItems={[{ label: 'Femme', href: '/femme' }]} cartCount={1} />],
  ['SiteFooter', <SiteFooter colonnes={[{ titre: 'Aide', liens: [{ label: 'Contact', href: '/contact' }] }]} annee={2026} />],
  ['ProductCard', <ProductCard produit={P} />],
  ['BandeMarques', <BandeMarques marques={[P.marque]} />],
  ['SectionBonnesAffaires', <SectionBonnesAffaires produits={[P]} />],
  ['MosaiqueCategories', <MosaiqueCategories />],
  ['Infolettre', <Infolettre />],
  ['Reassurance', <Reassurance />],
];

describe('aucun composant ne porte de titre de niveau 1', () => {
  it.each(CAS)('%s', (_nom, element) => {
    const { container } = render(element);
    expect(container.querySelectorAll('h1')).toHaveLength(0);
  });
});
FIN_GARDE
ok "6 tickets écrits ; garde permanente tests/garde-sans-h1.test.tsx posée"

echo "== porte de qualité"
npm run --silent typecheck || mort "tsc rouge"
ok "tsc"
if ! npm run --silent test >/tmp/victo-test.log 2>&1; then
  grep -E "✗|×|FAIL|h1" /tmp/victo-test.log | head -20
  mort "tests rouges. Si c'est la garde sans-h1 sur SiteFooter, applique d'abord le correctif du pied de page (h1 → p)."
fi
ok "tests, garde sans-h1 comprise"
npm run --silent build >/tmp/victo-build.log 2>&1 || { tail -25 /tmp/victo-build.log; mort "build rouge"; }
ok "build"

git add -A -- package.json package-lock.json tests/garde-sans-h1.test.tsx tickets
git commit -q -m "chore: lot finitions accueil (lucide-react, garde sans-h1, tickets 070-075)"
GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/dev/null && ok "poussé sur GitHub" || true

cat <<'TXT'

Prêt. Une seule commande :

    MANIFEST=tickets/manifest-finitions.tsv ./run.sh

Six petits tickets, compte 30 à 45 minutes.
TXT
