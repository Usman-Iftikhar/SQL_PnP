/*
WINDOW FUNCTIONS

* Allows to compare one row with another without any JOIN
OVER and PARTITION BY are key to window functions


*/

-- Running Totals
---------------------------------------------------------------------

/*
Running total
How much standard paper is sold to-date.
*/

SELECT 
	standard_qty,
	SUM(standard_qty) OVER(ORDER BY occurred_at) AS running_total
FROM orders;

/*
This creates running_total aggregation without GROUP BY
The statement is read as:
	Take the sum of the standard quantity across all rows leading up to a given row in order by occurred at.
*/


/*
Running total
Start the running total over each month.
*/

SELECT 
	standard_qty,
	DATE_TRUNC('month', occurred_at) AS month,
	SUM(standard_qty) OVER(PARTITION BY DATE_TRUNC('month', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders;


/*
Running total
Create a running total of standard_amt_usd over order time with no date truncation.
The final table should have two columns: amount being added for each new row, 
and second with the running total.
*/

SELECT 
	standard_amt_usd,
	SUM(standard_amt_usd) OVER(ORDER BY occurred_at) AS running_total
FROM orders;

/*
Modify the the above query to include date partition by year.
*/

SELECT 
	standard_amt_usd,
	DATE_TRUNC('year', occurred_at) AS year,
	SUM(standard_amt_usd) OVER(PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders;


-- ROW_NUMBER(), RANK(), DENSE_RANK()
---------------------------------------------------------------------

/*
Row number
ROW NUMBER() does not require to specify a variable.
Windows function in COUNT.
*/

SELECT 
	id, 
	account_id, 
	occurred_at,
	ROW_NUMBER() OVER(ORDER BY id) AS row_num
FROM orders;

-- If the above ORDER BY is by occurred_at, now id and row_num will not match.

SELECT 
	id, 
	account_id, 
	occurred_at,
	ROW_NUMBER() OVER(ORDER BY occurred_at) AS row_num
FROM orders;

-- Row number within each account id.

SELECT 
	id, 
	account_id, 
	occurred_at,
	ROW_NUMBER() OVER(PARTITION BY account_id ORDER BY occurred_at) AS row_num
FROM orders;

/*
RANK() - If two rows have the same value in occurred_at, they are given the same rank.
ROW NUMBER() will give them different numbers.
*/

SELECT 
	id, 
	account_id, 
	occurred_at,
	RANK() OVER(PARTITION BY account_id ORDER BY occurred_at) AS row_num
FROM orders;

/*
The second query below makes it clear with DATE_TRUNC by month.
Notice in row 3, number 3 is skipped from 2 to 4.
*/

SELECT 
	id, 
	account_id, 
	DATE_TRUNC('month', occurred_at) AS month,
	RANK() OVER(PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS row_num
FROM orders;


-- DENSE_RANK() doesn't let numbers to skip.
															
SELECT 
	id, 
	account_id, 
	DATE_TRUNC('month', occurred_at) AS month,
	DENSE_RANK() OVER(PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS row_num
FROM orders;
																  
/*
Ranking total paper ordered by account.

Select id, acccount_id, and total from the orders table.
Then create a column called total_rank that ranks this total amount of paper ordered																  
(from highest to lowest) for each account using a partition.
*/
																  
SELECT id, account_id, total,
	RANK() OVER(PARTITION BY account_id ORDER BY total DESC) AS total_rank 
FROM orders;
																  
																  
-- Aggregates in Woindow Functions																  
--------------------------------------------------------------------

/*
Apply the same aggregates as would under normal circumstances.

Removing ORDER BY clause would leave an unordered partition.
Each column's value is simply an aggregation of all the standard_qty values in 
in its respective account_id
*/																  
																  
SELECT id, account_id, standard_qty,
	DATE_TRUNC('month', occurred_at) AS month,
	DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS dense_rank,
	SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS sum_standard_qty,
	COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS count_std_qty,
	AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS avg_std_qty,
	MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS min_std_qty,
	MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at)) AS max_std_qty
FROM orders;

-- Removing ORDER BY
																		
SELECT id, account_id, standard_qty,
	DATE_TRUNC('month', occurred_at) AS month,
	DENSE_RANK() OVER (PARTITION BY account_id) AS dense_rank,
	SUM(standard_qty) OVER (PARTITION BY account_id) AS sum_standard_qty,
	COUNT(standard_qty) OVER (PARTITION BY account_id) AS count_std_qty,
	AVG(standard_qty) OVER (PARTITION BY account_id) AS avg_std_qty,
	MIN(standard_qty) OVER (PARTITION BY account_id) AS min_std_qty,
	MAX(standard_qty) OVER (PARTITION BY account_id) AS max_std_qty
FROM orders;

																		
-- Aliases for Multiple Woindow Functions																  
--------------------------------------------------------------------

/*
WINDOW alias
Goes between WHERE and GROUP BY
*/
																		
SELECT id, account_id, standard_qty,
	DATE_TRUNC('month', occurred_at) AS month,
	DENSE_RANK() OVER main_window AS dense_rank,
	SUM(standard_qty) OVER main_window AS sum_standard_qty,
	COUNT(standard_qty) OVER main_window AS count_std_qty,
	AVG(standard_qty) OVER main_window AS avg_std_qty,
	MIN(standard_qty) OVER main_window AS min_std_qty,
	MAX(standard_qty) OVER main_window AS max_std_qty
FROM orders
WINDOW main_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('month', occurred_at));
																		