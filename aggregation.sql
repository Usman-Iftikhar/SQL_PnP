
-- SUM
---------------------------------------------------------------------------

-- Find the standard_amt_usd per unit of standard_qty paper. 

SELECT SUM(standard_amt_usd)/SUM(standard_qty) std_amt_per_unit
FROM orders;



-- MIN, MAX, and AVG
---------------------------------------------------------------------------

-- When was the earlist order placed?

SELECT MIN(occurred_at) earliest_order
FROM orders;



-- When did the most recent (latest) web_event occur?

SELECT MAX(occurred_at) latest_event
FROM  web_events;




-- Find the average amount spent per order on each paper type, 
-- as well as the mean amount of each paper type purchased per order.

SELECT 
	AVG(standard_qty),
	AVG(gloss_qty),
	AVG(poster_qty),
	AVG(standard_amt_usd),
	AVG(gloss_amt_usd),
	AVG(poster_amt_usd)
FROM orders;



-- GROUP BY
---------------------------------------------------------------------------




-- DISTINCT
---------------------------------------------------------------------------



-- HAVING
---------------------------------------------------------------------------



-- DATE
---------------------------------------------------------------------------




-- CASE
---------------------------------------------------------------------------
