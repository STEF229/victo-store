'use client';

import { Heart, House, LogOut, MapPin, Package, User } from 'lucide-react';
import Link from 'next/link';
import { MENU_LIEN, MENU_LIEN_ACTIF } from '@/components/compte/compte-affichage';
import { useSession } from '@/components/compte/SessionProvider';

export type EntreeCompte = 'tableau' | 'commandes' | 'favoris' | 'adresses' | 'informations';

const ENTREES = [
  { cle: 'tableau', libelle: 'Tableau de bord', href: '/compte', Icone: House },
  { cle: 'commandes', libelle: 'Mes commandes', href: '/compte/commandes', Icone: Package },
  { cle: 'favoris', libelle: 'Favoris', href: '/compte/favoris', Icone: Heart },
  { cle: 'adresses', libelle: 'Adresses', href: '/compte/adresses', Icone: MapPin },
  { cle: 'informations', libelle: 'Informations personnelles', href: '/compte/informations', Icone: User },
] as const;

export function MenuCompte({ actif }: { actif: EntreeCompte }) {
  const session = useSession();
  
  return (
    <nav aria-label="Espace client" data-testid="menu-compte" className="flex flex-col gap-1 max-sm:-mx-5 max-sm:flex-row max-sm:gap-2 max-sm:overflow-x-auto max-sm:px-5 max-sm:pb-1">
      {ENTREES.map((e) => (
        <Link 
          key={e.cle}
          href={e.href} 
          aria-current={e.cle === actif ? 'page' : undefined}
          className={`${e.cle === actif ? MENU_LIEN_ACTIF : MENU_LIEN} max-sm:shrink-0 max-sm:whitespace-nowrap max-sm:border max-sm:border-[var(--vs-ligne)]`}
        >
          <e.Icone aria-hidden size={19} />
          {e.libelle}
        </Link>
      ))}
      <div className="my-3 h-px bg-[var(--vs-ligne)] max-sm:hidden" />
      <button 
        type="button" 
        onClick={() => session.deconnecter()}
        className="flex h-[50px] items-center gap-3 rounded-full px-[18px] text-[15px] font-semibold text-[var(--vs-gris)] max-sm:shrink-0 max-sm:whitespace-nowrap"
      >
        <LogOut aria-hidden size={19} />
        Se déconnecter
      </button>
    </nav>
  );
}
