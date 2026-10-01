'use client';

import { ChevronLeft, ChevronRight, Menu, X } from 'lucide-react';
import Link from 'next/link';
import { useState } from 'react';
import type { NavItem } from '@/components/ui/SiteHeader';
import { ARBRE, estRubrique, hrefDe, type Rubrique } from '@/lib/arbre-categories';

const LIGNE = 'flex h-[58px] w-full items-center justify-between border-b border-[var(--vs-ligne)] text-[17px] font-extrabold';

export function MenuMobile({ navItems }: { navItems: NavItem[] }) {
  const [ouvert, setOuvert] = useState(false);
  const [rubrique, setRubrique] = useState<Rubrique | null>(null);
  const [deplie, setDeplie] = useState<string | null>(null);

  function fermer() {
    setOuvert(false);
    setRubrique(null);
    setDeplie(null);
  }

  const niveau1 = (
    <>
      {navItems.map((item) => {
        const segment = item.href.replace(/^\//, '');
        if (estRubrique(segment)) {
          return (
            <button key={item.href} type="button" onClick={() => setRubrique(segment)} className={LIGNE}>
              {item.label}
              <ChevronRight aria-hidden size={18} />
            </button>
          );
        }
        return (
          <Link key={item.href} href={item.href} onClick={fermer}
            className={item.promo ? `${LIGNE} text-[#E4002B]` : LIGNE}>
            {item.label}
          </Link>
        );
      })}
      <div className="mt-6 flex flex-col">
        <Link href="/compte" onClick={fermer} className="flex h-12 items-center text-[15px] font-bold">Mon compte</Link>
        <Link href="/livraison" onClick={fermer} className="flex h-12 items-center text-[15px] font-bold">Aide et livraison</Link>
      </div>
    </>
  );

  const niveau2 = rubrique === null ? null : (
    <>
      <Link href={hrefDe(rubrique, [])} onClick={fermer}
        className="my-2.5 flex h-14 items-center justify-between rounded-2xl bg-[var(--vs-noir)] px-[18px] text-base font-extrabold text-[var(--vs-blanc)]">
        {`Tout voir ${ARBRE[rubrique].libelle}`}
        <ChevronRight aria-hidden size={18} />
      </Link>
      {ARBRE[rubrique].enfants.map((sc) => sc.enfants.length === 0 ? (
        <Link key={sc.slug} href={hrefDe(rubrique, [sc.slug])} onClick={fermer} className={LIGNE}>{sc.libelle}</Link>
      ) : (
        <div key={sc.slug} className="border-b border-[var(--vs-ligne)]">
          <button type="button" aria-expanded={deplie === sc.slug} onClick={() => setDeplie(deplie === sc.slug ? null : sc.slug)}
            className="flex h-[54px] w-full items-center justify-between text-[17px] font-extrabold">
            {sc.libelle}
            <span aria-hidden="true" className="text-[22px] font-medium">{deplie === sc.slug ? '−' : '+'}</span>
          </button>
          {deplie === sc.slug && (
            <div className="flex flex-col pb-2 pl-3.5">
              {sc.enfants.map((f) => (
                <Link key={f.slug} href={hrefDe(rubrique, [sc.slug, f.slug])} onClick={fermer} className="py-2 text-[15px]">{f.libelle}</Link>
              ))}
              <Link href={hrefDe(rubrique, [sc.slug])} onClick={fermer} className="py-2 text-[15px] font-extrabold underline">{`Tout ${sc.libelle.toLowerCase()}`}</Link>
            </div>
          )}
        </div>
      ))}
    </>
  );

  return (
    <>
      <button type="button" aria-label="Ouvrir le menu" aria-expanded={ouvert} onClick={() => setOuvert(true)}
        className="flex h-11 w-11 items-center justify-center lg:hidden">
        <Menu aria-hidden size={22} />
      </button>
      {ouvert && (
        <div className="fixed inset-0 z-50 lg:hidden" onKeyDown={(e) => { if (e.key === 'Escape') fermer(); }}>
          <div aria-hidden="true" data-testid="menu-mobile-fond" onClick={fermer} className="absolute inset-0 bg-[rgba(16,16,20,0.45)]" />
          <div role="dialog" aria-modal="true" aria-label="Menu" className="absolute inset-y-0 left-0 flex w-[350px] max-w-[90vw] flex-col bg-[var(--vs-blanc)] text-[var(--vs-noir)]">
            <div className="flex h-[60px] shrink-0 items-center justify-between border-b border-[var(--vs-ligne)] px-[18px]">
              {rubrique === null ? (
                <span className="text-xl font-black tracking-[0.06em]">VICTO STORE</span>
              ) : (
                <button type="button" onClick={() => { setRubrique(null); setDeplie(null); }}
                  className="flex items-center gap-1.5 text-[17px] font-extrabold">
                  <ChevronLeft aria-hidden size={20} />
                  {ARBRE[rubrique].libelle}
                </button>
              )}
              <button type="button" aria-label="Fermer le menu" onClick={fermer}
                className="flex h-11 w-11 items-center justify-center rounded-full bg-[var(--vs-surface)]">
                <X aria-hidden size={18} />
              </button>
            </div>
            <div className="flex-1 overflow-y-auto px-5 pb-6">{rubrique === null ? niveau1 : niveau2}</div>
          </div>
        </div>
      )}
    </>
  );
}
