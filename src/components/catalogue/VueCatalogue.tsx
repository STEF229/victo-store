'use client';

import { useMemo, useState } from 'react';
import { FiltresBarre } from '@/components/catalogue/FiltresBarre';
import { GrilleProduits } from '@/components/catalogue/GrilleProduits';
import { Pagination } from '@/components/catalogue/Pagination';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import type { Produit } from '@/lib/catalogue';
import { taillesCatalogue } from '@/lib/donnees';
import { filtrerProduits, paginer, trierProduits, type Criteres, type Tri } from '@/lib/filtres';
import { COLONNES_PIED, NAV } from '@/lib/navigation';

interface VueCatalogueProps {
  titre: string;
  description?: string;
  produits: Produit[];
}

export function VueCatalogue({ titre, description, produits }: VueCatalogueProps) {
  const [criteres, setCriteres] = useState<Criteres>({});
  const [tri, setTri] = useState<Tri>('nouveautes');
  const [page, setPage] = useState(1);
  
  const resultats = useMemo(
    () => trierProduits(filtrerProduits(produits, criteres), tri),
    [produits, criteres, tri],
  );
  
  const pagine = paginer(resultats, page, 6);
  
  const marques = produits
    .map((p) => p.marque)
    .filter((m, i, t) => t.findIndex((x) => x.id === m.id) === i);
  
  const changerCriteres = (c: Criteres) => { 
    setCriteres(c); 
    setPage(1); 
  };
  
  const changerTri = (t: Tri) => { 
    setTri(t); 
    setPage(1); 
  };
  
  const n = resultats.length;
  const libelle = `${n} ${n > 1 ? 'produits' : 'produit'}`;
  
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto max-w-[1440px] px-5 py-12 lg:px-12">
        <div className="flex items-end justify-between gap-8">
          <div>
            <h1 data-testid="liste-titre" className="text-5xl font-black tracking-tight lg:text-6xl">{titre}</h1>
            {description && (
              <p data-testid="liste-description" className="mt-3 max-w-2xl text-lg text-[var(--vs-gris)]">{description}</p>
            )}
          </div>
          <p data-testid="compteur" className="whitespace-nowrap text-[15px] text-[var(--vs-gris)]">{libelle}</p>
        </div>
        <div className="mt-8">
          <FiltresBarre
            marques={marques}
            tailles={taillesCatalogue()}
            criteres={criteres}
            onChange={changerCriteres}
            tri={tri}
            onTriChange={changerTri}
          />
        </div>
        <div className="mt-8">
          <GrilleProduits produits={pagine.items} colonnes={4} />
        </div>
        <Pagination page={pagine.page} pages={pagine.pages} onChange={setPage} />
      </main>
      <SiteFooter colonnes={COLONNES_PIED} annee={2026} />
    </>
  );
}
