import { describe, expect, it } from 'vitest';
import * as convertir from '../src/lib/medusa/convertir';
import type { ProduitMedusa } from '../src/lib/medusa/convertir';

// Import par espace de noms : avant le ticket, imageLocale n'existe pas, et le test échoue sans planter.
const P: ProduitMedusa = { id: 'p', title: 'P', subtitle: 'Nike', handle: 'p', description: null, thumbnail: null };

describe('photos de Medusa', () => {
  it('fait passer les photos téléversées par la boutique', () => {
    expect(typeof convertir.imageLocale).toBe('function');
    expect(convertir.imageLocale('http://localhost:9000/static/1728-pegasus.png')).toBe('/medusa-images/1728-pegasus.png');
    expect(convertir.imageLocale('/static/a/b.jpg')).toBe('/medusa-images/a/b.jpg');
    expect(convertir.imageLocale('https://exemple.ca/vignette.jpg')).toBe('https://exemple.ca/vignette.jpg');
  });

  it('l’applique à la vignette et aux images du produit', () => {
    const p = convertir.convertirProduit({ ...P, thumbnail: 'http://localhost:9000/static/v.png', images: [{ url: 'http://localhost:9000/static/a.png' }] }, []);
    expect([p.imageUrl, p.images]).toEqual(['/medusa-images/v.png', ['/medusa-images/a.png']]);
    expect(convertir.convertirProduit(P, []).imageUrl).toBe(convertir.IMAGE_ABSENTE);
  });
});
