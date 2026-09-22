'use client';

import { ChevronDown, SlidersHorizontal, X } from 'lucide-react';
import { useState } from 'react';
import type { Marque } from '@/lib/catalogue';
import type { Criteres, Tri } from '@/lib/filtres';

interface FiltresBarreProps {
  marques: Marque[];
  tailles: string[];
  criteres: Criteres;
  onChange: (criteres: Criteres) => void;
  tri: Tri;
  onTriChange: (tri: Tri) => void;
}

export function FiltresBarre({
  marques,
  tailles,
  criteres,
  onChange,
  tri,
  onTriChange
}: FiltresBarreProps) {
  const [ouvert, setOuvert] = useState<null | 'marques' | 'tailles' | 'tiroir' | 'tri'>(null);

  const togglePanneau = (panneau: 'marques' | 'tailles') => {
    if (ouvert === panneau) {
      setOuvert(null);
    } else {
      setOuvert(panneau);
    }
  };

  const toggleTiroir = () => {
    setOuvert(ouvert === 'tiroir' ? null : 'tiroir');
  };

  const toggleTri = () => {
    setOuvert(ouvert === 'tri' ? null : 'tri');
  };

  const fermerPanneaux = () => {
    setOuvert(null);
  };

  const ajouterFiltre = (filtre: keyof Criteres, valeur: string | boolean) => {
    const nouveauxCriteres: Criteres = { ...criteres };
    
    if (filtre === 'marques' || filtre === 'tailles') {
      const valeurs = [...(criteres[filtre] || [])];
      const index = valeurs.indexOf(valeur as string);
      
      if (index === -1) {
        valeurs.push(valeur as string);
      } else {
        valeurs.splice(index, 1);
      }
      
      nouveauxCriteres[filtre] = valeurs;
    } else {
      nouveauxCriteres[filtre] = valeur as boolean;
    }
    
    onChange(nouveauxCriteres);
  };

  const retirerFiltre = (filtre: keyof Criteres, valeur: string | boolean) => {
    const nouveauxCriteres: Criteres = { ...criteres };
    
    if (filtre === 'marques' || filtre === 'tailles') {
      const valeurs = [...(criteres[filtre] || [])];
      const index = valeurs.indexOf(valeur as string);
      
      if (index !== -1) {
        valeurs.splice(index, 1);
        nouveauxCriteres[filtre] = valeurs;
      }
    } else {
      delete nouveauxCriteres[filtre];
    }
    
    onChange(nouveauxCriteres);
  };

  const reinitialiserFiltres = () => {
    onChange({});
  };

  const nombreFiltresActifs = 
    (criteres.marques?.length || 0) + 
    (criteres.tailles?.length || 0) + 
    (criteres.promotionSeulement ? 1 : 0) + 
    (criteres.enStockSeulement ? 1 : 0);

  const marquesSelectionnees = criteres.marques || [];
  const taillesSelectionnees = criteres.tailles || [];

  return (
    <div data-testid="filtres-barre">
      {/* Barre de bureau */}
      <div 
        data-testid="barre-bureau" 
        className="hidden flex-wrap items-center gap-3 lg:flex"
      >
        <div className="relative">
          <button
            type="button"
            data-testid="bouton-marques"
            aria-expanded={ouvert === 'marques'}
            onClick={() => togglePanneau('marques')}
            className="flex items-center gap-1 rounded-md bg-[var(--vs-blanc)] px-3 py-2 text-sm font-medium text-[var(--vs-noir)] shadow-sm hover:bg-[var(--vs-fond)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-principal)]"
          >
            <span>Marque{marquesSelectionnees.length > 0 ? ` (${marquesSelectionnees.length})` : ''}</span>
            <ChevronDown aria-hidden size={16} />
          </button>
          
          {ouvert === 'marques' && (
            <div 
              data-testid="panneau-marques" 
              className="absolute left-0 top-full z-10 mt-1 w-48 rounded-md bg-[var(--vs-blanc)] shadow-lg ring-1 ring-black ring-opacity-5"
            >
              {marques.map((marque) => (
                <button
                  key={marque.slug}
                  type="button"
                  data-testid={`filtre-marque-${marque.slug}`}
                  aria-pressed={marquesSelectionnees.includes(marque.slug)}
                  onClick={() => ajouterFiltre('marques', marque.slug)}
                  className="block w-full px-4 py-2 text-left text-sm text-[var(--vs-noir)] hover:bg-[var(--vs-fond)]"
                >
                  {marque.nom}
                </button>
              ))}
            </div>
          )}
        </div>
        
        <div className="relative">
          <button
            type="button"
            data-testid="bouton-tailles"
            aria-expanded={ouvert === 'tailles'}
            onClick={() => togglePanneau('tailles')}
            className="flex items-center gap-1 rounded-md bg-[var(--vs-blanc)] px-3 py-2 text-sm font-medium text-[var(--vs-noir)] shadow-sm hover:bg-[var(--vs-fond)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-principal)]"
          >
            <span>Taille{taillesSelectionnees.length > 0 ? ` (${taillesSelectionnees.length})` : ''}</span>
            <ChevronDown aria-hidden size={16} />
          </button>
          
          {ouvert === 'tailles' && (
            <div 
              data-testid="panneau-tailles" 
              className="absolute left-0 top-full z-10 mt-1 w-48 rounded-md bg-[var(--vs-blanc)] shadow-lg ring-1 ring-black ring-opacity-5"
            >
              {tailles.map((taille) => (
                <button
                  key={taille}
                  type="button"
                  data-testid={`filtre-taille-${taille}`}
                  onClick={() => ajouterFiltre('tailles', taille)}
                  className="block w-full px-4 py-2 text-left text-sm text-[var(--vs-noir)] hover:bg-[var(--vs-fond)]"
                >
                  {taille}
                </button>
              ))}
            </div>
          )}
        </div>
        
        <button
          type="button"
          data-testid="filtre-promo"
          aria-pressed={!!criteres.promotionSeulement}
          onClick={() => ajouterFiltre('promotionSeulement', !criteres.promotionSeulement)}
          className={`rounded-md px-3 py-2 text-sm font-medium ${
            criteres.promotionSeulement 
              ? 'bg-[var(--vs-principal)] text-[var(--vs-blanc)]' 
              : 'bg-[var(--vs-blanc)] text-[var(--vs-noir)] shadow-sm hover:bg-[var(--vs-fond)]'
          } focus:outline-none focus:ring-2 focus:ring-[var(--vs-principal)]`}
        >
          Promotions
        </button>
        
        <button
          type="button"
          data-testid="filtre-stock"
          aria-pressed={!!criteres.enStockSeulement}
          onClick={() => ajouterFiltre('enStockSeulement', !criteres.enStockSeulement)}
          className={`rounded-md px-3 py-2 text-sm font-medium ${
            criteres.enStockSeulement 
              ? 'bg-[var(--vs-principal)] text-[var(--vs-blanc)]' 
              : 'bg-[var(--vs-blanc)] text-[var(--vs-noir)] shadow-sm hover:bg-[var(--vs-fond)]'
          } focus:outline-none focus:ring-2 focus:ring-[var(--vs-principal)]`}
        >
          En stock
        </button>
        
        <div className="ml-auto flex items-center gap-2">
          <label htmlFor="tri" className="text-sm font-medium text-[var(--vs-noir)]">Trier par</label>
          <select
            id="tri"
            data-testid="tri"
            value={tri}
            onChange={(e) => onTriChange(e.target.value as Tri)}
            className="rounded-md border border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-3 py-2 text-sm text-[var(--vs-noir)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-principal)]"
          >
            <option value="nouveautes">Nouveautés</option>
            <option value="prix-croissant">Prix croissant</option>
            <option value="prix-decroissant">Prix décroissant</option>
            <option value="remise">Meilleures remises</option>
          </select>
        </div>
      </div>
      
      {/* Pastilles des filtres actifs */}
      {nombreFiltresActifs > 0 && (
        <div data-testid="pastilles" className="mt-3 flex flex-wrap gap-2">
          {marquesSelectionnees.map((slug) => {
            const marque = marques.find(m => m.slug === slug);
            return marque ? (
              <button
                key={slug}
                type="button"
                aria-label={`Retirer le filtre ${marque.nom}`}
                onClick={() => retirerFiltre('marques', slug)}
                className="flex items-center gap-1 rounded-full bg-[var(--vs-principal)] px-3 py-1 text-xs font-medium text-[var(--vs-blanc)]"
              >
                <span>{marque.nom}</span>
                <X aria-hidden size={14} />
              </button>
            ) : null;
          })}
          
          {taillesSelectionnees.map((taille) => (
            <button
              key={taille}
              type="button"
              aria-label={`Retirer le filtre Taille ${taille}`}
              onClick={() => retirerFiltre('tailles', taille)}
              className="flex items-center gap-1 rounded-full bg-[var(--vs-principal)] px-3 py-1 text-xs font-medium text-[var(--vs-blanc)]"
            >
              <span>Taille {taille}</span>
              <X aria-hidden size={14} />
            </button>
          ))}
          
          {criteres.promotionSeulement && (
            <button
              type="button"
              aria-label="Retirer le filtre Promotions"
              onClick={() => retirerFiltre('promotionSeulement', true)}
              className="flex items-center gap-1 rounded-full bg-[var(--vs-principal)] px-3 py-1 text-xs font-medium text-[var(--vs-blanc)]"
            >
              <span>Promotions</span>
              <X aria-hidden size={14} />
            </button>
          )}
          
          {criteres.enStockSeulement && (
            <button
              type="button"
              aria-label="Retirer le filtre En stock"
              onClick={() => retirerFiltre('enStockSeulement', true)}
              className="flex items-center gap-1 rounded-full bg-[var(--vs-principal)] px-3 py-1 text-xs font-medium text-[var(--vs-blanc)]"
            >
              <span>En stock</span>
              <X aria-hidden size={14} />
            </button>
          )}
          
          <button
            type="button"
            data-testid="filtres-reinitialiser"
            onClick={reinitialiserFiltres}
            className="text-xs text-[var(--vs-principal)] underline hover:no-underline"
          >
            Tout effacer
          </button>
        </div>
      )}
      
      {/* Barre mobile */}
      <div 
        data-testid="barre-mobile" 
        className="flex items-center gap-3 lg:hidden"
      >
        <button
          type="button"
          data-testid="ouvrir-filtres"
          onClick={toggleTiroir}
          className="flex items-center gap-1 rounded-md bg-[var(--vs-blanc)] px-3 py-2 text-sm font-medium text-[var(--vs-noir)] shadow-sm hover:bg-[var(--vs-fond)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-principal)]"
        >
          <SlidersHorizontal aria-hidden size={17} />
          <span>Filtrer{nombreFiltresActifs > 0 ? ` (${nombreFiltresActifs})` : ''}</span>
        </button>
        
        <button
          type="button"
          data-testid="ouvrir-tri"
          onClick={toggleTri}
          className="rounded-md bg-[var(--vs-blanc)] px-3 py-2 text-sm font-medium text-[var(--vs-noir)] shadow-sm hover:bg-[var(--vs-fond)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-principal)]"
        >
          Trier
        </button>
      </div>
      
      {/* Tiroir des filtres */}
      {ouvert === 'tiroir' && (
        <div 
          data-testid="tiroir-filtres" 
          role="dialog" 
          aria-label="Filtrer"
          className="fixed inset-0 z-50 flex flex-col bg-[var(--vs-blanc)] lg:hidden"
        >
          <div className="flex items-center justify-between border-b border-[var(--vs-ligne)] p-4">
            <button
              type="button"
              aria-label="Fermer"
              onClick={fermerPanneaux}
              className="rounded-md p-2 text-[var(--vs-noir)] hover:bg-[var(--vs-fond)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-principal)]"
            >
              <X aria-hidden size={20} />
            </button>
            <h3 className="text-lg font-bold text-[var(--vs-noir)]">Filtrer</h3>
            <div className="w-8"></div> {/* Pour l'alignement */}
          </div>
          
          <div className="flex-1 overflow-y-auto p-4">
            <div className="mb-6">
              <h4 className="mb-2 text-sm font-medium text-[var(--vs-noir)]">Marques</h4>
              <div className="space-y-1">
                {marques.map((marque) => (
                  <button
                    key={marque.slug}
                    type="button"
                    data-testid={`filtre-marque-${marque.slug}`}
                    aria-pressed={marquesSelectionnees.includes(marque.slug)}
                    onClick={() => ajouterFiltre('marques', marque.slug)}
                    className={`block w-full text-left px-3 py-2 rounded-md ${
                      marquesSelectionnees.includes(marque.slug)
                        ? 'bg-[var(--vs-principal)] text-[var(--vs-blanc)]'
                        : 'text-[var(--vs-noir)] hover:bg-[var(--vs-fond)]'
                    }`}
                  >
                    {marque.nom}
                  </button>
                ))}
              </div>
            </div>
            
            <div className="mb-6">
              <h4 className="mb-2 text-sm font-medium text-[var(--vs-noir)]">Tailles</h4>
              <div className="space-y-1">
                {tailles.map((taille) => (
                  <button
                    key={taille}
                    type="button"
                    data-testid={`filtre-taille-${taille}`}
                    onClick={() => ajouterFiltre('tailles', taille)}
                    className={`block w-full text-left px-3 py-2 rounded-md ${
                      taillesSelectionnees.includes(taille)
                        ? 'bg-[var(--vs-principal)] text-[var(--vs-blanc)]'
                        : 'text-[var(--vs-noir)] hover:bg-[var(--vs-fond)]'
                    }`}
                  >
                    {taille}
                  </button>
                ))}
              </div>
            </div>
            
            <div className="mb-6">
              <h4 className="mb-2 text-sm font-medium text-[var(--vs-noir)]">Filtres</h4>
              <div className="space-y-2">
                <button
                  type="button"
                  data-testid="filtre-promo"
                  aria-pressed={!!criteres.promotionSeulement}
                  onClick={() => ajouterFiltre('promotionSeulement', !criteres.promotionSeulement)}
                  className={`flex w-full items-center justify-between rounded-md px-3 py-2 ${
                    criteres.promotionSeulement
                      ? 'bg-[var(--vs-principal)] text-[var(--vs-blanc)]'
                      : 'text-[var(--vs-noir)] hover:bg-[var(--vs-fond)]'
                  }`}
                >
                  <span>Promotions</span>
                  <div className={`h-5 w-9 rounded-full ${criteres.promotionSeulement ? 'bg-[var(--vs-blanc)]' : 'bg-[var(--vs-ligne)]'}`}>
                    <div className={`h-4 w-4 rounded-full transition-transform ${criteres.promotionSeulement ? 'translate-x-4 bg-[var(--vs-principal)]' : 'translate-x-0.5 bg-[var(--vs-blanc)]'}`}></div>
                  </div>
                </button>
                
                <button
                  type="button"
                  data-testid="filtre-stock"
                  aria-pressed={!!criteres.enStockSeulement}
                  onClick={() => ajouterFiltre('enStockSeulement', !criteres.enStockSeulement)}
                  className={`flex w-full items-center justify-between rounded-md px-3 py-2 ${
                    criteres.enStockSeulement
                      ? 'bg-[var(--vs-principal)] text-[var(--vs-blanc)]'
                      : 'text-[var(--vs-noir)] hover:bg-[var(--vs-fond)]'
                  }`}
                >
                  <span>En stock</span>
                  <div className={`h-5 w-9 rounded-full ${criteres.enStockSeulement ? 'bg-[var(--vs-blanc)]' : 'bg-[var(--vs-ligne)]'}`}>
                    <div className={`h-4 w-4 rounded-full transition-transform ${criteres.enStockSeulement ? 'translate-x-4 bg-[var(--vs-principal)]' : 'translate-x-0.5 bg-[var(--vs-blanc)]'}`}></div>
                  </div>
                </button>
              </div>
            </div>
          </div>
          
          <div className="border-t border-[var(--vs-ligne)] p-4">
            <button
              type="button"
              onClick={fermerPanneaux}
              className="w-full rounded-md bg-[var(--vs-principal)] px-4 py-3 text-center font-medium text-[var(--vs-blanc)] hover:bg-[var(--vs-principal-hover)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-principal)]"
            >
              Appliquer les filtres
            </button>
          </div>
        </div>
      )}
      
      {/* Tiroir du tri */}
      {ouvert === 'tri' && (
        <div 
          data-testid="tiroir-tri" 
          role="dialog" 
          aria-label="Trier"
          className="fixed inset-0 z-50 flex flex-col bg-[var(--vs-blanc)] lg:hidden"
        >
          <div className="flex items-center justify-between border-b border-[var(--vs-ligne)] p-4">
            <button
              type="button"
              aria-label="Fermer"
              onClick={fermerPanneaux}
              className="rounded-md p-2 text-[var(--vs-noir)] hover:bg-[var(--vs-fond)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-principal)]"
            >
              <X aria-hidden size={20} />
            </button>
            <h3 className="text-lg font-bold text-[var(--vs-noir)]">Trier par</h3>
            <div className="w-8"></div> {/* Pour l'alignement */}
          </div>
          
          <div className="flex-1 overflow-y-auto p-4">
            <div className="space-y-2">
              {[
                { value: 'nouveautes', label: 'Nouveautés' },
                { value: 'prix-croissant', label: 'Prix croissant' },
                { value: 'prix-decroissant', label: 'Prix décroissant' },
                { value: 'remise', label: 'Meilleures remises' }
              ].map((option) => (
                <button
                  key={option.value}
                  type="button"
                  onClick={() => {
                    onTriChange(option.value as Tri);
                    fermerPanneaux();
                  }}
                  className={`block w-full text-left px-3 py-2 rounded-md ${
                    tri === option.value
                      ? 'bg-[var(--vs-principal)] text-[var(--vs-blanc)]'
                      : 'text-[var(--vs-noir)] hover:bg-[var(--vs-fond)]'
                  }`}
                >
                  {option.label}
                </button>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
