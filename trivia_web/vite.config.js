import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // Proxy /api requests to the PHP server on SiteGround
    proxy: {
      '/api': {
        target: 'https://institutoj17.sg-host.com',
        changeOrigin: true,
        secure: true,
      }
    }
  }
})
