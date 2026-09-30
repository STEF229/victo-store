import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { GabaritAide, RUBRIQUES_AIDE } from '../src/components/aide/GabaritAide';
import { MENU_LIEN_ACTIF } from '../src/components/compte/compte-affichage';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('GabaritAide', () => {
  it('liste les cinq rubriques, dans l’ordre, avec leurs adresses', () => {
    expect(RUBRIQUES_AIDE.map((r) => [r.libelle, r.href])).toEqual([
      ['Livraison', '/livraison'], ['Retours et échanges', '/retours'], ['Contact', '/contact'],
      ['Conditions de vente', '/conditions-de-vente'], ['Confidentialité', '/confidentialite'],
    ]);
  });

  it('assemble en-tête, fil, menu marqué, titre, contenu, date et pied', () => {
    render(<GabaritAide actif="retours" titre="Retours et échanges" intro="Pas la bonne pointure ?" miseAJour="27 septembre 2026"><p>contenu</p></GabaritAide>);
    // L'en-tête du site se repère par sa navigation : le <header> du titre, dans l'article, compte aussi comme « banner ».
    expect(screen.getByRole('navigation', { name: 'Navigation principale' })).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 1, name: 'Retours et échanges' })).toBeInTheDocument();
    expect(screen.getByText('Pas la bonne pointure ?')).toBeInTheDocument();
    const menu = screen.getByRole('navigation', { name: 'Aide' });
    const actif = within(menu).getByRole('link', { name: 'Retours et échanges' });
    expect(actif).toHaveAttribute('aria-current', 'page');
    for (const k of MENU_LIEN_ACTIF.split(' ')) expect(classes(actif)).toContain(k);
    expect(within(menu).getByRole('link', { name: 'Contact' })).not.toHaveAttribute('aria-current');
    expect(screen.getByText('contenu')).toBeInTheDocument();
    expect(screen.getByText('Dernière mise à jour : 27 septembre 2026')).toBeInTheDocument();
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('se passe de date quand il n’y en a pas', () => {
    render(<GabaritAide actif="contact" titre="Contact" intro="Une question ?"><p>x</p></GabaritAide>);
    expect(screen.queryByText(/Dernière mise à jour/)).toBeNull();
  });
});
