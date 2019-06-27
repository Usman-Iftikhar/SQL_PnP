-- Pull all the inforamtion from orders and accounts table.

SELECT *
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

-- Pull QTY data from orders and website and primary_poc from accounts

SELECT orders.standard_qty, orders.gloss_qty, orders.poster_qty, accounts.website, accounts.primary_poc
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

-- Provide a table that provides the region for each sales_rep along with their associated accounts. 
-- Your final table should include three columns: the region name, the sales rep name, and the account name. 
-- Sort the accounts alphabetically (A-Z) according to account name. 

SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
ORDER BY a.name;