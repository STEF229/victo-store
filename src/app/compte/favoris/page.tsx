'use client';

import Link from 'next/link';
import { BOUTON_PRINCIPAL, LIEN, SOUS_TITRE, TITRE_PAGE } from '@/components/compte/compte-affichage';
import { EspaceClient } from '@/components/compte/EspaceClient';
import { useSession } from '@/components/compte/SessionProvider';
import { useFavoris } from '@/components/favoris/FavorisProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { ProductCard } from '@/components/ui/ProductCard';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { trouverProduit } from '@/lib/donnees';
import { COLONNES_PIED, NAV } from '@/lib/navigation';

export default function PageFavoris() {
  const session = useSession();
  
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Mon compte', href: '/compte' }, { label: 'Favoris' }]} />
        <EspaceClient actif="favoris">
          {session.client && (
            <div aria-busy={!session.pret} className="min-h-[320px]">
              {session.pret ? (
                <>
                  <div className="flex flex-col gap-2.5">
                    <h1 className={TITRE_PAGE}>Mes favoris</h1>
                    <p data-testid="favoris-nombre" className={SOUS_TITRE}>{`${session.client.favoris.length} ${session.client.favoris.length > 1 ? 'produits' : 'produit'}`}</p>
                  </div>
                  {session.client.favoris.length === 0 ? (
                    <div data-testid="favoris-vide" className="flex flex-col items-start gap-4">
                      <p className={SOUS_TITRE}>Vous n'avez pas encore de favori. Touchez le cœur d'une fiche produit pour l'ajouter ici.</p>
                      <Link href="/boutique" className={`${BOUTON_PRINCIPAL} sm:w-auto`}>Découvrir la boutique</Link>
                    </div>
                  ) : (
                    <ul className="grid gap-x-5 gap-y-8 sm:grid-cols-2 lg:grid-cols-3">
                      {session.client.favoris.map((slug) => {
                        const produit = trouverProduit(slug);
                        if (!produit) return null;
                        return (
                          <li key={produit.slug} data-testid="favori" className="flex flex-col gap-3">
                            <ProductCard produit={produit} />
                            <button 
                              type="button" 
                              onClick={() => session.mettreAJourAdresses(session.client?.adresses || [])}
                              aria-label={`Retirer ${produit.nom} des favoris`}
                              className={`self-start ${LIEN}`}
                            >
                              Retirer des favoris
                            </button>
                          </li>
                        );
                      })}
                    </ul>
                  )}
                </>
              ) : (
                <div aria-busy="true" className="min-h-[320px]" />
              )}
            </div>
          )}
        </EspaceClient>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
