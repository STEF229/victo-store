TICKET 108g — page d'une sous-catégorie

Crée `src/components/catalogue/PageSousCategorie.tsx`, export nommé `PageSousCategorie`.
Composant **serveur** (pas de `'use client'`), utilisé par les routes
`/femme/…`, `/homme/…` et `/chaussures/…`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`, `.slice`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~40 lignes.
```tsx
import { notFound } from 'next/navigation';
import { SousCategories } from '@/components/catalogue/SousCategories';
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { FilAriane } from '@/components/produit/FilAriane';
import { hrefDe, produitsDe, sousCategories, titreDe, trouverNoeud, type Rubrique } from '@/lib/arbre-categories';
import { listerProduits } from '@/lib/donnees';

export function PageSousCategorie({ rubrique, chemin }: { rubrique: Rubrique; chemin: string[] }) {
  const trouve = trouverNoeud(rubrique, chemin);
  if (!trouve || chemin.length === 0) notFound();
  const tous = listerProduits();
  // Un nœud qui a des enfants les propose ; une feuille propose ses sœurs, elle-même marquée.
  const base = trouve.noeud.enfants.length > 0 ? chemin : chemin.slice(0, -1);
  const pastilles = [
    { libelle: 'Tout', href: hrefDe(rubrique, base), nombre: produitsDe(tous, rubrique, base).length },
    ...sousCategories(tous, rubrique, base),
  ];
  const fil = trouve.lignee.map((n, i) =>
    i === trouve.lignee.length - 1 ? { label: n.libelle } : { label: n.libelle, href: hrefDe(rubrique, chemin.slice(0, i)) },
  );
  return (
    <VueCatalogue
      titre={titreDe(rubrique, chemin)}
      produits={produitsDe(tous, rubrique, chemin)}
      entete={
        <div className="flex flex-col gap-4">
          <FilAriane items={[{ label: 'Accueil', href: '/' }, ...fil]} />
          <SousCategories titre={`Sous-catégories de ${trouve.noeud.libelle}`} forme="pastilles" elements={pastilles} actif={hrefDe(rubrique, chemin)} />
        </div>
      }
    />
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
