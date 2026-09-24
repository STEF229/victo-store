'use client';

import { ChevronDown, SlidersHorizontal, X } from 'lucide-react';
import { useState } from 'react';
import {
  MOBILE_FILTRER, MOBILE_TRIER, OPTION_MARQUE, OPTION_TAILLE, OPTIONS_TRI, PANNEAU, PANNEAU_MARQUES,
  PANNEAU_TAILLES, PASTILLE, PASTILLE_CROIX, PASTILLES, PILULE, PILULE_OFF, PILULE_ON, TOUT_EFFACER, TRI_LIBELLE, TRI_SELECT,
} from '@/components/catalogue/filtres-affichage';
import { TiroirsFiltres } from '@/components/catalogue/TiroirsFiltres';
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
  const [ouvert, setOuvert] = useState<null | 'marques' | 'tailles' | 'filtres' | 'tri'>(null);

  const marquesChoisies = criteres.marques ?? [];
  const taillesChoisies = criteres.tailles ?? [];

  const nombreFiltresActifs = 
    marquesChoisies.length + 
    taillesChoisies.length + 
    (criteres.promotionSeulement ? 1 : 0) + 
    (criteres.enStockSeulement ? 1 : 0);

  const basculerMarque = (slug: string) => {
    const nouvellesMarques = marquesChoisies.includes(slug)
      ? marquesChoisies.filter(m => m !== slug)
      : [...marquesChoisies, slug];
    
    onChange({ ...criteres, marques: nouvellesMarques });
  };

  const basculerTaille = (taille: string) => {
    const nouvellesTailles = taillesChoisies.includes(taille)
      ? taillesChoisies.filter(t => t !== taille)
      : [...taillesChoisies, taille];
    
    onChange({ ...criteres, tailles: nouvellesTailles });
  };

  const basculerPromo = () => {
    onChange({ ...criteres, promotionSeulement: !criteres.promotionSeulement });
  };

  const basculerStock = () => {
    onChange({ ...criteres, enStockSeulement: !criteres.enStockSeulement });
  };

  const retirerFiltre = (filtre: string) => {
    if (marquesChoisies.includes(filtre)) {
      basculerMarque(filtre);
    } else if (taillesChoisies.includes(filtre)) {
      basculerTaille(filtre);
    } else if (filtre === 'Promotions') {
      basculerPromo();
    } else if (filtre === 'En stock') {
      basculerStock();
    }
  };

  const toutEffacer = () => {
    onChange({});
  };

  const ouvrirVue = (vue: 'marques' | 'tailles' | 'filtres' | 'tri') => {
    if (ouvert === vue) {
      setOuvert(null);
    } else {
      setOuvert(vue);
    }
  };

  const fermerVue = () => {
    setOuvert(null);
  };

  return (
    <div data-testid="filtres-barre">
      {/* Barre bureau */}
      <div data-testid="barre-bureau" className="hidden flex-wrap items-center gap-3 lg:flex">
        <div className="relative">
          <button
            type="button"
            data-testid="bouton-marques"
            aria-expanded={ouvert === 'marques'}
            className={`${PILULE} ${ouvert === 'marques' || marquesChoisies.length > 0 ? PILULE_ON : PILULE_OFF}`}
            onClick={() => ouvrirVue('marques')}
          >
            <span>
              {marquesChoisies.length > 0 
                ? `Marque (${marquesChoisies.length})` 
                : 'Marque'}
            </span>
            <ChevronDown aria-hidden size={16} />
          </button>
          
          {ouvert === 'marques' && (
            <div data-testid="panneau-marques" className={`${PANNEAU} ${PANNEAU_MARQUES}`}>
              {marques.map((marque) => (
                <button
                  key={marque.slug}
                  type="button"
                  data-testid={`filtre-marque-${marque.slug}`}
                  className={`${OPTION_MARQUE} ${marquesChoisies.includes(marque.slug) ? PILULE_ON : PILULE_OFF}`}
                  aria-pressed={marquesChoisies.includes(marque.slug)}
                  onClick={() => basculerMarque(marque.slug)}
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
            className={`${PILULE} ${ouvert === 'tailles' || taillesChoisies.length > 0 ? PILULE_ON : PILULE_OFF}`}
            onClick={() => ouvrirVue('tailles')}
          >
            <span>
              {taillesChoisies.length > 0 
                ? `Taille (${taillesChoisies.length})` 
                : 'Taille'}
            </span>
            <ChevronDown aria-hidden size={16} />
          </button>
          
          {ouvert === 'tailles' && (
            <div data-testid="panneau-tailles" className={`${PANNEAU} ${PANNEAU_TAILLES}`}>
              {tailles.map((taille) => (
                <button
                  key={taille}
                  type="button"
                  data-testid={`filtre-taille-${taille}`}
                  className={`${OPTION_TAILLE} ${taillesChoisies.includes(taille) ? PILULE_ON : PILULE_OFF}`}
                  aria-pressed={taillesChoisies.includes(taille)}
                  onClick={() => basculerTaille(taille)}
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
          className={`${PILULE} ${criteres.promotionSeulement === true ? PILULE_ON : PILULE_OFF}`}
          aria-pressed={criteres.promotionSeulement === true}
          onClick={basculerPromo}
        >
          Promotions
        </button>

        <button
          type="button"
          data-testid="filtre-stock"
          className={`${PILULE} ${criteres.enStockSeulement === true ? PILULE_ON : PILULE_OFF}`}
          aria-pressed={criteres.enStockSeulement === true}
          onClick={basculerStock}
        >
          En stock
        </button>

        <div className="ml-auto flex items-center gap-2">
          <label htmlFor="tri" className={TRI_LIBELLE}>Trier par</label>
          <select
            id="tri"
            data-testid="tri"
            className={TRI_SELECT}
            value={tri}
            onChange={(e) => onTriChange(e.target.value as Tri)}
          >
            {OPTIONS_TRI.map((option) => (
              <option key={option.valeur} value={option.valeur}>
                {option.libelle}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Pastilles */}
      {nombreFiltresActifs > 0 && (
        <div data-testid="pastilles" className={PASTILLES}>
          {marquesChoisies.map((slug) => {
            const marque = marques.find(m => m.slug === slug);
            return marque ? (
              <button
                key={slug}
                type="button"
                className={PASTILLE}
                aria-label={`Retirer le filtre ${marque.nom}`}
                onClick={() => retirerFiltre(slug)}
              >
                <span>{marque.nom}</span>
                <X aria-hidden size={14} className={PASTILLE_CROIX} />
              </button>
            ) : null;
          })}
          
          {taillesChoisies.map((taille) => (
            <button
              key={taille}
              type="button"
              className={PASTILLE}
              aria-label={`Retirer le filtre Taille ${taille}`}
              onClick={() => retirerFiltre(taille)}
            >
              <span>Taille {taille}</span>
              <X aria-hidden size={14} className={PASTILLE_CROIX} />
            </button>
          ))}
          
          {criteres.promotionSeulement === true && (
            <button
              type="button"
              className={PASTILLE}
              aria-label="Retirer le filtre Promotions"
              onClick={() => retirerFiltre('Promotions')}
            >
              <span>Promotions</span>
              <X aria-hidden size={14} className={PASTILLE_CROIX} />
            </button>
          )}
          
          {criteres.enStockSeulement === true && (
            <button
              type="button"
              className={PASTILLE}
              aria-label="Retirer le filtre En stock"
              onClick={() => retirerFiltre('En stock')}
            >
              <span>En stock</span>
              <X aria-hidden size={14} className={PASTILLE_CROIX} />
            </button>
          )}
          
          <button
            data-testid="filtres-reinitialiser"
            className={TOUT_EFFACER}
            onClick={toutEffacer}
          >
            Tout effacer
          </button>
        </div>
      )}

      {/* Barre mobile */}
      <div data-testid="barre-mobile" className="flex items-center gap-3 lg:hidden">
        <button
          type="button"
          data-testid="ouvrir-filtres"
          className={MOBILE_FILTRER}
          onClick={() => ouvrirVue('filtres')}
        >
          <SlidersHorizontal aria-hidden size={17} />
          <span>
            {nombreFiltresActifs > 0 
              ? `Filtrer (${nombreFiltresActifs})` 
              : 'Filtrer'}
          </span>
        </button>
        
        <button
          type="button"
          data-testid="ouvrir-tri"
          className={MOBILE_TRIER}
          onClick={() => ouvrirVue('tri')}
        >
          Trier
        </button>
      </div>

      {/* Tiroirs */}
      <TiroirsFiltres
        vue={ouvert === 'filtres' || ouvert === 'tri' ? ouvert : null}
        marques={marques}
        tailles={tailles}
        criteres={criteres}
        tri={tri}
        onMarque={basculerMarque}
        onTaille={basculerTaille}
        onPromo={basculerPromo}
        onStock={basculerStock}
        onTri={onTriChange}
        onFermer={fermerVue}
      />
    </div>
  );
}
