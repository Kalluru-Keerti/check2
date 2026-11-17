import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// BACKEND_URL lets you point the dev proxy at a non-default backend port.
const backend = process.env.BACKEND_URL || 'http://localhost:8000';

export default defineConfig({
  plugins: [react()],
  server: { port: 5173, proxy: { '/api': { target: backend, changeOrigin: true } } },
  css: { preprocessorOptions: { scss: { quietDeps: true, silenceDeprecations: ['import', 'global-builtin', 'mixed-decls'] } } },
});
