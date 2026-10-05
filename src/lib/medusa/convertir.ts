import type { Categorie, Genre, Marque, Produit, Variante } from '@/lib/catalogue';
import { normaliser } from '@/lib/recherche';

/** Les champs de l'API boutique de Medusa dont le site se sert (le reste est ignoré). */
export interface CategorieMedusa {
  id: string;
  name: string;
  handle: string;
  parent_category_id: string | null;
}
export interface VarianteMedusa {
  id: string;
  title: string | null;
  sku: string | null;
  manage_inventory: boolean | null;
  inventory_quantity?: number | null;
  options?: { value: string; option?: { title: string } | null }[] | null;
  calculated_price?: { calculated_amount: number | null; original_amount: number | null } | null;
}
export interface ProduitMedusa {
  id: string;
  title: string;
  subtitle: string | null;
  handle: string;
  description: string | null;
  thumbnail: string | null;
  images?: { url: string }[] | null;
  tags?: { value: string }[] | null;
  categories?: { id: string }[] | null;
  variants?: VarianteMedusa[] | null;
}

export const IMAGE_ABSENTE = '/img/sans-photo.svg';
/** Stock affiché quand Medusa ne suit pas l'inventaire d'une variante. */
export const STOCK_NON_SUIVI = 99;
const RAYONS: Categorie[] = ['chaussures', 'vetements', 'accessoires'];

/**
 * Les photos téléversées dans Medusa (adresse finissant par /static/fichier.jpg) sont servies par la
 * boutique elle-même, à /medusa-images/fichier.jpg, relayées vers Medusa (next.config.ts) : elles s'affichent partout,
 * tunnel compris. Les autres adresses ne changent pas.
 */
export function imageLocale(url: string): string {
  return url.includes('/static/') ? url.replace(/^.*?\/static\//, '/medusa-images/') : url;
}

const enCents = (montant: number) => Math.round(montant * 100);
const estRayon = (handle: string | undefined): handle is Categorie => RAYONS.some((r) => r === handle);

function genreDe(tags: { value: string }[]): Genre | undefined {
  const femme = tags.some((t) => t.value === 'femme');
  const homme = tags.some((t) => t.value === 'homme');
  if (femme && homme) return 'mixte';
  if (femme) return 'femme';
  if (homme) return 'homme';
  return undefined;
}

function varianteDe(v: VarianteMedusa): Variante {
  const valeur = (v.options ?? []).find(() => true)?.value;
  return {
    id: v.id,
    taille: valeur ?? v.title ?? '',
    sku: v.sku ?? v.id,
    stock: v.manage_inventory ? Math.max(0, v.inventory_quantity ?? 0) : STOCK_NON_SUIVI,
  };
}

/** Les marques : les catégories rangées sous « Marques ». */
export function convertirMarques(categories: CategorieMedusa[]): Marque[] {
  const racine = categories.find((c) => c.handle === 'marques');
  if (!racine) return [];
  return categories.filter((c) => c.parent_category_id === racine.id).map((c) => ({ id: c.id, nom: c.name, slug: c.handle }));
}

/** Un produit Medusa, au format du site. */
export function convertirProduit(p: ProduitMedusa, categories: CategorieMedusa[]): Produit {
  const parId = (id: string | null) => categories.find((c) => c.id === id);
  const siennes = (p.categories ?? []).map((c) => parId(c.id)).filter((c): c is CategorieMedusa => c !== undefined);
  const marqueCat = siennes.find((c) => parId(c.parent_category_id)?.handle === 'marques');
  const typeCat = siennes.find((c) => estRayon(parId(c.parent_category_id)?.handle));
  const rayon = typeCat ? parId(typeCat.parent_category_id)?.handle : siennes.map((c) => c.handle).find(estRayon);
  const nomMarque = p.subtitle ?? 'Sans marque';
  const marque: Marque = marqueCat
    ? { id: marqueCat.id, nom: marqueCat.name, slug: marqueCat.handle }
    : { id: `marque-${normaliser(nomMarque).replace(/ /g, '-')}`, nom: nomMarque, slug: normaliser(nomMarque).replace(/ /g, '-') };

  const prix = (p.variants ?? [])
    .map((v) => v.calculated_price)
    .filter((c): c is { calculated_amount: number; original_amount: number | null } => typeof c?.calculated_amount === 'number')
    .reduce<{ calculated_amount: number; original_amount: number | null } | undefined>((min, c) => (min === undefined || c.calculated_amount < min.calculated_amount ? c : min), undefined);
  const images = (p.images ?? []).map((i) => imageLocale(i.url));
  const genre = genreDe(p.tags ?? []);
  const original = prix?.original_amount;

  return {
    id: p.id,
    slug: p.handle,
    nom: p.title,
    marque,
    imageUrl: (p.thumbnail ? imageLocale(p.thumbnail) : undefined) ?? images.find(() => true) ?? IMAGE_ABSENTE,
    prixCents: prix ? enCents(prix.calculated_amount) : 0,
    ...(prix && typeof original === 'number' && original > prix.calculated_amount ? { prixCompareCents: enCents(original) } : {}),
    variantes: (p.variants ?? []).map(varianteDe),
    ...(genre ? { genre } : {}),
    ...(rayon && estRayon(rayon) ? { categorie: rayon } : {}),
    ...(typeCat ? { type: typeCat.handle } : {}),
    ...(p.description ? { description: p.description } : {}),
    ...(images.length > 0 ? { images } : {}),
  };
}
