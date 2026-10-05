import Link from 'next/link';
import type { NavItem } from '@/components/ui/SiteHeader';

const TEINTES: Record<string, string> = {
  '/femme': 'bg-[#EEF1F8]',
  '/homme': 'bg-[#F0F0EE]',
  '/chaussures': 'bg-[#E9E4DA]',
  '/marques': 'bg-[#D9D2C4]',
  '/soldes': 'bg-[#FFD3DB]',
};

/** Accès rapide aux rubriques, sous le carrousel : téléphone et tablette seulement. */
export function RubriquesRapides({ items }: { items: NavItem[] }) {
  return (
    <nav aria-label="Rubriques" className="-mx-5 mb-10 flex gap-3 overflow-x-auto px-5 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden lg:hidden">
      {items.map((item) => (
        <Link key={item.href} href={item.href} className="flex w-[72px] shrink-0 flex-col items-center gap-2">
          <span aria-hidden="true" className={`h-[68px] w-[68px] rounded-full ring-1 ring-[var(--vs-ligne)] ${TEINTES[item.href] ?? 'bg-[var(--vs-surface)]'}`} />
          <span className={`text-[13px] font-bold ${item.promo ? 'text-[var(--vs-promo)]' : 'text-[var(--vs-noir)]'}`}>{item.label}</span>
        </Link>
      ))}
    </nav>
  );
}
