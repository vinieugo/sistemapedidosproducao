import axios from 'axios';

const API_URL = 'http://192.168.5.3:8081/api';
console.log('API URL:', API_URL);

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
});

// Adiciona um interceptor para logar todas as requisições
api.interceptors.request.use(
  config => {
    console.log('Requisição:', {
      url: config.url,
      method: config.method,
      baseURL: config.baseURL,
      params: config.params
    });
    return config;
  },
  error => {
    console.error('Erro na requisição:', error);
    return Promise.reject(error);
  }
);

// Adiciona um interceptor para logar todas as respostas
api.interceptors.response.use(
  response => {
    console.log('Resposta:', {
      status: response.status,
      data: response.data
    });
    return response;
  },
  error => {
    console.error('Erro na resposta:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data
    });
    return Promise.reject(error);
  }
);

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