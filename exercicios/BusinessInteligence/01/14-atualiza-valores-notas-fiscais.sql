-- set search_path to "comercio-oltp";

-- cria a view para calcular a soma total por nota fiscal
-- raise notice 'criando/substituindo a view v_nota_fiscal...';

create or replace view "comercio-oltp".v_nota_fiscal as
select
    id_nota_fiscal,
    sum(total) as soma
from
    "comercio-oltp".item_nota -- qualificado com schema
group by
    id_nota_fiscal;
-- raise notice 'view v_nota_fiscal criada/substituída.';

-- exemplo de consulta na view v_nota_fiscal
-- raise notice 'consultando v_nota_fiscal para id_nota_fiscal = 1000...';
select * from "comercio-oltp".v_nota_fiscal
where id_nota_fiscal = 1000;

-- cria a view para juntar nota_fiscal com a soma dos itens (v_nota_fiscal)
-- raise notice 'criando/substituindo a view v_carga_nf...';
create or replace view "comercio-oltp".v_carga_nf as
select
    n.idnota,
    n.total as totalnota, -- coluna total da tabela nota_fiscal
    i.soma -- coluna soma calculada pela view v_nota_fiscal
from
    "comercio-oltp".nota_fiscal n -- qualificado com schema
inner join
    "comercio-oltp".v_nota_fiscal i on n.idnota = i.id_nota_fiscal; -- qualificado com schema
-- raise notice 'view v_carga_nf criada/substituída.';

-- exemplo de consulta na view v_carga_nf
-- raise notice 'consultando v_carga_nf...';
select * from "comercio-oltp".v_carga_nf limit 100;

-- atualiza a tabela nota_fiscal diretamente
-- views com agregações não são diretamente atualizáveis no postgresql.
-- atualizamos a tabela base nota_fiscal usando a lógica da view v_nota_fiscal.
-- raise notice 'atualizando a coluna total na tabela nota_fiscal com base na soma dos itens...';
update "comercio-oltp".nota_fiscal n
set total = sub.soma -- define n.total como a soma calculada
from (
    -- subconsulta para calcular a soma por nota (lógica de v_nota_fiscal)
    select id_nota_fiscal, sum(total) as soma
    from "comercio-oltp".item_nota
    group by id_nota_fiscal
) as sub
where n.idnota = sub.id_nota_fiscal; -- condição para ligar a nota fiscal à sua soma
-- raise notice 'coluna total em nota_fiscal atualizada.';

-- verifica o resultado da atualização (opcional)
-- raise notice 'verificando alguns totais atualizados em nota_fiscal...';
select n.idnota, n.total as total_atualizado_nf, vnf.soma as soma_itens_view
from "comercio-oltp".nota_fiscal n
join "comercio-oltp".v_nota_fiscal vnf on n.idnota = vnf.id_nota_fiscal
where n.total != vnf.soma -- verifica se há alguma diferença (não deveria haver após o update)
limit 10;

select n.idnota, n.total as total_atualizado_nf, vnf.soma as soma_itens_view
from "comercio-oltp".nota_fiscal n
join "comercio-oltp".v_nota_fiscal vnf on n.idnota = vnf.id_nota_fiscal
order by n.idnota
limit 10;


-- criando uma view para o relatório oltp
-- raise notice 'criando/substituindo a view v_relatorio_oltp...';
create or replace view "comercio-oltp".v_relatorio_oltp as
select
    c.nome,
    c.sobrenome as "cliente",
    -- c.sexo, -- coluna sexo não existe na tabela cliente conforme ddl anterior. descomente se existir.
    n.data,
    n.idnota,
    p.produto,
    n.total -- agora este total deve refletir a soma dos itens após o update
from
    "comercio-oltp".cliente c
inner join
    "comercio-oltp".nota_fiscal n on c.idcliente = n.id_cliente
inner join
    "comercio-oltp".item_nota i on n.idnota = i.id_nota_fiscal
inner join
    "comercio-oltp".produto p on p.idproduto = i.id_produto;
-- raise notice 'view v_relatorio_oltp criada/substituída.';

-- exemplo de consulta na view v_relatorio_oltp
-- raise notice 'consultando v_relatorio_oltp...';
select * from "comercio-oltp".v_relatorio_oltp
order by idnota
limit 100;
