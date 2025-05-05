-- substitua '"comercio-olap".' e '"stage".' pelos nomes reais dos seus schemas no postgresql.
-- se as tabelas estiverem no schema 'public', remova os prefixos.

-- cria ou substitui a view para análise por fornecedor e ano
-- raise notice 'criando/substituindo a view v_analise_fornecedor...';
create or replace view "comercio-olap".v_analise_fornecedor as -- qualificado com schema 'dw'
select
    fn.nome as fornecedor,
    t.ano as ano,
    sum(f.quantidade) as quantidade,
    sum(f.total_item) as total_vendido
from
    "stage".st_fato f -- qualificado com schema 'stage'
inner join
    "comercio-olap".dim_fornecedor fn on f.idfornecedor = fn.idfornecedor -- qualificado com schema 'dw'
inner join
    "comercio-olap".dim_tempo t on t.data = f.data -- qualificado com schema 'dw'. comparação direta de datas.
group by
    fn.nome,
    t.ano;
-- raise notice 'view v_analise_fornecedor criada/substituída.';

-- consulta para obter anos distintos da tabela fato (via dim_tempo)
-- raise notice 'consultando anos distintos...';
select distinct t.ano
from "comercio-olap".dim_tempo t -- qualificado com schema 'dw'
inner join "comercio-olap".fato fa on t.idsk = fa.idtempo -- qualificado com schema 'dw'
order by t.ano;

-- consulta na view v_analise_fornecedor filtrando por ano
-- no postgresql, o filtro seria aplicado usando where diretamente,
-- passando o valor do ano como parâmetro em uma aplicação ou função.
-- raise notice 'consultando v_analise_fornecedor por ano (exemplo com valor fixo)...';
select fornecedor, ano, quantidade, total_vendido
from "comercio-olap".v_analise_fornecedor -- qualificado com schema 'dw'
where ano = 2016 -- exemplo: substitua 2016 pelo valor desejado (@ano)
order by fornecedor;

-- consulta na view v_analise_fornecedor filtrando por múltiplos anos
-- similarmente, os valores seriam passados como parâmetros.
-- raise notice 'consultando v_analise_fornecedor por múltiplos anos (exemplo com valores fixos)...';
select fornecedor, ano, quantidade, total_vendido
from "comercio-olap".v_analise_fornecedor -- qualificado com schema 'dw'
where ano in (2015, 2017) -- exemplo: substitua (2015, 2017) pelos valores desejados (@ano)
order by fornecedor;

-- consulta para obter produtos e categorias por fornecedor
-- o valor do fornecedor seria passado como parâmetro.
-- raise notice 'consultando produtos/categorias por fornecedor (exemplo com valor fixo)...';
select distinct
    p.nome as produto,
    c.nome as categoria
from
    "comercio-olap".dim_produto p -- qualificado com schema 'dw'
inner join
    "comercio-olap".fato fa on p.idsk = fa.idproduto -- qualificado com schema 'dw'
inner join
    "comercio-olap".dim_fornecedor f on f.idsk = fa.idfornecedor -- qualificado com schema 'dw'
inner join
    "comercio-olap".categoria c on p.id_categoria = c.idcategoria -- qualificado com schema 'dw'. join corrigido. assumindo que dim_produto tem id_categoria e categoria tem idcategoria.
where
    f.nome = 'nome do fornecedor exemplo'; -- exemplo: substitua pelo valor desejado (@fornecedor)
