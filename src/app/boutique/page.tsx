import { chargerCatalogue } from '@/lib/catalogue-source';
import VueCatalogue from '@/components/catalogue/VueCatalogue';

export default async function PageBoutique() {
  const { produits } = await chargerCatalogue();
  return (
    <VueCatalogue
      titre="Boutique"
      description="Toute la sélection, toutes marques confondues, au bon prix."
      produits={produits}
    />
  );
}
