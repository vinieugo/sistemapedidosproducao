import React from 'react';
import { Pedido } from './Painel';

interface HistoricoProps {
  pedidos: Pedido[];
  setPedidos: React.Dispatch<React.SetStateAction<Pedido[]>>;
}

const Historico: React.FC<HistoricoProps> = ({ pedidos, setPedidos }) => {
  const darBaixa = (id: number) => {
    const updatedPedidos = pedidos.map((pedido) =>
      pedido.id === id
        ? { ...pedido, dataBaixa: new Date().toISOString().split('T')[0] }
        : pedido
    );
    setPedidos(updatedPedidos);
  };

  const pedidosBaixados = pedidos.filter((pedido) => pedido.dataBaixa);

  return (
    <div>
      <h2>Histórico de Pedidos Baixados</h2>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Nome do Item</th>
            <th>Quantidade</th>
            <th>Data Preenchimento</th>
            <th>Data Solicitação</th>
            <th>Data Baixa</th>
            <th>Solicitante</th>
            <th>Ação</th>
          </tr>
        </thead>
        <tbody>
          {pedidos.map((pedido) => (
            <tr key={pedido.id}>
              <td>{pedido.id}</td>
              <td>{pedido.nomeItem}</td>
              <td>{pedido.quantidade}</td>
              <td>{pedido.dataPreenchimento}</td>
              <td>{pedido.dataSolicitacao}</td>
              <td>{pedido.dataBaixa || 'Pendente'}</td>
              <td>{pedido.solicitante}</td>
              <td>
                {!pedido.dataBaixa && (
                  <button onClick={() => darBaixa(pedido.id)}>Dar Baixa</button>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default Historico;