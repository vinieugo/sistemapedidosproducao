const express = require('express');
const path = require('path');
const compression = require('compression');
const app = express();
const PORT = 3000;

// Usar compressão para reduzir o tamanho das respostas
app.use(compression());

// Configurar cache para arquivos estáticos
const oneMonth = 30 * 24 * 60 * 60 * 1000; // 30 dias em milissegundos
app.use(express.static(path.join(__dirname, 'dist'), {
  maxAge: oneMonth,
  etag: true,
  lastModified: true
}));

// Rota para qualquer outra requisição
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

// Iniciar o servidor
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor frontend rodando em http://0.0.0.0:${PORT}`);
}); 