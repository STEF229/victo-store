TICKET 108a — arbre des catégories

Crée `src/lib/arbre-categories.ts`. Fonctions **pures**, recopiées telles quelles.
Le deuxième niveau (chaussures, vêtements, accessoires) s'appuie sur le vrai champ
`categorie` ; le troisième (sneakers, course…) sur un classement de démonstration, en
attendant les catégories de Medusa.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index sur un
  tableau ; utilise `.find`, `.filter`, `.map`, la déstructuration. Lire `ARBRE[r]` ou
  `TYPES_DEMO[slug]` est permis : ce sont des `Record` (le second est partiel).
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~85 lignes.
```ts
import { correspondAuGenre, type Produit } from '@/lib/catalogue';

export interface Noeud {
  slug: string;
  libelle: string;
  enfants: Noeud[];
}
export type Rubrique = 'femme' | 'homme' | 'chaussures';
export interface ElementSousCategorie {
  libelle: string;
  href: string;
  nombre: number;
}

const feuille = (slug: string, libelle: string): Noeud => ({ slug, libelle, enfants: [] });
const TYPES_CHAUSSURES = [feuille('sneakers', 'Sneakers'), feuille('course', 'Course'), feuille('basket', 'Basket'), feuille('sandales', 'Sandales')];
const PAR_GENRE: Noeud[] = [
  { slug: 'chaussures', libelle: 'Chaussures', enfants: TYPES_CHAUSSURES },
  { slug: 'vetements', libelle: 'Vêtements', enfants: [feuille('t-shirts', 'T-shirts'), feuille('polos', 'Polos'), feuille('sweats', 'Sweats et hoodies'), feuille('jeans', 'Jeans'), feuille('vestes', 'Vestes')] },
  { slug: 'accessoires', libelle: 'Accessoires', enfants: [feuille('casquettes', 'Casquettes'), feuille('sacs', 'Sacs'), feuille('chaussettes', 'Chaussettes')] },
];

export const ARBRE: Record<Rubrique, Noeud> = {
  femme: { slug: 'femme', libelle: 'Femme', enfants: PAR_GENRE },
  homme: { slug: 'homme', libelle: 'Homme', enfants: PAR_GENRE },
  chaussures: { slug: 'chaussures', libelle: 'Chaussures', enfants: [...TYPES_CHAUSSURES, feuille('bottes', 'Bottes')] },
};

/** Classement de démonstration : slug du produit → type (troisième niveau). */
export const TYPES_DEMO: Partial<Record<string, string>> = {
  'air-zoom-pegasus-41': 'course',
  'ultra-boost-22': 'course',
  'chuck-taylor-all-star': 'sneakers',
  'polo-shirt': 'polos',
};

export function estRubrique(x: string): x is Rubrique {
  return x === 'femme' || x === 'homme' || x === 'chaussures';
}

export function hrefDe(rubrique: Rubrique, chemin: string[]): string {
  return `/${[rubrique, ...chemin].join('/')}`;
}

/** La lignée de la racine au nœud visé, ou undefined si un segment n'existe pas. */
export function trouverNoeud(rubrique: Rubrique, chemin: string[]): { noeud: Noeud; lignee: Noeud[] } | undefined {
  let noeud: Noeud = ARBRE[rubrique];
  const lignee: Noeud[] = [noeud];
  for (const segment of chemin) {
    const suivant = noeud.enfants.find((e) => e.slug === segment);
    if (!suivant) return undefined;
    lignee.push(suivant);
    noeud = suivant;
  }
  return { noeud, lignee };
}

export function produitsDe(produits: Produit[], rubrique: Rubrique, chemin: string[]): Produit[] {
  if (rubrique === 'chaussures') {
    const [type] = chemin;
    return produits.filter((p) => p.categorie === 'chaussures' && (type === undefined || TYPES_DEMO[p.slug] === type));
  }
  const [categorie, type] = chemin;
  return produits.filter(
    (p) => correspondAuGenre(p, rubrique)
      && (categorie === undefined || p.categorie === categorie)
      && (type === undefined || TYPES_DEMO[p.slug] === type),
  );
}

/** Les enfants du nœud visé, avec leur adresse et leur nombre de produits. */
export function sousCategories(produits: Produit[], rubrique: Rubrique, chemin: string[]): ElementSousCategorie[] {
  const trouve = trouverNoeud(rubrique, chemin);
  if (!trouve) return [];
  return trouve.noeud.enfants.map((e) => ({
    libelle: e.libelle,
    href: hrefDe(rubrique, [...chemin, e.slug]),
    nombre: produitsDe(produits, rubrique, [...chemin, e.slug]).length,
  }));
}

/** « Chaussures Homme », « Course Homme » ; sous la rubrique Chaussures : « Course ». */
export function titreDe(rubrique: Rubrique, chemin: string[]): string {
  const trouve = trouverNoeud(rubrique, chemin);
  if (!trouve) return '';
  if (chemin.length === 0 || rubrique === 'chaussures') return trouve.noeud.libelle;
  return `${trouve.noeud.libelle} ${ARBRE[rubrique].libelle}`;
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
