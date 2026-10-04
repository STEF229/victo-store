import Link from 'next/link';
import { PILULE, PILULE_OFF, PILULE_ON } from '@/components/catalogue/filtres-affichage';
import type { ElementSousCategorie } from '@/lib/arbre-categories';

export function SousCategories({ titre, elements, forme, actif }: {
  titre: string;
  elements: ElementSousCategorie[];
  forme: 'vignettes' | 'pastilles';
  actif?: string | undefined;
}) {
  if (elements.length === 0) return null;
  if (forme === 'vignettes') {
    return (
      <nav aria-label={titre} className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4 max-sm:-mx-5 max-sm:flex max-sm:gap-3 max-sm:overflow-x-auto max-sm:px-5 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
        {elements.map((e) => (
          <Link key={e.href} href={e.href} className="flex flex-col gap-2.5 text-[var(--vs-noir)] max-sm:w-[112px] max-sm:shrink-0 max-sm:gap-1.5">
            <span aria-hidden="true" className="h-[150px] rounded-[20px] bg-[var(--vs-surface)] max-sm:h-[112px] max-sm:rounded-[18px]" />
            <span className="text-base font-extrabold max-sm:text-sm">{e.libelle}</span>
            <span className="text-[13px] text-[var(--vs-gris)]">{`${e.nombre} ${e.nombre > 1 ? 'produits' : 'produit'}`}</span>
          </Link>
        ))}
      </nav>
    );
  }
  return (
    <nav aria-label={titre} className="flex flex-wrap gap-2.5 max-sm:-mx-5 max-sm:flex-nowrap max-sm:overflow-x-auto max-sm:px-5 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
      {elements.map((e) => (
        <Link key={e.href} href={e.href} aria-current={e.href === actif ? 'page' : undefined}
          className={`${PILULE} ${e.href === actif ? PILULE_ON : PILULE_OFF} max-sm:shrink-0 max-sm:whitespace-nowrap`}>
          {e.libelle}
        </Link>
      ))}
    </nav>
  );
}
