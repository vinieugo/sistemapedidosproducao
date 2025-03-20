module.exports = {
  apps: [
    {
      name: "sistema-pedidos-frontend",
      script: "serve.cjs",
      cwd: "./",
      env: {
        NODE_ENV: "production",
        PORT: 3000
      },
      watch: false,
      instances: 1,
      exec_mode: "fork",
      max_memory_restart: "300M",
      node_args: "--max-old-space-size=300"
    },
    {
      name: "sistema-pedidos-backend",
      script: "./backend/src/server.js",
      cwd: "./",
      env: {
        NODE_ENV: "production",
      },
      watch: false,
      instances: "max",
      exec_mode: "cluster",
      max_memory_restart: "400M",
      node_args: "--max-old-space-size=400"
    }
  ]
}; 