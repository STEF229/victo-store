import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { SousCategories } from '@/components/catalogue/SousCategories';
import { correspondAuGenre } from '@/lib/catalogue';
import { listerProduits } from '@/lib/donnees';
import { sousCategories } from '@/lib/arbre-categories';

export default function PageFemme() {
  return (
    <VueCatalogue
      titre="Femme"
      description="Sneakers, vêtements et accessoires des grandes marques, au bon prix."
      produits={listerProduits().filter((p) => correspondAuGenre(p, 'femme'))}
      entete={<SousCategories titre="Sous-catégories de Femme" forme="vignettes" elements={sousCategories(listerProduits(), 'femme', [])} />}
    />
  );
}
