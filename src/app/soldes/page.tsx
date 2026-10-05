import { chargerCatalogue } from '@/lib/catalogue-source';
import { estEnPromotion } from '@/lib/catalogue';
import { VueCatalogue } from '@/components/catalogue/VueCatalogue';

export default async function PageSoldes() {
  const { produits } = await chargerCatalogue();
  return (
    <VueCatalogue
      titre="Soldes"
      description="Toutes les remises du moment, jusqu'à moitié prix."
      produits={produits.filter(estEnPromotion)}
    />
  );
}
