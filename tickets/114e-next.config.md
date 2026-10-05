TICKET 114e — la boutique relaie les photos de Medusa

Modifie `next.config.ts`. Une règle de réécriture relaie `/medusa-images/…` vers le dossier `/static/` de Medusa (adresse prise dans `MEDUSA_URL`).

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
  allowedDevOrigins: ['192.168.40.32'],
};
```
Après :
```tsx
  allowedDevOrigins: ['192.168.40.32'],
  // Les photos téléversées dans Medusa, servies par la boutique : elles s'affichent aussi à travers le tunnel.
  async rewrites() {
    return [{ source: '/medusa-images/:chemin*', destination: `${process.env.MEDUSA_URL ?? 'http://192.168.40.40:9000'}/static/:chemin*` }];
  },
};
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
