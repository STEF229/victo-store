import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import AccueilPage from '../src/app/page';
import { estEnPromotion } from '../src/lib/catalogue';
import { MARQUES, PRODUITS } from '../src/lib/donnees';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);

describe('page d’accueil', () => {
  it('commence par l’en-tête, sans barre d’annonce séparée', () => {
    render(<AccueilPage />);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByTestId('filet-annonce')).toBeInTheDocument();
    expect(screen.queryByTestId('barre-annonce')).toBeNull();
  });

  it('rend le contenu principal et le pied', () => {
    render(<AccueilPage />);
    expect(screen.getByRole('main')).toBeInTheDocument();
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('n’a qu’un seul titre de niveau 1', () => {
    render(<AccueilPage />);
    expect(screen.getAllByRole('heading', { level: 1 })).toHaveLength(1);
  });

  it('enchaîne les sections dans l’ordre de la maquette', () => {
    render(<AccueilPage />);
    const ids = ['carrousel', 'bande-marques', 'bonnes-affaires', 'categories', 'infolettre', 'reassurance', 'pied'];
    const blocs = ids.map((id) => screen.getByTestId(id));
    for (let i = 1; i < blocs.length; i++) {
      const avant = blocs[i - 1] as Element;
      const apres = blocs[i] as Element;
      expect(avant.compareDocumentPosition(apres) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    }
  });

  it('garde les cinq entrées de navigation, Soldes en rouge', () => {
    render(<AccueilPage />);
    const nav = screen.getByRole('navigation', { name: 'Navigation principale' });
    const liens = Array.from(nav.querySelectorAll('a'));
    expect(liens.map((a) => a.textContent)).toEqual(['Femme', 'Homme', 'Chaussures', 'Marques', 'Soldes']);
    expect(classes(liens[4] as Element)).toContain('text-[#FF5A74]');
  });

  it('garde les marques et les quatre bonnes affaires', () => {
    render(<AccueilPage />);
    expect(screen.getByTestId('bande-piste').querySelectorAll('ul')[0]?.querySelectorAll('li')).toHaveLength(MARQUES.length);
    const attendu = Math.min(4, PRODUITS.filter(estEnPromotion).length);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(attendu);
  });
});
