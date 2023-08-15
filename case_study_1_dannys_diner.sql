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

-------------------------------------------- x ------------------------------------------------

-- 2. How many days has each customer visited the restaurant?
-- Solution:
SELECT
	customer_id,
    COUNT(DISTINCT order_date) AS days_visited
FROM
	dannys_diner.sales s
GROUP BY 1
ORDER BY days_visited DESC;

-------------------------------------------- x ------------------------------------------------

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

-------------------------------------------- x ------------------------------------------------

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

-------------------------------------------- x ------------------------------------------------

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

-------------------------------------------- x ------------------------------------------------

-- 6. Which item was purchased first by the customer after they became a member?
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
            ON s.product_id = m.product_id
    	INNER JOIN dannys_diner.members l     	-- l for loyalty
    		ON s.customer_id = l.customer_id
    		AND s.order_date >= l.join_date) a
WHERE
	ind = 1;
-- Assumption: If order_date and join_date are same, it is assumed the order is after the membership is joined

-------------------------------------------- x ------------------------------------------------

-- 7. Which item was purchased just before the customer became a member?
-- Solution:
SELECT
	customer_id,
    product_name
FROM
	(SELECT
        s.customer_id, 
        s.order_date,
        m.product_name,
        ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS ind
    FROM 
        dannys_diner.sales s
        INNER JOIN dannys_diner.menu m
            ON s.product_id = m.product_id
    	LEFT JOIN dannys_diner.members l     	-- l for loyalty
    		ON s.customer_id = l.customer_id
    		AND s.order_date >= l.join_date
    WHERE
    	l.join_date IS NULL) a
WHERE
	ind = 1;
-- Assumption: If there are two items ordered just before the membership, the item that appears first in the data is considered

-------------------------------------------- x ------------------------------------------------

-- 8. What is the total items and amount spent for each member before they became a member?
-- Solution:
SELECT
	s.customer_id, 
    COUNT(s.product_id) AS number_of_items,
    SUM(m.price) AS amount
FROM 
    dannys_diner.sales s
    INNER JOIN dannys_diner.menu m
        ON s.product_id = m.product_id
  	INNER JOIN dannys_diner.members l     	-- l for loyalty
    	ON s.customer_id = l.customer_id
    	AND s.order_date < l.join_date
GROUP BY 1
ORDER BY 1;

-------------------------------------------- x ------------------------------------------------

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- Solution:
SELECT
	s.customer_id, 
    SUM(CASE
        WHEN m.product_name = 'sushi' THEN 20*m.price
       	ELSE 10*m.price
    END) AS points
FROM 
    dannys_diner.sales s
    INNER JOIN dannys_diner.menu m
        ON s.product_id = m.product_id
  	INNER JOIN dannys_diner.members l     	-- l for loyalty
    	ON s.customer_id = l.customer_id
    	AND s.order_date >= l.join_date
GROUP BY 1
ORDER BY 1;

-------------------------------------------- x ------------------------------------------------

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-- Solution:
SELECT
	s.customer_id, 
    SUM(CASE
        WHEN DATE_TRUNC('week', order_date) = DATE_TRUNC('week', join_date) THEN 20*m.price
       	ELSE 10*m.price
    END) AS points
FROM 
    dannys_diner.sales s
    INNER JOIN dannys_diner.menu m
        ON s.product_id = m.product_id
  	INNER JOIN dannys_diner.members l     	-- l for loyalty
    	ON s.customer_id = l.customer_id
    	AND s.order_date >= l.join_date
WHERE
	s.order_date <= '2021-01-31'
GROUP BY 1
ORDER BY 1;

------------------------------------------ BONUS-1 ---------------------------------------------

-- JOIN ALL THE THINGS
-- Solution:
SELECT
	s.customer_id,
    -- DATE(s.order_date) AS order_date,    -- Normally, this would work in most IDEs
    TEXT(s.order_date) AS order_date,		-- This works on db-fiddle
    m.product_name,
    m.price,
    CASE
    	WHEN s.order_date >= l.join_date THEN 'Y'
        ELSE 'N'
    END AS member
FROM 
	dannys_diner.sales s
    LEFT JOIN dannys_diner.menu m
    	ON s.product_id = m.product_id
    LEFT JOIN dannys_diner.members l     -- l for loyalty
    	ON s.customer_id = l.customer_id
ORDER BY 1, 2, 3

------------------------------------------ BONUS-2 ---------------------------------------------

-- RANK ALL THE THINGS
-- Solution:
SELECT
	a.*,
    CASE
    	WHEN member = 'N' THEN NULL
        ELSE RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date) 
    END AS ranking
FROM
	(SELECT
      s.customer_id,
      TEXT(s.order_date) AS order_date,
      m.product_name,
      m.price,
      CASE
          WHEN s.order_date >= l.join_date THEN 'Y'
          ELSE 'N'
      END AS member
  FROM 
      dannys_diner.sales s
      LEFT JOIN dannys_diner.menu m
          ON s.product_id = m.product_id
    LEFT JOIN dannys_diner.members l     -- l for loyalty
    	ON s.customer_id = l.customer_id) a
ORDER BY 1, 2, 3
