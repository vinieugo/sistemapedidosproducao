module.exports = {
  apps: [
    {
      name: 'sistema-pedidos-frontend',
      script: 'node',
      args: 'node_modules/vite/bin/vite.js preview',
      cwd: './',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 5173,
        HOST: '192.168.5.3',
        NODE_TLS_REJECT_UNAUTHORIZED: '0',
        DEBUG: '*'
      },
      error_file: './logs/frontend-error.log',
      out_file: './logs/frontend-out.log',
      time: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
      log_type: 'json'
    },
    {
      name: 'sistema-pedidos-backend',
      script: 'node',
      args: 'src/index.js',
      cwd: './backend',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 8081,
        HOST: '192.168.5.3',
        NODE_TLS_REJECT_UNAUTHORIZED: '0',
        DEBUG: '*'
      },
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      time: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
      log_type: 'json'
    }
  ]
}; 