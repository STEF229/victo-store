'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import {
  ajouterAuPanier, changerQuantite, CLE_PANIER, ecrirePanier, lirePanier, nombreArticles, retirerDuPanier,
  type Panier,
} from '@/lib/panier';

export interface ContextePanier {
  lignes: Panier;
  nombre: number;
  ajouter: (article: { slug: string; sku: string }, quantite: number, stock: number) => void;
  changerQuantite: (sku: string, quantite: number, stock: number) => void;
  retirer: (sku: string) => void;
  vider: () => void;
}

const Contexte = createContext<ContextePanier>({
  lignes: [],
  nombre: 0,
  ajouter: () => {},
  changerQuantite: () => {},
  retirer: () => {},
  vider: () => {},
});

export function usePanier(): ContextePanier {
  return useContext(Contexte);
}

export function PanierProvider({ children }: { children: ReactNode }) {
  const [lignes, setLignes] = useState<Panier>([]);
  const [pret, setPret] = useState(false);

  useEffect(() => {
    try {
      const panierEnregistre = window.localStorage.getItem(CLE_PANIER);
      const lignesChargees = lirePanier(panierEnregistre);
      setLignes(lignesChargees);
      setPret(true);
    } catch {
      setLignes([]);
      setPret(true);
    }
  }, []);

  useEffect(() => {
    if (pret) {
      try {
        window.localStorage.setItem(CLE_PANIER, ecrirePanier(lignes));
      } catch {
        // Ignore les erreurs de stockage
      }
    }
  }, [lignes, pret]);

  const nombre = nombreArticles(lignes);

  return (
    <Contexte.Provider value={{
      lignes,
      nombre,
      ajouter: (article, quantite, stock) => {
        setLignes((precedent) => ajouterAuPanier(precedent, article, quantite, stock));
      },
      changerQuantite: (sku, quantite, stock) => {
        setLignes((precedent) => changerQuantite(precedent, sku, quantite, stock));
      },
      retirer: (sku) => {
        setLignes((precedent) => retirerDuPanier(precedent, sku));
      },
      vider: () => {
        setLignes([]);
      },
    }}>
      {children}
    </Contexte.Provider>
  );
}
