
/*
COMMANDS

LEFT - pull characters from the left side of the string and present them as a separate string.

RIGHT - pull characters from the right side of the string and present them as a separate string.

LENGTH - pulls the length of the string.

POSITION - provides the position of a string counting from the LEFT

STRPOS - provides the position of a string counting from the LEFT

LOWER - force every character in a string to be lower case 

UPPER - force every character in a string to be upper case

CONCAT - combine several values from columns in to one

PIPING - same as CONCAT

CAST - allows to change columns from one data type to another

COALESCE - to work with NULL values, returns the fisrt non-NULL value passed for each row

*/

---------------------------------------------------------------------

/*
Pull website extensions and provide how many of each websites types exist in the accounts table.
*/

SELECT RIGHT(website, 3) AS "Domain", COUNT(*) AS "Count"
FROM accounts
GROUP BY "Domain";

---------------------------------------------------------------------

/*
Pull the first letter of each company name to see the distribution.
*/

SELECT LEFT(name, 1) letter, COUNT(*)
FROM accounts
GROUP BY letter
ORDER BY 2 DESC;

---------------------------------------------------------------------

/*
Use the accounts table and a CASE statement to create two groups: 
one group of company names that start with a number and a second group 
of those company names that start with a letter. 

What proportion of company names start with a letter?
*/

SELECT first_character, COUNT(*)
FROM 
	(SELECT 
	 	name,
	 	CASE WHEN LEFT(UPPER(name),1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 'number' 
	 	ELSE 'letter'
	 	END AS first_character
	 FROM accounts
	) t1
GROUP BY 1;

---------------------------------------------------------------------

/*
What proportion of company names start with a vowel (a, e, i, o, u) 
and what percent start with anything else.
*/

SELECT first_character, COUNT(*)
FROM 
	(SELECT 
	 	name,
	 	CASE WHEN LEFT(UPPER(name),1) IN ('A','E','I','O','U') THEN 'vowel' ELSE 'not vowel'
	 	END AS first_character
	 FROM accounts
	) t1
GROUP BY 1;


---------------------------------------------------------------------

/*
Create first and last name columns that hold the first and last 
names for the primary poc.

Repeat the same thing for ever sales rep name.
*/

SELECT 
	primary_poc,
	LEFT(primary_poc, STRPOS(primary_poc, ' ')-1) first_name,
	RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name
FROM accounts
GROUP BY 1;

-- Sales rep name
													
SELECT 
	name,
	LEFT(name, STRPOS(name, ' ')-1) first_name,
	RIGHT(name, LENGTH(name) - STRPOS(name, ' ')) last_name
FROM sales_reps
GROUP BY 1;
									  
---------------------------------------------------------------------

/*
Each company in the accounts table wants to create an email address for each primary_poc. 
The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.
*/									  

SELECT 
	primary_poc,
	LEFT(primary_poc, STRPOS(primary_poc, ' ')) || '.' ||
	RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) || '@' ||
	REPLACE(name, ' ', '') || '.com'
FROM accounts;
													
---------------------------------------------------------------------

/*
We would also like to create an initial password, which they will change after their first log in. 
The first password will be the first letter of the primary_poc's first name (lowercase), 
then the last letter of their first name (lowercase), the first letter of their last name (lowercase), 
the last letter of their last name (lowercase), the number of letters in their first name, 
the number of letters in their last name, and then the name of the company they are working with, 
all capitalized with no spaces. 
*/

													
WITH 
	t1 AS 
		(SELECT 
		 	name, primary_poc,
		 	LEFT(primary_poc, STRPOS(primary_poc, ' ')-1) first_name,
		 	RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name
		 	FROM accounts
		)
SELECT
	name, first_name, last_name,
	LEFT(LOWER(first_name), 1) || 
	RIGHT(LOWER(first_name), 1) || 
	LEFT(LOWER(last_name), 1) || 
	RIGHT(LOWER(last_name), 1) ||
	LENGTH(first_name) || 
	LENGTH(last_name) || 
	UPPER(REPLACE(name, ' ', ''))
FROM t1;

				  
---------------------------------------------------------------------

/*
Fill the NULL values and get a value in every cell.
*/
				  
SELECT
	COUNT(primary_poc) AS regular_count,
	COUNT(COALESCE(primary_poc, 'no POC')) AS modified_count
FROM accounts;
				   			   
---------------------------------------------------------------------

/*
Run the query to notice the row with missing data.
*/
				   
SELECT *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;	
				   
				   
/*
Use COALESCE to fill in the account id column with the account id for the NULL value for the table above.			   
*/
				   
SELECT 
	COALESCE(a.id, a.id) filled_id, 
	a.name,	a.website, a.lat, a.long, 
	a.primary_poc, a.sales_rep_id,
	o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;
				   
		
				   
/*
Use COALESCE to fill in each of the qto and usd columns with 0 for the table above.			   
*/
				   
SELECT 
	COALESCE(a.id, a.id) filled_id, 
	a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, 
	COALESCE(o.account_id, a.id) account_id, o.occurred_at, 
	COALESCE(o.standard_qty, 0) standard_qty, COALESCE(o.gloss_qty,0) gloss_qty, 
	COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total, 
	COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, 
	COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;   