import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Reassurance } from '../src/components/accueil/Reassurance';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('engagements — téléphone', () => {
  it('place l’icône à gauche du titre et du texte', () => {
    render(<Reassurance />);
    const titre = screen.getByRole('heading', { name: 'Paiement sécurisé' });
    expect(classes(titre.closest('li'))).toContain('max-sm:flex-row');
    const bloc = titre.closest('div');
    expect(bloc?.contains(screen.getByText(/ne transitent jamais/))).toBe(true);
    expect(bloc?.querySelector('svg')).toBeNull();
  });
});
