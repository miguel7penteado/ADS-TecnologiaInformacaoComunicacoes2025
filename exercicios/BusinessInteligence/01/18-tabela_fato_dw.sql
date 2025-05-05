-- substitua '"comercio-olap".' e '"estagio".' pelos nomes reais dos seus schemas no postgresql.
-- se as tabelas estiverem no schema 'public', remova os prefixos.

create or replace procedure "comercio-olap".carga_fato() -- nome da procedure qualificado com o schema "comercio-olap"
language plpgsql
as $$
declare
    v_final date;    -- usando date em vez de datetime
    v_inicial date;  -- usando date em vez de datetime
begin
    raise notice 'iniciando carga_fato...';

    -- encontra a data máxima na dimensão de tempo
    select max(t.data)
    into v_final
    from "comercio-olap".dim_tempo t; -- schema "comercio-olap"

    raise notice 'data final encontrada em dim_tempo: %', v_final;

    -- encontra a data máxima já carregada na tabela fato
    select max(t.data)
    into v_inicial
    from "comercio-olap".fato ft -- schema "comercio-olap"
    join "comercio-olap".dim_tempo t on (ft.idtempo = t.idsk); -- schema "comercio-olap"

    raise notice 'data máxima encontrada em fato (inicial): %', v_inicial;

    -- se a tabela fato estiver vazia, busca a data mínima da dimensão de tempo
    if v_inicial is null then
        raise notice 'tabela fato vazia. buscando data mínima em dim_tempo...';
        select min(t.data)
        into v_inicial
        from "comercio-olap".dim_tempo t; -- schema "comercio-olap"
        raise notice 'data inicial definida como a mínima de dim_tempo: %', v_inicial;
    end if;

    -- garante que as datas não sejam nulas antes de prosseguir
    if v_inicial is null or v_final is null then
        raise exception 'não foi possível determinar as datas inicial ou final. verifique dim_tempo.';
    end if;

    raise notice 'período de carga definido: % a %', v_inicial, v_final;

    -- insere os dados da stage na fato para o período calculado
    raise notice 'iniciando insert na tabela fato...';
    insert into "comercio-olap".fato ( -- schema "comercio-olap"
        idnota,
        idcliente,
        idvendedor,
        idforma,
        idfornecedor,
        idproduto,
        idtempo,
        quantidade,
        total_item,
        custo_total,
        lucro_total
    )
    select
        n.idsk as idnota,
        c.idsk as idcliente,
        v.idsk as idvendedor,
        fo.idsk as idforma,
        fn.idsk as idfornecedor,
        p.idsk as idproduto,
        t.idsk as idtempo,
        f.quantidade,
        f.total_item,
        f.custo_total,
        f.lucro_total
    from
        "estagio".st_fato f -- schema 'estagio'

    inner join "comercio-olap".dim_forma fo on (f.idforma = fo.idforma) -- schema "comercio-olap"

    inner join "comercio-olap".dim_nota n on (f.idnota = n.idnota) -- schema "comercio-olap"

    inner join "comercio-olap".dim_fornecedor fn on (f.idfornecedor = fn.idfornecedor
        and f.data >= fn.inicio -- lógica scd
        and (f.data <= fn.fim or fn.fim is null)) -- schema "comercio-olap"

    inner join "comercio-olap".dim_cliente c on (f.idcliente = c.idcliente
        and f.data >= c.inicio -- lógica scd
        and (f.data <= c.fim or c.fim is null)) -- schema "comercio-olap"

    inner join "comercio-olap".dim_vendedor v on (f.idvendedor = v.idvendedor
        and f.data >= v.inicio -- lógica scd
        and (f.data <= v.fim or v.fim is null)) -- schema "comercio-olap"

    inner join "comercio-olap".dim_produto p on (f.idproduto = p.idproduto
        and f.data >= p.inicio -- lógica scd
        and (f.data <= p.fim or p.fim is null)) -- schema "comercio-olap"

    inner join "comercio-olap".dim_tempo t on (t.data = f.data) -- schema "comercio-olap". comparação direta de datas é mais eficiente.

    where f.data between v_inicial and v_final; -- filtra pelo período de carga

    raise notice 'insert na tabela fato concluído. % linhas inseridas.', (select count(*) from "comercio-olap".fato where idtempo in (select idsk from "comercio-olap".dim_tempo where data between v_inicial and v_final)); -- feedback sobre linhas inseridas no período

    raise notice 'carga_fato concluída com sucesso.';

end;
$$;

call "comercio-olap".carga_fato();

-- como chamar a procedure (exemplo):
-- call "comercio-olap".carga_fato(); -- ajuste o nome do schema se necessário
