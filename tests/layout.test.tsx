import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Container, Heading, Section, Text } from '../src/components/ui/layout';

describe('Container', () => {
  it('rend ses enfants dans un conteneur identifiable', () => {
    render(<Container>contenu</Container>);
    const el = screen.getByText('contenu');
    expect(el).toHaveAttribute('data-ui', 'container');
  });

  it('vaut "default" en taille par défaut et accepte "narrow"', () => {
    const { rerender } = render(<Container>a</Container>);
    expect(screen.getByText('a')).toHaveAttribute('data-size', 'default');
    rerender(<Container size="narrow">a</Container>);
    expect(screen.getByText('a')).toHaveAttribute('data-size', 'narrow');
  });

  it('conserve la classe fournie', () => {
    render(<Container className="ma-classe">b</Container>);
    expect(screen.getByText('b').className).toContain('ma-classe');
  });
});

describe('Section', () => {
  it('rend un élément section', () => {
    render(<Section>zone</Section>);
    const el = screen.getByText('zone');
    expect(el.tagName).toBe('SECTION');
    expect(el).toHaveAttribute('data-ui', 'section');
  });
});

describe('Heading', () => {
  it.each([1, 2, 3, 4] as const)('rend un h%i pour level=%i', (level) => {
    render(<Heading level={level}>titre {level}</Heading>);
    const el = screen.getByRole('heading', { level });
    expect(el).toHaveAttribute('data-ui', 'heading');
  });

  it('rend un h2 par défaut', () => {
    render(<Heading>sans niveau</Heading>);
    expect(screen.getByRole('heading', { level: 2 })).toBeInTheDocument();
  });
});

describe('Text', () => {
  it('rend un paragraphe de ton "default"', () => {
    render(<Text>phrase</Text>);
    const el = screen.getByText('phrase');
    expect(el.tagName).toBe('P');
    expect(el).toHaveAttribute('data-tone', 'default');
  });

  it('accepte le ton "muted"', () => {
    render(<Text tone="muted">discret</Text>);
    expect(screen.getByText('discret')).toHaveAttribute('data-tone', 'muted');
  });
});
