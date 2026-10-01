import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';

export default async function PageSousCategorieFemme({ params }: { params: Promise<{ chemin: string[] }> }) {
  const { chemin } = await params;
  return <PageSousCategorie rubrique="femme" chemin={chemin} />;
}
