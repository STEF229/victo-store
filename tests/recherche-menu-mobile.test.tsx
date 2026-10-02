import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { MenuMobile } from '../src/components/navigation/MenuMobile';
import { NAV } from '../src/lib/navigation';

describe('menu mobile — recherche', () => {
  it('propose un vrai formulaire de recherche en haut du menu', () => {
    render(<MenuMobile navItems={NAV} />);
    fireEvent.click(screen.getByRole('button', { name: 'Ouvrir le menu' }));
    const tiroir = within(screen.getByRole('dialog', { name: 'Menu' }));
    const formulaire = tiroir.getByRole('search');
    expect(formulaire).toHaveAttribute('action', '/recherche');
    expect(formulaire).toHaveAttribute('method', 'get');
    const champ = tiroir.getByLabelText('Rechercher dans la boutique');
    expect(champ).toHaveAttribute('name', 'q');
    expect(champ).toHaveAttribute('type', 'search');
    expect(champ.getAttribute('class') ?? '').toContain('text-base');
  });

  it('le place avant les rubriques, et pas au second niveau', () => {
    render(<MenuMobile navItems={NAV} />);
    fireEvent.click(screen.getByRole('button', { name: 'Ouvrir le menu' }));
    const tiroir = screen.getByRole('dialog', { name: 'Menu' });
    const formulaire = within(tiroir).getByRole('search');
    const femme = within(tiroir).getByRole('button', { name: 'Femme' });
    expect(formulaire.compareDocumentPosition(femme) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    fireEvent.click(femme);
    expect(within(screen.getByRole('dialog', { name: 'Menu' })).queryByRole('search')).toBeNull();
  });
});
