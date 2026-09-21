'use client';

import { useMemo, useState } from 'react';
import { FiltresPanneau } from '@/components/catalogue/FiltresPanneau';
import { GrilleProduits } from '@/components/catalogue/GrilleProduits';
import { Pagination } from '@/components/catalogue/Pagination';
import { TriSelect } from '@/components/catalogue/TriSelect';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { Container, Heading, Section, Text } from '@/components/ui/layout';
import { listerMarques, listerProduits, taillesCatalogue } from '@/lib/donnees';
import { filtrerProduits, paginer, trierProduits, type Criteres, type Tri } from '@/lib/filtres';

export function BoutiquePage() {
  const [criteres, setCriteres] = useState<Criteres>({});
  const [tri, setTri] = useState<Tri>('nouveautes');
  const [page, setPage] = useState(1);

  const produits = listerProduits();
  const marques = listerMarques();
  const tailles = taillesCatalogue();

  // Apply filters and sorting
  const produitsTries = useMemo(() => {
    let result = filtrerProduits(produits, criteres);
    result = trierProduits(result, tri);
    return result;
  }, [criteres, tri, produits]);

  // Paginate results
  const { items: produitsPagines, pages } = paginer(produitsTries, page, 6);

  // Reset to first page when filters or sorting change
  const handleCriteresChange = (newCriteres: Criteres) => {
    setCriteres(newCriteres);
    setPage(1);
  };

  const handleTriChange = (newTri: Tri) => {
    setTri(newTri);
    setPage(1);
  };

  const handlePageChange = (newPage: number) => {
    setPage(newPage);
  };

  const total = produitsTries.length;
  const libelle = `${total} ${total > 1 ? 'produits' : 'produit'}`;

  return (
    <div className="min-h-screen flex flex-col">
      <SiteHeader 
        navItems={[
          { label: 'Femme', href: '/femme' },
          { label: 'Homme', href: '/homme' },
          { label: 'Soldes', href: '/soldes' }
        ]}
        cartCount={0}
      />
      
      <main className="flex-grow">
        <Section>
          <Container>
            <Heading level={1}>Boutique</Heading>
            
            <div className="flex flex-col md:flex-row gap-8 mt-8">
              <div className="md:w-1/4">
                <FiltresPanneau 
                  marques={marques}
                  tailles={tailles}
                  criteres={criteres}
                  onChange={handleCriteresChange}
                />
              </div>
              
              <div className="md:w-3/4">
                <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6">
                  <p data-testid="compteur">{libelle}</p>
                  <TriSelect value={tri} onChange={handleTriChange} />
                </div>
                
                <GrilleProduits produits={produitsPagines} />
                
                {pages > 1 && (
                  <div className="mt-8 flex justify-center">
                    <Pagination 
                      page={page} 
                      pages={pages} 
                      onChange={handlePageChange} 
                    />
                  </div>
                )}
              </div>
            </div>
          </Container>
        </Section>
      </main>
      
      <SiteFooter 
        colonnes={[
          {
            titre: 'Service client',
            liens: [
              { label: 'Contact', href: '/contact' },
              { label: 'Livraison', href: '/livraison' },
              { label: 'Retours', href: '/retours' }
            ]
          },
          {
            titre: 'Entreprise',
            liens: [
              { label: 'À propos', href: '/a-propos' },
              { label: 'Emploi', href: '/emploi' },
              { label: 'Presse', href: '/presse' }
            ]
          }
        ]}
        annee={2026}
      />
    </div>
  );
}

export default BoutiquePage;
