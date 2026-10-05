TICKET 113d — choisir la source du catalogue

Crée `src/lib/catalogue-source.ts`. Le point d'entrée unique du catalogue : démonstration par défaut, Medusa avec `CATALOGUE_SOURCE=medusa`, et retour automatique à la démonstration si Medusa ne répond pas.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : recopie le fichier tel quel (il n'utilise
  aucun accès par index ; `.find`, `.filter`, `.map`, `.reduce`, `.some`).
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~35 lignes.
```ts
import type { Marque, Produit } from '@/lib/catalogue';
import { listerMarques, listerProduits } from '@/lib/donnees';
import { configMedusa, lireCategoriesMedusa, lireProduitsMedusa } from '@/lib/medusa/client';
import { convertirMarques, convertirProduit } from '@/lib/medusa/convertir';

export interface Catalogue {
  produits: Produit[];
  marques: Marque[];
  source: 'demo' | 'medusa';
}

/**
 * Le catalogue du site. Par défaut, les données de démonstration ; avec CATALOGUE_SOURCE=medusa,
 * celui de Medusa. Si Medusa est mal configuré ou ne répond pas, retour aux données de
 * démonstration (une démonstration ne tombe jamais), avec un message dans les journaux.
 */
export async function chargerCatalogue(env: Record<string, string | undefined> = process.env): Promise<Catalogue> {
  const demo: Catalogue = { produits: listerProduits(), marques: listerMarques(), source: 'demo' };
  if (env.CATALOGUE_SOURCE !== 'medusa') return demo;
  const config = configMedusa(env);
  if (!config) {
    console.error('[catalogue] CATALOGUE_SOURCE=medusa, mais MEDUSA_URL, MEDUSA_CLE ou MEDUSA_REGION manque : données de démonstration.');
    return demo;
  }
  try {
    const [bruts, categories] = await Promise.all([lireProduitsMedusa(config), lireCategoriesMedusa(config)]);
    return { produits: bruts.map((p) => convertirProduit(p, categories)), marques: convertirMarques(categories), source: 'medusa' };
  } catch (erreur) {
    console.error('[catalogue] Medusa ne répond pas : données de démonstration.', erreur);
    return demo;
  }
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
