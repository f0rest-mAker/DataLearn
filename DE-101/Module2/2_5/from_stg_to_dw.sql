-- Creating dimensional modeling tables
-- Vermont state contains null values in postal_code column, so replace them with other value
update orders set postal_code = 0 where state = 'Vermont';

drop table if exists customer_dim;
CREATE TABLE customer_dim
(
 customer_id   varchar(10) NOT NULL,
 customer_name varchar(22) NOT NULL,
 segment       varchar(11) NOT NULL,
 CONSTRAINT PK_6 PRIMARY KEY ( customer_id )
);

drop table if exists manager_dim;
CREATE TABLE manager_dim
(
 region    varchar(7) NOT NULL,
 manager   varchar(17) NOT NULL,
 CONSTRAINT PK_7 PRIMARY KEY ( region )
);

drop table if exists deliver_dim;
CREATE TABLE deliver_dim
(
 deliver_id  int NOT NULL,
 country     varchar(13) NOT NULL,
 state     varchar(20) NOT NULL,
 city        varchar(17) NOT NULL,
 postal_code int4 NULL,
 region      varchar(7) NOT NULL,
 CONSTRAINT PK_4 PRIMARY KEY ( deliver_id ),
 CONSTRAINT FK_2 FOREIGN KEY ( region ) REFERENCES manager_dim ( region )
);

drop index if exists FK_2;
CREATE INDEX FK_2 ON deliver_dim
(
 region
);

drop table if exists order_dim;
CREATE TABLE order_dim
(
 order_id   varchar(14) NOT NULL,
 order_date date NOT NULL,
 ship_date  date NOT NULL,
 returned   varchar(3) NOT NULL,
 CONSTRAINT PK_3 PRIMARY KEY ( order_id )
);

drop table if exists product_dim;
CREATE TABLE product_dim
(
 product_id   int NOT NULL,
 product_name varchar(127) NOT NULL,
 category     varchar(15) NOT NULL,
 subcategory  varchar(11) NOT NULL,
 CONSTRAINT PK_2 PRIMARY KEY ( product_id )
);

drop table if exists ship_dim;
CREATE TABLE ship_dim
(
 ship_id   int NOT NULL,
 ship_mode varchar(14) NOT NULL,
 CONSTRAINT PK_5 PRIMARY KEY ( ship_id )
);

drop table if exists sales_fact;
CREATE TABLE sales_fact
(
 row_id      int4 NOT NULL,
 ship_id     int NOT NULL,
 sales       numeric(9, 4) NOT NULL,
 quantity    int4 NOT NULL,
 discount    numeric(4, 2) NOT NULL,
 profit      numeric(21, 16) NOT NULL,
 order_id    varchar(14) NOT NULL,
 product_id  int NOT NULL,
 customer_id varchar(10) NOT NULL,
 deliver_id  int NOT NULL,
 CONSTRAINT PK_1 PRIMARY KEY ( row_id ),
 CONSTRAINT FK_1 FOREIGN KEY ( product_id ) REFERENCES product_dim ( product_id ),
 CONSTRAINT FK_3 FOREIGN KEY ( deliver_id ) REFERENCES deliver_dim ( deliver_id ),
 CONSTRAINT FK_4 FOREIGN KEY ( ship_id ) REFERENCES ship_dim ( ship_id ),
 CONSTRAINT FK_5 FOREIGN KEY ( order_id ) REFERENCES order_dim ( order_id ),
 CONSTRAINT FK_6 FOREIGN KEY ( customer_id ) REFERENCES customer_dim ( customer_id )
);

drop index if exists FK_1;
CREATE INDEX FK_1 ON sales_fact
(
 product_id
);

drop index if exists FK_3;
CREATE INDEX FK_3 ON sales_fact
(
 deliver_id
);

drop index if exists FK_4;
CREATE INDEX FK_4 ON sales_fact
(
 ship_id
);

drop index if exists FK_5;
CREATE INDEX FK_5 ON sales_fact
(
 order_id
);

drop index if exists FK_6;
CREATE INDEX FK_6 ON sales_fact
(
 customer_id
);
-------------------------------------------------
-- inserting values
-- manager_dim
insert into manager_dim (region, manager)
select region, person from people;

-- deliver_dim
set @p := 0;
insert into deliver_dim (deliver_id, country, state, city, postal_code, region)
select (@p:=@p+1) as deliver_id, d.country, d.state, d.city, d.postal_code, d.region 
from (select distinct o.country, o.state, o.city, o.postal_code, o.region from orders as o) as d;

-- customer_dim
insert into customer_dim (customer_id, customer_name, segment)
select distinct customer_id, customer_name, segment from orders;


-- ship dim
set @p := 0;
insert into ship_dim (ship_id, ship_mode)
select (@p:=@p+1) as ship_id, s.ship_mode from (select distinct ship_mode from orders) as s;

-- product_dim
set @p := 0;
insert into product_dim (product_id, product_name, category, subcategory)
select (@p:=@p+1), s.product_name, s.category, s.subcategory from 
(select distinct product_name, category, subcategory from orders) as s;

-- order dim 
insert into order_dim (order_id, order_date, ship_date, returned)
select distinct o.order_id, o.order_date, o.ship_date, coalesce(r.returned, 'No') as returned
	from orders o left join (select distinct * from returns) r on r.order_id = o.order_id;

-- sales fact 
insert into sales_fact
select o.row_id, s.ship_id, o.sales, o.quantity, o.discount, o.profit, o.order_id, p.product_id, o.customer_id, d.deliver_id
from orders o join product_dim p using(product_name, category, subcategory)
	join deliver_dim d using(country, state, city, postal_code, region)
	join ship_dim s using(ship_mode);

