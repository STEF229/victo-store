import Link from 'next/link';
import type { ElementFil } from '@/lib/fiche-produit';

export function FilAriane({ items }: { items: ElementFil[] }) {
  return (
    <nav aria-label="Fil d'Ariane" data-testid="fil-ariane" className="flex flex-wrap items-center gap-2.5 py-4 text-sm text-[var(--vs-gris)]">
      <ol className="flex flex-wrap items-center gap-2.5">
        {items.map((e, i) => (
          <li key={i} className="flex items-center gap-2.5">
            {i > 0 && <span aria-hidden="true">/</span>}
            {i === items.length - 1 ? (
              <span aria-current="page" className="font-semibold text-[var(--vs-noir)]">{e.label}</span>
            ) : e.href ? (
              <Link href={e.href}>{e.label}</Link>
            ) : (
              <span>{e.label}</span>
            )}
          </li>
        ))}
      </ol>
    </nav>
  );
}
