
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

-- Total sales for each account.

SELECT a.name, SUM(o.total_amt_usd) total_sales
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY a.name;



-- Total number of times each web_channel was used.

SELECT COUNT (we.channel), we.channel
FROM web_events we
GROUP BY we.channel;



-- Smallest order placed by each account in terms of total usd.

SELECT a.name acct_name, MIN(o.total_amt_usd) smallest_order
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY acct_name
ORDER BY smallest_order;

-- Number of sales reps in each region.

SELECT r.name region, COUNT(sr.id)
FROM region r
JOIN sales_reps sr
ON r.id = sr.region_id
GROUP BY region;

-- Determine the average amount of each type of paper purchased by each account accross theri orders.

SELECT 
	a.name account,
	AVG(o.standard_qty) avg_std,
	AVG(o.gloss_qty) avg_gloss,
	AVG(o.poster_qty) avg_poster
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY account;

-- Average amount spent per order on each paper for each account.

SELECT 
	a.name account,
	AVG(o.standard_amt_usd) avg_stand,
	AVG(o.gloss_amt_usd) avg_gloss,
	AVG(o.poster_amt_usd) avg_poster
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY account;



-- The number of times a particular channel was used for each regin.

SELECT r.name region, we.channel channel, COUNT(*) channel_count
FROM web_events we
JOIN accounts a
ON a.id = we.account_id
JOIN sales_reps sr
ON sr.id = a.sales_rep_id
JOIN region r
ON r.id = sr.region_id
GROUP BY region, channel
ORDER BY channel_count DESC;




-- DISTINCT
---------------------------------------------------------------------------

-- Are there any accounts associated with more than one region.




-- Have any sales reps worked on more than one account.



-- HAVING
---------------------------------------------------------------------------



-- DATE
---------------------------------------------------------------------------




-- CASE
---------------------------------------------------------------------------
