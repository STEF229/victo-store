import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { PageSousCategorie } from '../src/components/catalogue/PageSousCategorie';

describe('page de sous-catégorie — fil d’Ariane en haut', () => {
  it('place le fil d’Ariane avant le titre, et les pastilles après', () => {
    render(<PageSousCategorie rubrique="femme" chemin={['vetements']} />);
    const fil = screen.getByTestId('fil-ariane');
    const titre = screen.getByTestId('liste-titre');
    const pastilles = screen.getByRole('navigation', { name: 'Sous-catégories de Vêtements' });
    expect(fil.compareDocumentPosition(titre) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(titre.compareDocumentPosition(pastilles) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  });
});
