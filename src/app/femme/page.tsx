import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { SousCategories } from '@/components/catalogue/SousCategories';
import { correspondAuGenre } from '@/lib/catalogue';
import { chargerCatalogue } from '@/lib/catalogue-source';
import { sousCategories } from '@/lib/arbre-categories';

export default async function PageFemme() {
  const { produits } = await chargerCatalogue();
  return (
    <VueCatalogue
      titre="Femme"
      description="Sneakers, vêtements et accessoires des grandes marques, au bon prix."
      produits={produits.filter((p) => correspondAuGenre(p, 'femme'))}
      entete={<SousCategories titre="Sous-catégories de Femme" forme="vignettes" elements={sousCategories(produits, 'femme', [])} />}
    />
  );
}
