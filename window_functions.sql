/*

WINDOW FUNCTIONS
* Allows to compare one row with another without any JOIN


*/

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

---------------------------------------------------------------------

/*
Running total
Start the running total over each month.
*/

SELECT 
	standard_qty,
	DATE_TRUNC('month', occurred_at) AS month,
	SUM(standard_qty) OVER(PARTITION BY DATE_TRUNC('month', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders;

---------------------------------------------------------------------

/*
Row number
Windows function in COUNT.
*/

SELECT id, account_id, occurred_at,
	ROW_NUMBER() OVER(ORDER BY id) AS row_num
FROM orders;