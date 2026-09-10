

-- select * from products limit 10;
-- select * from order_items limit 10;


--  Create table products_summary as select order_items.order_id, order_items.product_id,products.product_name,products.category, order_items.quantity, order_items.price_in_USD, order_items.profits_in_USD from order_items left JOIN products on order_items.product_id = products.product_id  order by order_items.profits_in_USD desc;

-- drop table products_summary;

-- select * from products_summary order by quantity desc;

-- select * from products_summary order by Category, profits_in_USD desc;


-- select Category, sum(profits_in_USD) as total_profits from products_summary Group by Category 

-- select Category, sum(order_id) as total_orders from products_summary Group by Category 


-- select Category, avg(price_in_USD) as avg_price from products_summary Group by Category 



-- select order_id, ROUND(SUM(profits_in_USD) / SUM(price_in_USD)) * 100 AS profit_percentage from products_summary Group by order_id;

-- select COUNT(DISTINCT order_id) as total_orders , Category from products_summary Group by Category;


-- select COUNT(DISTINCT order_id) as total_orders , profits_in_USD from products_summary Group by profits_in_USD;


-- select COUNT(DISTINCT order_id) as total_orders , ROUND(AVG(price_in_USD),2) as avg_price from products_summary Group by profits_in_USD;

-- select  order_id , profits_in_USD from products_summary Group by profits_in_USD,order_id order by profits_in_USD desc;