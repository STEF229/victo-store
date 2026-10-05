import { chargerCatalogue } from '@/lib/catalogue-source';
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { SousCategories } from '@/components/catalogue/SousCategories';
import { correspondAuGenre } from '@/lib/catalogue';
import { sousCategories } from '@/lib/arbre-categories';

export default async function PageHomme() {
  const { produits } = await chargerCatalogue();
  return (
    <VueCatalogue
      titre="Homme"
      description="Sneakers, vêtements et accessoires des grandes marques, au bon prix."
      produits={produits.filter((p) => correspondAuGenre(p, 'homme'))}
      entete={<SousCategories titre="Sous-catégories de Homme" forme="vignettes" elements={sousCategories(produits, 'homme', [])} />}
    />
  );
}
