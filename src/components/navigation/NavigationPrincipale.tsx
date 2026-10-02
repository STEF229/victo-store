'use client';

import { ChevronRight } from 'lucide-react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useEffect, useRef, useState } from 'react';
import type { NavItem } from '@/components/ui/SiteHeader';
import { ARBRE, estRubrique, hrefDe, produitsDe, type Rubrique } from '@/lib/arbre-categories';
import { hrefMarque } from '@/lib/catalogue';
import { listerMarques, listerProduits } from '@/lib/donnees';

type Panneau = Rubrique | 'marques';

function classeLien(promo: boolean | undefined, actif: boolean): string | undefined {
  if (promo && actif) return 'text-[#FF5A74] font-extrabold underline decoration-2 underline-offset-[10px]';
  if (promo) return 'text-[#FF5A74]';
  if (actif) return 'font-extrabold underline decoration-2 underline-offset-[10px]';
  return undefined;
}

function panneauDe(href: string): Panneau | null {
  const segment = href.replace(/^\//, '');
  if (estRubrique(segment)) return segment;
  return segment === 'marques' ? 'marques' : null;
}

const CADRE = 'fixed inset-x-0 top-[84px] z-50 grid gap-x-10 gap-y-6 border-t border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-20 pb-10 pt-8 text-[var(--vs-noir)] shadow-[0_24px_40px_rgba(16,16,20,0.18)]';

function Tete({ titre, href, texte }: { titre: string; href: string; texte: string }) {
  return (
    <div className="col-span-full flex items-baseline justify-between border-b border-[var(--vs-ligne)] pb-4">
      <p className="text-2xl font-black">{titre}</p>
      <Link href={href} className="flex items-center gap-1.5 text-[15px] font-extrabold transition-colors hover:text-[var(--vs-accent)]">
        {texte}
        <ChevronRight aria-hidden size={16} />
      </Link>
    </div>
  );
}

function PanneauMega({ panneau }: { panneau: Panneau }) {
  if (panneau === 'marques') {
    return (
      <div role="region" aria-label="Sous-catégories de Marques" className={`${CADRE} grid-cols-5`}>
        <Tete titre="Marques" href="/marques" texte="Toutes les marques" />
        {listerMarques().map((m) => (
          <Link key={m.slug} href={hrefMarque(m)} className="flex h-[110px] items-center justify-center rounded-[18px] bg-[var(--vs-surface)] text-lg font-black tracking-wide transition-colors hover:text-[var(--vs-accent)]">
            {m.nom}
          </Link>
        ))}
      </div>
    );
  }
  const racine = ARBRE[panneau];
  const total = produitsDe(listerProduits(), panneau, []).length;
  const tete = <Tete titre={racine.libelle} href={hrefDe(panneau, [])} texte={`Tout voir ${racine.libelle} (${total} ${total > 1 ? 'produits' : 'produit'})`} />;
  if (panneau === 'chaussures') {
    return (
      <div role="region" aria-label="Sous-catégories de Chaussures" className={`${CADRE} grid-cols-5`}>
        {tete}
        {racine.enfants.map((e) => (
          <Link key={e.slug} href={hrefDe(panneau, [e.slug])} className="flex flex-col gap-2.5 transition-colors hover:text-[var(--vs-accent)]">
            <span aria-hidden="true" className="h-[150px] rounded-[20px] bg-[var(--vs-surface)]" />
            <span className="text-base font-extrabold">{e.libelle}</span>
          </Link>
        ))}
      </div>
    );
  }
  return (
    <div role="region" aria-label={`Sous-catégories de ${racine.libelle}`} className={`${CADRE} grid-cols-3`}>
      {tete}
      {racine.enfants.map((sc) => (
        <div key={sc.slug} className="flex flex-col">
          <Link href={hrefDe(panneau, [sc.slug])} className="mb-1.5 text-base font-black transition-colors hover:text-[var(--vs-accent)]">{sc.libelle}</Link>
          {sc.enfants.map((f) => (
            <Link key={f.slug} href={hrefDe(panneau, [sc.slug, f.slug])} className="py-1.5 text-[15px] font-medium transition-colors hover:text-[var(--vs-accent)]">{f.libelle}</Link>
          ))}
          <Link href={hrefDe(panneau, [sc.slug])} className="mt-1.5 text-sm font-bold text-[var(--vs-gris)] underline transition-colors hover:text-[var(--vs-accent)]">{`Tout ${sc.libelle.toLowerCase()}`}</Link>
        </div>
      ))}
    </div>
  );
}

export function NavigationPrincipale({ navItems }: { navItems: NavItem[] }) {
  const chemin: string | null = usePathname();
  const [ouvert, setOuvert] = useState<Panneau | null>(null);
  const minuterie = useRef<ReturnType<typeof setTimeout> | null>(null);

  function annuler() {
    if (minuterie.current !== null) clearTimeout(minuterie.current);
    minuterie.current = null;
  }
  function fermerBientot() {
    annuler();
    minuterie.current = setTimeout(() => setOuvert(null), 200);
  }
  useEffect(() => () => { if (minuterie.current !== null) clearTimeout(minuterie.current); }, []);
  useEffect(() => { setOuvert(null); }, [chemin]);

  return (
    <nav aria-label="Navigation principale" className="hidden justify-self-center gap-8 text-[15px] font-semibold lg:flex"
      onMouseEnter={annuler} onMouseLeave={fermerBientot}
      onKeyDown={(e) => { if (e.key === 'Escape') setOuvert(null); }}>
      {navItems.map((item) => {
        const actif = chemin !== null && (chemin === item.href || chemin.startsWith(`${item.href}/`));
        const panneau = panneauDe(item.href);
        return (
          <a key={item.href} href={item.href} aria-current={actif ? 'page' : undefined} className={classeLien(item.promo, actif)}
            onMouseEnter={() => { annuler(); setOuvert(panneau); }}
            onFocus={() => setOuvert(panneau)}>
            {item.label}
          </a>
        );
      })}
      {ouvert !== null && <PanneauMega panneau={ouvert} />}
    </nav>
  );
}
