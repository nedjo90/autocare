import { handler } from './dist/server/entry.mjs';
import { createServer } from 'node:http';

const PORT = process.env.PORT || 3000;

const server = createServer(handler);

server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
