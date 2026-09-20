export const TOKENS = {
  '--vs-noir': '#101014',
  '--vs-blanc': '#FFFFFF',
  '--vs-surface': '#F5F5F3',
  '--vs-ligne': '#E5E5E1',
  '--vs-gris': '#6B6B70',
  '--vs-accent': '#0B41CD',
  '--vs-accent-fonce': '#082F94',
  '--vs-promo': '#E4002B',
  '--vs-font-display': "'Archivo', system-ui, sans-serif",
  '--vs-maxw': '1220px',
  '--vs-radius': '6px',
} as const;

export function cssTokens(): string {
  let css = ':root {\n';
  
  for (const [key, value] of Object.entries(TOKENS)) {
    css += `  ${key}: ${value};\n`;
  }
  
  css += '}';
  return css;
}
