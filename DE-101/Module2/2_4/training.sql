-- Total Sales
select round(sum(sales)) as total_sales from orders;

-- Total Profit
select round(sum(profit)) as total_profit from orders;

-- Profit Ratio
select concat(round(sum(profit) / sum(sales) * 100, 3), '%') as ratio from orders;

-- Profit per Order
select order_id, round(sum(profit), 2) as profit from orders group by order_id order by profit desc;

-- Sales per Customer
-- selected customer_id instead customer_name because people may have same names
select customer_id, sum(sales) as total_sales from orders group by customer_id order by total_sales desc;

-- Avg. Discount
select concat(round(avg(discount), 2) * 100, '%') as average_discount from orders;

-- Monthly Sales by Segment
select extract(year from order_date) as year, extract(month from order_date) as month, segment, sum(sales) as total_sales 
from orders 
group by year, month, segment 
order by year asc, month asc;

-- Monthly Sales by Product Category
select extract(year from order_date) as year, extract(month from order_date) as month, category, sum(sales) as total_sales 
from orders 
group by year, month, category 
order by year asc, month asc;

-- Sales by Product Category over time
select category, round(sum(sales), 2) as total_sales_over_time from orders group by category;

-- Sales and Profit by Customer
select customer_id, sum(sales) as sales, sum(profit) as profit from orders group by customer_id 
order by profit desc, sales desc;

-- Customer Ranking by sales
select row_number() over (order by sum(sales) desc) as rank, customer_id, round(sum(sales), 2) as sales
from orders group by customer_id;

-- Sales per region
select region, round(sum(sales), 2) as sales from orders group by region order by sales asc;