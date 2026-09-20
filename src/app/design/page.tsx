'use client';

import { useState } from 'react';
import { 
  Container, 
  Section, 
  Heading, 
  Text, 
  Button, 
  Badge, 
  Price, 
  Field, 
  SizeSelector, 
  QuantityStepper, 
  ProductCard 
} from '../../components/ui';
import { SiteHeader } from '../../components/layout';
import { Produit } from '../../lib/catalogue';

export function DesignPage() {
  // State for size selector and quantity stepper
  const [selectedSize, setSelectedSize] = useState<string | null>(null);
  const [quantity, setQuantity] = useState<number>(1);

  // Mock product data
  const mockProducts: Produit[] = [
    {
      id: '1',
      slug: 'produit-1',
      nom: 'Produit en promotion',
      marque: { id: '1', nom: 'Marque A', slug: 'marque-a' },
      imageUrl: '/images/produit1.jpg',
      prixCents: 2990,
      prixCompareCents: 3990,
      variantes: [
        { id: '1-1', taille: 'S', sku: 'SKU1-S', stock: 5 },
        { id: '1-2', taille: 'M', sku: 'SKU1-M', stock: 0 },
        { id: '1-3', taille: 'L', sku: 'SKU1-L', stock: 3 }
      ],
      badge: 'Promo'
    },
    {
      id: '2',
      slug: 'produit-2',
      nom: 'Produit standard',
      marque: { id: '2', nom: 'Marque B', slug: 'marque-b' },
      imageUrl: '/images/produit2.jpg',
      prixCents: 4990,
      variantes: [
        { id: '2-1', taille: 'S', sku: 'SKU2-S', stock: 2 },
        { id: '2-2', taille: 'M', sku: 'SKU2-M', stock: 7 },
        { id: '2-3', taille: 'L', sku: 'SKU2-L', stock: 1 }
      ]
    },
    {
      id: '3',
      slug: 'produit-3',
      nom: 'Produit avec badge',
      marque: { id: '3', nom: 'Marque C', slug: 'marque-c' },
      imageUrl: '/images/produit3.jpg',
      prixCents: 1990,
      variantes: [
        { id: '3-1', taille: 'S', sku: 'SKU3-S', stock: 0 },
        { id: '3-2', taille: 'M', sku: 'SKU3-M', stock: 4 },
        { id: '3-3', taille: 'L', sku: 'SKU3-L', stock: 6 }
      ],
      badge: 'Nouveau'
    }
  ];

  return (
    <div className="min-h-screen bg-[var(--vs-surface)]">
      <SiteHeader 
        navigation={[
          { label: 'Femme', href: '/femme' },
          { label: 'Homme', href: '/homme' },
          { label: 'Soldes', href: '/soldes' }
        ]}
        cartCount={2}
      />
      
      <Container className="py-8">
        <Heading level={1} className="mb-8">Design system</Heading>
        
        {/* Buttons Section */}
        <Section className="mb-12">
          <Heading level={2} className="mb-4">Boutons</Heading>
          <div className="flex flex-wrap gap-4 items-center">
            <Button variant="primary" size="sm">Petit</Button>
            <Button variant="primary" size="md">Moyen</Button>
            <Button variant="primary" size="lg">Grand</Button>
            
            <Button variant="accent" size="sm">Petit</Button>
            <Button variant="accent" size="md">Moyen</Button>
            <Button variant="accent" size="lg">Grand</Button>
            
            <Button variant="ghost" size="sm">Petit</Button>
            <Button variant="ghost" size="md">Moyen</Button>
            <Button variant="ghost" size="lg">Grand</Button>
            
            <Button loading>Chargement</Button>
          </div>
        </Section>
        
        {/* Badges Section */}
        <Section className="mb-12">
          <Heading level={2} className="mb-4">Badges</Heading>
          <div className="flex gap-2">
            <Badge variant="promo">Promo</Badge>
            <Badge variant="neutre">Neutre</Badge>
            <Badge variant="marque">Marque</Badge>
            <Badge variant="nouveau">Nouveau</Badge>
          </div>
        </Section>
        
        {/* Prices Section */}
        <Section className="mb-12">
          <Heading level={2} className="mb-4">Prix</Heading>
          <div className="flex flex-col gap-4">
            <Price amount={2990} />
            <Price amount={2990} compareAt={3990} />
          </div>
        </Section>
        
        {/* Form Section */}
        <Section className="mb-12">
          <Heading level={2} className="mb-4">Formulaire</Heading>
          <div className="flex flex-col gap-4 max-w-md">
            <Field 
              id="field1" 
              label="Champ normal" 
              placeholder="Placeholder" 
            />
            <Field 
              id="field2" 
              label="Avec aide" 
              hint="Texte d'aide" 
              placeholder="Placeholder" 
            />
            <Field 
              id="field3" 
              label="En erreur" 
              error="Erreur de validation" 
              placeholder="Placeholder" 
            />
          </div>
        </Section>
        
        {/* Selection Section */}
        <Section className="mb-12">
          <Heading level={2} className="mb-4">Sélection</Heading>
          <div className="flex flex-col gap-6 max-w-md">
            <div>
              <Text className="mb-2">Taille :</Text>
              <SizeSelector 
                sizes={[
                  { value: 'S', available: true },
                  { value: 'M', available: true },
                  { value: 'L', available: false },
                  { value: 'XL', available: true }
                ]}
                value={selectedSize}
                onChange={setSelectedSize}
              />
            </div>
            
            <div>
              <Text className="mb-2">Quantité :</Text>
              <QuantityStepper 
                value={quantity} 
                onChange={setQuantity} 
                min={1} 
                max={10} 
              />
              <Text data-testid="quantite-valeur" className="mt-2">
                Valeur actuelle : {quantity}
              </Text>
            </div>
          </div>
        </Section>
        
        {/* Products Section */}
        <Section>
          <Heading level={2} className="mb-4">Produits</Heading>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {mockProducts.map((produit) => (
              <ProductCard key={produit.id} produit={produit} />
            ))}
          </div>
        </Section>
      </Container>
    </div>
  );
}

export default DesignPage;
