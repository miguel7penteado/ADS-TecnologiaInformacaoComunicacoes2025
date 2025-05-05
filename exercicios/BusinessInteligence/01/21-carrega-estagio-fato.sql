-- define o schema padrão para a sessão atual (opcional, mas recomendado se não conectar diretamente ao schema)
-- set search_path to "comercio-oltp";

-- remove a view existente, se houver
drop view if exists "comercio-oltp".relatorio_vendas;

-- cria a view relatorio_vendas no schema comercio-oltp
create view "comercio-oltp".relatorio_vendas as
select
    c.idcliente as idcliente,
    v.idvendedor as idvendedor,
    p.idproduto as idproduto,
    fo.idfornecedor as idfornecedor,
    n.idnota as idnota,
    n.id_forma as idforma, -- corrigido para pegar da nota_fiscal
    i.quantidade as quantidade,
    (i.quantidade * p.custo_medio) as custo_total,
    (i.total - (i.quantidade * p.custo_medio)) as lucro_total,
    i.total as total_item,
    n.data as data
from
    "comercio-oltp".nota_fiscal n -- qualificado com schema
inner join
    "comercio-oltp".item_nota i on (n.idnota = i.id_nota_fiscal) -- qualificado com schema
inner join
    "comercio-oltp".cliente c on (c.idcliente = n.id_cliente) -- qualificado com schema
inner join
    "comercio-oltp".vendedor v on (v.idvendedor = n.id_vendedor) -- qualificado com schema
inner join
    "comercio-oltp".produto p on (p.idproduto = i.id_produto) -- qualificado com schema e condição de join corrigida para item_nota
inner join
    "comercio-oltp".forma_pagamento f on (f.idforma = n.id_forma) -- qualificado com schema
inner join
    "comercio-oltp".fornecedor fo on (fo.idfornecedor = p.id_fornecedor); -- qualificado com schema

-- seleciona dados da view recém-criada (exemplo)
select * from "comercio-oltp".relatorio_vendas
order by idnota;
