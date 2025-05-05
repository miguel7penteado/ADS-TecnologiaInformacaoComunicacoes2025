-- define o schema padrão para a sessão atual (opcional, mas recomendado)
-- set search_path to "comercio-oltp";

-- trunca a tabela item_nota antes de inserir novos dados
-- raise notice 'truncando a tabela "comercio-oltp".item_nota...';
truncate table "comercio-oltp".item_nota restart identity; -- assume que iditemnota é identity e reinicia a sequência
-- raise notice 'tabela truncada e identidade reiniciada.';

-- bloco anônimo pl/pgsql para inserir 27000 itens aleatórios
do $$
declare
    v_id_produto int;
    v_id_nota_fiscal int;
    v_quantidade int;
    v_valor numeric(10,2);
    v_total numeric(10,2);
    v_record_count int := 0;
begin
    raise notice 'iniciando a inserção de 27000 registros em "comercio-oltp".item_nota...';

    -- loop para inserir 27000 registros
    for i in 1..27000 loop
        -- seleciona ids aleatórios de produto e nota_fiscal
        select idproduto into v_id_produto from "comercio-oltp".produto order by random() limit 1;
        select idnota into v_id_nota_fiscal from "comercio-oltp".nota_fiscal order by random() limit 1;

        -- gera quantidade aleatória entre 1 e 5
        v_quantidade := floor(random() * 4 + 1)::int;

        -- obtém o valor do produto selecionado
        select valor into v_valor from "comercio-oltp".produto where idproduto = v_id_produto;

        -- calcula o total do item
        v_total := v_quantidade * v_valor;

        -- insere na tabela item_nota, omitindo iditemnota (que é auto-gerado)
        -- assumindo que as colunas id_produto, id_nota_fiscal, quantidade, total existem
        insert into "comercio-oltp".item_nota (id_produto, id_nota_fiscal, quantidade, total)
        values (v_id_produto, v_id_nota_fiscal, v_quantidade, v_total);

        v_record_count := v_record_count + 1;

        -- feedback periódico (opcional, pode deixar mais lento)
        -- if i % 1000 = 0 then
        --     raise notice 'inseridos % de 27000 registros...', i;
        -- end if;

    end loop; -- fim do loop de 27000 inserções

    raise notice 'inserção inicial de % registros em item_nota concluída.', v_record_count;

end $$ language plpgsql;

-- exibe um exemplo de nota_fiscal e item_nota
-- raise notice 'exibindo exemplos de registros:';
select * from "comercio-oltp".nota_fiscal order by random() limit 1;
select * from "comercio-oltp".item_nota order by random() limit 1;

-- verificando as notas que ficaram sem itens
-- raise notice 'verificando notas fiscais sem itens...';
select idnota from "comercio-oltp".nota_fiscal where idnota not in (select distinct id_nota_fiscal from "comercio-oltp".item_nota where id_nota_fiscal is not null);
-- adicionado distinct e is not null para otimizar e garantir a subquery

-- criando uma procedure para preencher as notas que não tiveram itens
-- raise notice 'criando procedure cad_notas...';
create or replace procedure "comercio-oltp".cad_notas()
language plpgsql
as $$
declare
    r_nota record; -- para iterar sobre as notas sem itens
    v_id_produto int;
    v_valor decimal(10,2);
    v_total decimal(10,2);
    v_count int := 0;
begin
    raise notice 'executando cad_notas para preencher notas sem itens...';
    -- loop for sobre as notas fiscais que não estão em item_nota
    for r_nota in
        select idnota
        from "comercio-oltp".nota_fiscal nf
        where not exists (
            select 1
            from "comercio-oltp".item_nota it
            where it.id_nota_fiscal = nf.idnota
        )
    loop
        -- seleciona um produto aleatório
        select idproduto into v_id_produto from "comercio-oltp".produto order by random() limit 1;

        -- obtém o valor do produto
        select valor into v_valor from "comercio-oltp".produto where idproduto = v_id_produto;

        -- define o total (quantidade 1)
        v_total := v_valor;

        -- insere o item padrão para a nota fiscal órfã
        insert into "comercio-oltp".item_nota (id_produto, id_nota_fiscal, quantidade, total)
        values (v_id_produto, r_nota.idnota, 1, v_total);

        v_count := v_count + 1;
    end loop;

    raise notice 'procedure cad_notas concluída. % notas órfãs preenchidas.', v_count;
end;
$$;

-- executa a procedure recém-criada
call "comercio-oltp".cad_notas();

-- verifica novamente se ainda existem notas sem itens (deve retornar 0 linhas)
-- raise notice 'verificando novamente notas fiscais sem itens (deve ser 0)...';
select idnota 
from "comercio-oltp".nota_fiscal nf
where not exists (
    select 1
    from "comercio-oltp".item_nota it
    where it.id_nota_fiscal = nf.idnota
);

-- criando uma view para verificar os itens pedidos
-- raise notice 'criando/substituindo a view v_item_nota...';
create or replace view "comercio-oltp".v_item_nota as
select
    i.id_nota_fiscal as "nota fiscal", -- alias i para item_nota
    p.produto, -- alias p para produto
    p.valor,
    i.quantidade,
    i.total as "total do item"
from
    "comercio-oltp".produto p -- adicionado alias p
inner join
    "comercio-oltp".item_nota i on p.idproduto = i.id_produto; -- adicionado alias i e corrigido join
-- raise notice 'view v_item_nota criada/substituída.';

-- exibe alguns dados da view e da tabela
-- raise notice 'exibindo dados de item_nota e v_item_nota:';
select * from "comercio-oltp".item_nota order by iditemnota limit 10;
select * from "comercio-oltp".v_item_nota order by 1 limit 10;

-- exibe dados da nota_fiscal
-- raise notice 'exibindo dados de nota_fiscal:';
select * from "comercio-oltp".nota_fiscal order by idnota limit 10;

-- consulta join entre cliente, nota fiscal, item nota e produto
-- raise notice 'executando consulta join...';
select
    c.nome,
    c.sobrenome,
    c.sexo, -- coluna sexo não existe na tabela cliente conforme ddl anterior
    n.data,
    n.idnota,
    p.produto,
    n.total -- atenção: n.total na nota_fiscal pode não refletir a soma dos itens se não for atualizado
from
    "comercio-oltp".cliente c
inner join
    "comercio-oltp".nota_fiscal n on c.idcliente = n.id_cliente
inner join
    "comercio-oltp".item_nota i on n.idnota = i.id_nota_fiscal
inner join
    "comercio-oltp".produto p on p.idproduto = i.id_produto
order by 5 -- ordena por idnota
limit 100; -- limita a saída

-- consulta para somar o total por nota fiscal
-- raise notice 'calculando soma total por nota fiscal...';
select
    id_nota_fiscal,
    sum(total) as soma_itens -- renomeado para clareza
from
    "comercio-oltp".item_nota
group by
    id_nota_fiscal
order by
    1
limit 100; -- limita a saída
