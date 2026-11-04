/* ASSIGNMENT 2 */
--Please write responses between the QUERY # and END QUERY blocks
/* SECTION 2 */

-- COALESCE
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list:

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product


But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a blank for the first column with
nulls, and 'unit' for the second column with nulls. 

**HINT**: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same. */

--QUERY 1

SELECT
-- COALESCE returns the first non-NULL value.
-- If the column value is NULL, the specified replacement value is returned instead.
-- Note: || in sequel joins pieces of text together. Here we are telling sql to take each element specified and put it together.
	-- We are indicating inside the COALESCE arugment to replace NULL with a blank for either of the first two colums.
	product_name || ', ' || 
	COALESCE(product_size, '')|| ' (' || 
	-- We are indicating inside the COALESCE argument to replace NULL with 'unit; for the third column. 
	COALESCE(product_qty_type, 'unit') || ')'
-- The output is based off of data taken from the table product.
FROM product
;

--END QUERY

--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). 
Filter the visits to dates before April 29, 2022. */

--QUERY 2a

-- DENSE_RANK approach
	-- Keeps all purchase rows and have the visit number change only when the date changes.
SELECT
	-- Display selected columns. 
	product_id,
	vendor_id,
	market_date,
	customer_id,
	quantity, 
	cost_per_quantity,
	transaction_time,
	DENSE_RANK() OVER (
		-- Restarts the counting for each customer_id.
		PARTITION BY customer_id
		-- Put each customer's visits in order of the market_date.
	--Note: OVER enables us to tell SQL what sets of rows should be numbered (PARTITION) and in what order (ORDER BY).
		ORDER BY market_date) 
		-- Display the count column as visits.
		AS visits
FROM customer_purchases
-- Only display visits for dates before April 29, 2022. 
WHERE market_date < '2022-04-29'
;

-- END QUERY

--QUERY 2b

-- ROW_NUMBER approach
	-- Reduces data to one row per unique customer_id and market_date and then numbers the visits. 
SELECT
	-- Display selected columns. 
	market_date,
	customer_id,
	ROW_NUMBER() OVER (
		-- Restarts the count for each customer_id
		PARTITION by customer_id
		-- Put each customer's visits in order of the market_date.
		ORDER BY market_date)
	--Note: OVER enables us to tell SQL what sets of rows should be numbered (PARTITION) and in what order (ORDER BY).
	-- Display the count column as visits.
	AS visits
-- Only select rows with disinct combinations of customer_id and market_date. 
-- This ensures 1 row represents each visit per customer.
-- The execution of numbering and ordering is being effected on the distinct subset of rows only. 
FROM (
	SELECT DISTINCT
		customer_id,
		market_date
	FROM customer_purchases
-- Only display visits for dates before April 29, 2022. 
	WHERE market_date < '2022-04-29')
;

--END QUERY

/* 2. Reverse the numbering of the query so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit.
HINT: Do not use the previous visit dates filter. */

--QUERY 3

-- Only display these two columns in the final output.
SELECT
	market_date,
	customer_id
FROM (
	SELECT DISTINCT
	-- Display distinct combinations of market_date and customer_id. 
		market_date,
		customer_id,
		DENSE_RANK() OVER 
			-- Start the counting separately for each customer_id.
			(PARTITION BY customer_id
			-- Put each customer's visits in order of the market_date.
			-- DESC ensures the visits are listed in descending order.
			-- This means the most recent visit will get rank 1.
			ORDER BY market_date DESC) 
		-- Display the count column as visits.
		AS visits
	FROM customer_purchases)
-- Only display the most recent visit numbered as 1.
WHERE visits = 1
;

--END QUERY

/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. 

You can make this a running count by including an ORDER BY within the PARTITION BY if desired.
Filter the visits to dates before April 29, 2022. */

--QUERY 4

-- Display these three columns in the output. 
SELECT
	product_id,
	customer_id,
	market_date,
	-- Count the number of rows for the data specified in the following argument.
	COUNT(*) OVER (
		-- Counts are applied for each group of rows defined by unique combinations of customer_id and product_id.
		PARTITION BY customer_id, product_id
		-- ORDER BY makes it a running count where the tally is updated as the item is purchased subsequently. 
		ORDER BY market_date) 
		-- Display the number of times purchased in a new colum called times_purchased. 
		AS times_purchased
-- Rows of the selected columns are retrieved from customer_purchases table.
FROM customer_purchases
-- Only market dates before April 29 2022 are displayed. 
WHERE market_date < '2022-04-29'
;

--END QUERY

-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */

--QUERY 5

SELECT
	-- The data we are looking at is only product name.
    product_name,
	-- Defining how we will identify and present product description using CASE.
    CASE
		-- Identify rows where there is a '-' in the product name.
        WHEN INSTR(product_name, '-') > 0
		-- If there is a '-' in the product name return the part of product name 2 spaces after the dash.
		-- Note: TRIM removes any trailing or leading whitespaces from the output which was requested in the question. 
        THEN TRIM(
			-- SUBSTR returns the string at the specified location within the original string. In this case 2 spaces after the '-' in product_name.
			SUBSTR(
				product_name,
				INSTR(product_name, '-') + 2 ))
		-- If there is no '-' in the product name return NULL. 
        ELSE NULL
	-- We must end the CASE statement before proceeding.
    END 
	-- Display the result in a new column called description. 
	AS description
-- The data is from the table product_name
FROM product
;

--END QUERY

/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */

--QUERY 6

-- Take all columns from product table.
SELECT *
FROM product 
-- Return rows where product_size includes a number from 0 to 9.
WHERE product_size REGEXP '[0-9]'
;

-- END QUERY

-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */

--QUERY 7

-- Creating a temporary table called sales
DROP TABLE IF EXISTS sales;
CREATE TEMP TABLE sales AS
-- Select market_date and total_sales to be included in the temporary table.
SELECT
	market_date,
	-- total_sales is computed as the quantity * cost_per_quantity and displayed in the table as total_sales.
	SUM(quantity * cost_per_quantity) AS total_sales
-- Data is taken from the customer_purchases table. 
FROM customer_purchases
-- Tells sql to group all the rows with the same market_date and sum the total_sales for that date. 
GROUP BY market_date
-- Order the table by ascending total_sales (worst to best day). 
ORDER BY total_sales DESC;

-- Creating a temporary table called bestday
DROP TABLE IF EXISTS bestday;
CREATE TEMP TABLE bestday AS
-- Isolate the best day of sales from the temp table sales. 
-- Select all the data and order by descending (DESC).
SELECT *
	FROM sales
	ORDER by total_sales DESC
	-- Only include the first row, i.e. best day. 
	LIMIT 1; 

-- Creating a temporary table called worstday
DROP TABLE IF EXISTS worstday;
CREATE TEMP TABLE worstday AS
-- Select all the data and order by ascending (ASC)
SELECT *
	FROM sales
	ORDER by total_sales ASC
	-- Only include the first row, i.e. worst day.
	LIMIT 1; 

--Combine the bestday and worstday into an output. 
SELECT
	market_date,
	total_sales,
	'best day' as day_type
FROM bestday

UNION

SELECT
	market_date,
	total_sales,
	'worst day' as day_type
FROM worstday
;

--END QUERY

/* SECTION 3 */

-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

--QUERY 8

-- Create a temp table of distinct combinations of vendor, product and prices from the table vendor_inventory.
DROP TABLE IF EXISTS vendor_product_cross;
CREATE TEMP TABLE vendor_product_cross AS
SELECT DISTINCT
	vendor_id,
	product_id,
	original_price
FROM vendor_inventory
;
 
-- Create a temp table of unique customer_id
DROP TABLE IF EXISTS customer_cross;
CREATE TEMP TABLE customer_cross AS
SELECT
	customer_id
FROM customer;

-- Create a temp table that includes the total revenue for each vendor, product combination if they sold 5 of each item.
DROP TABLE IF EXISTS final_cross;
CREATE TEMP TABLE final_cross AS
SELECT
	vendor_id,
	product_id,
	SUM(original_price * 5) AS revenue
FROM vendor_product_cross
-- Cross join the combinations for each customer.
CROSS JOIN customer_cross
-- Group by unique vendor and product combinations where the revenue will be the sum of all rows that match on both criteria.
GROUP BY vendor_id, product_id;

-- Display revenue, vendor_name and product_name in the final output. 
SELECT
	final_cross.revenue,
	vendor.vendor_name,
	product.product_name
FROM final_cross
-- Join final_cross with vendor on vendor_id so that the vendor name is displayed. 
JOIN vendor
	ON final_cross.vendor_id = vendor.vendor_id
-- Join final_cross with product on product_id so that the product name is displayed. 
JOIN product
	ON final_cross.product_id = product.product_id;

--END QUERY

-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

--QUERY 9

-- We are creating a new table called product_units.
DROP TABLE IF EXISTS product_units;
CREATE TABLE product_units AS
-- We are selecting specific columns from the table product.
SELECT
	product_id,
	product_name,
	product_size,
	product_qty_type,
	product_category_id,
	-- We are adding an additional column to the table that is the CURRENT_TIMESTAMP which we label snapshot_timestamp.
	CURRENT_TIMESTAMP AS snapshot_timestamp
FROM product
-- We specify we only want product with product_qty_type that has 'unit' in the name. 
WHERE product_qty_type = 'unit'
;

--END QUERY

/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */
--QUERY 10

-- INSERT INTO allows us to select the table you want to add a row to.
INSERT INTO product_units
	-- We specify what values we want to add in each colum. 
	-- The command CURRENT_TIMESTAMP records the actual time when you add the new row. 
	VALUES (7, 'Apple Pie', '10"', 'unit', '3', CURRENT_TIMESTAMP);

--END QUERY

-- DELETE
/* 1. Delete the older record for whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

--QUERY 11

-- DELETE FROM allows us to specify the table we want to remove a row from.
-- Note: we often use SELECT first to test whether the correct row is being specified before making a deletion.
DELETE FROM product_units
-- Here we are specifying what characteristics we want to use to select the row to delete. 
-- ROWID enables us to specify one specific row from the table. 
WHERE ROWID = 
	(SELECT ROWID 
	-- The row we are selecting for deletion is from the table product_units.
	FROM product_units
	-- The product_id we are filtering by is 7.
	WHERE product_id = 7
	-- Since we want to delete the oldest entry for product_id 7, we are ordering all rows with that id by snapshot_timestamp
	-- We specify that we want to order in ascending order (ASC) so the oldest will be the first row. 
	ORDER BY snapshot_timestamp ASC
	-- We want to select the older entry so we select just the first row by limiting the selection to 1.
	LIMIT 1);

--END QUERY

-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */

--QUERY 12

-- Add empty column called current_quantity to the table. 
ALTER TABLE product_units
ADD current_quantity INT;

-- Create a temp table of distinct combinations of vendor, product and prices from the table vendor_inventory.
DROP TABLE IF EXISTS last_quantity;
CREATE TEMP TABLE last_quantity AS
-- This outer query specifies we only want to return the last_record for each product.product_category_id
-- We put the * because we want all the last columns from the inner query. 
SELECT *
FROM (	
-- We need the inner query because we are creating the colum last_record which is ultimately used to identify the ones we want to display in the final output. 
-- We use last_record to identify the most recent occurence. 
	SELECT
		-- These are the variables from vendor_inventory we need to identify the last quantity. 
		market_date,
		quantity,
		product_id,
		-- We number the occurences of product_id in descending order by market_date.
		-- The most recent purchase of that product would be the first row. 
		ROW_NUMBER() OVER
			-- Numbering restarts for each product_id. 
			(PARTITION BY product_id
			-- Rows are ordered by the most recent to least recent using market_date. 
			ORDER BY market_date DESC)
		-- Save the numbering of the occurences in a column called last_record. 
		AS record
	-- Data used to generate this temporary table was taken from the table vendor_inventory. 
	FROM vendor_inventory)
-- Select only the first row of the new column last_record.
-- This table therefore only includes the most recent inventory record of each product.  
WHERE record = 1;

-- Update the column current_quantity in product_units to the quantity from the most recent purchase of the product.  
UPDATE product_units
SET current_quantity =
	COALESCE (
		(SELECT quantity
		FROM last_quantity
		-- Only current_quantity in the table product_units for rows where the product_id matches.
		WHERE last_quantity.product_id = product_units.product_id)
	,
	-- If a product has no matching row in last_quantity, the current_quantity for that product will be set to 0.
	0)
;

--END QUERY
