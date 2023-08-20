-- Solutions of Week 2 of 8 week SQL Challenge

---------------------------   P I Z Z A   M E T R I C S   -------------------------------
-- Q1 : How many pizzas were ordered?
-- Solution:
SELECT
	COUNT(pizza_id) AS pizza_ordered
FROM 
	pizza_runner.customer_orders;
-- Assumption: Identical rows represent multiple quantity of pizza and not duplicates


-- Q2 : How many unique customer orders were made?
-- Solution:
SELECT
	COUNT(DISTINCT order_id) AS num_orders
FROM 
	pizza_runner.customer_orders;


-- Q3 : How many successful orders were delivered by each runner?
-- Solution:
SELECT
	COUNT(DISTINCT order_id) AS orders_delivered
FROM
	pizza_runner.runner_orders
WHERE
	LOWER(cancellation) NOT LIKE '%cancel%';


-- Q4 : How many of each type of pizza was delivered?
-- Solution:
SELECT
	p.pizza_name,
	COUNT(c.pizza_id) AS pizza_delivered
FROM
	pizza_runner.runner_orders r
    LEFT JOIN pizza_runner.customer_orders c
    	ON r.order_id = c.order_id
    LEFT JOIN pizza_runner.pizza_names p
    	ON c.pizza_id = p.pizza_id
WHERE
	LOWER(r.cancellation) NOT LIKE '%cancel%'
GROUP BY 1;


-- Q5 : How many Vegetarian and Meatlovers were ordered by each customer?
-- Q5 : How many Vegetarian and Meatlovers were ordered by each customer?
-- Solution:
SELECT
	customer_id,
    SUM(CASE
    	When pizza_id = 1 THEN 1
        ELSE 0
    END) AS meatlovers_pizza_ordered,
    SUM(CASE
    	When pizza_id = 2 THEN 1
        ELSE 0
    END) AS vegetarian_pizza_ordered
FROM
	pizza_runner.customer_orders
GROUP BY 1;


