module.exports = {
  apps: [
    {
      name: 'sistema-pedidos-frontend',
      script: 'npm',
      args: 'run preview -- --host 0.0.0.0',
      cwd: './',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
      }
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
        HOST: '0.0.0.0'
      }
    }
  ]
}; 