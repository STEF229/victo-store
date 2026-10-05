import { chargerCatalogue } from '@/lib/catalogue-source';

/** Le catalogue, pour les composants du navigateur (recherche, menus, panier). Revalidé chaque minute. */
export const revalidate = 60;

export async function GET() {
  return Response.json(await chargerCatalogue());
}
