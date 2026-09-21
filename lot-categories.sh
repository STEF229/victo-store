#!/usr/bin/env bash
# VICTO STORE — lot « modèle de données et pages de catégorie » (tickets 080 à 088).
# Usage :  cd ~/victo-store && bash lot-categories.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore : attends la fin du run"
git checkout -q main
[ -z "$(git status --porcelain -- . ':!lot-categories.sh')" ] || mort "arbre sale : commit ou stash d'abord"
git pull -q --ff-only 2>/dev/null || true
grep -q 'imports_inventes' run.sh || mort "run.sh n'a pas la garde des imports : applique d'abord correctif-assemblage.sh"
ok "sur main, à jour, harnais avec garde des imports"

mkdir -p tickets/tests public/img/produits
cat > 'tickets/080-catalogue-enrichi.md' <<'FIN_VICTO_00'
TICKET 080 — modèle de domaine : genre, catégorie, fiche

Modifie `src/lib/catalogue.ts`. Ajoute ce que la fiche produit et les pages de
catégorie consomment, **sans rien casser** : tout le reste du fichier reste identique.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  les fichiers `page.tsx` qui n'ont **qu'un export par défaut**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** N'importe que des modules réels ; leurs
  déclarations de types exactes te sont fournies en lecture seule.
- Icônes : uniquement `lucide-react`, avec `aria-hidden`.
- Classes imposées en toutes lettres ; les tests les vérifient.
- Accès aux tableaux : `t[0]` est `T | undefined` ; pas de `!` ni de `as`.
- **Les tests existants qui touchent ce fichier doivent rester verts.**
## Ajouts exacts

```ts
export type Genre = 'femme' | 'homme' | 'mixte';
export type Categorie = 'chaussures' | 'vetements' | 'accessoires';

export const LIBELLES_CATEGORIE: Record<Categorie, string> = {
  chaussures: 'Chaussures',
  vetements: 'Vêtements',
  accessoires: 'Accessoires',
};
```

Dans l'interface `Produit` existante, ajoute ces cinq champs, **tous optionnels** :
```ts
  genre?: Genre;
  categorie?: Categorie;
  description?: string;
  composition?: string;
  images?: string[];
```
Ils doivent rester optionnels : de nombreux tests construisent des produits sans eux,
et les rendre obligatoires ferait échouer toute la suite.

## Fonctions à ajouter

- `imagesProduit(produit: Produit): string[]` — une **copie** de `produit.images`
  si ce tableau existe et n'est pas vide, sinon `[produit.imageUrl]`.
- `correspondAuGenre(produit: Produit, genre: 'femme' | 'homme'): boolean` — vrai si
  `produit.genre` vaut `genre` **ou** `'mixte'`. Un produit sans genre ne
  correspond à aucun.
- `economieCents(produit: Produit): number` — `prixCompareCents - prixCents` si
  `estEnPromotion(produit)`, sinon `0`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_00
cat > 'tickets/081-donnees-enrichies.md' <<'FIN_VICTO_01'
TICKET 081 — catalogue complet

Modifie `src/lib/donnees.ts`. Chaque produit reçoit les cinq nouveaux champs, et
deux fonctions d'accès aux marques s'ajoutent.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  les fichiers `page.tsx` qui n'ont **qu'un export par défaut**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** N'importe que des modules réels ; leurs
  déclarations de types exactes te sont fournies en lecture seule.
- Icônes : uniquement `lucide-react`, avec `aria-hidden`.
- Classes imposées en toutes lettres ; les tests les vérifient.
- Accès aux tableaux : `t[0]` est `T | undefined` ; pas de `!` ni de `as`.
- **Les tests existants qui touchent ce fichier doivent rester verts.**
## Contraintes conservées
Tout ce que vérifie `tests/donnees.test.ts` reste vrai : 6 marques, 12 produits,
identifiants et slugs uniques, au moins 4 promotions, au moins une rupture, visuels
`imageUrl` parmi `/img/pegasus.svg`, `/img/chuck70.svg`, `/img/polo.svg`.
Garde les constantes de marques nommées (`NIKE`, `ADIDAS`…) et leur réutilisation.

## Nouveaux champs, pour chacun des 12 produits
- `genre` : `'femme'`, `'homme'` ou `'mixte'`.
- `categorie` : `'chaussures'`, `'vetements'` ou `'accessoires'`, cohérente avec
  le produit (une sneaker est une chaussure, un polo un vêtement).
- `description` : deux phrases en français, **au moins 60 caractères**.
- `composition` : une phrase décrivant les matières, **au moins 20 caractères**.
- `images` : **exactement 4** chemins, dans cet ordre :
  `[imageUrl, '/img/produits/vue-2.svg', '/img/produits/vue-3.svg', '/img/produits/vue-4.svg']`.

## Répartition exigée
- au moins **4** produits pour lesquels `correspondAuGenre(p, 'femme')` est vrai ;
- au moins **4** pour `correspondAuGenre(p, 'homme')` ;
- au moins **5** produits de catégorie `'chaussures'` ;
- au moins **3** de catégorie `'vetements'`.

## Fonctions à ajouter
- `trouverMarque(slug: string): Marque | undefined`
- `produitsDeMarque(slug: string): Produit[]` — les produits dont `marque.slug`
  vaut `slug`, dans l'ordre de `PRODUITS`, en **nouveau tableau**.

## Import à utiliser
```ts
import type { Marque, Produit } from '@/lib/catalogue';
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_01
cat > 'tickets/082-navigation.md' <<'FIN_VICTO_02'
TICKET 082 — navigation partagée

Crée `src/lib/navigation.ts`. Les pages de liste partagent le même menu et le même
pied de page ; ils vivent à un seul endroit.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  les fichiers `page.tsx` qui n'ont **qu'un export par défaut**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** N'importe que des modules réels ; leurs
  déclarations de types exactes te sont fournies en lecture seule.
- Icônes : uniquement `lucide-react`, avec `aria-hidden`.
- Classes imposées en toutes lettres ; les tests les vérifient.
- Accès aux tableaux : `t[0]` est `T | undefined` ; pas de `!` ni de `as`.
- **Les tests existants qui touchent ce fichier doivent rester verts.**
## Import exact
```ts
import type { NavItem } from '@/components/ui/SiteHeader';
```

## Contenu exact
```ts
export const NAV: NavItem[] = [
  { label: 'Femme', href: '/femme' },
  { label: 'Homme', href: '/homme' },
  { label: 'Chaussures', href: '/chaussures' },
  { label: 'Marques', href: '/marques' },
  { label: 'Soldes', href: '/soldes', promo: true },
];

export const COLONNES_PIED = [
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

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_02
cat > 'tickets/083-vue-catalogue.md' <<'FIN_VICTO_03'
TICKET 083 — vue de catalogue réutilisable

Crée `src/components/catalogue/VueCatalogue.tsx`, export `VueCatalogue`. C'est le
corps complet d'une page de liste — en-tête, titre, filtres, tri, grille, pagination,
pied — alimenté par une liste de produits reçue en prop. Les pages Femme, Homme,
Chaussures, Soldes et Marque ne feront que l'appeler avec leur propre liste.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  les fichiers `page.tsx` qui n'ont **qu'un export par défaut**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** N'importe que des modules réels ; leurs
  déclarations de types exactes te sont fournies en lecture seule.
- Icônes : uniquement `lucide-react`, avec `aria-hidden`.
- Classes imposées en toutes lettres ; les tests les vérifient.
- Accès aux tableaux : `t[0]` est `T | undefined` ; pas de `!` ni de `as`.
- **Les tests existants qui touchent ce fichier doivent rester verts.**
Exception à la règle des titres : ce composant **est** un corps de page, il porte
donc le `<h1>` de la page.

## Bloc d'imports exact
```tsx
'use client';

import { useMemo, useState } from 'react';
import { FiltresPanneau } from '@/components/catalogue/FiltresPanneau';
import { GrilleProduits } from '@/components/catalogue/GrilleProduits';
import { Pagination } from '@/components/catalogue/Pagination';
import { TriSelect } from '@/components/catalogue/TriSelect';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import type { Produit } from '@/lib/catalogue';
import { taillesCatalogue } from '@/lib/donnees';
import { filtrerProduits, paginer, trierProduits, type Criteres, type Tri } from '@/lib/filtres';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```

## Props
```ts
{ titre: string; description?: string; produits: Produit[] }
```

## État et calcul — exactement comme la page boutique
```ts
const [criteres, setCriteres] = useState<Criteres>({});
const [tri, setTri] = useState<Tri>('nouveautes');
const [page, setPage] = useState(1);
const resultats = useMemo(
  () => trierProduits(filtrerProduits(produits, criteres), tri),
  [produits, criteres, tri],
);
const pagine = paginer(resultats, page, 6);
```
Changer un filtre ou le tri remet `page` à `1`.

Les marques proposées dans les filtres sont **uniquement** celles présentes dans
`produits`, sans doublon, dans leur ordre d'apparition :
```ts
const marques = produits
  .map((p) => p.marque)
  .filter((m, i, t) => t.findIndex((x) => x.id === m.id) === i);
```

## Structure et contrat
```tsx
<>
  <SiteHeader navItems={NAV} cartCount={0} />
  <main className="mx-auto max-w-[1440px] px-5 py-12 lg:px-20">
    <h1 data-testid="liste-titre" className="text-5xl font-black tracking-tight">{titre}</h1>
    {description && <p data-testid="liste-description" className="mt-3 max-w-2xl text-lg text-[var(--vs-gris)]">{description}</p>}
    <div className="mt-10 grid grid-cols-1 gap-10 lg:grid-cols-[260px_minmax(0,1fr)]">
      <FiltresPanneau marques={marques} tailles={taillesCatalogue()} criteres={criteres} onChange={…} />
      <div>
        <div className="mb-6 flex items-center justify-between gap-4">
          <p data-testid="compteur">{libelle}</p>
          <TriSelect value={tri} onChange={…} />
        </div>
        <GrilleProduits produits={pagine.items} />
        <Pagination page={pagine.page} pages={pagine.pages} onChange={setPage} />
      </div>
    </div>
  </main>
  <SiteFooter colonnes={COLONNES_PIED} annee={2026} />
</>
```
Le compteur : `${n} produits` si `n > 1`, sinon `${n} produit`, où `n` est
`resultats.length`. Les classes des éléments ci-dessus sont imposées.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_03
cat > 'tickets/084-page-femme.md' <<'FIN_VICTO_04'
TICKET 084 — page Femme

Crée `src/app/femme/page.tsx`. **Un seul export, par défaut.** Aucun état, pas de `'use client'`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  les fichiers `page.tsx` qui n'ont **qu'un export par défaut**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** N'importe que des modules réels ; leurs
  déclarations de types exactes te sont fournies en lecture seule.
- Icônes : uniquement `lucide-react`, avec `aria-hidden`.
- Classes imposées en toutes lettres ; les tests les vérifient.
- Accès aux tableaux : `t[0]` est `T | undefined` ; pas de `!` ni de `as`.
- **Les tests existants qui touchent ce fichier doivent rester verts.**
## Contenu exact du fichier

```tsx
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { correspondAuGenre } from '@/lib/catalogue';
import { listerProduits } from '@/lib/donnees';

export default function PageFemme() {
  return (
    <VueCatalogue
      titre="Femme"
      description="Sneakers, vêtements et accessoires des grandes marques, au bon prix."
      produits={listerProduits().filter((p) => correspondAuGenre(p, 'femme'))}
    />
  );
}
```

Recopie ce fichier tel quel. C'est volontairement court : toute la logique vit dans
`VueCatalogue`, déjà testé.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_04
cat > 'tickets/085-page-homme.md' <<'FIN_VICTO_05'
TICKET 085 — page Homme

Crée `src/app/homme/page.tsx`. **Un seul export, par défaut.** Aucun état, pas de `'use client'`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  les fichiers `page.tsx` qui n'ont **qu'un export par défaut**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** N'importe que des modules réels ; leurs
  déclarations de types exactes te sont fournies en lecture seule.
- Icônes : uniquement `lucide-react`, avec `aria-hidden`.
- Classes imposées en toutes lettres ; les tests les vérifient.
- Accès aux tableaux : `t[0]` est `T | undefined` ; pas de `!` ni de `as`.
- **Les tests existants qui touchent ce fichier doivent rester verts.**
## Contenu exact du fichier

```tsx
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { correspondAuGenre } from '@/lib/catalogue';
import { listerProduits } from '@/lib/donnees';

export default function PageHomme() {
  return (
    <VueCatalogue
      titre="Homme"
      description="Sneakers, vêtements et accessoires des grandes marques, au bon prix."
      produits={listerProduits().filter((p) => correspondAuGenre(p, 'homme'))}
    />
  );
}
```

Recopie ce fichier tel quel. C'est volontairement court : toute la logique vit dans
`VueCatalogue`, déjà testé.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_05
cat > 'tickets/086-page-chaussures.md' <<'FIN_VICTO_06'
TICKET 086 — page Chaussures

Crée `src/app/chaussures/page.tsx`. **Un seul export, par défaut.** Aucun état, pas de `'use client'`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  les fichiers `page.tsx` qui n'ont **qu'un export par défaut**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** N'importe que des modules réels ; leurs
  déclarations de types exactes te sont fournies en lecture seule.
- Icônes : uniquement `lucide-react`, avec `aria-hidden`.
- Classes imposées en toutes lettres ; les tests les vérifient.
- Accès aux tableaux : `t[0]` est `T | undefined` ; pas de `!` ni de `as`.
- **Les tests existants qui touchent ce fichier doivent rester verts.**
## Contenu exact du fichier

```tsx
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { listerProduits } from '@/lib/donnees';

export default function PageChaussures() {
  return (
    <VueCatalogue
      titre="Chaussures"
      description="Running, lifestyle et classiques, toutes pointures."
      produits={listerProduits().filter((p) => p.categorie === 'chaussures')}
    />
  );
}
```

Recopie ce fichier tel quel. C'est volontairement court : toute la logique vit dans
`VueCatalogue`, déjà testé.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_06
cat > 'tickets/087-page-soldes.md' <<'FIN_VICTO_07'
TICKET 087 — page Soldes

Crée `src/app/soldes/page.tsx`. **Un seul export, par défaut.** Aucun état, pas de `'use client'`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  les fichiers `page.tsx` qui n'ont **qu'un export par défaut**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** N'importe que des modules réels ; leurs
  déclarations de types exactes te sont fournies en lecture seule.
- Icônes : uniquement `lucide-react`, avec `aria-hidden`.
- Classes imposées en toutes lettres ; les tests les vérifient.
- Accès aux tableaux : `t[0]` est `T | undefined` ; pas de `!` ni de `as`.
- **Les tests existants qui touchent ce fichier doivent rester verts.**
## Contenu exact du fichier

```tsx
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { estEnPromotion } from '@/lib/catalogue';
import { listerProduits } from '@/lib/donnees';

export default function PageSoldes() {
  return (
    <VueCatalogue
      titre="Soldes"
      description="Toutes les remises du moment, jusqu'à moitié prix."
      produits={listerProduits().filter(estEnPromotion)}
    />
  );
}
```

Recopie ce fichier tel quel. C'est volontairement court : toute la logique vit dans
`VueCatalogue`, déjà testé.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_07
cat > 'tickets/088-page-marque.md' <<'FIN_VICTO_08'
TICKET 088 — page Marque

Crée `src/app/marques/[slug]/page.tsx`. **Un seul export, par défaut.** Aucun état, pas de `'use client'`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  les fichiers `page.tsx` qui n'ont **qu'un export par défaut**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** N'importe que des modules réels ; leurs
  déclarations de types exactes te sont fournies en lecture seule.
- Icônes : uniquement `lucide-react`, avec `aria-hidden`.
- Classes imposées en toutes lettres ; les tests les vérifient.
- Accès aux tableaux : `t[0]` est `T | undefined` ; pas de `!` ni de `as`.
- **Les tests existants qui touchent ce fichier doivent rester verts.**
## Contenu exact du fichier

```tsx
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { produitsDeMarque, trouverMarque } from '@/lib/donnees';

export default async function PageMarque({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const marque = trouverMarque(slug);
  if (!marque) {
    return <VueCatalogue titre="Marque introuvable" produits={[]} />;
  }
  return (
    <VueCatalogue
      titre={marque.nom}
      description={`Toute la sélection ${marque.nom}, au bon prix.`}
      produits={produitsDeMarque(slug)}
    />
  );
}
```

Recopie ce fichier tel quel. C'est volontairement court : toute la logique vit dans
`VueCatalogue`, déjà testé.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
FIN_VICTO_08
cat > 'tickets/manifest-catalogue-v2.tsv' <<'FIN_VICTO_09'
# id	cible	tests	spec	contexte_lecture_seule
080	src/lib/catalogue.ts	tests/catalogue-enrichi.test.ts	tickets/080-catalogue-enrichi.md	
081	src/lib/donnees.ts	tests/donnees-enrichies.test.ts	tickets/081-donnees-enrichies.md	src/lib/catalogue.ts
082	src/lib/navigation.ts	tests/navigation.test.ts	tickets/082-navigation.md	src/components/ui/SiteHeader.tsx
083	src/components/catalogue/VueCatalogue.tsx	tests/VueCatalogue.test.tsx	tickets/083-vue-catalogue.md	src/components/catalogue/FiltresPanneau.tsx,src/components/catalogue/GrilleProduits.tsx,src/components/catalogue/Pagination.tsx,src/components/catalogue/TriSelect.tsx,src/components/ui/SiteFooter.tsx,src/components/ui/SiteHeader.tsx,src/lib/catalogue.ts,src/lib/donnees.ts,src/lib/filtres.ts,src/lib/navigation.ts
084	src/app/femme/page.tsx	tests/page-femme.test.tsx	tickets/084-page-femme.md	src/components/catalogue/VueCatalogue.tsx,src/lib/catalogue.ts,src/lib/donnees.ts
085	src/app/homme/page.tsx	tests/page-homme.test.tsx	tickets/085-page-homme.md	src/components/catalogue/VueCatalogue.tsx,src/lib/catalogue.ts,src/lib/donnees.ts
086	src/app/chaussures/page.tsx	tests/page-chaussures.test.tsx	tickets/086-page-chaussures.md	src/components/catalogue/VueCatalogue.tsx,src/lib/catalogue.ts,src/lib/donnees.ts
087	src/app/soldes/page.tsx	tests/page-soldes.test.tsx	tickets/087-page-soldes.md	src/components/catalogue/VueCatalogue.tsx,src/lib/catalogue.ts,src/lib/donnees.ts
088	src/app/marques/[slug]/page.tsx	tests/page-marque.test.tsx	tickets/088-page-marque.md	src/components/catalogue/VueCatalogue.tsx,src/lib/catalogue.ts,src/lib/donnees.ts
FIN_VICTO_09
cat > 'tickets/tests/VueCatalogue.test.tsx' <<'FIN_VICTO_10'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
// Dépendance déclarée pour le harnais : sans la navigation partagée, ce ticket est BLOQUÉ.
import { NAV as _dependance } from '../src/lib/navigation';
import { VueCatalogue } from '../src/components/catalogue/VueCatalogue';
import type { Marque, Produit } from '../src/lib/catalogue';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const LACOSTE: Marque = { id: 'm2', nom: 'Lacoste', slug: 'lacoste' };
const ADIDAS: Marque = { id: 'm3', nom: 'Adidas', slug: 'adidas' };

const P = (id: string, marque: Marque, prix: number): Produit => ({
  id,
  slug: `p-${id}`,
  nom: `Produit ${id}`,
  marque,
  imageUrl: '/img/pegasus.svg',
  prixCents: prix,
  variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 2 }],
});
const HUIT = [
  P('a', NIKE, 5000), P('b', NIKE, 6000), P('c', LACOSTE, 7000), P('d', NIKE, 8000),
  P('e', LACOSTE, 9000), P('f', NIKE, 10000), P('g', LACOSTE, 11000), P('h', NIKE, 12000),
];

describe('VueCatalogue — structure', () => {
  it('rend l’en-tête, le titre, la description et le pied', () => {
    render(<VueCatalogue titre="Femme" description="Une description." produits={HUIT} />);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe('Femme');
    expect(screen.getByTestId('liste-description').textContent).toBe('Une description.');
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('omet la description quand elle est absente', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    expect(screen.queryByTestId('liste-description')).toBeNull();
  });

  it('propose le menu partagé', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    const nav = screen.getByRole('navigation', { name: 'Navigation principale' });
    expect(Array.from(nav.querySelectorAll('a')).map((a) => a.getAttribute('href'))).toEqual([
      '/femme', '/homme', '/chaussures', '/marques', '/soldes',
    ]);
  });

  it('dispose filtres et résultats sur deux colonnes en grand écran', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    const grille = screen.getByTestId('filtres').parentElement as Element;
    for (const k of ['grid', 'grid-cols-1', 'gap-10', 'lg:grid-cols-[260px_minmax(0,1fr)]']) {
      expect(classes(grille)).toContain(k);
    }
  });

  it('impose la taille du titre', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    for (const k of ['text-5xl', 'font-black', 'tracking-tight']) {
      expect(classes(screen.getByTestId('liste-titre'))).toContain(k);
    }
  });
});

describe('VueCatalogue — contenu', () => {
  it('compte tous les produits reçus', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    expect(screen.getByTestId('compteur').textContent).toBe('8 produits');
  });

  it('affiche six produits par page', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(6);
    fireEvent.click(screen.getByRole('button', { name: 'Page suivante' }));
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(2);
  });

  it('ne propose que les marques présentes, sans doublon', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    expect(screen.getByTestId('filtre-marque-nike')).toBeInTheDocument();
    expect(screen.getByTestId('filtre-marque-lacoste')).toBeInTheDocument();
    expect(screen.queryByTestId('filtre-marque-adidas')).toBeNull();
  });

  it('filtre par marque et revient à la première page', () => {
    render(<VueCatalogue titre="Femme" produits={HUIT} />);
    fireEvent.click(screen.getByRole('button', { name: 'Page suivante' }));
    fireEvent.click(screen.getByTestId('filtre-marque-lacoste'));
    expect(screen.getByTestId('compteur').textContent).toBe('3 produits');
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(3);
  });

  it('accorde le compteur au singulier', () => {
    render(<VueCatalogue titre="Adidas" produits={[P('z', ADIDAS, 9000)]} />);
    expect(screen.getByTestId('compteur').textContent).toBe('1 produit');
  });

  it('gère une liste vide', () => {
    render(<VueCatalogue titre="Marque introuvable" produits={[]} />);
    expect(screen.getByTestId('compteur').textContent).toBe('0 produit');
    expect(screen.getByTestId('grille-vide')).toBeInTheDocument();
  });
});
FIN_VICTO_10
cat > 'tickets/tests/catalogue-enrichi.test.ts' <<'FIN_VICTO_11'
import { describe, expect, it } from 'vitest';
import {
  correspondAuGenre,
  economieCents,
  imagesProduit,
  LIBELLES_CATEGORIE,
  type Produit,
} from '../src/lib/catalogue';

const BASE: Produit = {
  id: 'p1',
  slug: 'p-1',
  nom: 'Produit 1',
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.svg',
  prixCents: 12600,
  prixCompareCents: 18000,
  variantes: [{ id: 'v1', taille: '41', sku: 'S-41', stock: 2 }],
};

describe('champs optionnels', () => {
  it('accepte un produit sans les nouveaux champs', () => {
    expect(BASE.genre).toBeUndefined();
    expect(imagesProduit(BASE)).toEqual(['/img/pegasus.svg']);
  });

  it('accepte un produit complet', () => {
    const complet: Produit = {
      ...BASE,
      genre: 'femme',
      categorie: 'chaussures',
      description: 'Une description.',
      composition: 'Mesh et caoutchouc.',
      images: ['/a.svg', '/b.svg'],
    };
    expect(imagesProduit(complet)).toEqual(['/a.svg', '/b.svg']);
  });
});

describe('imagesProduit', () => {
  it('retombe sur imageUrl quand la liste est vide', () => {
    expect(imagesProduit({ ...BASE, images: [] })).toEqual(['/img/pegasus.svg']);
  });

  it('retourne une copie', () => {
    const images = ['/a.svg'];
    const r = imagesProduit({ ...BASE, images });
    r.push('/x.svg');
    expect(images).toEqual(['/a.svg']);
  });
});

describe('correspondAuGenre', () => {
  it('reconnaît le genre exact', () => {
    expect(correspondAuGenre({ ...BASE, genre: 'femme' }, 'femme')).toBe(true);
    expect(correspondAuGenre({ ...BASE, genre: 'femme' }, 'homme')).toBe(false);
  });

  it('place les produits mixtes dans les deux', () => {
    expect(correspondAuGenre({ ...BASE, genre: 'mixte' }, 'femme')).toBe(true);
    expect(correspondAuGenre({ ...BASE, genre: 'mixte' }, 'homme')).toBe(true);
  });

  it('écarte un produit sans genre', () => {
    expect(correspondAuGenre(BASE, 'femme')).toBe(false);
    expect(correspondAuGenre(BASE, 'homme')).toBe(false);
  });
});

describe('economieCents', () => {
  it('calcule l’économie d’une promotion', () => {
    expect(economieCents(BASE)).toBe(5400);
  });

  it('vaut zéro hors promotion', () => {
    const { prixCompareCents: _r, ...plein } = BASE;
    expect(economieCents(plein)).toBe(0);
    expect(economieCents({ ...BASE, prixCompareCents: 12600 })).toBe(0);
  });
});

describe('libellés de catégorie', () => {
  it('couvre les trois catégories', () => {
    expect(LIBELLES_CATEGORIE).toEqual({
      chaussures: 'Chaussures',
      vetements: 'Vêtements',
      accessoires: 'Accessoires',
    });
  });
});
FIN_VICTO_11
cat > 'tickets/tests/donnees-enrichies.test.ts' <<'FIN_VICTO_12'
import { describe, expect, it } from 'vitest';
import { correspondAuGenre } from '../src/lib/catalogue';
import { MARQUES, PRODUITS, produitsDeMarque, trouverMarque } from '../src/lib/donnees';

const GENRES = ['femme', 'homme', 'mixte'];
const CATEGORIES = ['chaussures', 'vetements', 'accessoires'];

describe('catalogue complet — champs de fiche', () => {
  it.each(PRODUITS.map((p) => [p.slug, p] as const))('%s est complet', (_slug, p) => {
    expect(GENRES).toContain(p.genre);
    expect(CATEGORIES).toContain(p.categorie);
    expect((p.description ?? '').length).toBeGreaterThanOrEqual(60);
    expect((p.composition ?? '').length).toBeGreaterThanOrEqual(20);
    expect(p.images).toEqual([
      p.imageUrl,
      '/img/produits/vue-2.svg',
      '/img/produits/vue-3.svg',
      '/img/produits/vue-4.svg',
    ]);
  });
});

describe('catalogue complet — répartition', () => {
  it('propose assez de produits femme', () => {
    expect(PRODUITS.filter((p) => correspondAuGenre(p, 'femme')).length).toBeGreaterThanOrEqual(4);
  });

  it('propose assez de produits homme', () => {
    expect(PRODUITS.filter((p) => correspondAuGenre(p, 'homme')).length).toBeGreaterThanOrEqual(4);
  });

  it('propose assez de chaussures', () => {
    expect(PRODUITS.filter((p) => p.categorie === 'chaussures').length).toBeGreaterThanOrEqual(5);
  });

  it('propose assez de vêtements', () => {
    expect(PRODUITS.filter((p) => p.categorie === 'vetements').length).toBeGreaterThanOrEqual(3);
  });
});

describe('accès aux marques', () => {
  it('trouve chaque marque par son slug', () => {
    for (const m of MARQUES) expect(trouverMarque(m.slug)?.id).toBe(m.id);
  });

  it('retourne undefined pour une marque inconnue', () => {
    expect(trouverMarque('marque-inexistante')).toBeUndefined();
  });

  it('liste les produits d’une marque, dans l’ordre du catalogue', () => {
    for (const m of MARQUES) {
      const attendus = PRODUITS.filter((p) => p.marque.slug === m.slug).map((p) => p.id);
      expect(produitsDeMarque(m.slug).map((p) => p.id)).toEqual(attendus);
    }
  });

  it('retourne un nouveau tableau, vide pour une marque inconnue', () => {
    expect(produitsDeMarque('marque-inexistante')).toEqual([]);
    const slug = MARQUES.map((m) => m.slug).slice(0, 1).join('');
    expect(produitsDeMarque(slug)).not.toBe(produitsDeMarque(slug));
  });
});
FIN_VICTO_12
cat > 'tickets/tests/navigation.test.ts' <<'FIN_VICTO_13'
import { describe, expect, it } from 'vitest';
import { COLONNES_PIED, NAV } from '../src/lib/navigation';

describe('navigation partagée', () => {
  it('propose les cinq entrées du menu, Soldes en promo', () => {
    expect(NAV).toEqual([
      { label: 'Femme', href: '/femme' },
      { label: 'Homme', href: '/homme' },
      { label: 'Chaussures', href: '/chaussures' },
      { label: 'Marques', href: '/marques' },
      { label: 'Soldes', href: '/soldes', promo: true },
    ]);
  });

  it('propose les deux colonnes du pied de page', () => {
    expect(COLONNES_PIED.map((c) => c.titre)).toEqual(['Boutique', 'Aide']);
    expect(COLONNES_PIED[1]?.liens.map((l) => l.href)).toEqual(['/livraison', '/retours', '/contact']);
  });
});
FIN_VICTO_13
cat > 'tickets/tests/page-chaussures.test.tsx' <<'FIN_VICTO_14'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
// Dépendance déclarée pour le harnais : sans VueCatalogue, ce ticket est BLOQUÉ au lieu d'échouer trois fois.
import { VueCatalogue as _dependance } from '../src/components/catalogue/VueCatalogue';
import Page from '../src/app/chaussures/page';

import { PRODUITS } from '../src/lib/donnees';

const attendus = PRODUITS.filter((p) => p.categorie === 'chaussures');

describe('page Chaussures', () => {
  it('titre la page', () => {
    render(<Page />);
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe('Chaussures');
  });

  it('présente exactement les produits attendus', () => {
    render(<Page />);
    const n = attendus.length;
    expect(screen.getByTestId('compteur').textContent).toBe(`${n} ${n > 1 ? 'produits' : 'produit'}`);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(Math.min(6, n));
  });

  it('n’affiche que des produits de la sélection', () => {
    render(<Page />);
    const ids = new Set(attendus.map((p) => p.id));
    for (const carte of screen.getAllByTestId('carte-produit')) {
      expect(ids.has(carte.getAttribute('data-produit-id') ?? '')).toBe(true);
    }
  });
});
FIN_VICTO_14
cat > 'tickets/tests/page-femme.test.tsx' <<'FIN_VICTO_15'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
// Dépendance déclarée pour le harnais : sans VueCatalogue, ce ticket est BLOQUÉ au lieu d'échouer trois fois.
import { VueCatalogue as _dependance } from '../src/components/catalogue/VueCatalogue';
import Page from '../src/app/femme/page';
import { correspondAuGenre } from '../src/lib/catalogue';
import { PRODUITS } from '../src/lib/donnees';

const attendus = PRODUITS.filter((p) => correspondAuGenre(p, 'femme'));

describe('page Femme', () => {
  it('titre la page', () => {
    render(<Page />);
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe('Femme');
  });

  it('présente exactement les produits attendus', () => {
    render(<Page />);
    const n = attendus.length;
    expect(screen.getByTestId('compteur').textContent).toBe(`${n} ${n > 1 ? 'produits' : 'produit'}`);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(Math.min(6, n));
  });

  it('n’affiche que des produits de la sélection', () => {
    render(<Page />);
    const ids = new Set(attendus.map((p) => p.id));
    for (const carte of screen.getAllByTestId('carte-produit')) {
      expect(ids.has(carte.getAttribute('data-produit-id') ?? '')).toBe(true);
    }
  });
});
FIN_VICTO_15
cat > 'tickets/tests/page-homme.test.tsx' <<'FIN_VICTO_16'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
// Dépendance déclarée pour le harnais : sans VueCatalogue, ce ticket est BLOQUÉ au lieu d'échouer trois fois.
import { VueCatalogue as _dependance } from '../src/components/catalogue/VueCatalogue';
import Page from '../src/app/homme/page';
import { correspondAuGenre } from '../src/lib/catalogue';
import { PRODUITS } from '../src/lib/donnees';

const attendus = PRODUITS.filter((p) => correspondAuGenre(p, 'homme'));

describe('page Homme', () => {
  it('titre la page', () => {
    render(<Page />);
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe('Homme');
  });

  it('présente exactement les produits attendus', () => {
    render(<Page />);
    const n = attendus.length;
    expect(screen.getByTestId('compteur').textContent).toBe(`${n} ${n > 1 ? 'produits' : 'produit'}`);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(Math.min(6, n));
  });

  it('n’affiche que des produits de la sélection', () => {
    render(<Page />);
    const ids = new Set(attendus.map((p) => p.id));
    for (const carte of screen.getAllByTestId('carte-produit')) {
      expect(ids.has(carte.getAttribute('data-produit-id') ?? '')).toBe(true);
    }
  });
});
FIN_VICTO_16
cat > 'tickets/tests/page-marque.test.tsx' <<'FIN_VICTO_17'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
// Dépendance déclarée pour le harnais : sans VueCatalogue, ce ticket est BLOQUÉ au lieu d'échouer trois fois.
import { VueCatalogue as _dependance } from '../src/components/catalogue/VueCatalogue';
import PageMarque from '../src/app/marques/[slug]/page';
import { MARQUES, PRODUITS } from '../src/lib/donnees';

const rendre = async (slug: string) => render(await PageMarque({ params: Promise.resolve({ slug }) }));

describe('page marque', () => {
  it.each(MARQUES.map((m) => [m.nom, m] as const))('présente la marque %s', async (_nom, m) => {
    await rendre(m.slug);
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe(m.nom);
    const n = PRODUITS.filter((p) => p.marque.slug === m.slug).length;
    expect(screen.getByTestId('compteur').textContent).toBe(`${n} ${n > 1 ? 'produits' : 'produit'}`);
  });

  it('n’affiche que les produits de la marque', async () => {
    const m = MARQUES.find((x) => PRODUITS.some((p) => p.marque.slug === x.slug));
    expect(m).toBeDefined();
    await rendre(m?.slug ?? '');
    for (const carte of screen.queryAllByTestId('carte-produit')) {
      const p = PRODUITS.find((x) => x.id === carte.getAttribute('data-produit-id'));
      expect(p?.marque.slug).toBe(m?.slug);
    }
  });

  it('gère une marque inconnue', async () => {
    await rendre('marque-inexistante');
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe('Marque introuvable');
    expect(screen.getByTestId('compteur').textContent).toBe('0 produit');
  });
});
FIN_VICTO_17
cat > 'tickets/tests/page-soldes.test.tsx' <<'FIN_VICTO_18'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
// Dépendance déclarée pour le harnais : sans VueCatalogue, ce ticket est BLOQUÉ au lieu d'échouer trois fois.
import { VueCatalogue as _dependance } from '../src/components/catalogue/VueCatalogue';
import Page from '../src/app/soldes/page';
import { estEnPromotion } from '../src/lib/catalogue';
import { PRODUITS } from '../src/lib/donnees';

const attendus = PRODUITS.filter(estEnPromotion);

describe('page Soldes', () => {
  it('titre la page', () => {
    render(<Page />);
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe('Soldes');
  });

  it('présente exactement les produits attendus', () => {
    render(<Page />);
    const n = attendus.length;
    expect(screen.getByTestId('compteur').textContent).toBe(`${n} ${n > 1 ? 'produits' : 'produit'}`);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(Math.min(6, n));
  });

  it('n’affiche que des produits de la sélection', () => {
    render(<Page />);
    const ids = new Set(attendus.map((p) => p.id));
    for (const carte of screen.getAllByTestId('carte-produit')) {
      expect(ids.has(carte.getAttribute('data-produit-id') ?? '')).toBe(true);
    }
  });
});
FIN_VICTO_18
cat > 'public/img/produits/vue-2.svg' <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 1000" preserveAspectRatio="xMidYMid slice">
  <rect width="800" height="1000" fill="#E9E4DA"/>
  <text x="48" y="952" font-family="Archivo, sans-serif" font-size="22" letter-spacing="3" fill="#7D7668">PHOTO PRODUIT — VUE DE DESSUS</text>
</svg>
SVG
cat > 'public/img/produits/vue-3.svg' <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 1000" preserveAspectRatio="xMidYMid slice">
  <rect width="800" height="1000" fill="#EDEDED"/>
  <text x="48" y="952" font-family="Archivo, sans-serif" font-size="22" letter-spacing="3" fill="#8E8E8E">PHOTO PRODUIT — SEMELLE</text>
</svg>
SVG
cat > 'public/img/produits/vue-4.svg' <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 1000" preserveAspectRatio="xMidYMid slice">
  <rect width="800" height="1000" fill="#1E1E26"/>
  <text x="48" y="952" font-family="Archivo, sans-serif" font-size="22" letter-spacing="3" fill="#8A8A92">PHOTO PRODUIT — PORTÉE</text>
</svg>
SVG
ok "9 tickets, 9 tests en attente, 3 visuels de vues produit"

echo "== porte de qualité"
npm run --silent typecheck || mort "tsc rouge"
ok "tsc"
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×" /tmp/victo-test.log | head -15; mort "tests rouges"; }
ok "tests"
npm run --silent build >/tmp/victo-build.log 2>&1 || { tail -25 /tmp/victo-build.log; mort "build rouge"; }
ok "build"

git add -A -- tickets public/img/produits
git commit -q -m "chore: lot modele de donnees et pages de categorie (tickets 080-088)"
GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/dev/null && ok "poussé sur GitHub" || true

cat <<'TXT'

Prêt. Une seule commande :

    MANIFEST=tickets/manifest-catalogue-v2.tsv ./run.sh

Neuf tickets, compte 1 h à 1 h 30. Pages visibles ensuite sur
/femme, /homme, /chaussures, /soldes et /marques/nike.
TXT
