
delete from "estagio".st_categoria;
INSERT INTO "estagio".st_categoria( idcategoria, nome) SELECT idcategoria, nome FROM "comercio-oltp".categoria;

delete from "estagio".st_cliente;
INSERT INTO estagio.st_cliente( idcliente, nome, email, sexo, nascimento, cidade, estado, regiao) 
( SELECT c.idcliente, concat(c.nome,' ' ,c.sobrenome) as nome, c.email, c.sexo, c.nascimento, e.cidade, e.estado, e.regiao FROM "comercio-oltp".cliente c
    inner join "comercio-oltp".endereco e on (c.idcliente = e.id_cliente) order by c.idcliente );

delete from "estagio".st_forma;
INSERT INTO estagio.st_forma( idforma, forma) SELECT idforma, forma 	FROM "comercio-oltp".forma_pagamento;

delete from "estagio".st_fornecedor;
INSERT INTO "estagio".st_fornecedor( idfornecedor, nome) ( SELECT idfornecedor, nome FROM "comercio-oltp".fornecedor );

delete from "estagio".st_nota;
INSERT INTO "estagio".st_nota( idnota) SELECT idnota FROM "comercio-oltp".nota_fiscal;

delete from "estagio".st_produto;
INSERT INTO "estagio".st_produto( idproduto, nome, valor_unitario, custo_medio, id_categoria) SELECT idproduto, produto, valor, custo_medio, id_categoria FROM "comercio-oltp".produto;

delete from "estagio".st_vendedor;
INSERT INTO "estagio".st_vendedor( idvendedor, nome, sexo, idgerente) SELECT idvendedor, nome, sexo, id_gerente FROM "comercio-oltp".vendedor;




-- define o schema padrão para a sessão atual (opcional, mas recomendado)
set search_path to "comercio-oltp";

-- remove a view existente, se houver (alternativa ao create or replace)
drop view if exists "comercio-oltp".relatorio_vendas;

-- cria ou substitui a view relatorio_vendas no schema comercio-oltp
create or replace view "comercio-oltp".relatorio_vendas as
select
    c.idcliente as idcliente,
    v.idvendedor as idvendedor,
    p.idproduto as idproduto,
    fo.idfornecedor as idfornecedor,
    n.idnota as idnota,
    n.id_forma as idforma, -- corrigido: coluna vem da tabela nota_fiscal (n)
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
    "comercio-oltp".produto p on (p.idproduto = i.id_produto) -- qualificado com schema e join corrigido para item_nota (i)
inner join
    "comercio-oltp".forma_pagamento f on (f.idforma = n.id_forma) -- qualificado com schema
inner join
    "comercio-oltp".fornecedor fo on (fo.idfornecedor = p.id_fornecedor); -- qualificado com schema

-- exemplo de consulta na view recém-criada
select * from "comercio-oltp".relatorio_vendas
order by idnota
limit 100; -- adicionado limit para exemplo

delete from "estagio".st_fato;

INSERT INTO "estagio".st_fato(
	idcliente, idvendedor, idproduto, idfornecedor, idnota, idforma, quantidade, total_item, data, custo_total, lucro_total)
	SELECT idcliente, idvendedor, idproduto, idfornecedor, idnota, idforma, quantidade, total_item, data, custo_total, lucro_total
	FROM "comercio-oltp".relatorio_vendas order by data ;
