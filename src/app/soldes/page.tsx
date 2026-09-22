import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { estEnPromotion } from '@/lib/catalogue';
import { listerProduits } from '@/lib/donnees';

export default function PageSoldes() {
  return (
    <VueCatalogue
      titre="Soldes"
      description="Toutes les remises du moment, jusqu'à moitié prix."
      produits={listerProduits().filter(estEnPromotion)}
    />
  );
}
