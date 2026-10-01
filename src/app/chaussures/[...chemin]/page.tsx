import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';

export default async function PageSousCategorieChaussures({ params }: { params: Promise<{ chemin: string[] }> }) {
  const { chemin } = await params;
  return <PageSousCategorie rubrique="chaussures" chemin={chemin} />;
}
