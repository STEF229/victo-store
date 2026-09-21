import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { AccueilPage } from '../src/app/page';
import { estEnPromotion } from '../src/lib/catalogue';
import { MARQUES, PRODUITS } from '../src/lib/donnees';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);

describe('page d’accueil — structure', () => {
  it('rend l’en-tête, le contenu et le pied', () => {
    render(<AccueilPage />);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByRole('main')).toBeInTheDocument();
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('n’a qu’un seul titre de niveau 1', () => {
    render(<AccueilPage />);
    expect(screen.getAllByRole('heading', { level: 1 })).toHaveLength(1);
  });

  it('enchaîne les sections dans l’ordre de la maquette', () => {
    render(<AccueilPage />);
    const ids = ['barre-annonce', 'carrousel', 'bande-marques', 'bonnes-affaires', 'categories', 'infolettre', 'reassurance', 'pied'];
    const blocs = ids.map((id) => screen.getByTestId(id));
    for (let i = 1; i < blocs.length; i++) {
      const avant = blocs[i - 1] as Element;
      const apres = blocs[i] as Element;
      expect(avant.compareDocumentPosition(apres) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    }
  });

  it('place la barre d’annonce avant l’en-tête', () => {
    render(<AccueilPage />);
    const barre = screen.getByTestId('barre-annonce');
    expect(barre.compareDocumentPosition(screen.getByRole('banner')) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  });
});

describe('page d’accueil — contenu', () => {
  it('propose cinq entrées de navigation, Soldes en rouge', () => {
    render(<AccueilPage />);
    const nav = screen.getByRole('navigation', { name: 'Navigation principale' });
    const liens = Array.from(nav.querySelectorAll('a'));
    expect(liens.map((a) => a.textContent)).toEqual(['Femme', 'Homme', 'Chaussures', 'Marques', 'Soldes']);
    expect(classes(liens[4] as Element)).toContain('text-[var(--vs-promo)]');
  });

  it('fait défiler toutes les marques', () => {
    render(<AccueilPage />);
    const listes = screen.getByTestId('bande-piste').querySelectorAll('ul');
    expect(listes[0]?.querySelectorAll('li')).toHaveLength(MARQUES.length);
  });

  it('présente quatre bonnes affaires, toutes en promotion', () => {
    render(<AccueilPage />);
    const attendu = Math.min(4, PRODUITS.filter(estEnPromotion).length);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(attendu);
    expect(screen.getAllByTestId('prix-remise')).toHaveLength(attendu);
  });
});

describe('page d’accueil — enveloppes', () => {
  it.each(['bonnes-affaires', 'categories', 'infolettre', 'reassurance'])(
    'centre la section %s dans la largeur de la maquette',
    (id) => {
      render(<AccueilPage />);
      const env = screen.getByTestId(id).parentElement as Element;
      for (const k of ['mx-auto', 'max-w-[1440px]', 'px-5', 'lg:px-20']) expect(classes(env)).toContain(k);
    },
  );
});
