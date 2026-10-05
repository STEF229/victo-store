import type { CategorieMedusa, ProduitMedusa } from '@/lib/medusa/convertir';

/** Les champs demandés à Medusa : prix calculés, stock, options, catégories, étiquettes, photos. */
export const CHAMPS_PRODUITS = '*variants.calculated_price,+variants.inventory_quantity,*variants.options,*variants.options.option,*categories,*tags,*images';

export interface ConfigMedusa {
  url: string;
  cle: string;
  region: string;
}

/** Lit MEDUSA_URL, MEDUSA_CLE et MEDUSA_REGION ; null s'il en manque un. */
export function configMedusa(env: Record<string, string | undefined> = process.env): ConfigMedusa | null {
  const url = env.MEDUSA_URL;
  const cle = env.MEDUSA_CLE;
  const region = env.MEDUSA_REGION;
  if (!url || !cle || !region) return null;
  return { url: url.replace(/\/+$/, ''), cle, region };
}

async function lire<T>(c: ConfigMedusa, chemin: string): Promise<T> {
  const reponse = await fetch(`${c.url}${chemin}`, {
    headers: { 'x-publishable-api-key': c.cle },
    next: { revalidate: 60 },
  });
  if (!reponse.ok) throw new Error(`Medusa a répondu ${reponse.status} pour ${chemin}`);
  return (await reponse.json()) as T;
}

/** Tous les produits visibles par la boutique, page par page (100 à la fois). */
export async function lireProduitsMedusa(c: ConfigMedusa): Promise<ProduitMedusa[]> {
  const tous: ProduitMedusa[] = [];
  for (let offset = 0; ; offset += 100) {
    const page = await lire<{ products: ProduitMedusa[]; count: number }>(
      c,
      `/store/products?limit=100&offset=${offset}&region_id=${encodeURIComponent(c.region)}&fields=${encodeURIComponent(CHAMPS_PRODUITS)}`,
    );
    tous.push(...page.products);
    if (page.products.length === 0 || tous.length >= page.count) return tous;
  }
}

export async function lireCategoriesMedusa(c: ConfigMedusa): Promise<CategorieMedusa[]> {
  const r = await lire<{ product_categories: CategorieMedusa[] }>(c, '/store/product-categories?limit=500&fields=id,name,handle,parent_category_id');
  return r.product_categories;
}
