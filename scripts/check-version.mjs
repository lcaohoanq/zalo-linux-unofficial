import { readFile } from 'node:fs/promises';

const readJson = async (path) => JSON.parse(await readFile(path, 'utf8'));

const rootVersion = (await readJson('package.json')).version;
const appVersion = (await readJson('app/package.json')).version;
const versionFile = (await readFile('version', 'utf8')).trim();

const versions = new Map([
  ['package.json', rootVersion],
  ['app/package.json', appVersion],
  ['version', versionFile],
]);

if (process.env.GITHUB_REF_TYPE === 'tag') {
  const tag = process.env.GITHUB_REF_NAME ?? '';
  if (!tag.startsWith('v')) {
    throw new Error(`Release tag must start with "v"; received "${tag}".`);
  }
  versions.set('release tag', tag.slice(1));
}

const mismatches = [...versions].filter(([, version]) => version !== rootVersion);
if (mismatches.length > 0) {
  const details = [...versions]
    .map(([source, version]) => `  ${source}: ${version}`)
    .join('\n');
  throw new Error(`Versions do not match:\n${details}`);
}

console.log(`Version ${rootVersion} is consistent across ${[...versions.keys()].join(', ')}.`);
