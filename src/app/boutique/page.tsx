import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { listerProduits } from '@/lib/donnees';

export default function PageBoutique() {
  return (
    <VueCatalogue
      titre="Boutique"
      description="Toute la sélection, toutes marques confondues, au bon prix."
      produits={listerProduits()}
    />
  );
}
