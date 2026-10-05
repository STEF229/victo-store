import { VueCatalogue } from '@/components/catalogue/VueCatalogue';
import { chargerCatalogue } from '@/lib/catalogue-source';

export default async function PageMarque({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const catalogue = await chargerCatalogue();
  const marque = catalogue.marques.find((m) => m.slug === slug);
  if (!marque) {
    return <VueCatalogue titre="Marque introuvable" produits={[]} />;
  }
  return (
    <VueCatalogue
      titre={marque.nom}
      description={`Toute la sélection ${marque.nom}, au bon prix.`}
      produits={catalogue.produits.filter((p) => p.marque.slug === slug)}
    />
  );
}
