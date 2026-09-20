import { render, screen } from '@testing-library/react';
import { expect, it } from 'vitest';
import { readFileSync } from 'node:fs';

function Hello({ nom }: { nom: string }) {
  return <p>Bonjour {nom}</p>;
}

it('React et jsdom fonctionnent', () => {
  render(<Hello nom="VICTO" />);
  expect(screen.getByText('Bonjour VICTO')).toBeInTheDocument();
});

it('node:fs est typé et lisible', () => {
  expect(readFileSync('package.json', 'utf8')).toContain('victo-store');
});

it('Tailwind est branché sur PostCSS', () => {
  expect(readFileSync('postcss.config.mjs', 'utf8')).toContain('@tailwindcss/postcss');
});
