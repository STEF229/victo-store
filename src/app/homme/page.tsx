import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { SousCategories } from '@/components/catalogue/SousCategories';
import { correspondAuGenre } from '@/lib/catalogue';
import { listerProduits } from '@/lib/donnees';
import { sousCategories } from '@/lib/arbre-categories';

export default function PageHomme() {
  return (
    <VueCatalogue
      titre="Homme"
      description="Sneakers, vêtements et accessoires des grandes marques, au bon prix."
      produits={listerProduits().filter((p) => correspondAuGenre(p, 'homme'))}
      entete={<SousCategories titre="Sous-catégories de Homme" forme="vignettes" elements={sousCategories(listerProduits(), 'homme', [])} />}
    />
  );
}
