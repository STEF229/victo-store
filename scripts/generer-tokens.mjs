import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';

const src = readFileSync('src/lib/tokens.ts', 'utf8');
const bloc = src.match(/TOKENS\s*=\s*\{([\s\S]*?)\}\s*as const/);
if (!bloc) {
  console.error('TOKENS introuvable dans src/lib/tokens.ts');
  process.exit(1);
}
const paires = [...bloc[1].matchAll(/["']?(--vs-[a-z-]+)["']?\s*:\s*(?:"([^"]*)"|'([^']*)')/g)]
  .map((m) => [m[1], m[2] !== undefined ? m[2] : m[3]]);
if (paires.length < 10) {
  console.error(`tokens incomplets : ${paires.length} trouvés`);
  process.exit(1);
}
mkdirSync('src/styles', { recursive: true });
writeFileSync(
  'src/styles/tokens.css',
  ':root {\n' + paires.map(([k, v]) => `  ${k}: ${v};`).join('\n') + '\n}\n',
);
console.log(`${paires.length} tokens → src/styles/tokens.css`);
