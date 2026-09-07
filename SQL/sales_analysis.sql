-- Creating Sales KPIs

-- select * from order_items limit 10;             -- I only need the first 10 rows of this table to calculate the KPIs


-- select order_id,product_id ,CONCAT( sum(quantity * price) , ' USD') as Profits 
-- from order_items group by product_id,order_id order by sum(quantity * price) desc       -- I want the sum of profits for each row

-- alter table order_items add column Profits numeric(10) not null default 0;

-- update order_items set Profits = quantity * price;        -- I want to update the profits column with the calculated profits for each row


-- alter table order_items rename Column profits to profits_in_USD; 
-- alter table order_items rename Column price to price_in_USD; 


-- select COUNT(DISTINCT order_id) as total_orders , 
-- Count(DISTINCT product_id) as total_products,
-- SUM(quantity) as total_sold_units,
-- SUM(profits_in_USD) as total_profits
-- from order_items;


-- select order_id , div(profits_in_USD, quantity) as avg_price_per_unit_in_usd 
-- from order_items order by avg_price_per_unit_in_usd desc;    -- I want the average price per unit for each order and I want to see the top 10 orders with the highest average price per unit




-- select * from orders limit 10;

-- select order_items.order_id, order_items.product_id, orders.customer_id, order_items.quantity, order_items.price_in_USD, order_items.profits_in_USD, orders.order_date, orders.status
-- from order_items left JOIN orders on order_items.order_id = orders.order_id order by orders.order_date;

-- Create table order_summary as select order_items.order_id, order_items.product_id, orders.customer_id, order_items.quantity, order_items.price_in_USD, order_items.profits_in_USD, orders.order_date, orders.status
-- from order_items left JOIN orders on order_items.order_id = orders.order_id order by orders.order_date;


-- select * from order_summary limit 10;

-- Select 
-- CONCAT(EXTRACT( 'year' from date_trunc('year', order_date)), '-', 
-- EXTRACT( 'month' from date_trunc('month', order_date))) as order_month,
-- CONCAT( SUM(profits_in_USD) , ' USD') as "Revenue"  from order_summary group by order_month order by "Revenue" desc;


-- select date_trunc('month', order_date) as order_month from order_summary group by order_month order by order_month;  

-- alter table order_summary add column "Revenue" numeric(10) not null default 0;

-- alter table order_summary drop column "Revenue";


