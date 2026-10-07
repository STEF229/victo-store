'use client';

import { createContext, useContext, useEffect, useRef, useState, type ReactNode } from 'react';
import {
  ajouterAuPanier, changerQuantite, CLE_PANIER, ecrirePanier, lirePanier, nombreArticles, retirerDuPanier,
  type Panier,
} from '@/lib/panier';
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
import { CLE_PANIER_MEDUSA, synchroniserPanier } from '@/lib/medusa/panier-medusa';

export interface ContextePanier {
  lignes: Panier;
  nombre: number;
  pret: boolean;
  ajouter: (article: { slug: string; sku: string }, quantite: number, stock: number) => void;
  changerQuantite: (sku: string, quantite: number, stock: number) => void;
  retirer: (sku: string) => void;
  vider: () => void;
  /** Identifiant du panier Medusa recopié (mode Medusa), sinon null. */
  panierMedusa: string | null;
}

const Contexte = createContext<ContextePanier>({
  lignes: [],
  nombre: 0,
  pret: true,
  ajouter: () => {},
  changerQuantite: () => {},
  retirer: () => {},
  vider: () => {},
  panierMedusa: null,
});

export function usePanier(): ContextePanier {
  return useContext(Contexte);
}

export function PanierProvider({ children }: { children: ReactNode }) {
  const [lignes, setLignes] = useState<Panier>([]);
  const [pret, setPret] = useState(false);
  const { source, produits } = useCatalogue();
  const [panierMedusa, setPanierMedusa] = useState<string | null>(null);
  const file = useRef<Promise<void>>(Promise.resolve());

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

  // Mode Medusa : chaque changement du panier est recopié dans un panier Medusa, une opération à la fois.
  useEffect(() => {
    if (!pret || source !== 'medusa') return;
    const voulu = lignes.flatMap((l) => {
      const variante = produits.find((p) => p.slug === l.slug)?.variantes.find((v) => v.sku === l.sku);
      return variante ? [{ variantId: variante.id, quantite: l.quantite }] : [];
    });
    file.current = file.current.then(async () => {
      try {
        let id: string | null = null;
        try { id = window.localStorage.getItem(CLE_PANIER_MEDUSA); } catch { id = null; }
        const nouveau = await synchroniserPanier(id, voulu);
        try { if (nouveau) window.localStorage.setItem(CLE_PANIER_MEDUSA, nouveau); } catch { /* stockage indisponible */ }
        setPanierMedusa(nouveau || null);
      } catch (erreur) {
        console.warn('[panier] recopie dans Medusa impossible', erreur);
      }
    });
  }, [lignes, pret, source, produits]);

  const nombre = nombreArticles(lignes);

  return (
    <Contexte.Provider value={{
      lignes,
      nombre,
      pret,
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
      panierMedusa,
    }}>
      {children}
    </Contexte.Provider>
  );
}
