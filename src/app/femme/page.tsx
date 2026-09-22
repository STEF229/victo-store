import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { correspondAuGenre } from '@/lib/catalogue';
import { listerProduits } from '@/lib/donnees';

export default function PageFemme() {
  return (
    <VueCatalogue
      titre="Femme"
      description="Sneakers, vêtements et accessoires des grandes marques, au bon prix."
      produits={listerProduits().filter((p) => correspondAuGenre(p, 'femme'))}
    />
  );
}
