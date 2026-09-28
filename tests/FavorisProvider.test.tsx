import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { CLE_FAVORIS, FavorisProvider, useFavoris } from '../src/components/favoris/FavorisProvider';

function Temoin() {
  const f = useFavoris();
  return (
    <div>
      <span data-testid="favoris">{f.favoris.join(',') || 'aucun'}</span>
      <span data-testid="pegasus">{String(f.estFavori('air-zoom-pegasus-41'))}</span>
      <button type="button" onClick={() => f.basculer('air-zoom-pegasus-41')}>pegasus</button>
      <button type="button" onClick={() => f.basculer('polo-shirt')}>polo</button>
    </div>
  );
}
const cliquer = (n: string) => fireEvent.click(screen.getByRole('button', { name: n }));
const favoris = () => screen.getByTestId('favoris').textContent;
const garde = () => window.localStorage.getItem(CLE_FAVORIS);

beforeEach(() => window.localStorage.clear());

describe('FavorisProvider', () => {
  it('ajoute puis retire un favori, et le garde', () => {
    render(<FavorisProvider><Temoin /></FavorisProvider>);
    cliquer('pegasus');
    cliquer('polo');
    expect(favoris()).toBe('air-zoom-pegasus-41,polo-shirt');
    expect(screen.getByTestId('pegasus').textContent).toBe('true');
    expect(garde()).toBe('["air-zoom-pegasus-41","polo-shirt"]');
    cliquer('pegasus');
    expect(favoris()).toBe('polo-shirt');
    expect(garde()).toBe('["polo-shirt"]');
  });

  it('relit les favoris gardés et ignore une liste illisible', () => {
    window.localStorage.setItem(CLE_FAVORIS, '["polo-shirt"]');
    const { unmount } = render(<FavorisProvider><Temoin /></FavorisProvider>);
    expect(favoris()).toBe('polo-shirt');
    unmount();
    window.localStorage.setItem(CLE_FAVORIS, '[1,2]');
    render(<FavorisProvider><Temoin /></FavorisProvider>);
    expect(favoris()).toBe('aucun');
  });

  it('ne fait rien hors du fournisseur', () => {
    render(<Temoin />);
    cliquer('pegasus');
    expect(favoris()).toBe('aucun');
    expect(screen.getByTestId('pegasus').textContent).toBe('false');
  });
});
