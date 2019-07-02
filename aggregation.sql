
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

SELECT 
	a.id AS "Account ID", r.id as "Region ID",
	a.name AS "Account Name", r.name AS "Region Name"
FROM accounts a
JOIN sales_reps sr
ON sr.id = a.sales_rep_id
JOIN region r
ON r.id = sr.region_id;

-- 351 rows affected.

SELECT DISTINCT id, name
FROM accounts;

-- 351 rows affected.

-- If each account was associated with more than one region, 
-- the first query will return more rows than the second query.



-- Have any sales reps worked on more than one account.

SELECT sr.id, sr.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps sr
ON sr.id = a.sales_rep_id
GROUP BY sr.id, sr.name
ORDER BY num_accounts;

-- 50 rows affected.

SELECT DISTINCT id, name
FROM sales_reps;

-- 50 rows affected.

-- Actually all of the sales reps have worked on more than one account. 
-- The fewest number of accounts any sales rep works on is 3. There are 50 sales reps, 
-- and they all have more than one account. Using DISTINCT in the second query 
-- assures that all of the sales reps are accounted for in the first query.



-- HAVING
---------------------------------------------------------------------------

-- Sales reps with more than 5 accounts.

SELECT sr.id, sr.name, COUNT(*)
FROM sales_reps sr
JOIN accounts a
ON a.sales_rep_id = sr.id
GROUP BY sr.id, sr.name
HAVING COUNT(*) > 5;



-- Accounts with more than 20 orders.

SELECT a.id, a.name, COUNT(*)
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY a.id, a.name
HAVING COUNT(*) > 20;

-- Account with the most orders.

SELECT a.id, a.name, COUNT(*) AS "Number of orders"
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY a.id, a.name
ORDER BY COUNT(*) DESC
LIMIT 1;

-- Accounts that spent more than $30,000 total across all orders.

SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) > 30000;



-- Account that spent the most.

SELECT a.id, a.name, SUM(o.total_amt_usd)
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY a.id, a.name
ORDER BY SUM(o.total_amt_usd) DESC
LIMIT 1;



-- Accounts that used Facebook channel to contact customers more than 6 times.

SELECT a.id, a.name, we.channel, COUNT(*)
FROM accounts a
JOIN web_events we
ON a.id = we.account_id
GROUP BY a.id, a.name, we.channel
HAVING COUNT(*) > 6 AND we.channel = 'facebook';



-- Channel most frequently used.

SELECT we.channel, COUNT(*)
FROM web_events we
GROUP BY we.channel
ORDER BY COUNT(*) DESC;




-- DATE
---------------------------------------------------------------------------

-- Total sales for all orders in each year.

SELECT DATE_PART('year', occurred_at) order_year, SUM(total_amt_usd) total
FROM orders
GROUP BY 1
ORDER BY 2 DESC;



-- Month with the greatest sales.

SELECT DATE_PART('month', occurred_at) order_year, SUM(total_amt_usd) total
FROM orders
GROUP BY 1
ORDER BY 2 DESC;



-- Year with greatest sales in terms of total number of orders.

SELECT DATE_PART('year', occurred_at) order_year, COUNT(*)
FROM orders
GROUP BY 1
ORDER BY 2 DESC;



-- Year/month that Walmart spent the most on gloss paper.

SELECT a.name account, DATE_TRUNC('month', o.occurred_at) order_date, SUM(o.gloss_amt_usd) gloss_amt
-- Using DATE_PART would only give the month without year.
FROM accounts a
JOIN orders o
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY order_date, account
ORDER BY gloss_amt DESC;




-- CASE
---------------------------------------------------------------------------

-- For year 2016, identify customers based on the following 3 total sales value:
-- Greater than $200,000.
-- Between $200,000 and $100,000.
-- Below $100,000.

SELECT 
	a.name account, DATE_PART('year', o.occurred_at) AS year,
	SUM(o.total_amt_usd) total,
	CASE 
		WHEN SUM(o.total_amt_usd) >= 200000 THEN 'High'
		WHEN SUM(o.total_amt_usd) > 100000 AND SUM(o.total_amt_usd) < 200000 THEN 'Mid'
		ELSE 'Low' END AS level
FROM accounts a
JOIN orders o
ON o.account_id = a.id
WHERE 2016 = DATE_PART('year', o.occurred_at)
GROUP BY account, year;



-- Performance category of sales reps:
-- TOP: Orders > 200 or total sales > 750000.
-- MIDDLE: Orders between 150 and 200 or total sales between 500000 and 750000.
-- LOW: All other.

SELECT 
	sr.name sales_rep,
	COUNT(*) orders,
	SUM(o.total_amt_usd) sales,
	CASE
		WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'Top'
		WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'Middle'
		ELSE 'Low'
	END AS "Sales Level"
FROM sales_reps sr
JOIN accounts a
ON sr.id = a.sales_rep_id
JOIN orders o
ON o.account_id = a.id
GROUP BY sales_rep;