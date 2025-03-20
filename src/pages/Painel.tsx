                  import React, { useState } from 'react';

interface Pedido {
  id: number;
  nomeItem: string;
  quantidade: number;
  dataPreenchimento: string;
  dataSolicitacao: string;
  dataBaixa?: string;
  solicitante: string;
}

const Painel: React.FC = () => {
  const [pedidos, setPedidos] = useState<Pedido[]>([]);
  const [form, setForm] = useState({
    nomeItem: '',
    quantidade: 0,
    dataPreenchimento: new Date().toISOString().split('T')[0],
    dataSolicitacao: '',
    solicitante: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const novoPedido: Pedido = {
      id: pedidos.length + 1,
      ...form,
      quantidade: Number(form.quantidade),
    };
    setPedidos([...pedidos, novoPedido]);
    setForm({
      nomeItem: '',
      quantidade: 0,
      dataPreenchimento: new Date().toISOString().split('T')[0],
      dataSolicitacao: '',
      solicitante: '',
    });
  };

  return (
    <div>
      <h2>Painel de Pedidos</h2>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          name="nomeItem"
          placeholder="Nome do Item"
          value={form.nomeItem}
          onChange={handleChange}
          required
        />
        <input
          type="number"
          name="quantidade"
          placeholder="Quantidade"
          value={form.quantidade}
          onChange={handleChange}
          required
        />
        <input
          type="date"
          name="dataPreenchimento"
          value={form.dataPreenchimento}
          onChange={handleChange}
          required
        />
        <input
          type="date"
          name="dataSolicitacao"
          value={form.dataSolicitacao}
          onChange={handleChange}
          required
        />
        <input
          type="text"
          name="solicitante"
          placeholder="Solicitante"
          value={form.solicitante}
          onChange={handleChange}
          required
        />
        <button type="submit">Adicionar Pedido</button>
      </form>

      <h3>Lista de Pedidos</h3>
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Nome do Item</th>
            <th>Quantidade</th>
            <th>Data Preenchimento</th>
            <th>Data Solicitação</th>
            <th>Solicitante</th>
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
              <td>{pedido.solicitante}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};
  
          export default Painel;