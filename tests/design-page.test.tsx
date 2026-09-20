import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { DesignPage } from '../src/app/design/page';

describe('page design system', () => {
  it('rend le titre principal', () => {
    render(<DesignPage />);
    expect(screen.getByRole('heading', { level: 1, name: 'Design system' })).toBeInTheDocument();
  });

  it('rend l’en-tête du site', () => {
    render(<DesignPage />);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByTestId('entete-panier')).toHaveAttribute('data-cart-count', '2');
  });

  it.each(['Boutons', 'Badges', 'Prix', 'Formulaire', 'Sélection', 'Produits'])(
    'rend la section %s',
    (titre) => {
      render(<DesignPage />);
      expect(screen.getByRole('heading', { level: 2, name: titre })).toBeInTheDocument();
    },
  );

  it('montre les quatre variantes de badge', () => {
    render(<DesignPage />);
    const variantes = screen.getAllByTestId('badge').map((b) => b.getAttribute('data-variant'));
    for (const v of ['promo', 'neutre', 'marque', 'nouveau']) {
      expect(variantes).toContain(v);
    }
  });

  it('montre un prix en promotion', () => {
    render(<DesignPage />);
    expect(screen.getAllByTestId('prix-remise').length).toBeGreaterThan(0);
  });

  it('rend trois cartes produit dont une en promotion', () => {
    render(<DesignPage />);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(3);
    expect(screen.getAllByTestId('prix-compare').length).toBeGreaterThan(0);
  });

  it('rend un champ en erreur', () => {
    render(<DesignPage />);
    expect(screen.getAllByRole('alert').length).toBeGreaterThan(0);
  });

  it('la sélection de taille est réellement interactive', () => {
    render(<DesignPage />);
    const groupe = screen.getByRole('group');
    const boutons = Array.from(groupe.querySelectorAll('button')).filter((b) => !b.disabled);
    const cible = boutons[1] ?? boutons[0];
    expect(cible).toBeDefined();
    fireEvent.click(cible as HTMLButtonElement);
    expect(cible).toHaveAttribute('aria-pressed', 'true');
  });

  it('le compteur de quantité est réellement interactif', () => {
    render(<DesignPage />);
    const avant = screen.getByTestId('quantite-valeur').textContent;
    fireEvent.click(screen.getByRole('button', { name: 'Augmenter la quantité' }));
    expect(screen.getByTestId('quantite-valeur').textContent).not.toBe(avant);
  });
});
