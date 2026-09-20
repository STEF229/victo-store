import { ReactNode } from 'react';

interface BadgeProps {
  children: ReactNode;
  variant?: 'promo' | 'neutre' | 'marque' | 'nouveau';
  className?: string;
}

export function Badge({ children, variant = 'neutre', className = '' }: BadgeProps) {
  const baseClasses = 'text-xs font-medium rounded-full px-2 py-1 inline-block';
  
  const variantClasses = {
    promo: 'bg-[var(--vs-promo)] text-white font-bold',
    nouveau: 'bg-[var(--vs-noir)] text-white',
    marque: 'bg-transparent border border-[var(--vs-ligne)] text-[var(--vs-gris)] uppercase tracking-wide',
    neutre: 'bg-[var(--vs-surface)] text-[var(--vs-noir)]'
  };
  
  const classes = `${baseClasses} ${variantClasses[variant]} ${className}`.trim();
  
  return (
    <span 
      data-ui="badge" 
      data-testid="badge" 
      data-variant={variant}
      className={classes}
    >
      {children}
    </span>
  );
}
