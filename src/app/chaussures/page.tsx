import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { listerProduits } from '@/lib/donnees';

export default function PageChaussures() {
  return (
    <VueCatalogue
      titre="Chaussures"
      description="Running, lifestyle et classiques, toutes pointures."
      produits={listerProduits().filter((p) => p.categorie === 'chaussures')}
    />
  );
}
