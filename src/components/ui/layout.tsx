import { ReactNode } from 'react';

export function Container({ 
  children, 
  size = 'default', 
  className = '' 
}: { 
  children: ReactNode; 
  size?: 'default' | 'narrow'; 
  className?: string; 
}) {
  const sizeClasses = size === 'narrow' 
    ? 'max-w-[var(--vs-maxw)] mx-auto px-4'
    : 'max-w-[var(--vs-maxw)] mx-auto px-4';
  
  return (
    <div 
      data-ui="container" 
      data-size={size}
      className={`${sizeClasses} ${className}`}
    >
      {children}
    </div>
  );
}

export function Section({ 
  children, 
  className = '' 
}: { 
  children: ReactNode; 
  className?: string; 
}) {
  return (
    <section 
      data-ui="section"
      className={`py-8 ${className}`}
    >
      {children}
    </section>
  );
}

export function Heading({ 
  children, 
  level = 2, 
  className = '' 
}: { 
  children: ReactNode; 
  level?: 1 | 2 | 3 | 4; 
  className?: string; 
}) {
  const HeadingTag = `h${level}`;
  
  return (
    <HeadingTag 
      data-ui="heading"
      className={`font-bold tracking-tight ${className}`}
    >
      {children}
    </HeadingTag>
  );
}

export function Text({ 
  children, 
  tone = 'default', 
  className = '' 
}: { 
  children: ReactNode; 
  tone?: 'default' | 'muted'; 
  className?: string; 
}) {
  const toneClasses = tone === 'muted' 
    ? 'text-[var(--vs-gris)]'
    : 'text-[var(--vs-noir)]';
  
  return (
    <p 
      data-ui="text"
      data-tone={tone}
      className={`${toneClasses} ${className}`}
    >
      {children}
    </p>
  );
}
