TICKET 111a — la vue des listes : fil d'Ariane en haut, marges réduites sur téléphone

Modifie `src/components/catalogue/VueCatalogue.tsx`. Une prop facultative `filAriane` est affichée **avant** le titre (rien ne change si elle est absente). Sur téléphone, la marge du haut passe de 48 à 24 px, et les écarts avant le bandeau et les filtres de 32 à 20 px.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
  entete?: ReactNode | undefined;
}
```
Après :
```tsx
  entete?: ReactNode | undefined;
  filAriane?: ReactNode | undefined;
}
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
export function VueCatalogue({ titre, description, produits, entete }: VueCatalogueProps) {
```
Après :
```tsx
export function VueCatalogue({ titre, description, produits, entete, filAriane }: VueCatalogueProps) {
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
      <main className="mx-auto max-w-[1440px] px-5 py-12 lg:px-12">
```
Après :
```tsx
      <main className="mx-auto max-w-[1440px] px-5 py-12 lg:px-12 max-sm:pt-6">
        {filAriane}
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
          <div className="mt-8">
            {entete}
```
Après :
```tsx
          <div className="mt-8 max-sm:mt-5">
            {entete}
```

## Remplacement 5 (l'occurrence unique)
Avant :
```tsx
        <div className="mt-8">
          <FiltresBarre
```
Après :
```tsx
        <div className="mt-8 max-sm:mt-5">
          <FiltresBarre
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
