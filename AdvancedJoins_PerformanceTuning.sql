/*
FULL JOIN or FULL OUTER JOIN
Commonly used in conjunction with aggregations to understand 
the amount of overlap betweeen two tables. 
*/


-- Each acccount who has a sales rep and each sales rep that has an account.
-- but also each account that doe snot have a sales rep and each sales rep that does
-- not have an account

SELECT *
FROM accounts a
FULL JOIN sales_reps sr
ON a.sales_rep_id = sr.id
-- To check for unmatched rows
WHERE a.sales_rep_id IS NULL OR sr.id IS NULL;


-- JOINs with comparison operators (inequality operators)
---------------------------------------------------------------

/*
Campaign
Want to check all the actions customer took before making their purchase.
Or look at web traffic events before the purchase.
*/

SELECT
	o.id, 
	o.occurred_at AS order_date,
	we.*
FROM orders o
LEFT JOIN web_events we
-- Conditional statements and filter with less than operator
-- JOIN clause is evaluated before the WHERE clause
-- Filtering in the JOIN clause will eliminate rows before they are joined
ON we.account_id = o.account_id AND we.occurred_at < o.occurred_at
WHERE DATE_TRUNC('month', o.occurred_at) =
	(SELECT DATE_TRUNC('month', min(o.occurred_at)) FROM orders o)
ORDER BY o.account_id, o.occurred_at;

/*
Write a query that left joins the accounts table and the sales_reps tables 
on each sale rep's ID number and joins it using the < comparison operator on 
accounts.primary_poc and sales_reps.name.
*/
					   
SELECT a.name account, a.primary_poc, sr.name sales_rep
FROM accounts a
LEFT JOIN sales_reps sr
ON a.sales_rep_id = sr.id
AND a.primary_poc < sr.name; -- primary_poc's full name comes before the sales_rep's name alphabetically


-- Self JOINs
---------------------------------------------------------------

/*
Self JOIN
Commonly used when two events occured, one after another
					   
Which accounts made multiple orders within 30 days
*/					   
					   
SELECT 
	o1.id AS o1_id,
	o1.account_id AS o1_account_id,
	o1.occurred_at AS o1_occurred_at,
	o2.id AS o2_id,
	o2.account_id AS o2_account_id,
	o2.occurred_at AS o2_occurred_at
FROM orders o1
LEFT JOIN orders o2
ON o1.account_id = o2.account_id
	AND o2.occurred_at > o1.occurred_at
	AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at;	
					   
/*
Join on the same account				   
Compare the account ids from both tables					   
Want the record to be within 28 days from o1 table					   
Two conditional statements:
	Where o2.occurred_at > o1.occurred_at, orders that happened after the original order date
	Where o2.occurred_at is 28 days less than o1.occurred_at					   
*/					   

-- Apply the above query for web events table
					   
SELECT 
	we1.id AS we1_id,
	we1.account_id AS we_account_id,
	we1.occurred_at AS we1_occurred_at,
	we2.id AS we2_id,
	we2.account_id AS we2_account_id,
	we2.occurred_at AS we2_occurred_at
FROM web_events we1
LEFT JOIN web_events we2
ON we1.account_id = we2.account_id
	AND we2.occurred_at > we1.occurred_at
	AND we2.occurred_at <= we1.occurred_at + INTERVAL '28 days'
ORDER BY we1.account_id, we1.occurred_at;						   
					   
					   
-- UNION
---------------------------------------------------------------

/*
UNION - appends distinct values
UNION ALL - append all values from the second table
					   
Two rules:
1) Both tables must ahve the same number of columns					   
2) Those columns must have the same data types in the same order as the first table.					   
*/
					   
					   
SELECT *					   
FROM web_events			   
UNION				   
SELECT *
FROM web_events;					   

					   
-- Pretreating tables before doing a UNION					   
SELECT *					   
FROM web_events	
WHERE channel = 'facebook'
UNION ALL				   
SELECT *
FROM web_events;
					   
-- Performing operations on a combined dataset					   

WITH web_events AS 
	(SELECT *					   
	FROM web_events	
	WHERE channel = 'facebook'
	UNION ALL				   
	SELECT *
	FROM web_events)					   
					   
SELECT channel, COUNT(*) AS sessions
FROM web_events
GROUP BY 1
ORDER BY 2 DESC;
					   
					   
/*
Write a query that uses UNION ALL on two instances of the accounts table.
*/					   
					   
SELECT *
FROM accounts a1
UNION ALL	
SELECT *					   
FROM accounts a2;					   
					   
					   
/*
Add a WHERE clause to of the tables.
Fitler the first table for Walmart.
Filter the second table for Disney.					   
*/					   
					   
SELECT *
FROM accounts a1
WHERE name = 'Walmart'
UNION ALL	
SELECT *					   
FROM accounts a2
WHERE name = 'Disney';					   
		
					   
/*
Count the number of times a name appears in the table below.
*/					   

WITH double_accounts AS					   
	(SELECT *
	FROM accounts a1
	UNION ALL	
	SELECT *					   
	FROM accounts a2)				   

SELECT name, COUNT(*)
FROM double_accounts
GROUP BY 1;					   
					   
					   
-- Performance tuning
---------------------------------------------------------------

/*
One way to make query run faster is to reduce the number of calculations that need to be 
performed.  Some of the high-level things that will affect the number of calculations a given
query will make includes:			   

* Table size
* Joins	 
*Aggregations					   
					   
*/	

-- Example, limiting time for a time-series data					   
					   
SELECT *
FROM orders	o
WHERE o.occurred_at >= '2016-01-01' AND o.occurred_at < '2016-07-01';

					   
-- Limiting number of rows doesn't help with aggregates because aggregation is applied first.
-- Limit is applied at the end of the query					   
-- Below query takes 162 msec.
					   
SELECT account_id,
	SUM(poster_qty) AS sum_poster_qty
FROM orders	o
WHERE o.occurred_at >= '2016-01-01' AND o.occurred_at < '2016-07-01'
GROUP BY account_id
LIMIT 10;					   
	
					   
-- To speed it up, need to do a sub-query
-- Below query takes 92 msec.
-- Limit query time where it is executed first (putting limited in sub-query).
					   
SELECT account_id,
	SUM(poster_qty) AS sum_poster_qty
FROM 
	(SELECT * 
	 FROM orders o 
	 LIMIT 100) sub
WHERE occurred_at >= '2016-01-01' AND occurred_at < '2016-07-01'
GROUP BY account_id;	
					   
					   
-- Make joins less complicated, or reduce the number of joins  

SELECT a.name, COUNT(*) AS web_events
FROM accounts a
JOIN web_events we
ON we.account_id = a.id				   
GROUP BY 1	
ORDER BY 2 DESC;

-- Pre-aggreating the web_events table, this could reduce the number of rows 
-- that need to be evaluated in the join
					   
WITH sub AS
	(SELECT account_id, COUNT(*) AS web_events
	FROM web_events we			   
	GROUP BY 1)

SELECT a.name, sub.web_events
FROM sub
JOIN accounts a
ON a.id = sub.account_id
ORDER BY 2 DESC;					   
				
					   
-- Add EXPLAIN before any query, it will show how long it will take	

EXPLAIN
SELECT *					   
FROM web_events we					   
WHERE we.occurred_at >= '2016-01-01' AND occurred_at < '2016-07-01'					   
LIMIT 100;					   
					   					   
					   
-- JOINing Subqueries
---------------------------------------------------------------

/*
The below query joins on date field, this means	joining every row in a given day from one table 
onto every row with the same day in another table.				   
					   
*/					   
					   
SELECT
	DATE_TRUNC('day', o.occurred_at) AS date,
	COUNT(DISTINCT a.sales_rep_id) AS active_sales_reps,
	COUNT(DISTINCT o.id) AS orders,
	COUNT(DISTINCT we.id) AS web_events
FROM accounts a
JOIN orders o
ON o.account_id = a.id
JOIN web_events we
ON DATE_TRUNC('day', we.occurred_at) = DATE_TRUNC('day', o.occurred_at)
GROUP BY 1
ORDER BY 1 DESC;

					   
-- Check how big this data gets before aggregating
-- 79,083 rows are produced before aggreating
					   
					   
SELECT
	o.occurred_at AS date,
	a.sales_rep_id,				   
	o.id AS order_id,
	we.id AS web_event_id				   
FROM accounts a
JOIN orders o
ON o.account_id = a.id
JOIN web_events we
ON DATE_TRUNC('day', we.occurred_at) = DATE_TRUNC('day', o.occurred_at)
ORDER BY 1 DESC;
					   

-- Can get the same result more efficiently by aggregating the tables separtely					   

SELECT COALESCE(orders.date, web_events.date) AS date,
	orders.active_sales_reps,
	orders.orders,
	web_events.web_visits
FROM
	(-- Subquery 1
	SELECT
	DATE_TRUNC('day', o.occurred_at) AS date,
	COUNT(a.sales_rep_id) AS active_sales_reps,
	COUNT(o.id) AS orders
	FROM accounts a
	JOIN orders o
	ON o.account_id = a.id
	GROUP BY date) orders					   

FULL JOIN
	
	(-- Subquery 2					   
	SELECT
		DATE_TRUNC('day', we.occurred_at) AS date,
		COUNT(we.id) AS web_visits
	FROM web_events we
	GROUP BY date) web_events
ON web_events.date = orders.date
ORDER BY 1 DESC;				   