import { formatPrice } from '../../lib/formatPrice';

interface PriceProps {
  amount: number;
  compareAt?: number;
  afficherRemise?: boolean;
  className?: string;
}

export function Price({ amount, compareAt, afficherRemise = true, className = '' }: PriceProps) {
  const isPromo = compareAt !== undefined && compareAt > amount;
  
  return (
    <div 
      data-ui="price" 
      data-testid="prix"
      data-promo={isPromo.toString()}
      className={className}
    >
      <span 
        data-testid="prix-courant" 
        className={`font-bold ${isPromo ? 'text-[var(--vs-promo)]' : 'text-[var(--vs-noir)]'}`}
      >
        {formatPrice(amount)}
      </span>
      
      {isPromo && (
        <>
          <s 
            data-testid="prix-compare" 
            className="ml-2 text-sm text-[var(--vs-gris)]"
          >
            {formatPrice(compareAt)}
          </s>
          {afficherRemise && (
            <span 
              data-testid="prix-remise" 
              className="ml-2 text-[var(--vs-promo)]"
            >
              {`\u2212${Math.round((1 - amount / compareAt) * 100)}\u00A0%`}
            </span>
          )}
        </>
      )}
    </div>
  );
}
