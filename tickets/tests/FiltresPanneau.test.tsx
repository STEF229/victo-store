import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { FiltresPanneau } from '../src/components/catalogue/FiltresPanneau';
import type { Marque } from '../src/lib/catalogue';

const MARQUES: Marque[] = [
  { id: 'm1', nom: 'Nike', slug: 'nike' },
  { id: 'm2', nom: 'Lacoste', slug: 'lacoste' },
];
const TAILLES = ['40', '41', 'M'];

function poser(criteres = {}, onChange = vi.fn()) {
  render(<FiltresPanneau marques={MARQUES} tailles={TAILLES} criteres={criteres} onChange={onChange} />);
  return onChange;
}

describe('FiltresPanneau — structure', () => {
  it('rend le panneau et ses groupes', () => {
    poser();
    expect(screen.getByTestId('filtres')).toBeInTheDocument();
    expect(screen.getByText('Marques')).toBeInTheDocument();
    expect(screen.getByText('Tailles')).toBeInTheDocument();
  });

  it('rend une case par marque et par taille', () => {
    poser();
    expect(screen.getByTestId('filtre-marque-nike')).toBeInTheDocument();
    expect(screen.getByTestId('filtre-marque-lacoste')).toBeInTheDocument();
    for (const t of TAILLES) expect(screen.getByTestId(`filtre-taille-${t}`)).toBeInTheDocument();
  });

  it('rend les bascules promo et stock', () => {
    poser();
    expect(screen.getByTestId('filtre-promo')).toBeInTheDocument();
    expect(screen.getByTestId('filtre-stock')).toBeInTheDocument();
  });
});

describe('FiltresPanneau — reflet de l’état', () => {
  it('coche les marques sélectionnées', () => {
    poser({ marques: ['nike'] });
    expect(screen.getByTestId('filtre-marque-nike')).toBeChecked();
    expect(screen.getByTestId('filtre-marque-lacoste')).not.toBeChecked();
  });

  it('coche les bascules actives', () => {
    poser({ promotionSeulement: true });
    expect(screen.getByTestId('filtre-promo')).toBeChecked();
    expect(screen.getByTestId('filtre-stock')).not.toBeChecked();
  });
});

describe('FiltresPanneau — interactions', () => {
  it('ajoute une marque', () => {
    const onChange = poser({});
    fireEvent.click(screen.getByTestId('filtre-marque-nike'));
    expect(onChange).toHaveBeenCalledTimes(1);
    expect(onChange.mock.calls[0]![0].marques).toEqual(['nike']);
  });

  it('retire une marque déjà cochée', () => {
    const onChange = poser({ marques: ['nike', 'lacoste'] });
    fireEvent.click(screen.getByTestId('filtre-marque-nike'));
    expect(onChange.mock.calls[0]![0].marques).toEqual(['lacoste']);
  });

  it('ajoute une taille', () => {
    const onChange = poser({});
    fireEvent.click(screen.getByTestId('filtre-taille-41'));
    expect(onChange.mock.calls[0]![0].tailles).toEqual(['41']);
  });

  it('bascule les promotions', () => {
    const onChange = poser({});
    fireEvent.click(screen.getByTestId('filtre-promo'));
    expect(onChange.mock.calls[0]![0].promotionSeulement).toBe(true);
  });

  it('bascule le stock', () => {
    const onChange = poser({});
    fireEvent.click(screen.getByTestId('filtre-stock'));
    expect(onChange.mock.calls[0]![0].enStockSeulement).toBe(true);
  });

  it('réinitialise tout', () => {
    const onChange = poser({ marques: ['nike'], promotionSeulement: true });
    fireEvent.click(screen.getByTestId('filtres-reinitialiser'));
    expect(onChange).toHaveBeenCalledWith({});
  });

  it('ne mute pas l’objet de critères reçu', () => {
    const criteres = { marques: ['nike'] };
    const onChange = vi.fn();
    render(<FiltresPanneau marques={MARQUES} tailles={TAILLES} criteres={criteres} onChange={onChange} />);
    fireEvent.click(screen.getByTestId('filtre-marque-lacoste'));
    expect(criteres.marques).toEqual(['nike']);
  });
});
