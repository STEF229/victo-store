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
      <nav aria-label={titre} className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
        {elements.map((e) => (
          <Link key={e.href} href={e.href} className="flex flex-col gap-2.5 text-[var(--vs-noir)]">
            <span aria-hidden="true" className="h-[150px] rounded-[20px] bg-[var(--vs-surface)]" />
            <span className="text-base font-extrabold">{e.libelle}</span>
            <span className="text-[13px] text-[var(--vs-gris)]">{`${e.nombre} ${e.nombre > 1 ? 'produits' : 'produit'}`}</span>
          </Link>
        ))}
      </nav>
    );
  }
  return (
    <nav aria-label={titre} className="flex flex-wrap gap-2.5">
      {elements.map((e) => (
        <Link key={e.href} href={e.href} aria-current={e.href === actif ? 'page' : undefined}
          className={`${PILULE} ${e.href === actif ? PILULE_ON : PILULE_OFF}`}>
          {e.libelle}
        </Link>
      ))}
    </nav>
  );
}
