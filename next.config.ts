import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  allowedDevOrigins: ['192.168.40.32'],
  // Les photos téléversées dans Medusa, servies par la boutique : elles s'affichent aussi à travers le tunnel.
  async rewrites() {
    return [{ source: '/medusa-images/:chemin*', destination: `${process.env.MEDUSA_URL ?? 'http://192.168.40.40:9000'}/static/:chemin*` }];
  },
};

export default nextConfig;
