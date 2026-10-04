TICKET 111b — la page de sous-catégorie met son fil d'Ariane en haut

Modifie `src/components/catalogue/PageSousCategorie.tsx`. Le fil d'Ariane passe dans la nouvelle prop `filAriane` de la vue des listes (au-dessus du titre) ; le bandeau ne garde que les pastilles.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
      entete={
        <div className="flex flex-col gap-4">
          <FilAriane items={[{ label: 'Accueil', href: '/' }, ...fil]} />
          <SousCategories titre={`Sous-catégories de ${trouve.noeud.libelle}`} forme="pastilles" elements={pastilles} actif={hrefDe(rubrique, chemin)} />
        </div>
      }
```
Après :
```tsx
      filAriane={<FilAriane items={[{ label: 'Accueil', href: '/' }, ...fil]} />}
      entete={<SousCategories titre={`Sous-catégories de ${trouve.noeud.libelle}`} forme="pastilles" elements={pastilles} actif={hrefDe(rubrique, chemin)} />}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
