import type { ReactNode } from 'react';
import { CatalogueProvider } from '@/components/catalogue/CatalogueProvider';
import { chargerCatalogue } from '@/lib/catalogue-source';
import { FavorisProvider } from '@/components/favoris/FavorisProvider';
import { PanierProvider } from '@/components/panier/PanierProvider';
import { SessionProvider } from '@/components/compte/SessionProvider';
import './globals.css';

export const metadata = {
  title: 'VICTO STORE',
  description: 'Des grandes marques, au bon prix.',
};

export default async function RootLayout({ children }: { children: ReactNode }) {
  const catalogue = await chargerCatalogue();
  
  return (
    <html lang="fr" suppressHydrationWarning className="overflow-x-clip">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          href="https://fonts.googleapis.com/css2?family=Archivo:wght@400;500;600;700;800;900&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="overflow-x-clip" suppressHydrationWarning>
        <CatalogueProvider valeur={catalogue}>
          <FavorisProvider>
            <PanierProvider>
              <SessionProvider>{children}</SessionProvider>
            </PanierProvider>
          </FavorisProvider>
        </CatalogueProvider>
      </body>
    </html>
  );
}
