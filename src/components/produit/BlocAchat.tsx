'use client';

import { Check, Heart } from 'lucide-react';
import { useState } from 'react';
import { usePanier } from '@/components/panier/PanierProvider';
import { SelecteurPointure } from '@/components/produit/SelecteurPointure';
import { economieCents, estEnPromotion, type Produit } from '@/lib/catalogue';
import { texteStockBas } from '@/lib/fiche-produit';
import { formatPrice } from '@/lib/formatPrice';

export function BlocAchat({ produit }: { produit: Produit }) {
  const panier = usePanier();
  const [taille, setTaille] = useState<string | null>(null);
  const [quantite, setQuantite] = useState(1);
  const [favori, setFavori] = useState(false);
  const [erreur, setErreur] = useState(false);
  const [confirme, setConfirme] = useState(false);
  const promo = estEnPromotion(produit);
  const choisie = produit.variantes.find((v) => v.taille === taille);
  const plafond = choisie ? choisie.stock : 9;
  const alerte = texteStockBas(produit, taille);

  const choisir = (t: string) => {
    setTaille(t);
    setErreur(false);
    setConfirme(false);
    
    const variante = produit.variantes.find((v) => v.taille === t);
    if (variante) {
      setQuantite((q) => Math.min(q, Math.max(1, variante.stock)));
    }
  };

  const moins = () => {
    setQuantite(Math.max(1, quantite - 1));
  };

  const plus = () => {
    setQuantite(Math.min(plafond, quantite + 1));
  };

  const ajouter = () => {
    if (!choisie) {
      setErreur(true);
      setConfirme(false);
      return;
    }

    panier.ajouter({ slug: produit.slug, sku: choisie.sku }, quantite, choisie.stock);
    setErreur(false);
    setConfirme(true);
  };

  return (
    <div data-testid="bloc-achat" className="flex flex-col gap-[22px]">
      {/* Prix */}
      <div className="flex flex-wrap items-baseline gap-3.5">
        <span 
          data-testid="fiche-prix" 
          className={promo
            ? 'text-[32px] font-black text-[var(--vs-promo)]'
            : 'text-[32px] font-black text-[var(--vs-noir)]'}
        >
          {formatPrice(produit.prixCents)}
        </span>
        
        {promo && produit.prixCompareCents !== undefined && (
          <s data-testid="fiche-prix-barre" className="text-lg text-[var(--vs-gris)]">
            {formatPrice(produit.prixCompareCents)}
          </s>
        )}
        
        {promo && (
          <span 
            data-testid="fiche-economie" 
            className="rounded-full bg-[#FFD3DB] px-[11px] py-[5px] text-sm font-extrabold text-[var(--vs-promo)]"
          >
            {`Économisez ${formatPrice(economieCents(produit))}`}
          </span>
        )}
      </div>

      {/* Description */}
      {produit.description !== undefined && (
        <p 
          data-testid="fiche-description" 
          className="text-base leading-relaxed text-[var(--vs-gris)]"
        >
          {produit.description}
        </p>
      )}

      {/* Séparateur */}
      <div className="h-px bg-[var(--vs-ligne)]" />

      {/* Pointure */}
      <SelecteurPointure 
        variantes={produit.variantes} 
        valeur={taille} 
        onChoisir={choisir} 
      />
      
      {alerte !== null && (
        <p data-testid="stock-bas" className="text-sm font-bold text-[var(--vs-promo)]">
          {alerte}
        </p>
      )}

      {/* Actions */}
      <div className="flex flex-wrap items-stretch gap-3">
        {/* Quantité */}
        <div className="flex h-[58px] items-center rounded-full border-[1.5px] border-[var(--vs-ligne)]">
          <button 
            type="button" 
            aria-label="Diminuer la quantité" 
            disabled={quantite <= 1} 
            onClick={moins}
            className={quantite <= 1 ? 'h-14 w-[52px] text-[22px] text-[#B5B5BA]' : 'h-14 w-[52px] text-[22px] text-[var(--vs-noir)]'}
          >
            −
          </button>
          <span 
            data-testid="quantite" 
            aria-live="polite" 
            className="min-w-7 text-center text-[17px] font-extrabold"
          >
            {quantite}
          </span>
          <button 
            type="button" 
            aria-label="Augmenter la quantité" 
            onClick={plus} 
            className="h-14 w-[52px] text-[22px] text-[var(--vs-noir)]"
          >
            +
          </button>
        </div>

        {/* Bouton d'ajout */}
        <button 
          type="button" 
          onClick={ajouter}
          className="order-last h-[58px] basis-full rounded-full bg-[var(--vs-accent)] text-[17px] font-extrabold text-[var(--vs-blanc)] sm:order-none sm:basis-auto sm:flex-1"
        >
          Ajouter au panier
        </button>

        {/* Bouton favori */}
        <button 
          type="button" 
          aria-label="Ajouter aux favoris" 
          aria-pressed={favori} 
          onClick={() => setFavori(!favori)}
          className="flex h-[58px] w-[58px] items-center justify-center rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)]"
        >
          <Heart 
            aria-hidden 
            size={20} 
            className={favori ? 'fill-[var(--vs-promo)] text-[var(--vs-promo)]' : 'text-[var(--vs-noir)]'} 
          />
        </button>
      </div>

      {/* Erreur */}
      {erreur && (
        <p role="alert" className="text-sm font-bold text-[var(--vs-promo)]">
          Choisissez une pointure avant d'ajouter au panier.
        </p>
      )}

      {/* Confirmation */}
      {confirme && (
        <p 
          role="status" 
          className="flex items-center gap-2 text-sm font-bold text-[var(--vs-accent)]"
        >
          <Check aria-hidden size={18} />
          {`Ajouté au panier — pointure ${taille}, quantité ${quantite}`}
        </p>
      )}
    </div>
  );
}
