-- creating tables
drop table if exists stg.ship_dim_v2;
create table stg.ship_dim_v2 (
	ship_id   int primary key,
	ship_mode varchar(14) not null
);

drop table if exists stg.product_dim_v2;
create table stg.product_dim_v2 (
	product_id   int primary key,
	product_name varchar(127) not null,
	category     varchar(15) not null,
	subcategory  varchar(11) not null
);

drop table if exists stg.deliver_dim_v2;
create table stg.deliver_dim_v2 (
	deliver_id  int primary key,
	country     varchar(13) not null,
	state       varchar(20) not null,
	city        varchar(17) not null,
	postal_code int,
	region      varchar(7) not null
);

drop table if exists stg.customer_dim_v2;
create table stg.customer_dim_v2 (
	customer_id   varchar(10) primary key,
	customer_name varchar(22) not null,
	segment       varchar(11) not null
);

drop table if exists stg.orders_v2;
create table stg.orders_v2 (
	order_id varchar(14) primary key,
	order_date date not null,
	ship_date date not null,
	manager varchar(17) not null,
	returned varchar(3) not null,
	ship_id int not null, foreign key (ship_id) references stg.ship_dim_v2( ship_id ),
	deliver_id int not null, foreign key (deliver_id) references stg.deliver_dim_v2( deliver_id ),
	customer_id varchar(10) not null, foreign key (customer_id) references stg.customer_dim_v2( customer_id )
);

drop table if exists stg.order_details_v2;
create table stg.order_details_v2 (
	sales      numeric(9, 4) not null,
	quantity   int not null,
	profit     numeric(21, 16) not null,
	discount   numeric(4, 2) not null,
	product_id int not null, foreign key (product_id) references stg.product_dim_v2 ( product_id ),
	order_id   varchar(14) not null, foreign key (order_id) references stg.orders_v2 ( order_id )
);

-- inserting values
update orders set postal_code = 0 where state = 'Vermont';

insert into stg.ship_dim_v2 (ship_id, ship_mode)
select row_number() over(), s.ship_mode from (select distinct ship_mode from orders) as s;

insert into stg.product_dim_v2 (product_id, product_name, category, subcategory)
select row_number() over(), * from (select distinct product_name, category, subcategory from orders) as s;

insert into stg.customer_dim_v2 (customer_id, customer_name, segment)
select distinct customer_id, customer_name, segment from orders;

insert into stg.deliver_dim_v2 (deliver_id, country, state, city, postal_code, region)
select row_number() over(), * from (select distinct country, state, city, postal_code, region from orders) as s;

insert into stg.orders_v2 (order_id, order_date, ship_date, manager, returned, ship_id, deliver_id, customer_id)
select distinct o.order_id, o.order_date, o.ship_date, m.person, coalesce(r.returned, 'No'), s.ship_id, d.deliver_id, o.customer_id from
orders o left join returns r using(order_id)
		 join people m using(region)
		 join stg.ship_dim_v2 s using(ship_mode)
		 join stg.deliver_dim_v2 d using(country, state, city, postal_code, region)
		 
insert into stg.order_details_v2 (sales, quantity, profit, discount, product_id, order_id)
select o.sales, o.quantity, o.profit, o.discount, p.product_id, o.order_id from orders o
join stg.product_dim_v2 p using(product_name, category, subcategory) 