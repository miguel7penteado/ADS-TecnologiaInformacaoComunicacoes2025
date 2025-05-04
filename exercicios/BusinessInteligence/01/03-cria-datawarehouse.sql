

DROP SCHEMA IF EXISTS "comercio-olap";

CREATE SCHEMA "comercio-olap"  AUTHORIZATION "miguel";

drop table if exists "comercio-olap".dim_vendedor cascade ;

create table "comercio-olap".dim_vendedor(
	idsk integer primary key ,
	idvendedor integer,
	inicio timestamp,
	fim timestamp,
	nome varchar(50),
	sexo varchar(20),
	idgerente integer
);

drop table if exists "comercio-olap".dim_nota cascade ;

create table "comercio-olap".dim_nota(
	idsk integer primary key ,
	idnota integer
);

drop table if exists "comercio-olap".dim_forma cascade ;

create table "comercio-olap".dim_forma(
	idsk integer primary key ,
	idforma integer,
	forma varchar(30)
);

drop table if exists "comercio-olap".dim_cliente cascade ;

create table "comercio-olap".dim_cliente(
	idsk integer primary key ,
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

drop table if exists "comercio-olap".categoria cascade ;

create table "comercio-olap".categoria(
	idcategoria integer primary key,
	nome varchar(50)
);

drop table if exists "comercio-olap".dim_produto cascade ;

create table "comercio-olap".dim_produto(
	idsk integer primary key ,
	idproduto integer,
	inicio timestamp,
	fim timestamp,
	nome varchar(50),
	valor_unitario numeric(10,2) default null,
	custo_medio numeric(10,2) default null,
	id_categoria integer,
	foreign key(id_categoria) references
	categoria(idcategoria)
);

drop table if exists "comercio-olap".dim_fornecedor cascade ;

create table "comercio-olap".dim_fornecedor(
	idsk integer primary key ,
	idfornecedor integer,
	inicio timestamp,
	fim timestamp,
	nome varchar(30)
);

drop table if exists "comercio-olap".dim_tempo cascade ;

create table "comercio-olap".dim_tempo( 
    idsk integer primary key , 
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

drop table if exists "comercio-olap".fato cascade ;

create table "comercio-olap".fato(
	idnota integer references dim_nota(idsk),
	idcliente integer references dim_cliente(idsk),
	idvendedor integer references dim_vendedor(idsk),
	idforma integer references dim_forma(idsk),
	idproduto integer references dim_produto(idsk),
	idfornecedor integer references dim_fornecedor(idsk),
	idtempo integer references dim_tempo(idsk),
	quantidade integer,
	total_item numeric(10,2),
	custo_total numeric(10,2),
	lucro_total numeric(10,2)
);





