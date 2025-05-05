-- define o schema padrão para a sessão atual (opcional, mas recomendado)
-- set search_path to "comercio-oltp";

-- trunca a tabela nota_fiscal antes de inserir novos dados
-- restart identity (opcional): reinicia a sequência da coluna de identidade (idnota)
-- cascade (opcional): se outras tabelas tiverem fks para nota_fiscal (não comum para truncate)
raise notice 'truncando a tabela "comercio-oltp".nota_fiscal...';
truncate table "comercio-oltp".nota_fiscal restart identity; -- adicionado restart identity
raise notice 'tabela truncada e identidade reiniciada.';

-- bloco anônimo pl/pgsql para inserir dados aleatórios
do $$
declare
    v_id_cliente int;
    v_id_vendedor int;
    v_id_forma int;
    v_data date;
    v_ano int;
    v_mes int;
    v_dia int;
    v_total_inserido int := 0;
begin
    -- loop através dos anos desejados
    for v_ano in 2015..2017 loop
        raise notice 'gerando 8000 registros para o ano %...', v_ano;

        -- loop para inserir 8000 registros por ano
        for i in 1..8000 loop
            -- seleciona ids aleatórios de tabelas relacionadas
            select idcliente into v_id_cliente from "comercio-oltp".cliente order by random() limit 1;
            select idvendedor into v_id_vendedor from "comercio-oltp".vendedor order by random() limit 1;
            select idforma into v_id_forma from "comercio-oltp".forma_pagamento order by random() limit 1;

            -- gera um mês aleatório (1 a 12)
            v_mes := floor(random() * 12 + 1)::int;
            -- gera um dia aleatório (1 a 28 para simplificar e evitar datas inválidas)
            v_dia := floor(random() * 28 + 1)::int;
            -- cria a data
            v_data := make_date(v_ano, v_mes, v_dia);

            -- insere na tabela nota_fiscal, omitindo idnota (que é auto-gerado)
            -- assumindo que as colunas id_cliente, id_vendedor, id_forma, data existem
            insert into "comercio-oltp".nota_fiscal (id_cliente, id_vendedor, id_forma, data)
            values (v_id_cliente, v_id_vendedor, v_id_forma, v_data);

        end loop; -- fim do loop de 8000 inserções

        v_total_inserido := v_total_inserido + 8000;
        raise notice 'concluída a geração de registros para o ano %. total inserido até agora: %', v_ano, v_total_inserido;

    end loop; -- fim do loop dos anos

    raise notice 'geração de dados concluída. total de registros inseridos: %', v_total_inserido;

end $$ language plpgsql;

-- verifica a contagem de registros após a inserção
select count(*) as total_registros from "comercio-oltp".nota_fiscal;

-- exibe alguns dos registros inseridos (opcional)
select * from "comercio-oltp".nota_fiscal
order by idnota
limit 100; -- limita a saída para não sobrecarregar
