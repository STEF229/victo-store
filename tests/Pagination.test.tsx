import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { Pagination } from '../src/components/catalogue/Pagination';

const prec = () => screen.getByRole('button', { name: 'Page précédente' });
const suiv = () => screen.getByRole('button', { name: 'Page suivante' });

describe('Pagination — affichage', () => {
  it('rend une navigation étiquetée', () => {
    render(<Pagination page={2} pages={5} onChange={() => {}} />);
    expect(screen.getByRole('navigation', { name: 'Pagination' })).toBeInTheDocument();
  });

  it('affiche l’état exact', () => {
    render(<Pagination page={2} pages={5} onChange={() => {}} />);
    expect(screen.getByTestId('pagination-etat').textContent).toBe('Page 2 sur 5');
  });

  it('ne rend rien quand il n’y a qu’une page', () => {
    const { container } = render(<Pagination page={1} pages={1} onChange={() => {}} />);
    expect(container.innerHTML).toBe('');
  });
});

describe('Pagination — navigation', () => {
  it('avance d’une page', () => {
    const onChange = vi.fn();
    render(<Pagination page={2} pages={5} onChange={onChange} />);
    fireEvent.click(suiv());
    expect(onChange).toHaveBeenCalledWith(3);
  });

  it('recule d’une page', () => {
    const onChange = vi.fn();
    render(<Pagination page={2} pages={5} onChange={onChange} />);
    fireEvent.click(prec());
    expect(onChange).toHaveBeenCalledWith(1);
  });

  it('désactive le précédent sur la première page', () => {
    const onChange = vi.fn();
    render(<Pagination page={1} pages={5} onChange={onChange} />);
    expect(prec()).toBeDisabled();
    fireEvent.click(prec());
    expect(onChange).not.toHaveBeenCalled();
  });

  it('désactive le suivant sur la dernière page', () => {
    const onChange = vi.fn();
    render(<Pagination page={5} pages={5} onChange={onChange} />);
    expect(suiv()).toBeDisabled();
    fireEvent.click(suiv());
    expect(onChange).not.toHaveBeenCalled();
  });
});
