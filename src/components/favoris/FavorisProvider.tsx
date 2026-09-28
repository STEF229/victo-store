'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';

export const CLE_FAVORIS = 'victo-favoris';
export interface ContexteFavoris {
  favoris: string[];
  pret: boolean;
  estFavori: (slug: string) => boolean;
  basculer: (slug: string) => void;
}

const contexteParDefaut: ContexteFavoris = {
  favoris: [],
  pret: true,
  estFavori: () => false,
  basculer: () => {},
};

const FavorisContext = createContext<ContexteFavoris>(contexteParDefaut);

export function useFavoris(): ContexteFavoris {
  return useContext(FavorisContext);
}

export function FavorisProvider({ children }: { children: ReactNode }) {
  const [favoris, setFavoris] = useState<string[]>([]);
  const [pret, setPret] = useState(false);

  useEffect(() => {
    try {
      const texte = window.localStorage.getItem(CLE_FAVORIS);
      if (texte) {
        const valeur: unknown = JSON.parse(texte);
        if (Array.isArray(valeur) && valeur.every((s) => typeof s === 'string')) {
          setFavoris(valeur);
        }
      }
    } catch {
      // Ignorer les données illisibles
    } finally {
      setPret(true);
    }
  }, []);

  useEffect(() => {
    if (pret) {
      try {
        window.localStorage.setItem(CLE_FAVORIS, JSON.stringify(favoris));
      } catch {
        // Ignorer les erreurs de stockage
      }
    }
  }, [favoris, pret]);

  const estFavori = (slug: string) => favoris.includes(slug);
  
  const basculer = (slug: string) => {
    setFavoris((f) => (f.includes(slug) ? f.filter((s) => s !== slug) : [...f, slug]));
  };

  return (
    <FavorisContext.Provider value={{ favoris, pret, estFavori, basculer }}>
      {children}
    </FavorisContext.Provider>
  );
}
