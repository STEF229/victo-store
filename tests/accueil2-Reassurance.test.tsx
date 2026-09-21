import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Reassurance } from '../src/components/accueil/Reassurance';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);

describe('Reassurance', () => {
  it('rend trois engagements', () => {
    render(<Reassurance />);
    expect(screen.getByTestId('reassurance').querySelectorAll('li')).toHaveLength(3);
  });

  it('affiche les titres dans l’ordre', () => {
    render(<Reassurance />);
    expect(screen.getAllByRole('heading', { level: 3 }).map((h) => h.textContent)).toEqual([
      'Livraison offerte au Canada',
      'Retours gratuits 30 jours',
      'Paiement sécurisé',
    ]);
  });

  it('affiche les textes', () => {
    render(<Reassurance />);
    expect(screen.getByText('Expédiée du Québec sous 48 heures.')).toBeInTheDocument();
    expect(screen.getByText('Vos données de carte ne transitent jamais par nos serveurs.')).toBeInTheDocument();
  });

  it.each(['grid', 'grid-cols-1', 'gap-8', 'sm:grid-cols-3', 'lg:gap-12'])('la liste porte %s', (k) => {
    render(<Reassurance />);
    const ul = screen.getByTestId('reassurance').querySelector('ul');
    expect(classes(ul as Element)).toContain(k);
  });

  it('illustre chaque engagement d’une icône décorative', () => {
    render(<Reassurance />);
    const svgs = Array.from(screen.getByTestId('reassurance').querySelectorAll('svg'));
    expect(svgs).toHaveLength(3);
    for (const s of svgs) expect(s.getAttribute('aria-hidden')).toBe('true');
  });
});
