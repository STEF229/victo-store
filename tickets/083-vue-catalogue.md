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

## Gestionnaires — recopie-les exactement
Changer un filtre ou le tri doit **aussi** ramener à la page 1, sinon l'utilisateur
se retrouve sur une page vide :
```ts
const changerCriteres = (c: Criteres) => { setCriteres(c); setPage(1); };
const changerTri = (t: Tri) => { setTri(t); setPage(1); };
```

## Le compteur — recopie exactement ces deux lignes
```ts
const n = resultats.length;
const libelle = `${n} ${n > 1 ? 'produits' : 'produit'}`;
```
**Attention au réflexe anglais.** En anglais, zéro prend le pluriel ; en français,
zéro prend le **singulier**. Le résultat attendu est donc `0 produit`, `1 produit`,
`2 produits`. N'écris surtout pas `n === 1 ? 'produit' : 'produits'` : cette formule
donne `0 produits`, et c'est exactement l'erreur que le test attrape.

## Structure exacte — recopie ce rendu tel quel
```tsx
return (
  <>
    <SiteHeader navItems={NAV} cartCount={0} />
    <main className="mx-auto max-w-[1440px] px-5 py-12 lg:px-20">
      <h1 data-testid="liste-titre" className="text-5xl font-black tracking-tight">{titre}</h1>
      {description && (
        <p data-testid="liste-description" className="mt-3 max-w-2xl text-lg text-[var(--vs-gris)]">{description}</p>
      )}
      <div className="mt-10 grid grid-cols-1 gap-10 lg:grid-cols-[260px_minmax(0,1fr)]">
        <FiltresPanneau marques={marques} tailles={taillesCatalogue()} criteres={criteres} onChange={changerCriteres} />
        <div>
          <div className="mb-6 flex items-center justify-between gap-4">
            <p data-testid="compteur">{libelle}</p>
            <TriSelect value={tri} onChange={changerTri} />
          </div>
          <GrilleProduits produits={pagine.items} />
          <Pagination page={pagine.page} pages={pagine.pages} onChange={setPage} />
        </div>
      </div>
    </main>
    <SiteFooter colonnes={COLONNES_PIED} annee={2026} />
  </>
);
```
Deux points que les tests vérifient et qu'il ne faut pas « améliorer » :
- `<FiltresPanneau>` est l'**enfant direct** de la grille. Ne l'enveloppe dans aucun
  `<div>` ni `<aside>` supplémentaire : il porte déjà sa propre racine.
- Aucune autre enveloppe, aucun autre titre : un seul `<h1>`, celui ci-dessus.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
