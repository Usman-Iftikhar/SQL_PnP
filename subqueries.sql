
-- SUBQUERIES - build query from another query
-- Answer more complex questions than a single database table
-- Inner query is the sub query
-- Inner query must run first



-- The average number of events for each day for each channel.

-- The first table will provide the number of events for each day and channel
-- Then average these values.

SELECT channel, AVG(events) AS avg_events
FROM 
	(SELECT DATE_TRUNC('day', occurred_at) AS day, channel, COUNT(*) AS events
	FROM web_events
	GROUP BY day, channel) sub
GROUP BY channel
ORDER BY avg_events;

---------------------------------------------------------------------------------------

-- Pull month level information about the first order ever placed in the orders table.
-- SELECT DATE_TRUNC('month', MIN(occurred_at))
-- FROM orders

-- Then find only the orders that took place in the same month and year as the first order.
-- WHERE DATE_TRUNC('month', occured_at) = above query

-- Then pull the average for each type of paper quantity in this month.

SELECT AVG(standard_qty) avg_std, AVG(gloss_qty) avg_gloss, AVG(poster_qty) avg_qty
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = 
	(SELECT DATE_TRUNC('month', MIN(occurred_at))
	 FROM orders);
	 
---------------------------------------------------------------------------------------

-- Name of the sales rep in each region with the largest amount of sales.
-- FIRST: get rep, region, total and label as t1
-- Then pick the max from each region and label as t2
-- Creae another query (same as t1) and label as t3
-- Join t2 and t3 on regin and total (this will match the max total from both tables)

SELECT t3.rep_name, t3.region, t3.total_amt
FROM 
	(SELECT region, MAX(total) total_amt
	FROM
		(SELECT sr.name sales_rep, r.name region, SUM(o.total_amt_usd) total
		FROM region r
		JOIN sales_reps sr
		ON r.id = sr.region_id
		JOIN accounts a
		ON a.sales_rep_id = sr.id
		JOIN orders o
		ON o.account_id = a.id
		GROUP BY sales_rep, region) AS t1
	GROUP BY region) AS t2
JOIN
	(SELECT sr.name rep_name, r.name region, SUM(o.total_amt_usd) total_amt
	FROM region r
	JOIN sales_reps sr
	ON r.id = sr.region_id
	JOIN accounts a
	ON a.sales_rep_id = sr.id
	JOIN orders o
	ON o.account_id = a.id
	GROUP BY rep_name, region) AS t3
ON t3.region = t2.region AND t3.total_amt = t2.total_amt;

-- Same query as above using the WITH method.

WITH
	t1 AS 
		(SELECT sr.name sales_rep, r.name region, SUM(o.total_amt_usd) total
		FROM region r
		JOIN sales_reps sr
		ON r.id = sr.region_id
		JOIN accounts a
		ON a.sales_rep_id = sr.id
		JOIN orders o
		ON o.account_id = a.id
		GROUP BY sales_rep, region),
		
	t2 AS
		(SELECT region, MAX(total) total_amt
		FROM t1
		GROUP BY region),
		
	t3 AS 
		(SELECT sr.name rep_name, r.name region, SUM(o.total_amt_usd) total_amt
		FROM region r
		JOIN sales_reps sr
		ON r.id = sr.region_id
		JOIN accounts a
		ON a.sales_rep_id = sr.id
		JOIN orders o
		ON o.account_id = a.id
		GROUP BY rep_name, region)
		
SELECT t3.rep_name, t3.region, t3.total_amt
FROM t3 
JOIN t2
ON t3.region = t2.region AND t3.total_amt = t2.total_amt;

---------------------------------------------------------------------------------------

-- For the region withthe largest sales, how many total orders were placed?
-- FIRST: get total sales for each region and label it as t1
-- SECOND: get the max from the totals in t1

SELECT r.name region, COUNT(o.total) total_orders
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps sr
ON sr.id = a.sales_rep_id
JOIN region r
ON r.id = sr.region_id
GROUP BY 1
HAVING SUM(o.total_amt_usd) = 
	(SELECT MAX(total)
	 FROM
	 	(SELECT r.name region, SUM(o.total_amt_usd) total
		 FROM orders o
		 JOIN accounts a
		 ON o.account_id = a.id
		 JOIN sales_reps sr
		 ON sr.id = a.sales_rep_id
		 JOIN region r
		 ON r.id = sr.region_id
		 GROUP BY 1
		) t1
	);






