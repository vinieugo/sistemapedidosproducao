import React, { useState, useEffect } from 'react';
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs';
import 'react-tabs/style/react-tabs.css';
import './App.css';
import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import Modal from 'react-modal';
import { jsPDF } from 'jspdf';
import autoTable from 'jspdf-autotable';
import { 
  getPedidos, 
  criarPedido, 
  atualizarPedido, 
  deletarPedido,
  getConfiguracoes,
  arquivarPedidosAntigos
} from './services/api';

Modal.setAppElement('#root');

function App() {
  const [pedidosAtivos, setPedidosAtivos] = useState([]);
  const [historicoPedidos, setHistoricoPedidos] = useState([]);
  const [modalAberto, setModalAberto] = useState(false);
  const [modalRelatorioAberto, setModalRelatorioAberto] = useState(false);
  const [dataInicial, setDataInicial] = useState('');
  const [dataFinal, setDataFinal] = useState('');
  const [paginaAtual, setPaginaAtual] = useState(1);
  const [totalPaginas, setTotalPaginas] = useState(1);
  const [paginaHistorico, setPaginaHistorico] = useState(1);
  const [totalPaginasHistorico, setTotalPaginasHistorico] = useState(1);
  const [carregando, setCarregando] = useState(false);
  const [etapaAtual, setEtapaAtual] = useState(0);

  const [novoPedido, setNovoPedido] = useState({
    nomeItem: '',
    quantidade: '',
    solicitante: '',
    fornecedor: '',
    motivo: ''
  });

  const [dataInicialRelatorio, setDataInicialRelatorio] = useState('');
  const [dataFinalRelatorio, setDataFinalRelatorio] = useState('');

  const etapas = [
    { campo: 'nomeItem', label: 'Nome do Item', tipo: 'text' },
    { campo: 'quantidade', label: 'Quantidade', tipo: 'number' },
    { campo: 'solicitante', label: 'Solicitante', tipo: 'text' },
    { campo: 'fornecedor', label: 'Fornecedor', tipo: 'text' },
    { campo: 'motivo', label: 'Motivo', tipo: 'textarea' }
  ];

  useEffect(() => {
    carregarPedidos();
    carregarHistorico();
  }, [paginaAtual, paginaHistorico]);

  const carregarPedidos = async () => {
    try {
      setCarregando(true);
      const response = await getPedidos(paginaAtual, ['A Solicitar', 'Solicitado']);
      setPedidosAtivos(response.pedidos);
      setTotalPaginas(response.pages);
    } catch (error) {
      console.error('Erro ao carregar pedidos:', error);
    } finally {
      setCarregando(false);
    }
  };

  const carregarHistorico = async () => {
    try {
      setCarregando(true);
      const response = await getPedidos(paginaHistorico, 'Baixado', dataInicial, dataFinal);
      setHistoricoPedidos(response.pedidos);
      setTotalPaginasHistorico(response.pages);
    } catch (error) {
      console.error('Erro ao carregar histórico:', error);
    } finally {
      setCarregando(false);
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      if (etapaAtual < etapas.length - 1) {
        setEtapaAtual(etapaAtual + 1);
      } else {
        handleSubmit(e);
      }
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await criarPedido(novoPedido);
      setModalAberto(false);
      setNovoPedido({
        nomeItem: '',
        quantidade: '',
        solicitante: '',
        fornecedor: '',
        motivo: ''
      });
      setEtapaAtual(0);
      carregarPedidos();
    } catch (error) {
      console.error('Erro ao criar pedido:', error);
    }
  };

  const handleSolicitar = async (pedido) => {
    try {
      await atualizarPedido(pedido.id, {
        ...pedido,
        status: 'Solicitado',
        dataSolicitacao: new Date()
      });
      carregarPedidos();
    } catch (error) {
      console.error('Erro ao solicitar pedido:', error);
    }
  };

  const handleBaixar = async (pedido) => {
    try {
      await atualizarPedido(pedido.id, {
        ...pedido,
        status: 'Baixado',
        dataBaixa: new Date()
      });
      carregarPedidos();
      carregarHistorico();
    } catch (error) {
      console.error('Erro ao baixar pedido:', error);
    }
  };

  const handleDeletar = async (id) => {
    try {
      await deletarPedido(id);
      carregarPedidos();
      carregarHistorico();
    } catch (error) {
      console.error('Erro ao deletar pedido:', error);
    }
  };

  const formatarData = (data) => {
    if (!data) return '-';
    try {
      return format(new Date(data), 'dd/MM/yyyy HH:mm', { locale: ptBR });
    } catch (error) {
      console.error('Erro ao formatar data:', error);
      return '-';
    }
  };

  // Função para renderizar a célula de data com animação "Aguardando" quando vazia
  const renderizarDataSolicitacao = (data) => {
    if (!data) {
      return <span className="status-aguardando">Aguardando</span>;
    }
    return formatarData(data);
  };

  const gerarRelatorio = async () => {
    try {
      let dataInicioAjustada = null;
      let dataFimAjustada = null;
      
      if (dataInicialRelatorio) {
        const partes = dataInicialRelatorio.split('-');
        dataInicioAjustada = new Date(Date.UTC(partes[0], partes[1] - 1, partes[2], 0, 0, 0));
      }
      
      if (dataFinalRelatorio) {
        const partes = dataFinalRelatorio.split('-');
        dataFimAjustada = new Date(Date.UTC(partes[0], partes[1] - 1, partes[2], 23, 59, 59, 999));
      }
      
      console.log('Datas ajustadas para relatório:', {
        original: { dataInicialRelatorio, dataFinalRelatorio },
        ajustada: { 
          inicio: dataInicioAjustada ? dataInicioAjustada.toISOString() : null,
          fim: dataFimAjustada ? dataFimAjustada.toISOString() : null
        }
      });
      
      const response = await getPedidos(1, 'Baixado', dataInicioAjustada, dataFimAjustada);
      const pedidos = response.pedidos;

      const doc = new jsPDF();
      
      doc.setFontSize(16);
      doc.text('Relatório de Pedidos Baixados', 14, 20);
      doc.setFontSize(10);
      doc.text(`Gerado em: ${format(new Date(), 'dd/MM/yyyy HH:mm', { locale: ptBR })}`, 14, 30);

      if (dataInicialRelatorio && dataFinalRelatorio) {
        doc.text(`Período: ${format(new Date(dataInicialRelatorio), 'dd/MM/yyyy')} até ${format(new Date(dataFinalRelatorio), 'dd/MM/yyyy')}`, 14, 35);
      }

      const limitarTexto = (texto, limite) => {
        if (!texto) return '-';
        return texto.length > limite ? texto.substring(0, limite) + '...' : texto;
      };

      const tableData = pedidos.map(pedido => {
        return [
          pedido.id || '-',
          limitarTexto(pedido.nomeItem, 30),
          pedido.quantidade || '-',
          limitarTexto(pedido.fornecedor, 20),
          limitarTexto(pedido.solicitante, 20),
          pedido.dataPreenchimento ? format(new Date(pedido.dataPreenchimento), 'dd/MM/yyyy HH:mm', { locale: ptBR }) : '-',
          pedido.dataSolicitacao ? format(new Date(pedido.dataSolicitacao), 'dd/MM/yyyy HH:mm', { locale: ptBR }) : '-',
          pedido.dataBaixa ? format(new Date(pedido.dataBaixa), 'dd/MM/yyyy HH:mm', { locale: ptBR }) : '-'
        ];
      });

      autoTable(doc, {
        startY: dataInicialRelatorio && dataFinalRelatorio ? 40 : 35,
        head: [['ID', 'Item', 'QTD', 'Fornecedor', 'Solicitante', 'Data Reg.', 'Data Solic.', 'Data Baixa']],
        body: tableData,
        theme: 'grid',
        styles: { 
          fontSize: 7,
          cellPadding: 2,
          overflow: 'linebreak',
          cellWidth: 'wrap',
          halign: 'center'
        },
        columnStyles: {
          0: { cellWidth: 10 },
          1: { cellWidth: 35 },
          2: { cellWidth: 10 },
          3: { cellWidth: 25 },
          4: { cellWidth: 25 },
          5: { cellWidth: 25 },
          6: { cellWidth: 25 },
          7: { cellWidth: 25 }
        },
        headStyles: { 
          fillColor: [33, 150, 243],
          fontSize: 7,
          halign: 'center'
        },
        alternateRowStyles: { fillColor: [245, 245, 245] },
        margin: { left: 10, right: 10 }
      });

      doc.save('relatorio-pedidos-baixados.pdf');
      
      setModalRelatorioAberto(false);
      setDataInicialRelatorio('');
      setDataFinalRelatorio('');
    } catch (error) {
      console.error('Erro ao gerar relatório:', error);
    }
  };

  const renderPaginacao = (pagina, totalPaginas, setPagina) => {
    return (
      <div className="pagination">
        {Array.from({ length: totalPaginas }, (_, i) => i + 1).map((num) => (
          <button
            key={num}
            className={`pagination-button ${num === pagina ? 'active' : ''}`}
            onClick={() => setPagina(num)}
          >
            {num}
          </button>
        ))}
      </div>
    );
  };

  return (
    <div className="App">
      <div className="container">
        <h1>Sistema de Pedidos</h1>
        <Tabs>
          <TabList>
            <Tab>Pedidos Ativos</Tab>
            <Tab>Histórico</Tab>
          </TabList>

          <TabPanel>
            <button className="new-button" onClick={() => setModalAberto(true)}>
              Novo Pedido
            </button>
            
            <div className="table-container">
              <table>
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Item</th>
                    <th>QTD</th>
                    <th>Fornecedor</th>
                    <th>Solicitante</th>
                    <th>Motivo</th>
                    <th>Data Reg.</th>
                    <th>Data Solic.</th>
                    <th>Ações</th>
                  </tr>
                </thead>
                <tbody>
                  {pedidosAtivos.map((pedido) => (
                    <tr key={pedido.id}>
                      <td>{pedido.id}</td>
                      <td title={pedido.nomeItem}>{pedido.nomeItem}</td>
                      <td>{pedido.quantidade}</td>
                      <td title={pedido.fornecedor}>{pedido.fornecedor}</td>
                      <td title={pedido.solicitante}>{pedido.solicitante}</td>
                      <td title={pedido.motivo}>{pedido.motivo}</td>
                      <td>{formatarData(pedido.dataPreenchimento)}</td>
                      <td>{renderizarDataSolicitacao(pedido.dataSolicitacao)}</td>
                      <td>
                        <div className="action-buttons">
                          {pedido.status === 'A Solicitar' && (
                            <button className="action-button orange" onClick={() => handleSolicitar(pedido)}>
                              Solicitar
                            </button>
                          )}
                          {pedido.status === 'Solicitado' && (
                            <button className="action-button green" onClick={() => handleBaixar(pedido)}>
                              Baixar
                            </button>
                          )}
                          <button className="delete-button" onClick={() => handleDeletar(pedido.id)}>
                            ×
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            {renderPaginacao(paginaAtual, totalPaginas, setPaginaAtual)}
          </TabPanel>

          <TabPanel>
            <div className="report-controls">
              <button onClick={() => setModalRelatorioAberto(true)}>
                <span className="pdf-text">PDF</span>
              </button>
            </div>

            <div className="table-container">
              <table>
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Item</th>
                    <th>Quantidade</th>
                    <th>Solicitante</th>
                    <th>Fornecedor</th>
                    <th>Motivo</th>
                    <th>Data Preenchimento</th>
                    <th>Data Solicitação</th>
                    <th>Data Baixa</th>
                  </tr>
                </thead>
                <tbody>
                  {historicoPedidos.map((pedido) => (
                    <tr key={pedido.id}>
                      <td>{pedido.id}</td>
                      <td title={pedido.nomeItem}>{pedido.nomeItem}</td>
                      <td>{pedido.quantidade}</td>
                      <td title={pedido.solicitante}>{pedido.solicitante}</td>
                      <td title={pedido.fornecedor}>{pedido.fornecedor}</td>
                      <td title={pedido.motivo}>{pedido.motivo}</td>
                      <td>{formatarData(pedido.dataPreenchimento)}</td>
                      <td>{renderizarDataSolicitacao(pedido.dataSolicitacao)}</td>
                      <td>{formatarData(pedido.dataBaixa)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            {renderPaginacao(paginaHistorico, totalPaginasHistorico, setPaginaHistorico)}
          </TabPanel>
        </Tabs>

        <Modal
          isOpen={modalAberto}
          onRequestClose={() => {
            setModalAberto(false);
            setEtapaAtual(0);
            setNovoPedido({
              nomeItem: '',
              quantidade: '',
              solicitante: '',
              fornecedor: '',
              motivo: ''
            });
          }}
          className="modal"
          overlayClassName="modal-overlay"
        >
          <h2>Novo Pedido</h2>
          <div className="form-progress">
            Etapa {etapaAtual + 1} de {etapas.length}
          </div>
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label>{etapas[etapaAtual].label}:</label>
              {etapas[etapaAtual].tipo === 'textarea' ? (
                <textarea
                  value={novoPedido[etapas[etapaAtual].campo]}
                onChange={(e) =>
                    setNovoPedido({
                      ...novoPedido,
                      [etapas[etapaAtual].campo]: e.target.value
                    })
                }
                  onKeyDown={handleKeyDown}
                  autoFocus
              />
              ) : (
              <input
                  type={etapas[etapaAtual].tipo}
                  value={novoPedido[etapas[etapaAtual].campo]}
                onChange={(e) =>
                    setNovoPedido({
                      ...novoPedido,
                      [etapas[etapaAtual].campo]: etapas[etapaAtual].tipo === 'number' 
                        ? Number(e.target.value) 
                        : e.target.value
                    })
                  }
                  onKeyDown={handleKeyDown}
                  autoFocus
                  required={etapas[etapaAtual].campo !== 'motivo'}
                />
              )}
            </div>
            <div className="modal-buttons">
              {etapaAtual > 0 && (
                <button
                  type="button"
                  onClick={() => setEtapaAtual(etapaAtual - 1)}
                >
                  Anterior
                </button>
              )}
              {etapaAtual < etapas.length - 1 ? (
                <button
                  type="button"
                  onClick={() => setEtapaAtual(etapaAtual + 1)}
                  disabled={!novoPedido[etapas[etapaAtual].campo] && etapas[etapaAtual].campo !== 'motivo'}
                >
                  Próximo
                </button>
              ) : (
                <button
                  type="submit"
                  disabled={!novoPedido.nomeItem || !novoPedido.quantidade || !novoPedido.solicitante || !novoPedido.fornecedor}
                >
                  Salvar
                </button>
              )}
              <button
                type="button"
                onClick={() => {
                  setModalAberto(false);
                  setEtapaAtual(0);
                  setNovoPedido({
                    nomeItem: '',
                    quantidade: '',
                    solicitante: '',
                    fornecedor: '',
                    motivo: ''
                  });
                }}
              >
                Cancelar
              </button>
            </div>
          </form>
        </Modal>

        <Modal
          isOpen={modalRelatorioAberto}
          onRequestClose={() => setModalRelatorioAberto(false)}
          className="modal"
          overlayClassName="modal-overlay"
        >
          <h2>Gerar Relatório</h2>
          <div className="form-group">
            <label>Data Inicial:</label>
            <input
              type="date"
              value={dataInicialRelatorio}
              onChange={(e) => setDataInicialRelatorio(e.target.value)}
            />
          </div>
          <div className="form-group">
            <label>Data Final:</label>
            <input
              type="date"
              value={dataFinalRelatorio}
              onChange={(e) => setDataFinalRelatorio(e.target.value)}
            />
          </div>
          <p>Selecione o período para gerar o relatório. Se nenhuma data for selecionada, todos os pedidos serão incluídos.</p>
          <div className="modal-buttons">
            <button onClick={gerarRelatorio}>Gerar PDF</button>
            <button onClick={() => {
              setModalRelatorioAberto(false);
              setDataInicialRelatorio('');
              setDataFinalRelatorio('');
            }}>
              Cancelar
            </button>
          </div>
        </Modal>
      </div>
    </div>
  );
}

export default App;
