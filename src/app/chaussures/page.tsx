import { chargerCatalogue } from '@/lib/catalogue-source';
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { SousCategories } from '@/components/catalogue/SousCategories';
import { sousCategories } from '@/lib/arbre-categories';

export default async function PageChaussures() {
  const { produits } = await chargerCatalogue();
  return (
    <VueCatalogue
      titre="Chaussures"
      description="Running, lifestyle et classiques, toutes pointures."
      produits={produits.filter((p) => p.categorie === 'chaussures')}
      entete={<SousCategories titre="Sous-catégories de Chaussures" forme="vignettes" elements={sousCategories(produits, 'chaussures', [])} />}
    />
  );
}
