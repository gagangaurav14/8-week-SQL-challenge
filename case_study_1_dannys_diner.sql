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


-- 3. What was the first item from the menu purchased by each customer?

-- Solution:
SELECT
	customer_id,
    product_name
FROM
	(SELECT
        s.customer_id, 
        s.order_date,
        m.product_name,
        ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS ind
    FROM 
        dannys_diner.sales s
        INNER JOIN dannys_diner.menu m
            ON s.product_id = m.product_id) a
WHERE
	ind = 1;
-- This is assuming that if two orders are placed on same date, the item that appears first in the data source is considered.


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

-- Solution:
SELECT
	m.product_name,
    COUNT(s.product_id) AS number_of_times_ordered
FROM 
	dannys_diner.sales s
    INNER JOIN dannys_diner.menu m
    	ON s.product_id = m.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- 5. Which item was the most popular for each customer?

-- Solution:
WITH product_counts AS (
    SELECT	
        s.customer_id,
        m.product_name,
        COUNT(s.product_id) AS number_of_times_ordered
    FROM 
        dannys_diner.sales s
        INNER JOIN dannys_diner.menu m
            ON s.product_id = m.product_id
    GROUP BY 1,2
)

SELECT
	customer_id,
    product_name
FROM 
	(SELECT
        customer_id,
        product_name,
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY number_of_times_ordered DESC) AS ind
    FROM 
        product_counts) a
WHERE
	ind = 1;
