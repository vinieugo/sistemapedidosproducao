module.exports = {
  apps: [
    {
      name: 'sistema-pedidos-frontend',
      script: 'npm',
      args: 'run preview',
      cwd: './',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 5173,
        HOST: '0.0.0.0',
        NODE_TLS_REJECT_UNAUTHORIZED: '0'
      },
      error_file: './logs/frontend-error.log',
      out_file: './logs/frontend-out.log',
      time: true
    },
    {
      name: 'sistema-pedidos-backend',
      script: 'npm',
      args: 'run start',
      cwd: './backend',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 8081,
        HOST: '0.0.0.0',
        NODE_TLS_REJECT_UNAUTHORIZED: '0'
      },
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      time: true
    }
  ]
}; 