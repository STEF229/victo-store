'use client';

import { useState } from 'react';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { Field } from '@/components/ui/Field';
import { Price } from '@/components/ui/Price';
import { ProductCard } from '@/components/ui/ProductCard';
import { QuantityStepper } from '@/components/ui/QuantityStepper';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { SizeSelector } from '@/components/ui/SizeSelector';
import { Container, Heading, Section, Text } from '@/components/ui/layout';
import { optionsDeTaille, type Produit } from '@/lib/catalogue';

export function DesignPage() {
  // State for size selector
  const [selectedSize, setSelectedSize] = useState<string | null>(null);
  
  // State for quantity stepper
  const [quantity, setQuantity] = useState(1);

  // Mock product data
  const mockProducts: Produit[] = [
    {
      id: '1',
      slug: 'produit-1',
      nom: 'T-shirt Classique',
      marque: {
        id: 'marque-1',
        nom: 'Marque A',
        slug: 'marque-a'
      },
      imageUrl: '/images/tshirt.jpg',
      prixCents: 2999,
      prixCompareCents: 3999,
      variantes: [
        { id: 'v1', taille: 'S', sku: 'SKU1-S', stock: 5 },
        { id: 'v2', taille: 'M', sku: 'SKU1-M', stock: 0 },
        { id: 'v3', taille: 'L', sku: 'SKU1-L', stock: 3 }
      ],
      badge: 'Nouveau'
    },
    {
      id: '2',
      slug: 'produit-2',
      nom: 'Jeans Slim',
      marque: {
        id: 'marque-2',
        nom: 'Marque B',
        slug: 'marque-b'
      },
      imageUrl: '/images/jeans.jpg',
      prixCents: 5999,
      variantes: [
        { id: 'v4', taille: '32', sku: 'SKU2-32', stock: 2 },
        { id: 'v5', taille: '34', sku: 'SKU2-34', stock: 0 },
        { id: 'v6', taille: '36', sku: 'SKU2-36', stock: 7 }
      ]
    },
    {
      id: '3',
      slug: 'produit-3',
      nom: 'Veste Enfant',
      marque: {
        id: 'marque-3',
        nom: 'Marque C',
        slug: 'marque-c'
      },
      imageUrl: '/images/veste.jpg',
      prixCents: 4999,
      prixCompareCents: 6999,
      variantes: [
        { id: 'v7', taille: '40', sku: 'SKU3-40', stock: 1 },
        { id: 'v8', taille: '42', sku: 'SKU3-42', stock: 0 },
        { id: 'v9', taille: '44', sku: 'SKU3-44', stock: 4 }
      ],
      badge: 'Solde'
    }
  ];

  return (
    <Container>
      <SiteHeader 
        navigation={[
          { label: 'Femme', href: '/femme' },
          { label: 'Homme', href: '/homme' },
          { label: 'Soldes', href: '/soldes' }
        ]}
        cartCount={2}
      />
      
      <Heading level={1}>Design system</Heading>
      
      <Section>
        <Heading level={2}>Boutons</Heading>
        <div className="flex flex-wrap gap-4">
          <Button variant="primary">Primary</Button>
          <Button variant="accent">Accent</Button>
          <Button variant="ghost">Ghost</Button>
          
          <Button size="sm">Small</Button>
          <Button size="md">Medium</Button>
          <Button size="lg">Large</Button>
          
          <Button loading>Chargement</Button>
        </div>
      </Section>
      
      <Section>
        <Heading level={2}>Badges</Heading>
        <div className="flex gap-2">
          <Badge variant="promo">Promo</Badge>
          <Badge variant="neutre">Neutre</Badge>
          <Badge variant="marque">Marque</Badge>
          <Badge variant="nouveau">Nouveau</Badge>
        </div>
      </Section>
      
      <Section>
        <Heading level={2}>Prix</Heading>
        <div className="flex flex-col gap-4">
          <Price amount={2999} />
          <Price amount={2999} compareAt={3999} />
        </div>
      </Section>
      
      <Section>
        <Heading level={2}>Formulaire</Heading>
        <div className="flex flex-col gap-4 max-w-md">
          <Field id="field1" label="Champ normal" />
          <Field 
            id="field2" 
            label="Champ avec aide" 
            hint="Ceci est un texte d'aide"
          />
          <Field 
            id="field3" 
            label="Champ en erreur" 
            error="Ce champ est requis"
          />
        </div>
      </Section>
      
      <Section>
        <Heading level={2}>Sélection</Heading>
        <div className="flex flex-col gap-6 max-w-md">
          <div>
            <Text className="mb-2">Sélecteur de taille :</Text>
            <SizeSelector
              sizes={optionsDeTaille(mockProducts[0])}
              value={selectedSize}
              onChange={setSelectedSize}
              label="Taille"
            />
          </div>
          
          <div>
            <Text className="mb-2">Sélecteur de quantité :</Text>
            <QuantityStepper 
              value={quantity} 
              onChange={setQuantity} 
              min={1}
              max={10}
            />
            <Text data-testid="quantite-valeur" className="mt-2">
              Quantité sélectionnée : {quantity}
            </Text>
          </div>
        </div>
      </Section>
      
      <Section>
        <Heading level={2}>Produits</Heading>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {mockProducts.map((produit) => (
            <ProductCard key={produit.id} produit={produit} />
          ))}
        </div>
      </Section>
    </Container>
  );
}

export default DesignPage;
