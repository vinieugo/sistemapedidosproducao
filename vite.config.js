import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  return {
    plugins: [react()],
    server: {
      host: '0.0.0.0',
      port: 5173,
      strictPort: true,
      cors: true
    },
    preview: {
      host: '0.0.0.0',
      port: 5173,
      strictPort: true,
      cors: true
    },
    define: {
      'process.env.VITE_API_URL': JSON.stringify(env.VITE_API_URL || 'http://192.168.5.3:8081/api')
    }
  }
})
