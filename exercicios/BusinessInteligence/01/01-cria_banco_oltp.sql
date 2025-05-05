


DROP SCHEMA IF EXISTS "comercio-oltp" cascade;

CREATE SCHEMA "comercio-oltp"  AUTHORIZATION "miguel";

drop table if exists "comercio-oltp".cliente cascade;

create table "comercio-oltp".cliente(
	idcliente int generated always as identity,
	nome varchar(30) not null,
	sobrenome varchar(30) not null,
	email varchar(60) not null,
	sexo char,
	nascimento date not null
);

alter table "comercio-oltp".cliente add constraint "chave_primaria_cliente" primary key (idcliente);


drop table if exists "comercio-oltp".endereco cascade;

create table "comercio-oltp".endereco(
	idendereco int generated always as identity,
	rua varchar(100) not null,
	cidade varchar(50) not null,
	estado varchar(20) not null,
	regiao varchar(20) not null
);
alter table "comercio-oltp".endereco add column id_cliente integer unique;
alter table "comercio-oltp".endereco add constraint "chave_primaria_endereco" primary key (idendereco);
alter table "comercio-oltp".endereco add constraint "chave_estrangeira_endereco_cliente" foreign key (id_cliente) references "comercio-oltp".cliente (idcliente) ;


drop table if exists "comercio-oltp".gerente cascade;

create table "comercio-oltp".gerente(
	idgerente int generated always as identity,
	nome varchar(200) not null,
	sexo char(1) not null,
	email varchar(200) not null
);
alter table "comercio-oltp".gerente add constraint "chave_primaria_gerente" primary key (idgerente);

drop table if exists "comercio-oltp".vendedor cascade;

create table "comercio-oltp".vendedor(
	idvendedor int generated always as identity,
	nome varchar(30) not null,
	sexo char(1) not null,
	email varchar(30) not null
);

alter table "comercio-oltp".vendedor add column id_gerente integer;
alter table "comercio-oltp".vendedor add constraint "chave_primaria_vendedor" primary key (idvendedor);
alter table "comercio-oltp".vendedor add constraint "chave_estrangeira_vendedor_gerente" foreign key (id_gerente) references "comercio-oltp".gerente (idgerente) ;
 

drop table if exists "comercio-oltp".categoria cascade;

create table "comercio-oltp".categoria(
	idcategoria int generated always as identity,
	nome varchar(50) not null
);
alter table "comercio-oltp".categoria add constraint "chave_primaria_categoria" primary key (idcategoria);


drop table if exists "comercio-oltp".fornecedor cascade;

create table "comercio-oltp".fornecedor(
	idfornecedor int generated always as identity,
	nome varchar(200)
);
alter table "comercio-oltp".fornecedor add constraint "chave_primaria_fornecedor" primary key (idfornecedor);


drop table if exists "comercio-oltp".produto cascade;

create table "comercio-oltp".produto(
	idproduto int generated always as identity,
	produto varchar(100) not null,
	valor numeric(10,2) not null,
	custo_medio numeric(10,2)
);
alter table "comercio-oltp".produto add column id_categoria  integer;
alter table "comercio-oltp".produto add column id_fornecedor integer;
alter table "comercio-oltp".produto add constraint "chave_primaria_produto" primary key (idproduto);
alter table "comercio-oltp".produto add constraint "chave_estrangeira_produto_categoria"  foreign key (id_categoria)  references "comercio-oltp".categoria  (idcategoria);
alter table "comercio-oltp".produto add constraint "chave_estrangeira_produto_fornecedor" foreign key (id_fornecedor) references "comercio-oltp".fornecedor (idfornecedor);


drop table if exists "comercio-oltp".forma_pagamento cascade;

create table "comercio-oltp".forma_pagamento(
	idforma int generated always as identity,
	forma varchar(50) not null
);
alter table "comercio-oltp".forma_pagamento add constraint "chave_primaria_forma_pagamento" primary key (idforma);

drop table if exists "comercio-oltp".nota_fiscal cascade;

create table "comercio-oltp".nota_fiscal(
	idnota int generated always as identity,
	data date,
	total numeric(10,2),
	id_forma int,
	id_cliente int,
	id_vendedor int
);
alter table "comercio-oltp".nota_fiscal add constraint "chave_primaria_nota_fiscal" primary key (idnota);


drop table if exists "comercio-oltp".item_nota cascade;

create table "comercio-oltp".item_nota(
	iditemnota int generated always as identity,
	quantidade int,
	total numeric(10,2)
);

alter table "comercio-oltp".item_nota add column id_produto     integer;
alter table "comercio-oltp".item_nota add column id_nota_fiscal integer;
alter table "comercio-oltp".item_nota add constraint "chave_primaria_item_nota" primary key (id_produto,id_nota_fiscal);
alter table "comercio-oltp".item_nota add constraint "chave_estrangeira_item_nota_produto"    foreign key (id_produto)     references "comercio-oltp".produto  (idproduto);
alter table "comercio-oltp".item_nota add constraint "chave_estrangeira_item_nota_nota_fiscal" foreign key (id_nota_fiscal) references "comercio-oltp".nota_fiscal (idnota);










