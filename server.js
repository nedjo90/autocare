import { createServer } from 'node:http';
import { readFileSync, existsSync } from 'node:fs';
import { join, extname } from 'node:path';

const PORT = process.env.PORT || 3000;
const DIST = join(import.meta.dirname, 'dist');

const MIME = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'application/javascript',
  '.json': 'application/json',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.webp': 'image/webp',
};

const server = createServer((req, res) => {
  let path = req.url.split('?')[0];
  if (path === '/') path = '/index.html';
  if (!extname(path)) path += '/index.html';

  const file = join(DIST, path);

  if (existsSync(file)) {
    const content = readFileSync(file);
    res.writeHead(200, { 'Content-Type': MIME[extname(file)] || 'application/octet-stream' });
    res.end(content);
  } else {
    const notFound = join(DIST, '404.html');
    res.writeHead(404, { 'Content-Type': 'text/html' });
    res.end(existsSync(notFound) ? readFileSync(notFound) : 'Not Found');
  }
});

server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
