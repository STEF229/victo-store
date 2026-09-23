import { X } from 'lucide-react';
import {
  FERMER, OPTION_MARQUE, OPTION_TAILLE, OPTION_TRI, OPTIONS_TRI, PILULE, PILULE_OFF, PILULE_ON,
  TIROIR, TIROIR_ENTETE, TIROIR_FOND, TIROIR_SECTION, TIROIR_TITRE, VALIDER,
} from '@/components/catalogue/filtres-affichage';
import type { Marque } from '@/lib/catalogue';
import type { Criteres, Tri } from '@/lib/filtres';

export type VueTiroir = 'filtres' | 'tri' | null;

interface TiroirsFiltresProps {
  vue: VueTiroir;
  marques: Marque[];
  tailles: string[];
  criteres: Criteres;
  tri: Tri;
  onMarque: (slug: string) => void;
  onTaille: (taille: string) => void;
  onPromo: () => void;
  onStock: () => void;
  onTri: (tri: Tri) => void;
  onFermer: () => void;
}

export function TiroirsFiltres({
  vue,
  marques,
  tailles,
  criteres,
  tri,
  onMarque,
  onTaille,
  onPromo,
  onStock,
  onTri,
  onFermer,
}: TiroirsFiltresProps) {
  if (vue === null) {
    return null;
  }

  const handleFermer = () => {
    onFermer();
  };

  const titre = vue === 'filtres' ? 'Filtrer' : 'Trier par';
  
  const entete = (
    <div className={TIROIR_ENTETE}>
      <p className={TIROIR_TITRE}>{titre}</p>
      <button 
        type="button" 
        aria-label="Fermer" 
        className={FERMER} 
        onClick={handleFermer}
      >
        <X aria-hidden size={18} />
      </button>
    </div>
  );

  if (vue === 'filtres') {
    return (
      <>
        <div 
          data-testid="tiroir-fond" 
          aria-hidden="true" 
          className={TIROIR_FOND} 
          onClick={handleFermer} 
        />
        <div 
          data-testid="tiroir-filtres" 
          role="dialog" 
          aria-label="Filtrer" 
          className={TIROIR}
        >
          {entete}
          
          <p className={TIROIR_SECTION}>Marques</p>
          <div className="mb-6 flex flex-wrap gap-2">
            {marques.map((marque) => {
              const actif = criteres.marques?.includes(marque.slug) ?? false;
              return (
                <button
                  key={marque.id}
                  data-testid={`filtre-marque-${marque.slug}`}
                  type="button"
                  className={`${OPTION_MARQUE} ${actif ? PILULE_ON : PILULE_OFF}`}
                  aria-pressed={actif}
                  onClick={() => onMarque(marque.slug)}
                >
                  {marque.nom}
                </button>
              );
            })}
          </div>
          
          <p className={TIROIR_SECTION}>Tailles</p>
          <div className="mb-6 grid grid-cols-5 gap-2">
            {tailles.map((taille) => {
              const actif = criteres.tailles?.includes(taille) ?? false;
              return (
                <button
                  key={taille}
                  data-testid={`filtre-taille-${taille}`}
                  type="button"
                  className={`${OPTION_TAILLE} ${actif ? PILULE_ON : PILULE_OFF}`}
                  aria-pressed={actif}
                  onClick={() => onTaille(taille)}
                >
                  {taille}
                </button>
              );
            })}
          </div>
          
          <div className="mb-6 flex gap-2">
            <button
              data-testid="filtre-promo"
              type="button"
              className={`${PILULE} flex-1 justify-center`}
              aria-pressed={criteres.promotionSeulement === true}
              onClick={onPromo}
            >
              Promotions
            </button>
            <button
              data-testid="filtre-stock"
              type="button"
              className={`${PILULE} flex-1 justify-center`}
              aria-pressed={criteres.enStockSeulement === true}
              onClick={onStock}
            >
              En stock
            </button>
          </div>
          
          <button 
            type="button" 
            className={VALIDER} 
            onClick={handleFermer}
          >
            Appliquer les filtres
          </button>
        </div>
      </>
    );
  }

  if (vue === 'tri') {
    return (
      <>
        <div 
          data-testid="tiroir-fond" 
          aria-hidden="true" 
          className={TIROIR_FOND} 
          onClick={handleFermer} 
        />
        <div 
          data-testid="tiroir-tri" 
          role="dialog" 
          aria-label="Trier" 
          className={TIROIR}
        >
          {entete}
          
          <div className="flex flex-col gap-2.5">
            {OPTIONS_TRI.map((option) => {
              const actif = tri === option.valeur;
              return (
                <button
                  key={option.valeur}
                  type="button"
                  className={`${OPTION_TRI} ${actif ? PILULE_ON : PILULE_OFF}`}
                  aria-pressed={actif}
                  onClick={() => {
                    onTri(option.valeur);
                    handleFermer();
                  }}
                >
                  {option.libelle}
                </button>
              );
            })}
          </div>
        </div>
      </>
    );
  }

  return null;
}
