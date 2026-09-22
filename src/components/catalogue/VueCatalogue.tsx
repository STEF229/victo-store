'use client';

import { useMemo, useState } from 'react';
import { FiltresPanneau } from '@/components/catalogue/FiltresPanneau';
import { GrilleProduits } from '@/components/catalogue/GrilleProduits';
import { Pagination } from '@/components/catalogue/Pagination';
import { TriSelect } from '@/components/catalogue/TriSelect';
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
      <SiteHeader navItems={NAV} cartCount={0} />
      <main className="mx-auto max-w-[1440px] px-5 py-12 lg:px-20">
        <h1 data-testid="liste-titre" className="text-5xl font-black tracking-tight">{titre}</h1>
        {description && (
          <p data-testid="liste-description" className="mt-3 max-w-2xl text-lg text-[var(--vs-gris)]">{description}</p>
        )}
        <div className="mt-10 grid grid-cols-1 gap-10 lg:grid-cols-[260px_minmax(0,1fr)]">
          <FiltresPanneau marques={marques} tailles={taillesCatalogue()} criteres={criteres} onChange={changerCriteres} />
          <div>
            <div className="mb-6 flex items-center justify-between gap-4">
              <p data-testid="compteur">{libelle}</p>
              <TriSelect value={tri} onChange={changerTri} />
            </div>
            <GrilleProduits produits={pagine.items} />
            <Pagination page={pagine.page} pages={pagine.pages} onChange={setPage} />
          </div>
        </div>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} annee={2026} />
    </>
  );
}
