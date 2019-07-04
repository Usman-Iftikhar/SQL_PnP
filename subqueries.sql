
/*
SUBQUERIES - build query from another query
Answer more complex questions than a single database table
Inner query is the sub query
Inner query must run first
*/

/*
The average number of events for each day for each channel.
The first table will provide the number of events for each day and channel
Then average these values.
*/

SELECT channel, AVG(events) AS avg_events
FROM 
	(SELECT DATE_TRUNC('day', occurred_at) AS day, channel, COUNT(*) AS events
	FROM web_events
	GROUP BY day, channel) sub
GROUP BY channel
ORDER BY avg_events;

---------------------------------------------------------------------------------------

/*
Pull month level information about the first order ever placed in the orders table.
SELECT DATE_TRUNC('month', MIN(occurred_at))
FROM orders

Then find only the orders that took place in the same month and year as the first order.
WHERE DATE_TRUNC('month', occured_at) = above query

Then pull the average for each type of paper quantity in this month.
*/

SELECT AVG(standard_qty) avg_std, AVG(gloss_qty) avg_gloss, AVG(poster_qty) avg_qty
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = 
	(SELECT DATE_TRUNC('month', MIN(occurred_at))
	 FROM orders);
	 
---------------------------------------------------------------------------------------

/*
Name of the sales rep in each region with the largest amount of sales.
FIRST: get rep, region, total and label as t1
Then pick the max from each region and label as t2
Creae another query (same as t1) and label as t3
Join t2 and t3 on regin and total (this will match the max total from both tables)
*/

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

/*
For the region withthe largest sales, how many total orders were placed?
FIRST: get total sales for each region and label it as t1
SECOND: get the max from the totals in t1 
Now the max is known and can be used in a query.
*/

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
	
---------------------------------------------------------------------

/*
For the name of the account that purchased the most standard quantity,
how many acconts still had dmore in total purhcases?

1) Get the standard and total quantity for each account and label it as t1.
2) Get the total column only
3) Get the names of the accounts whoes order total is greater than subquery 2).
	a) Because a single value needs to be compared, 
	adjust subquery 1) in a desending order and limit it to 1.
4) Count the number of account in subquery 3).
*/

SELECT COUNT(*)
FROM 
	(SELECT a.name account
	FROM orders o 
	JOIN accounts a
	ON a.id = account_id
	GROUP BY account
	HAVING SUM(o.total) > 
	 	(SELECT total
		 FROM
		 	(SELECT a.name account, SUM(o.standard_qty) total_std_qty, SUM(o.total) total
			 FROM orders o
			 JOIN accounts a
			 ON a.id = o.account_id
			 GROUP BY account
			 ORDER BY total_std_qty DESC
			 LIMIT 1
			) t1
		) -- Do not write alias in a conditional statement because it is an individual value.
	 ) t2;

---------------------------------------------------------------------

/*
For the customer that spent the most, how many web_events did they have for each channel?

1) Get the customer name and id that spent the most and label it as t1.
2) Get the customer id from subquery 1) and label it as t2.
3) Run a query and join on account id matching that of subquery 2).

*/

WITH 
	t1 AS 
		(SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
		 FROM orders o
		 JOIN accounts a
		 ON a.id = o.account_id
		 GROUP BY a.id, a.name
		 ORDER BY 3 DESC
		 LIMIT 1),
		 
	t2 AS
		(SELECT id 
		 FROM t1)

SELECT a.name, we.channel, COUNT(*)
FROM accounts a
JOIN web_events we
ON a.id = we.account_id AND a.id = (SELECT * FROM t2)
GROUP BY 1, 2
ORDER BY 3 DESC;

---------------------------------------------------------------------

/*
What is the lifetime average amount spent in terms of sales
for the top 10 total spending accounts?

*/

WITH
	t1 AS
		(SELECT a.name account, SUM(o.total_amt_usd) total
		 FROM accounts a
		 JOIN orders o
		 ON o.account_id = a.id
		 GROUP BY account
		 ORDER BY total DESC
		 LIMIT 10
		)

SELECT AVG(total)
FROM t1;

---------------------------------------------------------------------

/*
What is the lifetime average amount spent in terms of sales
for only the companies that spent more than the average of all orders?

*/

SELECT AVG(avg_total)
FROM 
	(SELECT account_id id, AVG(total_amt_usd) avg_total
	 FROM orders
	 GROUP BY id
	 HAVING AVG(total_amt_usd) > 
	 	(SELECT AVG(o.total_amt_usd) avg_total
		 FROM accounts a
		 JOIN orders o
		 ON a.id = o.account_id)) t2;