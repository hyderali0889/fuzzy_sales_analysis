-- select * from customer_order_summary limit 10;



-- select (MAX(order_date) ) , customer_id from customer_order_summary GROUP BY customer_id order by customer_id;

--  select (CURRENT_DATE - MAX(order_date)  ) as Days_until_last_order , customer_id from customer_order_summary GROUP BY customer_id order by customer_id;


-- select (Count(order_id) ) as total_orders_per_customer , customer_id from customer_order_summary GROUP BY customer_id order by customer_id;

-- select (Count(profits_in_usd) ) as total_profit_per_customer , customer_id from customer_order_summary GROUP BY customer_id order by customer_id;

-- select customer_id , (CURRENT_DATE - MAX(order_date)  ) as Days_until_last_order , (Count(order_id) ) as total_orders_per_customer,  (Count(profits_in_usd) ) as total_profit_per_customer  from customer_order_summary GROUP BY customer_id order by customer_id;


-- CREATE TABLE FINAL_RFM as select customer_id , (CURRENT_DATE - MAX(order_date)  ) as Days_until_last_order , (Count(order_id) ) as total_orders_per_customer,  (Count(profits_in_usd) ) as total_profit_per_customer  from customer_order_summary GROUP BY customer_id order by customer_id;


/* 

AFTER RFM Analysis the following is what we found about our customers

*/







-- Most Loyal Customers

-- create view loyal_customers as select * from FINAL_RFM Where total_orders_per_customer > 15  order by total_orders_per_customer desc limit 10;


--  Potential Loyalists
-- create view potential_loyalist as select * from FINAL_RFM Where total_orders_per_customer > 15 and days_until_last_order < 800  order by total_orders_per_customer desc limit 10;

-- Top 10 Customers with the most Orders with us (Loyal Customers)
-- create view top_customers as  select * from FINAL_RFM order by total_orders_per_customer desc limit 10;


-- Top 10 Customers with the most profits for us (Can't Loose them)
-- 
-- create view top_customers_with_most_profits as select * from FINAL_RFM order by total_profit_per_customer desc limit 10;

-- most recent customers
-- 
-- create view recent_customers as select * from FINAL_RFM order by days_until_last_order limit 10;

-- Customers that need more Ads (AT Risk)
-- 
-- create view customers_at_risk as select * from FINAL_RFM Where days_until_last_order < 800 order by days_until_last_order desc limit 10 ;

-- New Customers
-- 
-- create view new_customers as select * from FINAL_RFM order by total_orders_per_customer limit 10;



-- Lost Customers 
-- 
-- create view lost_customers as select * from FINAL_RFM Where days_until_last_order > 800 order by days_until_last_order desc limit 10 ;


