
# Retrieve the total number of orders placed.
select count(order_id) total_orders from orders;

#Calculate the total revenue generated from pizza sales.
SELECT round(sum(od.quantity*p.price),2) as total_revenue from order_details od
join pizzas p on p.pizza_id = od.pizza_id ; 

#Identify the highest-priced pizza.
select pt.name as pizza_name,  p.price from pizza_types pt
join pizzas p on p.pizza_type_id= pt.pizza_type_id order by price desc limit 1;

#Identify the most common pizza size ordered.
SELECT p.size, count(od.order_id) as highest_orders FROM pizzas p 
join order_details od on od.pizza_id = p.pizza_id group by p.size order by highest_orders desc;

#List the top 5 most ordered pizza types along with their quantities.

with cte1 as
(select p.pizza_type_id, sum(od.quantity) as high_qty from order_details od
join pizzas p on p.pizza_id = od.pizza_id group by p.pizza_type_id)

select pt.name, c.high_qty, 
rank() over(order by high_qty desc) as top5_pizzaOrders from cte1 c
join pizza_types pt on pt.pizza_type_id = c.pizza_type_id limit 5;

#Join the necessary tables to find the total quantity of each pizza category ordered.
 select pt.category, sum(od.quantity) as total_qty from order_details od
 join pizzas p on p.pizza_id = od.pizza_id
 join pizza_types pt on pt.pizza_type_id = p.pizza_type_id  group by pt.category;
 
 #Determine the distribution of orders by hour of the day.
 select HOUR(order_time) as order_hour, count(order_id) as order_count 
 from orders group by HOUR(order_time);
 
 #Join relevant tables to find the category-wise distribution of pizzas.
 select category, count(pizza_type_id) as total_pizzas from pizza_types
 group by category;
 
 #Group the orders by date and calculate the average number of pizzas ordered per day.
 select round(avg(order_qty),0) as Avg_Order_perDay from
 (select o.order_date, sum(od.quantity) as order_qty from order_details od 
 join orders o on o.order_id = od.order_id group by o.order_date)
 as order_qty;
 
 #Determine the top 3 most ordered pizza types based on revenue.
 
select total_revenue.name, total_revenue, rank() over(order by total_revenue desc) as top3 from
(select pt.name, sum(od.quantity*p.price) as total_revenue
from order_details od 
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id group by
pt.pizza_type_id) as total_revenue limit 3;

#Calculate the percentage contribution of each pizza type to total revenue.
with rev_per_pizza as
(select pt.category, sum(od.quantity*p.price) as revenue
from order_details od 
join pizzas p on p.pizza_id = od.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.category order by revenue desc)

select category, round((revenue/(select sum(revenue) from rev_per_pizza))*100,2) as pct_contribution
from rev_per_pizza order by pct_contribution desc;

#Analyze the cumulative revenue generated over time.
select o.order_date, sum(sum(od.quantity*p.price)) 
over(order by o.order_date) as cumilative_revenue from orders o
join order_details od on od.order_id = o.order_id
join pizzas p on p.pizza_id = od.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id group by o.order_date;

#Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with cte1 as(select pt.name, pt.category, sum(od.quantity*p.price) as revenue
from order_details od
join pizzas p on p.pizza_id = od.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id group by category, name),
cte2 as
(select name, category, revenue, 
row_number() over(partition by category order by revenue desc) as top3_by_category
from cte1)
select name, category, revenue, top3_by_category from cte2 where top3_by_category<=3 ;
 
 
 





