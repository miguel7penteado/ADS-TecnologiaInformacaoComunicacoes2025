
-- define o schema padrão para a sessão atual (opcional, mas recomendado se st_produto não estiver no search_path)
-- set search_path to "estagio"; -- ou o schema onde st_produto está

-- cria ou substitui a procedure no postgresql
create or replace procedure "estagio".camel_case() -- use o schema correto se necessário
language plpgsql
as $$
begin
    raise notice 'iniciando a formatação dos nomes na tabela st_produto para title case...';

    -- atualiza a coluna nome usando a função initcap()
    -- initcap converte a primeira letra de cada palavra para maiúscula e o restante para minúscula.
    update "estagio".st_produto -- use o schema correto se necessário
    set nome = initcap(nome);

    raise notice 'formatação concluída. % linhas atualizadas.', (select count(*) from "estagio".st_produto); -- mostra quantas linhas foram afetadas

end;
$$;

-- como chamar a procedure (exemplo):
-- call "estagio".camel_case(); -- use o schema correto se necessário

-- como verificar o resultado (exemplo):
-- select idproduto, nome from "estagio".st_produto limit 20; -- use o schema correto se necessário
