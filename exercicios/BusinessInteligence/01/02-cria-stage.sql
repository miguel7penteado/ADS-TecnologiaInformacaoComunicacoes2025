
DROP SCHEMA IF EXISTS "estagio";

CREATE SCHEMA "estagio"  AUTHORIZATION "miguel";

DROP TABLE IF EXISTS  estagio.st_cliente;

create table estagio.st_cliente
(
	idcliente integer   default null,
	nome varchar(100)   default null,
	email varchar(60)   not null,
	sexo varchar(20)    default null,
	nascimento date     default null,
	cidade varchar(100) default null,
	estado varchar(10)  default null,
	regiao varchar(20)  default null
);

DROP TABLE IF EXISTS  estagio.st_vendedor;

create table estagio.st_vendedor
(
	idvendedor integer  default null,
	nome varchar(50)    default null,
	sexo varchar(20)    default null,
	idgerente integer   default null
);

DROP TABLE IF EXISTS  estagio.st_categoria;

create table estagio.st_categoria
(
	idcategoria integer          default null,
	nome varchar(50)             default null
);

DROP TABLE IF EXISTS  estagio.st_fornecedor;

create table estagio.st_fornecedor
(
	idfornecedor integer         default null,
	nome varchar(100)            default null
);

DROP TABLE IF EXISTS  estagio.st_produto;

create table estagio.st_produto
(
	idproduto integer            default null,
	nome varchar(50)             default null,
	valor_unitario numeric(10,2) default null,
	custo_medio numeric(10,2)    default null,
	id_categoria integer         default null
);

DROP TABLE IF EXISTS  estagio.st_nota;

create table estagio.st_nota(
	idnota integer default null
);

DROP TABLE IF EXISTS  estagio.st_forma;

create table estagio.st_forma(
	idforma integer default null,
	forma varchar(30) default null
);


DROP TABLE IF EXISTS  estagio.st_fato;


create table estagio.st_fato(
	idcliente integer default null,
	idvendedor integer default null,
	idproduto integer default null,
	idfornecedor integer default null,
	idnota integer default null,
	idforma integer default null,
	quantidade integer default null,
	total_item numeric(10,2) default null,
	data date default null,
	custo_total numeric(10,2) default null,
	lucro_total numeric(10,2) default null
);




