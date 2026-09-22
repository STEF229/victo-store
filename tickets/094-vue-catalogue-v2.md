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
