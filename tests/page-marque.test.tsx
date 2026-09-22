import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
// Dépendance déclarée pour le harnais : sans VueCatalogue, ce ticket est BLOQUÉ au lieu d'échouer trois fois.
import { VueCatalogue as _dependance } from '../src/components/catalogue/VueCatalogue';
import PageMarque from '../src/app/marques/[slug]/page';
import { MARQUES, PRODUITS } from '../src/lib/donnees';

const rendre = async (slug: string) => render(await PageMarque({ params: Promise.resolve({ slug }) }));

describe('page marque', () => {
  it.each(MARQUES.map((m) => [m.nom, m] as const))('présente la marque %s', async (_nom, m) => {
    await rendre(m.slug);
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe(m.nom);
    const n = PRODUITS.filter((p) => p.marque.slug === m.slug).length;
    expect(screen.getByTestId('compteur').textContent).toBe(`${n} ${n > 1 ? 'produits' : 'produit'}`);
  });

  it('n’affiche que les produits de la marque', async () => {
    const m = MARQUES.find((x) => PRODUITS.some((p) => p.marque.slug === x.slug));
    expect(m).toBeDefined();
    await rendre(m?.slug ?? '');
    for (const carte of screen.queryAllByTestId('carte-produit')) {
      const p = PRODUITS.find((x) => x.id === carte.getAttribute('data-produit-id'));
      expect(p?.marque.slug).toBe(m?.slug);
    }
  });

  it('gère une marque inconnue', async () => {
    await rendre('marque-inexistante');
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe('Marque introuvable');
    expect(screen.getByTestId('compteur').textContent).toBe('0 produit');
  });
});
