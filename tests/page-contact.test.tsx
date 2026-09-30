import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageContact from '../src/app/contact/page';

describe('page Contact', () => {
  it('assemble titre, menu marqué, formulaire et coordonnées', () => {
    render(<PageContact />);
    expect(screen.getByRole('heading', { level: 1, name: 'Contact' })).toBeInTheDocument();
    expect(within(screen.getByRole('navigation', { name: 'Aide' })).getByRole('link', { name: 'Contact' })).toHaveAttribute('aria-current', 'page');
    expect(screen.getByRole('form', { name: 'Écrire au service client' })).toBeInTheDocument();
    const coordonnees = screen.getByRole('complementary', { name: 'Nos coordonnées' });
    for (const t of ['Courriel', 'Téléphone', 'Heures', 'Adresse']) expect(within(coordonnees).getByText(t)).toBeInTheDocument();
    expect(coordonnees.querySelectorAll('mark')).toHaveLength(3);
  });
});
