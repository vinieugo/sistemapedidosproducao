import axios from 'axios';

// URL da API
const API_URL = import.meta.env.VITE_API_URL || 'http://192.168.5.3:8081/api';
console.log('API URL configurada:', API_URL);

// Configuração do Axios
const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  },
  timeout: 10000 // 10 segundos
});

// Interceptor para requisições
api.interceptors.request.use(
  config => {
    console.log('Requisição sendo enviada:', {
      url: config.url,
      method: config.method,
      baseURL: config.baseURL,
      params: config.params,
      headers: config.headers
    });
    
    // Força a URL base a ser a correta em todo o caso
    config.baseURL = API_URL;
    
    return config;
  },
  error => {
    console.error('Erro na requisição:', error);
    return Promise.reject(error);
  }
);

// Interceptor para respostas
api.interceptors.response.use(
  response => {
    console.log('Resposta recebida:', {
      status: response.status,
      data: response.data,
      headers: response.headers
    });
    return response;
  },
  error => {
    console.error('Erro na resposta:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
      config: {
        url: error.config?.url,
        baseURL: error.config?.baseURL,
        method: error.config?.method
      }
    });
    return Promise.reject(error);
  }
);

// Função para testar a conexão com a API
const testConnection = async () => {
  try {
    console.log('Testando conexão com a API...');
    const response = await api.get('/');
    console.log('Conexão com a API estabelecida:', response.data);
    return true;
  } catch (error) {
    console.error('Erro ao testar conexão com a API:', error);
    return false;
  }
};

// Testa a conexão ao iniciar
testConnection();

export const getPedidos = async (page = 1, status = null, dataInicial = null, dataFinal = null) => {
  // Garantir que as datas sejam enviadas no formato ISO para preservar o fuso horário
  const formattedDataInicial = dataInicial instanceof Date ? dataInicial.toISOString() : dataInicial;
  const formattedDataFinal = dataFinal instanceof Date ? dataFinal.toISOString() : dataFinal;
  
  const params = { 
    page,
    ...(Array.isArray(status) ? { status: status.join(',') } : status ? { status } : {}),
    ...(formattedDataInicial && { dataInicial: formattedDataInicial }),
    ...(formattedDataFinal && { dataFinal: formattedDataFinal })
  };
  
  console.log('Enviando parâmetros para API:', params);
  const response = await api.get('/pedidos', { params });
  return response.data;
};

export const criarPedido = async (pedido) => {
  // Validar e formatar os dados antes de enviar
  const pedidoFormatado = {
    ...pedido,
    quantidade: Number(pedido.quantidade) || 0,
    // Garantir que o fornecedor não seja undefined
    fornecedor: pedido.fornecedor || '',
    // Garantir que o motivo não seja undefined
    motivo: pedido.motivo || ''
  };
  
  console.log('Enviando pedido para criação:', pedidoFormatado);
  const response = await api.post('/pedidos', pedidoFormatado);
  return response.data;
};

export const atualizarPedido = async (id, pedido) => {
  const response = await api.put(`/pedidos/${id}`, pedido);
  return response.data;
};

export const deletarPedido = async (id) => {
  await api.delete(`/pedidos/${id}`);
};

export const getConfiguracoes = async () => {
  const response = await api.get('/configuracoes');
  return response.data;
};

export const atualizarConfiguracoes = async (config) => {
  const response = await api.put('/configuracoes', config);
  return response.data;
};

export const arquivarPedidosAntigos = async () => {
  const response = await api.post('/arquivar-pedidos');
  return response.data;
}; 