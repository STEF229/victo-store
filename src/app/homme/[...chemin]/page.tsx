import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';

export default async function PageSousCategorieHomme({ params }: { params: Promise<{ chemin: string[] }> }) {
  const { chemin } = await params;
  return <PageSousCategorie rubrique="homme" chemin={chemin} />;
}
