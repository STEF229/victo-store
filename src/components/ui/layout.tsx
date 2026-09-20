import { ReactNode } from 'react';

interface ContainerProps {
  children: ReactNode;
  size?: 'default' | 'narrow';
  className?: string;
}

export function Container({ children, size = 'default', className = '' }: ContainerProps) {
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

interface SectionProps {
  children: ReactNode;
  className?: string;
}

export function Section({ children, className = '' }: SectionProps) {
  return (
    <section 
      data-ui="section" 
      className={`py-8 ${className}`}
    >
      {children}
    </section>
  );
}

interface HeadingProps {
  children: ReactNode;
  level?: 1 | 2 | 3 | 4;
  className?: string;
}

const BALISES = { 1: 'h1', 2: 'h2', 3: 'h3', 4: 'h4' } as const;

export function Heading({ children, level = 2, className = '' }: HeadingProps) {
  const Balise = BALISES[level];
  return (
    <Balise 
      data-ui="heading" 
      className={`font-bold tracking-tight font-display ${className}`}
      style={{ fontFamily: 'var(--vs-font-display)' }}
    >
      {children}
    </Balise>
  );
}

interface TextProps {
  children: ReactNode;
  tone?: 'default' | 'muted';
  className?: string;
}

export function Text({ children, tone = 'default', className = '' }: TextProps) {
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
