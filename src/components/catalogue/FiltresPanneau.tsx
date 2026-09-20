'use client';

import type { Marque } from '@/lib/catalogue';
import type { Criteres } from '@/lib/filtres';

interface FiltresPanneauProps {
  marques: Marque[];
  tailles: string[];
  criteres: Criteres;
  onChange: (criteres: Criteres) => void;
  className?: string;
}

export function FiltresPanneau({ 
  marques, 
  tailles, 
  criteres, 
  onChange,
  className = ''
}: FiltresPanneauProps) {
  const handleMarqueChange = (slug: string) => {
    const nouvellesMarques = criteres.marques?.includes(slug)
      ? criteres.marques.filter(m => m !== slug)
      : [...(criteres.marques || []), slug];
    
    onChange({
      ...criteres,
      marques: nouvellesMarques
    });
  };

  const handleTailleChange = (taille: string) => {
    const nouvellesTailles = criteres.tailles?.includes(taille)
      ? criteres.tailles.filter(t => t !== taille)
      : [...(criteres.tailles || []), taille];
    
    onChange({
      ...criteres,
      tailles: nouvellesTailles
    });
  };

  const handlePromoChange = () => {
    onChange({
      ...criteres,
      promotionSeulement: !criteres.promotionSeulement
    });
  };

  const handleStockChange = () => {
    onChange({
      ...criteres,
      enStockSeulement: !criteres.enStockSeulement
    });
  };

  const handleReset = () => {
    onChange({});
  };

  return (
    <aside data-testid="filtres" className={className}>
      <fieldset>
        <legend>Marques</legend>
        {marques.map(marque => (
          <div key={marque.slug}>
            <input
              type="checkbox"
              id={`filtre-marque-${marque.slug}`}
              data-testid={`filtre-marque-${marque.slug}`}
              checked={criteres.marques?.includes(marque.slug) || false}
              onChange={() => handleMarqueChange(marque.slug)}
            />
            <label htmlFor={`filtre-marque-${marque.slug}`}>
              {marque.nom}
            </label>
          </div>
        ))}
      </fieldset>

      <fieldset>
        <legend>Tailles</legend>
        {tailles.map(taille => (
          <div key={taille}>
            <input
              type="checkbox"
              id={`filtre-taille-${taille}`}
              data-testid={`filtre-taille-${taille}`}
              checked={criteres.tailles?.includes(taille) || false}
              onChange={() => handleTailleChange(taille)}
            />
            <label htmlFor={`filtre-taille-${taille}`}>
              {taille}
            </label>
          </div>
        ))}
      </fieldset>

      <div>
        <input
          type="checkbox"
          id="filtre-promo"
          data-testid="filtre-promo"
          checked={criteres.promotionSeulement || false}
          onChange={handlePromoChange}
        />
        <label htmlFor="filtre-promo">Promotions seulement</label>
      </div>

      <div>
        <input
          type="checkbox"
          id="filtre-stock"
          data-testid="filtre-stock"
          checked={criteres.enStockSeulement || false}
          onChange={handleStockChange}
        />
        <label htmlFor="filtre-stock">En stock seulement</label>
      </div>

      <button 
        type="button" 
        data-testid="filtres-reinitialiser"
        onClick={handleReset}
      >
        Réinitialiser
      </button>
    </aside>
  );
}
