import { describe, expect, it } from 'vitest';
import { COLONNES_PIED, NAV } from '../src/lib/navigation';

describe('navigation partagée', () => {
  it('propose les cinq entrées du menu, Soldes en promo', () => {
    expect(NAV).toEqual([
      { label: 'Femme', href: '/femme' },
      { label: 'Homme', href: '/homme' },
      { label: 'Chaussures', href: '/chaussures' },
      { label: 'Marques', href: '/marques' },
      { label: 'Soldes', href: '/soldes', promo: true },
    ]);
  });

  it('propose les deux colonnes du pied de page', () => {
    expect(COLONNES_PIED.map((c) => c.titre)).toEqual(['Boutique', 'Aide']);
    expect(COLONNES_PIED[1]?.liens.map((l) => l.href)).toEqual(['/livraison', '/retours', '/contact']);
  });
});
