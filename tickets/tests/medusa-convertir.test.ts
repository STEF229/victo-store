import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import {
  IMAGE_ABSENTE, STOCK_NON_SUIVI, convertirMarques, convertirProduit, type CategorieMedusa, type ProduitMedusa, type VarianteMedusa,
} from '../src/lib/medusa/convertir';

// La vraie réponse de l'API boutique de Medusa, pour le produit d'essai (medusa-6-produit-essai.sh).
const reel = JSON.parse(readFileSync('tests/fixtures/medusa-essai.json', 'utf8')) as {
  produit_vu_par_la_boutique: { products: ProduitMedusa[] };
  categories_vues_par_la_boutique: { product_categories: CategorieMedusa[] };
};
const CATS = reel.categories_vues_par_la_boutique.product_categories;
const PEGASUS = reel.produit_vu_par_la_boutique.products.find(() => true) as ProduitMedusa;
const id = (handle: string) => CATS.find((c) => c.handle === handle)?.id ?? '';
const V = (nom: string, calcule: number, original: number, autre: Partial<VarianteMedusa> = {}): VarianteMedusa => ({
  id: `v-${nom}`, title: nom, sku: `sku-${nom}`, manage_inventory: true, inventory_quantity: 3,
  options: [{ value: nom }], calculated_price: { calculated_amount: calcule, original_amount: original }, ...autre,
});
const avec = (autre: Partial<ProduitMedusa>) => convertirProduit({ ...PEGASUS, ...autre }, CATS);

describe('Medusa → site : la vraie réponse', () => {
  it('traduit le produit d’essai, champ par champ', () => {
    expect(convertirProduit(PEGASUS, CATS)).toEqual({
      id: 'prod_01M44NZSNKV1SQH53B1XNAWRCH',
      slug: 'essai-air-zoom-pegasus-41',
      nom: 'Air Zoom Pegasus 41 (essai)',
      marque: { id: 'pcat_01M44NZMT1V09TM0T564QY74JN', nom: 'Nike', slug: 'nike' },
      imageUrl: IMAGE_ABSENTE,
      prixCents: 12900,
      prixCompareCents: 15900,
      variantes: [
        { id: 'variant_01M44NZSTW7P1PTBDRZFDG818P', taille: '41', sku: 'essai-pegasus-41', stock: 5 },
        { id: 'variant_01M44NZSTWSTC0VQFX44ZP5R21', taille: '42', sku: 'essai-pegasus-42', stock: 5 },
      ],
      genre: 'homme',
      categorie: 'chaussures',
      type: 'course',
      description: 'Produit d\'essai créé par l\'équipe technique pour brancher la boutique. À supprimer ensuite.',
    });
  });

  it('trouve les marques sous « Marques », et seulement elles', () => {
    expect(convertirMarques(CATS).map((m) => m.slug)).toEqual(['nike', 'adidas', 'converse', 'lacoste', 'levis', 'new-balance']);
    expect(convertirMarques(CATS.filter((c) => c.handle !== 'marques'))).toEqual([]);
  });
});

describe('Medusa → site : les cas du client', () => {
  it('lit le genre dans les étiquettes', () => {
    expect(avec({ tags: [{ value: 'femme' }, { value: 'homme' }] }).genre).toBe('mixte');
    expect(avec({ tags: [{ value: 'femme' }] }).genre).toBe('femme');
    expect('genre' in avec({ tags: [] })).toBe(false);
  });

  it('prend le prix le plus bas, et ne barre que pendant des soldes', () => {
    const p = avec({ variants: [V('41', 159, 159), V('42', 139, 179)] });
    expect([p.prixCents, p.prixCompareCents]).toEqual([13900, 17900]);
    const sansSolde = avec({ variants: [V('41', 159, 159)] });
    expect(sansSolde.prixCents).toBe(15900);
    expect('prixCompareCents' in sansSolde).toBe(false);
  });

  it('se rabat sur le sous-titre quand la marque n’est pas cochée', () => {
    expect(avec({ categories: [{ id: id('course') }], subtitle: 'New Balance' }).marque).toEqual({ id: 'marque-new-balance', nom: 'New Balance', slug: 'new-balance' });
    expect(avec({ categories: [], subtitle: null }).marque.nom).toBe('Sans marque');
  });

  it('accepte le rayon coché à la place du type', () => {
    const p = avec({ categories: [{ id: id('chaussures') }, { id: id('nike') }] });
    expect(p.categorie).toBe('chaussures');
    expect('type' in p).toBe(false);
  });

  it('lit le stock, et marque l’inventaire non suivi comme disponible', () => {
    const p = avec({ variants: [V('41', 159, 159, { inventory_quantity: -2 }), V('42', 159, 159, { manage_inventory: false }), V('43', 159, 159, { options: [] })] });
    expect(p.variantes.map((v) => [v.taille, v.stock])).toEqual([['41', 0], ['42', STOCK_NON_SUIVI], ['43', 3]]);
  });

  it('choisit la photo : vignette, sinon première image, sinon l’image de remplacement', () => {
    const images = [{ url: 'https://exemple.ca/a.jpg' }, { url: 'https://exemple.ca/b.jpg' }];
    const complet = avec({ thumbnail: 'https://exemple.ca/vignette.jpg', images });
    expect([complet.imageUrl, complet.images]).toEqual(['https://exemple.ca/vignette.jpg', ['https://exemple.ca/a.jpg', 'https://exemple.ca/b.jpg']]);
    expect(avec({ thumbnail: null, images }).imageUrl).toBe('https://exemple.ca/a.jpg');
    expect(avec({ thumbnail: null, images: [] }).imageUrl).toBe(IMAGE_ABSENTE);
  });
});
