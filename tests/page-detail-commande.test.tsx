import { render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import PageDetailCommande from '../src/app/compte/commandes/[numero]/page';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO, COMMANDES_DEMO, totauxCommande, type Commande } from '../src/lib/compte';
import { formatPrice } from '../src/lib/formatPrice';

const etat = vi.hoisted(() => ({ numero: 'VS-10482' }));
vi.mock('next/navigation', async (original) => ({
  ...(await original<typeof import('next/navigation')>()),
  useParams: () => ({ numero: etat.numero }),
}));

const poser = (numero: string, connecte = true) => {
  etat.numero = numero;
  if (connecte) window.localStorage.setItem(CLE_SESSION, JSON.stringify(CLIENT_DEMO));
  render(<SessionProvider><PageDetailCommande /></SessionProvider>);
};
const commande = (n: string) => COMMANDES_DEMO.find((c) => c.numero === n) as Commande;
const etats = () => screen.queryAllByTestId('etape').map((e: HTMLElement) => e.getAttribute('data-etat'));

beforeEach(() => window.localStorage.clear());

describe('détail d’une commande expédiée', () => {
  it('titre, date et retour à la liste', () => {
    poser('VS-10482');
    expect(screen.getByRole('heading', { level: 1, name: 'Commande VS-10482' })).toBeInTheDocument();
    expect(screen.getByText('Passée le 24 septembre 2026')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Toutes mes commandes' })).toHaveAttribute('href', '/compte/commandes');
  });

  it('montre le suivi en quatre étapes, dont trois faites, et le colis', () => {
    poser('VS-10482');
    expect(etats()).toEqual(['faite', 'faite', 'faite', 'a-venir']);
    expect(screen.getByTestId('detail-statut').textContent).toBe('Expédiée');
    expect(screen.getByTestId('suivi-colis').textContent).toBe('Postes Canada · n° de suivi 7302 1154 8890 4412');
  });

  it('liste les articles avec leur lien et calcule les taxes', () => {
    poser('VS-10482');
    const lignes = screen.getAllByTestId('ligne-commande');
    expect(lignes).toHaveLength(3);
    expect(within(lignes[0] as HTMLElement).getByRole('link', { name: 'Air Zoom Pegasus 41' })).toHaveAttribute('href', '/produits/air-zoom-pegasus-41');
    const t = totauxCommande(commande('VS-10482'));
    expect(screen.getByTestId('detail-sous-total').textContent).toBe(formatPrice(t.sousTotalCents));
    expect(screen.getByTestId('detail-tps').textContent).toBe(formatPrice(t.tpsCents));
    expect(screen.getByTestId('detail-tvq').textContent).toBe(formatPrice(t.tvqCents));
    expect(screen.getByTestId('detail-total').textContent).toBe(formatPrice(t.totalCents));
  });

  it('rappelle l’adresse et le paiement', () => {
    poser('VS-10482');
    const livraison = screen.getByTestId('detail-livraison');
    expect(livraison.textContent).toContain('4520, rue Saint-Denis, app. 3');
    expect(livraison.textContent).toContain('Visa se terminant par 4242');
  });
});

describe('autres cas', () => {
  it('signale une commande annulée, sans étapes', () => {
    poser('VS-10291');
    expect(screen.getByTestId('commande-annulee')).toBeInTheDocument();
    expect(etats()).toEqual([]);
    expect(screen.queryByTestId('suivi-colis')).toBeNull();
  });

  it('suit une commande livrée jusqu’au bout, à l’adresse du bureau', () => {
    poser('VS-10360');
    expect(etats()).toEqual(['faite', 'faite', 'faite', 'faite']);
    expect(screen.getByTestId('detail-livraison').textContent).toContain('1000, rue De La Gauchetière O., 12e étage');
  });

  it('dit qu’une commande inconnue est introuvable', () => {
    poser('VS-99999');
    expect(screen.getByRole('heading', { level: 1, name: 'Commande introuvable' })).toBeInTheDocument();
    expect(screen.getByTestId('commande-introuvable').textContent).toBe('Aucune commande VS-99999 dans votre compte.');
  });

  it('invite à se connecter sans session', () => {
    poser('VS-10482', false);
    expect(screen.getByTestId('compte-invitation')).toBeInTheDocument();
  });
});
