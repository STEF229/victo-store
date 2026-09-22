import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { produitsDeMarque, trouverMarque } from '@/lib/donnees';

export default async function PageMarque({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const marque = trouverMarque(slug);
  if (!marque) {
    return <VueCatalogue titre="Marque introuvable" produits={[]} />;
  }
  return (
    <VueCatalogue
      titre={marque.nom}
      description={`Toute la sélection ${marque.nom}, au bon prix.`}
      produits={produitsDeMarque(slug)}
    />
  );
}
