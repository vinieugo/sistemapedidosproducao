module.exports = {
  apps: [
    {
      name: 'sistema-pedidos-frontend',
      script: 'npm',
      args: 'run build && npm run preview',
      cwd: '.',
      env: {
        NODE_ENV: 'production',
        HOST: '192.168.5.3',
        PORT: 5173,
        DEBUG: 'vite:*',
        VITE_API_URL: 'http://192.168.5.3:8081/api'
      },
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
      log_type: 'json',
      error_file: 'logs/frontend-error.log',
      out_file: 'logs/frontend-out.log',
      max_restarts: 10,
      min_uptime: '10s',
      watch: false,
      autorestart: true,
      exp_backoff_restart_delay: 100,
      wait_ready: false,
      listen_timeout: 30000,
      kill_timeout: 5000,
      max_memory_restart: '1G',
      env_production: {
        NODE_ENV: 'production'
      }
    },
    {
      name: 'sistema-pedidos-backend',
      script: 'node',
      args: 'src/server.js',
      cwd: './backend',
      env: {
        NODE_ENV: 'production',
        HOST: '192.168.5.3',
        PORT: 8081,
        DEBUG: 'prisma:*,express:*',
        LOG_LEVEL: 'debug',
        DATABASE_URL: 'mysql://root:root@192.168.5.3:3307/sistema_pedidos',
        CORS_ORIGIN: '*'
      },
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
      log_type: 'json',
      error_file: '../logs/backend-error.log',
      out_file: '../logs/backend-out.log',
      max_restarts: 10,
      min_uptime: '10s',
      watch: false,
      autorestart: true,
      wait_ready: false,
      listen_timeout: 30000,
      kill_timeout: 5000,
      max_memory_restart: '1G',
      exp_backoff_restart_delay: 100,
      env_production: {
        NODE_ENV: 'production'
      }
    }
  ]
}; 