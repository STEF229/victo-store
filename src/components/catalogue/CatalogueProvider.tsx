'use client';

import { createContext, useContext, type ReactNode } from 'react';
import type { Catalogue } from '@/lib/catalogue-source';
import { listerMarques, listerProduits } from '@/lib/donnees';

// Sans fournisseur (tests, aperçus), les données de démonstration : les composants marchent toujours.
const Contexte = createContext<Catalogue>({ produits: listerProduits(), marques: listerMarques(), source: 'demo' });

/** Transmet aux composants du navigateur le catalogue chargé par le serveur (layout.tsx). */
export function CatalogueProvider({ valeur, children }: { valeur: Catalogue; children: ReactNode }) {
  return <Contexte.Provider value={valeur}>{children}</Contexte.Provider>;
}

/** Le catalogue du site : Medusa ou démonstration, selon CATALOGUE_SOURCE. */
export function useCatalogue(): Catalogue {
  return useContext(Contexte);
}
