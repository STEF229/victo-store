import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';
import { chargerCatalogue } from '@/lib/catalogue-source';

export default async function PageSousCategorieHomme({ params }: { params: Promise<{ chemin: string[] }> }) {
  const { chemin } = await params;
  const { produits } = await chargerCatalogue();
  return <PageSousCategorie rubrique="homme" chemin={chemin} produits={produits} />;
}
