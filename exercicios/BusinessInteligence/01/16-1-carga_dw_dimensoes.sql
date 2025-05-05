delete from "comercio-olap".categoria;
INSERT INTO "comercio-olap".categoria( idcategoria, nome) SELECT idcategoria, nome FROM "estagio".st_categoria;

delete from "comercio-olap".dim_cliente;
INSERT INTO "comercio-olap".dim_cliente( idcliente, nome, email, sexo, nascimento, cidade, estado, regiao) 
( SELECT  idcliente, nome, email, sexo, nascimento, cidade, estado, regiao FROM "estagio".st_cliente );

delete from "comercio-olap".dim_forma;
INSERT INTO "comercio-olap".dim_forma( idforma, forma) SELECT idforma, forma 	FROM "estagio".st_forma;

delete from "comercio-olap".dim_fornecedor;
INSERT INTO "comercio-olap".dim_fornecedor( idfornecedor, nome) ( SELECT idfornecedor, nome FROM "estagio".st_fornecedor );

delete from "comercio-olap".dim_nota;
INSERT INTO "comercio-olap".dim_nota( idnota) SELECT idnota FROM "estagio".st_nota;

delete from "comercio-olap".dim_produto;
INSERT INTO "comercio-olap".dim_produto( idproduto, nome, valor_unitario, custo_medio, id_categoria) SELECT idproduto, nome, valor_unitario, custo_medio, id_categoria FROM "estagio".st_produto;

delete from "comercio-olap".dim_vendedor;
INSERT INTO "comercio-olap".dim_vendedor( idvendedor, nome, sexo, idgerente) SELECT idvendedor, nome, sexo, idgerente FROM "estagio".st_vendedor;
