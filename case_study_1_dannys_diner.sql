/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

-- Solution:
SELECT
	s.customer_id,
    SUM(m.price) AS amount
FROM 
	dannys_diner.sales s
    LEFT JOIN dannys_diner.menu m
    	ON s.product_id = m.product_id
GROUP BY 1
ORDER BY 2 DESC;


-- 2. How many days has each customer visited the restaurant?

-- Solution:
SELECT
	customer_id,
    COUNT(DISTINCT order_date) AS days_visited
FROM
	dannys_diner.sales s
GROUP BY 1
ORDER BY days_visited DESC;
