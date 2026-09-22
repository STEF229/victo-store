import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { correspondAuGenre } from '@/lib/catalogue';
import { listerProduits } from '@/lib/donnees';

export default function PageHomme() {
  return (
    <VueCatalogue
      titre="Homme"
      description="Sneakers, vêtements et accessoires des grandes marques, au bon prix."
      produits={listerProduits().filter((p) => correspondAuGenre(p, 'homme'))}
    />
  );
}
