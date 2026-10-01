import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { listerProduits } from '@/lib/donnees';
import { SousCategories } from '@/components/catalogue/SousCategories';
import { sousCategories } from '@/lib/arbre-categories';

export default function PageChaussures() {
  return (
    <VueCatalogue
      titre="Chaussures"
      description="Running, lifestyle et classiques, toutes pointures."
      produits={listerProduits().filter((p) => p.categorie === 'chaussures')}
      entete={<SousCategories titre="Sous-catégories de Chaussures" forme="vignettes" elements={sousCategories(listerProduits(), 'chaussures', [])} />}
    />
  );
}
