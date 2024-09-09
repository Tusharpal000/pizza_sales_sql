-- Retrieve the total number of orders placed.--
SELECT COUNT(*) AS TOTAL_ORDERS FROM orders;

-- Calculate the total revenue generated from pizza sales.--

SELECT 
    ROUND(SUM(order_detail.QUANTITY * pizzas.price),
            2) AS total_sales
FROM
    order_detail
        LEFT JOIN
    pizzas ON order_detail.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza. --

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1 ;


-- Identify the most common pizza size ordered. --

select size,  count(QUANTITY) as cnt from order_detail
join pizzas on order_detail.pizza_id = pizzas.pizza_id
group by size 
order by cnt desc limit 1 ;

-- List the top 5 most ordered pizza types along with their quantities. --

SELECT 
    pizza_types.name, SUM(order_detail.QUANTITY) AS total_qty
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_detail ON order_detail.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_qty DESC
LIMIT 5 ;

-- Join the necessary tables to find the total quantity of each pizza category ordered. --
select pizza_types.category , sum(order_detail.QUANTITY) as tot_qty from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id 
join order_detail on order_detail.pizza_id = pizzas.pizza_id 
group by pizza_types.category ;


-- Determine the distribution of orders by hour of the day.--
SELECT hour(ORDER_TIME), count(ORDER_ID) as order_cnt FROM orders
GROUP by hour(ORDER_TIME)
ORDER BY count(ORDER_ID) DESC  ; 

-- Join relevant tables to find the category-wise distribution of pizzas. --
select category , count(name) from pizza_types
group by  category;

-- Group the orders by date and calculate the average number of pizzas ordered per day. --
SELECT 
    ROUND(AVG(qty_ordered), 0)
FROM
    (SELECT 
        orders.order_date, SUM(order_detail.quantity) AS qty_ordered
    FROM
        orders
    JOIN order_detail ON order_detail.ORDER_ID = orders.ORDER_ID
    GROUP BY orders.order_date) AS ordered_qty;

-- Determine the top 3 most ordered pizza types based on revenue. --

select pizza_types.name , sum(order_detail.QUANTITY * pizzas.price) as revenue from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id 
join order_detail on order_detail.pizza_id	= pizzas.pizza_id 
group by pizza_types.name order by revenue desc 
limit 3 ;

-- Calculate the percentage contribution of each pizza type to total revenue --
SELECT 
    pizza_types.category,
    ROUND(SUM(order_detail.QUANTITY * pizzas.price) / (SELECT 
                    ROUND(SUM(order_detail.QUANTITY * pizzas.price),
                                2) AS total_sales
                FROM
                    ORDER_DETAIL
                        JOIN
                    pizzas ON pizzas.pizza_id = order_detail.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_detail ON order_detail.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC
;

-- Analyze the cumulative revenue generated over time. -- 
 select order_date, sum(revenue) over (order by order_date) as cum_rev 
 from 
 (select orders.order_date , sum(order_detail.quantity * pizzas.price) as revenue from order_detail join pizzas
 on order_detail.pizza_id = pizzas.pizza_id
 join orders ON orders.ORDER_ID = order_detail.ORDER_ID 
 group by orders.order_date) as sales ; 
 
 -- Determine the top 3 most ordered pizza types based on revenue for each pizza category. --
 select name, revenue from 
 (select category, name , revenue , rank() over (partition by category order by revenue desc) as rnk 
 from 
 (select pizza_types.category , pizza_types.name , 
 sum((order_detail.quantity)* pizzas.price) as revenue 
 from pizza_types join pizzas
 on pizza_types.pizza_type_id = pizzas.pizza_type_id
 join order_detail on order_detail.pizza_id = pizzas.pizza_id 
 group  by  pizza_types.category ,  pizza_types.name) as new) as nb
 where rnk <=  3; 