-- bloco anônimo para executar código procedural pl/pgsql
do $$
declare
    -- variáveis para o loop de população
    v_datainicio date := '1950-01-01'; -- formato iso é mais seguro
    v_datafim date := '2050-01-01';
    v_data date := v_datainicio;

    -- variáveis para o loop for (substituindo o cursor)
    v_registro record; -- para armazenar cada linha da "comercio-olap".dim_tempo
    v_fimsemana text;
    v_estacao text;
    v_ano_cursor int; -- renomeado para evitar conflito com a coluna ano

    -- variáveis auxiliares para inserção
    v_dia int;
    v_mes int;
    v_ano_ins int;
    v_quarto int;
    v_diasemana_num int;
    v_diasemana_nome text;
    v_mes_nome text;
    v_quarto_nome text;

begin
    -------------------------------
    -- carregando a dimensão tempo --
    -------------------------------

    -- exibindo a data atual (equivalente ao print)
    raise notice 'data/hora atual: %', to_char(now(), 'dd mon yyyy hh:mi:ss'); -- formato similar ao 113 do t-sql

    -- alterando o incremento para início em 50000 (ajuste manual necessário)
    -- se idsk for uma coluna serial ou identity e a tabela estiver vazia ou você
    -- quiser garantir que o *próximo* id inserido seja 50000:
    -- 1. descubra o nome da sequência: select pg_get_serial_sequence('"comercio-olap".dim_tempo', 'idsk');
    -- 2. execute: alter sequence nome_da_sequencia restart with 50000;
    -- exemplo: alter sequence "comercio-olap".dim_tempo_idsk_seq restart with 50000;
    raise notice 'lembre-se de ajustar a sequência da coluna idsk manualmente, se necessário. ex: alter sequence "comercio-olap".dim_tempo_idsk_seq restart with 50000;';

    -- inserção de dados na dimensão
    raise notice 'iniciando inserção em "comercio-olap".dim_tempo em %', now();

    -- loop principal para popular as datas
    while v_data < v_datafim loop

        -- extrai os componentes da data
        v_dia := extract(day from v_data);
        v_mes := extract(month from v_data);
        v_ano_ins := extract(year from v_data);
        v_quarto := extract(quarter from v_data);
        v_diasemana_num := extract(dow from v_data); -- 0=domingo, 1=segunda, ..., 6=sábado

        -- determina o nome do dia da semana
        case v_diasemana_num
            when 0 then v_diasemana_nome := 'domingo';
            when 1 then v_diasemana_nome := 'segunda';
            when 2 then v_diasemana_nome := 'terça';
            when 3 then v_diasemana_nome := 'quarta';
            when 4 then v_diasemana_nome := 'quinta';
            when 5 then v_diasemana_nome := 'sexta';
            when 6 then v_diasemana_nome := 'sábado';
        end case;

        -- determina o nome do mês (mantendo a lógica original)
        case v_mes
            when 1 then v_mes_nome := 'janeiro';
            when 2 then v_mes_nome := 'fevereiro';
            when 3 then v_mes_nome := 'março';
            when 4 then v_mes_nome := 'abril';
            when 5 then v_mes_nome := 'maio';
            when 6 then v_mes_nome := 'junho';
            when 7 then v_mes_nome := 'julho';
            when 8 then v_mes_nome := 'agosto';
            when 9 then v_mes_nome := 'setembro';
            when 10 then v_mes_nome := 'outubro';
            when 11 then v_mes_nome := 'novembro';
            when 12 then v_mes_nome := 'dezembro';
        end case;

         -- determina o nome do quarto/trimestre
        case v_quarto
            when 1 then v_quarto_nome := 'primeiro';
            when 2 then v_quarto_nome := 'segundo';
            when 3 then v_quarto_nome := 'terceiro';
            when 4 then v_quarto_nome := 'quarto';
        end case;

        -- insere na tabela
        -- assumindo que a tabela "comercio-olap".dim_tempo existe com as colunas especificadas
        insert into "comercio-olap".dim_tempo
        (
            data,
            dia,
            diasemana,
            mes,
            nomemes,
            quarto,
            nomequarto,
            ano
            -- datacompleta, fimsemana, estacaoano são preenchidos depois
        )
        values
        (
            v_data,
            v_dia,
            v_diasemana_nome,
            v_mes,
            v_mes_nome,
            v_quarto,
            v_quarto_nome,
            v_ano_ins
        );

        -- incrementa a data
        v_data := v_data + interval '1 day';
    end loop; -- fim do while

    raise notice 'inserção inicial concluída em %', now();

    -- atualiza datacompleta (formato yyyymmdd)
    -- fazendo o padding aqui, assumindo que dia e mes são int na tabela e datacompleta é text
    raise notice 'atualizando datacompleta...';
    update "comercio-olap".dim_tempo
    set datacompleta = cast(ano as text) ||
                       lpad(cast(mes as text), 2, '0') ||
                       lpad(cast(dia as text), 2, '0');
    raise notice 'datacompleta atualizada.';

    ----------------------------------------------
    ----------fins de semana e estações-----------
    ----------------------------------------------
    raise notice 'atualizando fimsemana e estacaoano...';

    -- loop for para iterar sobre a tabela (substitui o cursor)
    -- assume que a tabela "comercio-olap".dim_tempo tem a coluna data do tipo date
    for v_registro in
        select idsk, data, diasemana from "comercio-olap".dim_tempo loop

        v_ano_cursor := extract(year from v_registro.data);

        -- determina fimsemana
        if v_registro.diasemana in ('domingo', 'sábado') then
            v_fimsemana := 'sim';
        else
            v_fimsemana := 'não';
        end if;

        -- determina estacaoano (usando datas reais para robustez)
        -- as datas limite são inclusivas no começo e exclusivas no fim (exceto verão)
        -- lógica adaptada para usar datas e lidar com a virada do ano para o verão
        if (v_registro.data >= make_date(v_ano_cursor, 3, 21) and v_registro.data < make_date(v_ano_cursor, 6, 21)) then
             v_estacao := 'outono';
        elsif (v_registro.data >= make_date(v_ano_cursor, 6, 21) and v_registro.data < make_date(v_ano_cursor, 9, 23)) then
             v_estacao := 'inverno';
        elsif (v_registro.data >= make_date(v_ano_cursor, 9, 23) and v_registro.data < make_date(v_ano_cursor, 12, 21)) then
             v_estacao := 'primavera';
        else -- inclui datas >= 21/12 e < 21/03 (verão)
             v_estacao := 'verão';
        end if;


        -- atualiza a linha corrente do loop
        -- nota: fazer updates dentro de um loop pode ser lento para tabelas grandes.
        --       considere calcular fimsemana e estacaoano diretamente no insert
        --       ou usar updates set-based após o loop principal, se possível.
        update "comercio-olap".dim_tempo
        set fimsemana = v_fimsemana,
            estacaoano = v_estacao
        where idsk = v_registro.idsk;

    end loop; -- fim do for loop (substituindo cursor)
    raise notice 'fimsemana e estacaoano atualizados.';

end $$ language plpgsql;

-- select fora do bloco do para verificar
-- select * from "comercio-olap".dim_tempo order by data limit 100; -- exemplo
