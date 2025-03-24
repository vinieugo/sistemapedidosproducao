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
        HOST: 'localhost'
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
        HOST: 'localhost'
      }
    }
  ]
}; 