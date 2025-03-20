import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: '192.168.1.57',
    port: 5173,
    strictPort: true,
    cors: true
  },
  preview: {
    host: '192.168.1.57',
    port: 5173,
    strictPort: true,
    cors: true
  }
})
