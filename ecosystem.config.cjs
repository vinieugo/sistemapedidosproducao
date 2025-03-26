module.exports = {
  apps: [
    {
      name: 'sistema-pedidos-frontend',
      cwd: '.',
      script: 'npm',
      args: 'run preview',
      env: {
        NODE_ENV: 'production',
        HOST: '192.168.5.3',
        PORT: 5173,
        DEBUG: 'false'
      },
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
      log_type: 'json',
      error_file: 'logs/frontend-error.log',
      out_file: 'logs/frontend-out.log',
      max_restarts: 10,
      min_uptime: '5s',
      watch: false,
      autorestart: true
    },
    {
      name: 'sistema-pedidos-backend',
      cwd: './backend',
      script: 'src/server.js',
      env: {
        NODE_ENV: 'production',
        HOST: '192.168.5.3',
        PORT: 8081,
        DEBUG: 'prisma:*',
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
      min_uptime: '5s',
      watch: false,
      autorestart: true,
      wait_ready: false,
      listen_timeout: 10000,
      kill_timeout: 5000,
      max_memory_restart: '1G'
    }
  ]
}; 