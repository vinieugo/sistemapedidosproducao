module.exports = {
  apps: [
    {
      name: 'sistema-pedidos-frontend',
      script: 'node',
      args: 'node_modules/vite/bin/vite.js preview',
      cwd: './frontend',
      env: {
        NODE_ENV: 'production',
        HOST: '192.168.5.3',
        PORT: 5173,
        DEBUG: '*'
      },
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
      log_type: 'json',
      error_file: './logs/frontend-error.log',
      out_file: './logs/frontend-out.log',
      max_restarts: 5,
      min_uptime: '5s',
      watch: false,
      autorestart: true,
      exp_backoff_restart_delay: 100
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
        DEBUG: 'prisma:*',
        LOG_LEVEL: 'debug',
        DATABASE_URL: 'mysql://root:@192.168.5.3:3307/sistema_pedidos',
        CORS_ORIGIN: '*'
      },
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
      log_type: 'json',
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      max_restarts: 10,
      min_uptime: '10s',
      watch: false,
      autorestart: true,
      exp_backoff_restart_delay: 100,
      wait_ready: true,
      listen_timeout: 30000,
      kill_timeout: 5000,
      max_memory_restart: '1G',
      env_production: {
        NODE_ENV: 'production'
      }
    }
  ]
}; 