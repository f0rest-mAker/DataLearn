create or replace procedure add_foreign_keys() as $$
begin
	alter table orders drop constraint if exists fk_orders_ship_id;	
	alter table orders add constraint fk_orders_ship_id foreign key (ship_id) references biss_layer.ship_dim(ship_id);
	
	alter table orders drop constraint if exists fk_orders_deliver_id;
	alter table orders add constraint fk_orders_deliver_id foreign key (deliver_id) references biss_layer.deliver_dim(deliver_id);
	
	alter table orders drop constraint if exists fk_orders_customer_id;
	alter table orders add constraint fk_orders_customer_id foreign key (customer_id) references biss_layer.customer_dim(customer_id);
	
	alter table order_details drop constraint if exists fk_order_details_order_id;
	alter table order_details add constraint fk_order_details_order_id foreign key (order_id) references biss_layer.orders(order_id);
	
	alter table order_details drop constraint if exists fk_order_details_product_id;
	alter table order_details add constraint fk_order_details_product_id foreign key (product_id) references biss_layer.product_dim(product_id);
end;
$$ language plpgsql;

create or replace procedure remove_foreign_keys() as $$
begin
	alter table orders drop constraint if exists fk_orders_ship_id;
	alter table orders drop constraint if exists fk_orders_deliver_id;
	alter table orders drop constraint if exists fk_orders_customer_id;
	
	alter table order_details drop constraint if exists fk_order_details_order_id;
	alter table order_details drop constraint if exists fk_order_details_product_id;
end;
$$ language plpgsql;

call add_foreign_keys();