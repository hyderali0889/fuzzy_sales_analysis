-- Create table customer_summary as select customers.customer_id,customers.country, customers.signup_date, orders.order_id, orders.order_date, orders.status
-- from customers left JOIN orders on orders.customer_id = customers.customer_id  WHERE orders.status = 'Completed' order by orders.order_date;


-- select * from customers;

-- select * from orders;


-- select * from customer_summary;

-- select * from order_summary limit 10;

-- create table customer_order_summary as select order_summary.order_id ,customer_summary.customer_id,  order_summary.order_date, order_summary.price_in_usd,order_summary.profits_in_usd, order_summary.quantity, order_summary.status,customer_summary.country,customer_summary.signup_date
-- from customer_summary left JOIN order_summary on customer_summary.order_id = order_summary.order_id  WHERE order_summary.status = 'Completed' order by customer_summary.customer_id;


-- select * from customer_order_summary limit 10;

-- select customer_id,profits_in_USD from customer_order_summary group by customer_id,profits_in_USD order by profits_in_USD desc;  -- I want to see the top 10 customers with the highest profits

-- select SUM(profits_in_USD) as total_profit_in_USD from customer_order_summary;

-- select Distinct order_id from customer_order_summary where order_id is not  null order by order_id;  -- I want to see the orders that do not have a customer_id

-- select Count(Distinct order_id) from customer_order_summary;

-- select Div(SUM(profits_in_USD), COUNT(Distinct customer_id)) as average_profit_per_customer from customer_order_summary;

-- select Div(SUM(profits_in_USD), COUNT(Distinct order_id)) as average_profit_per_order from customer_order_summary;

-- select MAX(order_date) as last_order_date, MIN(order_date) as first_order_date from customer_order_summary;  -- I want to see the date of the first and last order in the dataset


-- select (MAX(profits_in_USD) - MIN(profits_in_USD)) from customer_order_summary;