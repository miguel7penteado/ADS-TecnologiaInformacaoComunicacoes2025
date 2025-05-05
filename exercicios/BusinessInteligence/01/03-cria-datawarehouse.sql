

DROP SCHEMA IF EXISTS "comercio-olap" CASCADE;

CREATE SCHEMA "comercio-olap"  AUTHORIZATION "miguel";

drop table if exists "comercio-olap".dim_vendedor cascade ;

create table "comercio-olap".dim_vendedor(
	idsk integer GENERATED ALWAYS AS IDENTITY,
	idvendedor integer,
	inicio timestamp,
	fim timestamp,
	nome varchar(50),
	sexo varchar(20),
	idgerente integer
);
alter table "comercio-olap".dim_vendedor add constraint "chave_primaria_dim_vendedor" primary key (idsk);

drop table if exists "comercio-olap".dim_nota cascade ;

create table "comercio-olap".dim_nota(
	idsk integer GENERATED ALWAYS AS IDENTITY,
	idnota integer
);
alter table "comercio-olap".dim_nota add constraint "chave_primaria_dim_nota" primary key (idsk);

drop table if exists "comercio-olap".dim_forma cascade ;

create table "comercio-olap".dim_forma(
	idsk integer GENERATED ALWAYS AS IDENTITY,
	idforma integer,
	forma varchar(30)
);
alter table "comercio-olap".dim_forma add constraint "chave_primaria_dim_forma" primary key (idsk);

drop table if exists "comercio-olap".dim_cliente cascade ;

create table "comercio-olap".dim_cliente(
	idsk integer GENERATED ALWAYS AS IDENTITY,
	idcliente integer,
	inicio timestamp,
	fim timestamp,
	nome varchar(100),
	sexo varchar(20),
	nascimento date,
	email varchar(100),
	cidade varchar(100),
	estado varchar(10),
	regiao varchar(20)
);
alter table "comercio-olap".dim_cliente add constraint "chave_primaria_dim_cliente" primary key (idsk);

drop table if exists "comercio-olap".categoria cascade ;

create table "comercio-olap".categoria(
	idcategoria integer,
	nome varchar(50)
);
alter table "comercio-olap".categoria add constraint "chave_primaria_categoria" primary key (idcategoria);

drop table if exists "comercio-olap".dim_produto cascade ;

create table "comercio-olap".dim_produto(
	idsk integer GENERATED ALWAYS AS IDENTITY,
	idproduto integer,
	inicio timestamp,
	fim timestamp,
	nome varchar(50),
	valor_unitario numeric(10,2) default null,
	custo_medio numeric(10,2) default null	
);
alter table "comercio-olap".dim_produto add column id_categoria integer;
alter table "comercio-olap".dim_produto add constraint "chave_primaria_dim_produto" primary key (idsk);
alter table "comercio-olap".dim_produto add constraint "chave_estrangeira_dim_produto_categoria" foreign key (id_categoria) references "comercio-olap".categoria (idcategoria) ;



drop table if exists "comercio-olap".dim_fornecedor cascade ;

create table "comercio-olap".dim_fornecedor(
	idsk integer GENERATED ALWAYS AS IDENTITY,
	idfornecedor integer,
	inicio timestamp,
	fim timestamp,
	nome varchar(30)
);
alter table "comercio-olap".dim_fornecedor add constraint "chave_primaria_dim_fornecedor" primary key (idsk);

drop table if exists "comercio-olap".dim_tempo cascade ;

create table "comercio-olap".dim_tempo( 
    idsk integer GENERATED ALWAYS AS IDENTITY, 
    data date, 
    dia char(2), 
    diasemana varchar(10), 
    mes char(2), 
    nomemes varchar(10), 
    quarto integer, 
    nomequarto varchar(10), 
    ano char(4), 
	estacaoano varchar(20),
	fimsemana char(3),
	datacompleta varchar(10)
);
alter table "comercio-olap".dim_tempo add constraint "chave_primaria_dim_tempo" primary key (idsk);



drop table if exists "comercio-olap".fato cascade ;

create table "comercio-olap".fato(
	idnota       integer references "comercio-olap".dim_nota(idsk),
	idcliente    integer references "comercio-olap".dim_cliente(idsk),
	idvendedor   integer references "comercio-olap".dim_vendedor(idsk),
	idforma      integer references "comercio-olap".dim_forma(idsk),
	idproduto    integer references "comercio-olap".dim_produto(idsk),
	idfornecedor integer references "comercio-olap".dim_fornecedor(idsk),
	idtempo      integer references "comercio-olap".dim_tempo(idsk),
	quantidade   integer,
	total_item   numeric(10,2),
	custo_total  numeric(10,2),
	lucro_total  numeric(10,2)
);






