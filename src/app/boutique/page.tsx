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

  // Process products: filter, sort, then paginate
  const { produits, total } = useMemo(() => {
    let result = listerProduits();
    
    // Apply filters
    result = filtrerProduits(result, criteres);
    
    // Apply sorting
    result = trierProduits(result, tri);
    
    // Apply pagination (6 items per page)
    const paginated = paginer(result, page, 6);
    
    return {
      produits: paginated.items,
      total: result.length // Total count after filtering but before pagination
    };
  }, [criteres, tri, page]);

  // Handle filter changes - reset to first page
  const handleFilterChange = (newCriteres: Criteres) => {
    setCriteres(newCriteres);
    setPage(1);
  };

  // Handle tri changes - reset to first page
  const handleTriChange = (newTri: Tri) => {
    setTri(newTri);
    setPage(1);
  };

  // Handle pagination changes
  const handlePageChange = (newPage: number) => {
    setPage(newPage);
  };

  // Footer data
  const piedDePage = [
    {
      titre: 'Aide',
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
  ];

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
        <Container>
          <Section>
            <Heading level={1}>Boutique</Heading>
            
            <Text data-testid="compteur">
              {total} produit{total !== 1 ? 's' : ''}
            </Text>
            
            <div className="flex flex-col lg:flex-row gap-8 mt-6">
              <div className="lg:w-1/4">
                <FiltresPanneau 
                  marques={listerMarques()}
                  tailles={taillesCatalogue()}
                  criteres={criteres}
                  onChange={handleFilterChange}
                />
              </div>
              
              <div className="lg:w-3/4">
                <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6">
                  <TriSelect 
                    value={tri} 
                    onChange={handleTriChange} 
                  />
                </div>
                
                <GrilleProduits produits={produits} />
                
                {total > 0 && (
                  <div className="mt-8 flex justify-center">
                    <Pagination 
                      page={page} 
                      pages={Math.ceil(total / 6)} 
                      onChange={handlePageChange} 
                    />
                  </div>
                )}
              </div>
            </div>
          </Section>
        </Container>
      </main>
      
      <SiteFooter 
        colonnes={piedDePage} 
        annee={2026} 
      />
    </div>
  );
}

export default BoutiquePage;
