import type { ReactNode } from 'react';
import { PanierProvider } from '@/components/panier/PanierProvider';
import './globals.css';

export const metadata = {
  title: 'VICTO STORE',
  description: 'Des grandes marques, au bon prix.',
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="fr" suppressHydrationWarning>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          href="https://fonts.googleapis.com/css2?family=Archivo:wght@400;500;600;700;800;900&display=swap"
          rel="stylesheet"
        />
      </head>
      <body><PanierProvider>{children}</PanierProvider></body>
    </html>
  );
}
