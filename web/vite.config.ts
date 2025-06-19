/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-return */
/// <reference types="vitest" />
import tailwindcss from '@tailwindcss/vite';
import { TanStackRouterVite } from '@tanstack/router-plugin/vite';
import legacy from '@vitejs/plugin-legacy';
import react from '@vitejs/plugin-react-swc';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { defineConfig, loadEnv } from 'vite';
import svgr from 'vite-plugin-svgr';
import config from './_config';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export default defineConfig(({mode}) => {
  // Load env file based on `mode` in the current working directory.
  // Set the third parameter to '' to load all env regardless of the `VITE_` prefix.
  const env = loadEnv(mode, process.cwd(), '')

  return {
  define: {
      __APP_VERSION__: JSON.stringify(env.npm_package_version),
    },
    base: process.env.VITE_BASE_PATH,
    esbuild: {
      supported: {
        'top-level-await': true //browsers can handle top-level-await features
      },
    },
    optimizeDeps: {
      esbuildOptions: {
        target: 'esnext'
      }
    },
    build: {
      target: 'esnext'
    },
    plugins: [
      TanStackRouterVite({ target: 'react', autoCodeSplitting: true }),
      react(),
      tailwindcss(),
      svgr(),
      legacy(),
      {
        name: 'dynamic-html',
        transformIndexHtml(html) {
          return html
            .replaceAll('%TITLE%', config.metadata.title)
            .replaceAll('%DESCRIPTION%', config.metadata.description)
            .replaceAll('%KEYWORDS%', config.metadata.keywords);
        }
      }
    ],
    resolve: {
      alias: {
        '@': path.resolve(__dirname, 'src'),
      },
    },
    server: {
      host: config.server.host,
      port: config.server.port,
    }
  }
});
