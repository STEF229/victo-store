import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';
import { chargerCatalogue } from '@/lib/catalogue-source';

export default async function PageSousCategorieFemme({ params }: { params: Promise<{ chemin: string[] }> }) {
  const { chemin } = await params;
  const { produits } = await chargerCatalogue();
  return <PageSousCategorie rubrique="femme" chemin={chemin} produits={produits} />;
}
