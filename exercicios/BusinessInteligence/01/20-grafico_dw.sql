
-- substitua '"comercio-olap".' pelo nome real do seu schema no postgresql, se diferente.
-- se as tabelas estiverem no schema 'public', remova o prefixo '"comercio-olap".'.

select
    c.regiao,          -- coluna regiao da dim_cliente
    t.ano,             -- coluna ano da dim_tempo
    sum(f.lucro_total) as lucro, -- soma do lucro_total da fato
    sum(f.quantidade) as qtd,    -- soma da quantidade da fato
    sum(f.total_item) as total,  -- soma do total_item da fato
    sum(f.custo_total) as custo  -- soma do custo_total da fato
from
    "comercio-olap".dim_cliente c    -- tabela dim_cliente com alias c
inner join
    "comercio-olap".fato f on c.idsk = f.idcliente -- join com fato usando a chave do cliente
inner join
    "comercio-olap".dim_tempo t on t.idsk = f.idtempo -- join com dim_tempo usando a chave de tempo
group by
    c.regiao,          -- agrupa pela regiao do cliente
    t.ano              -- agrupa pelo ano do tempo
order by
    1, 2;              -- ordena pela primeira coluna (regiao) e depois pela segunda (ano)
