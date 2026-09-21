import type { NavItem } from '@/components/ui/SiteHeader';

export const NAV: NavItem[] = [
  { label: 'Femme', href: '/femme' },
  { label: 'Homme', href: '/homme' },
  { label: 'Chaussures', href: '/chaussures' },
  { label: 'Marques', href: '/marques' },
  { label: 'Soldes', href: '/soldes', promo: true },
];

export const COLONNES_PIED = [
  { titre: 'Boutique', liens: [
    { label: 'Femme', href: '/femme' },
    { label: 'Homme', href: '/homme' },
    { label: 'Soldes', href: '/soldes' },
  ] },
  { titre: 'Aide', liens: [
    { label: 'Livraison', href: '/livraison' },
    { label: 'Retours', href: '/retours' },
    { label: 'Contact', href: '/contact' },
  ] },
];
