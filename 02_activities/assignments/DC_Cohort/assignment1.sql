 /* ASSIGNMENT 1 */
--Please write responses between the QUERY # and END QUERY blocks
/* SECTION 2 */


--SELECT
/* 1. Write a query that returns everything in the customer table. */
--QUERY 1
-- Return all columns from the specified table. "*" is indicative of selecting all the columns. 
SELECT *
FROM customer;
--END QUERY


/* 2. Write a query that displays all of the columns and 10 rows from the customer table, 
sorted by customer_last_name, then customer_first_ name. */

--QUERY 2
SELECT *
FROM customer 

-- sort the data by the two specified characteristics customer_last_name and customer_first_name.
ORDER BY customer_last_name, customer_first_name
LIMIT 10;

--END QUERY

--WHERE
/* 1. Write a query that returns all customer purchases of product IDs 4 and 9. 
Limit to 25 rows of output. */

--QUERY 3

SELECT *
FROM customer_purchases

-- return data only for the specified product_ids. 
WHERE product_id = 4 OR product_id = 9
LIMIT 25;

--END QUERY

/*2. Write a query that returns all customer purchases and a new calculated column 'price' (quantity * cost_per_quantity), 
filtered by customer IDs between 8 and 10 (inclusive) using either:
	1.  two conditions using AND
	2.  one condition using BETWEEN
Limit to 25 rows of output.
*/

--QUERY 4
SELECT *,
 
-- create a new colum price by executing a mutliplcation on the columns quantity and cost_per_quantity in customer_purchases.
	quantity * cost_per_quantity AS price
FROM customer_purchases

-- return data for the specified customer_ids. 
WHERE customer_id BETWEEN 8 AND 10
LIMIT 25;

--END QUERY


--CASE
/* 1. Products can be sold by the individual unit or by bulk measures like lbs. or oz. 
Using the product table, write a query that outputs the product_id and product_name
columns and add a column called prod_qty_type_condensed that displays the word “unit” 
if the product_qty_type is “unit,” and otherwise displays the word “bulk.” */

--QUERY 5

SELECT 
	product_id,
	product_name,
	
-- Update how the product_qty_type is displayed during the circumstances you define.
	CASE
		WHEN product_qty_type = 'unit' 
			THEN 'unit'
		ELSE 'bulk'
	END 
-- Display the new column (prod_qty_type_condensed)in the output. 
AS prod_qty_type_condensed
FROM product;

--END QUERY


/* 2. We want to flag all of the different types of pepper products that are sold at the market. 
add a column to the previous query called pepper_flag that outputs a 1 if the product_name 
contains the word “pepper” (regardless of capitalization), and otherwise outputs 0. */
--QUERY 6

SELECT *,
-- Search in product_name for any products that contain pepper in the name regardless of case.
-- The output should be 1 if the product does contain pepper and 0 if not.
	CASE
	-- LOWER converts the product names into lowercase so that case no longer matters when filtering.
	-- We specify to check whether the word 'pepper' is contained anywhere in product_name.
		WHEN LOWER(product_name) LIKE '%pepper%' 
			THEN 1
		ELSE 0
		
-- Display the new column (pepper_flag)with the 1 and 0 depending on the name of the product.
	END 
-- Speify the output of the CASE specified above is contained in a column called pepper_flag.
AS pepper_flag
FROM product;

--END QUERY


--JOIN
/* 1. Write a query that INNER JOINs the vendor table to the vendor_booth_assignments table on the 
vendor_id field they both have in common, and sorts the result by market_date, then vendor_name.
Limit to 24 rows of output. */

--QUERY 7

-- Selecting which columns to include in the output.
SELECT 
vendor_name, -- coming from the vendor table.
vendor_type,
vendor_owner_first_name,
vendor_owner_last_name,
booth_number,-- coming from the vendor_booth_assignments table.
market_date

-- When a column occurs in multiple places you must tell sql how to combine them in the output.
FROM vendor

INNER JOIN vendor_booth_assignments
-- In this case the column vendor_id occurs in both vendor and vendor_booth_assignments.
-- vendor_id acts as the link between the two tables. 
-- When we are using INNER JOIN, we are telling sql to join the two tables on the column vendor_id.
	ON vendor_booth_assignments.vendor_id = vendor.vendor_id
	
-- Note: Since vendor_id was not include in the SELECT area, it is not part of the output table. 

-- Sort the results by the two specified columns (market_date and vendor_name).
ORDER BY market_date, vendor_name
LIMIT 24;

--END QUERY


/* SECTION 3 */

-- AGGREGATE
/* 1. Write a query that determines how many times each vendor has rented a booth 
at the farmer’s market by counting the vendor booth assignments per vendor_id. */

--QUERY 8

SELECT
-- Puts all rows with the same vendor_id together. 
	vendor_id,
-- Counts the number of rows per vendor.
-- Names the new column of counts as times_rented.
	COUNT(*) AS times_rented
FROM vendor_booth_assignments
-- Display each vendor_id in the table once.
GROUP BY vendor_id;

--END QUERY


/* 2. The Farmer’s Market Customer Appreciation Committee wants to give a bumper 
sticker to everyone who has ever spent more than $2000 at the market. Write a query that generates a list 
of customers for them to give stickers to, sorted by last name, then first name. 

HINT: This query requires you to join two tables, use an aggregate function, and use the HAVING keyword. */

--QUERY 9

-- Creating a new temporary table called purchases_with_price
WITH purchases_with_price AS (
	SELECT 
	-- Selecting which columns to include in the output.
		customer.customer_id,
		customer.customer_first_name, -- coming from the customer table.
		customer.customer_last_name,
		customer_purchases.quantity,-- coming from the customer_purchases table.
		customer_purchases.cost_per_quantity,
		-- Creating a new column that calculates price for each purchase. 
		customer_purchases.quantity * customer_purchases.cost_per_quantity AS price

-- When a column occurs in multiple places you must tell sql how to combine them in the output.
-- We are indicating we want to join customer and customer_purchases.
	FROM customer
	INNER JOIN customer_purchases
-- In this case the column customer_id occurs in both customer and customer_purchases.
-- vendor_id acts as the link between the two tables. 
-- When we are using INNER JOIN, we are telling sql to join the two tables on the column customer_id.
	ON customer.customer_id = customer_purchases.customer_id)

-- Create an output that includes the following columns.
SELECT
	customer_id,
	customer_first_name,
	customer_last_name,
	-- Since we are trying to identify customers that spent more than $2000 having the total spent will confirm we are filtering correctly.
	SUM(price) AS total_spent
FROM purchases_with_price
-- Display each vendor_id in the table once.
GROUP BY customer_id
-- Filter the groups so that you only display customers who spent more than $2000.
HAVING SUM(price) > 2000
-- Sort those customers by last name then first name
ORDER BY customer_last_name, customer_first_name;
	
--END QUERY

--Temp Table
/* 1. Insert the original vendor table into a temp.new_vendor and then add a 10th vendor: 
Thomass Superfood Store, a Fresh Focused store, owned by Thomas Rosenthal

HINT: This is two total queries -- first create the table from the original, then insert the new 10th vendor. 
When inserting the new vendor, you need to appropriately align the columns to be inserted 
(there are five columns to be inserted, I've given you the details, but not the syntax) 

-> To insert the new row use VALUES, specifying the value you want for each column:
VALUES(col1,col2,col3,col4,col5) 
*/

--QUERY 10

--Ensures you do not get an error if the temporary table already exists.
DROP TABLE IF EXISTS temp.new_vendor; 

-- Create the temp.new_vendor from original vendor table.
CREATE TEMP TABLE temp.new_vendor AS
SELECT *
FROM vendor;

-- Insert the new vendor into the 10th row. 
INSERT INTO temp.new_vendor (
	vendor_id, 
	vendor_name, 
	vendor_type, 
	vendor_owner_first_name, 
	vendor_owner_last_name
)
-- Specify the values to include for each column. 
VALUES (
	10,
	'Thomass Superfood',
	'Fresh Focused',
	'Thomas',
	'Rosenthal'
)
;

SELECT *
FROM temp.new_vendor
ORDER BY vendor_id;

--END QUERY

-- Date
/*1. Get the customer_id, month, and year (in separate columns) of every purchase in the customer_purchases table.

HINT: you might need to search for strfrtime modifers sqlite on the web to know what the modifers for month 
and year are! 
Limit to 25 rows of output. */

--QUERY 11

-- Select the columns you want to dispaly. 
SELECT
	customer_id,
	-- Convert the date into separate columns for month and year using strfrtime modifiers. 
	--'%m' is for month; '%Y' is for year. 
	strftime('%m', market_date) AS month,
	strftime('%Y', market_date) AS year
FROM customer_purchases
LIMIT 25;

--END QUERY

/* 2. Using the previous query as a base, determine how much money each customer spent in April 2022. 
Remember that money spent is quantity*cost_per_quantity. 

HINTS: you will need to AGGREGATE, GROUP BY, and filter...
but remember, STRFTIME returns a STRING for your WHERE statement...
AND be sure you remove the LIMIT from the previous query before aggregating!! */

--QUERY 12

-- Select the rows to display in the output. In this case we only want customer_id and money_spent.
-- Since money_spent does not exist we calculate it using existing columns. 
SELECT
	customer_id,
	-- Calculates total spending per purchase.
	SUM (quantity * cost_per_quantity) AS money_spent
-- Specify what table the data is taken from.
FROM customer_purchases
WHERE
-- Use the data in market_date to identify the month and year of each purchase.
-- Filter for the month and year you want the output to display.
	-- Keeps only purchases made in April.
	strftime('%m', market_date) = '04'
	AND 
	-- Keeps only purchases made in 2022.
	strftime('%Y', market_date) = '2022'
-- Display one row per customer. 
GROUP BY customer_id
;

--END QUERY