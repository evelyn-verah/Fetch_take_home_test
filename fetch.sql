-- creating schema
DROP SCHEMA IF EXISTS Fetch_Task;
CREATE SCHEMA Fetch_Task;
USE Fetch_Task;

-- creating users table 
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id VARCHAR(255) PRIMARY KEY,
    created_date DATETIME,
    birth_date DATETIME,
    state VARCHAR(100),
    language VARCHAR(50),
    gender VARCHAR(50)
);
-- creating transactions table
DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
    receipt_id VARCHAR(255),
    purchase_date VARCHAR(255),
    scan_date VARCHAR(255),
    store_name VARCHAR(255),
    user_id VARCHAR(255),
    barcode VARCHAR(255),
    final_quantity VARCHAR(255),
    final_sale VARCHAR(255)
   --  FOREIGN KEY (user_id) REFERENCES users(id)
);
-- creating products tables
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    category_1 VARCHAR(255),
    category_2 VARCHAR(255),
    category_3 VARCHAR(255),
    category_4 VARCHAR(255),
    manufacturer VARCHAR(255),
	brand VARCHAR(255),
    barcode VARCHAR(255)
   
);
SET GLOBAL local_infile = 1;

-- Loading users Data
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\USER_TAKEHOME.csv'
INTO TABLE Users 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(id, created_date, birth_date, state, language, gender);

SHOW VARIABLES LIKE 'secure_file_priv';

-- Loading transaction Data
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\TRANSACTION_TAKEHOME.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(receipt_id, purchase_date, scan_date, store_name, user_id, barcode, final_quantity, final_sale);
SHOW WARNINGS;

SET GLOBAL sql_mode='';

-- loading products data
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.4\\Uploads\\PRODUCTS_TAKEHOME.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(category_1, category_2, category_3, category_4, manufacturer,brand,barcode);
SHOW WARNINGS;

-- Confirm the data loaded successfully
SELECT * FROM products;

-- TASK 1: Top 5 brands by receipts scanned among users 21+
WITH BrandCounts AS (
    SELECT DISTINCT t.receipt_id, p.brand
    FROM Transactions t
    JOIN Products p ON t.barcode = p.barcode
    JOIN Users u ON t.user_id = u.id
    WHERE TIMESTAMPDIFF(YEAR, u.birth_date, CURDATE()) >= 21  -- Only include users who are 21 or older
    AND p.brand IS NOT NULL
    AND p.brand <> ''  -- Filter out NULL and empty brands
)
SELECT 
    brand, 
    COUNT(receipt_id) AS unique_receipt_count
FROM BrandCounts
GROUP BY brand
ORDER BY unique_receipt_count DESC
LIMIT 5;

-- TASK 2: Identify Fetch’s power users?
-- Who are Fetch’s power users? 
-- Option 1: Assume Fetch Power Users are the ones Contributing to 80% of Receipt Uploads.
-- This query identifies users who contribute 80% of uploaded receipts(pareto analysis)
-- Step 1: Calculate the total number of unique receipts per user

WITH ReceiptsByUser AS (
    SELECT 
        t.user_id, 
        COUNT(DISTINCT t.receipt_id) AS total_receipts  -- Count unique receipt IDs per user
    FROM Transactions t
    GROUP BY t.user_id
),
-- Step 2: Compute cumulative receipts and total receipts
CumulativeReceipts AS (
    SELECT 
        user_id, 
        total_receipts,
        -- Calculate running total of receipts ordered from highest to lowest
        SUM(total_receipts) OVER (ORDER BY total_receipts DESC) AS running_total,  -- should be incremental as users add more receipts. 
        -- Compute the grand total of all receipts across all users
        SUM(total_receipts) OVER () AS grand_total
    FROM ReceiptsByUser
)
-- Step 3: Identify the users contributing to the top 80% of receipts
SELECT 
    user_id, 
    -- Compute the percentage of receipts contributed by running total
    running_total / grand_total AS receipt_percentage
FROM CumulativeReceipts
WHERE running_total <= 0.8 * grand_total  -- Select users contributing to 80% of total receipts
ORDER BY total_receipts DESC;  -- Sort results by highest receipt count

-- Option 2: Assume Fetch Power Users are the ones contributing 80% of total revenue.
-- This query identifies users who contribute 80% of total revenue(pareto analysis)
WITH RevenueByUser AS (
    -- Step 1: Calculate total revenue spent by each user.
    -- 'total_spent' is computed by multiplying 'FINAL_QUANTITY' (converted to an integer,
    -- with 'zero' mapped to 0) by 'final_sale' for each transaction, then summing by user.
    SELECT 
        t.user_id, 
        SUM(
            CASE 
                WHEN t.FINAL_QUANTITY = 'zero' THEN 0
                ELSE CAST(t.FINAL_QUANTITY AS UNSIGNED)
            END * t.final_sale
        ) AS total_spent
    FROM Transactions t
    GROUP BY t.user_id
),
CumulativeRevenue AS (
    -- Step 2: Compute the cumulative (running) total of revenue in descending order.
    -- Also compute the grand total of all users' revenue for reference.
    SELECT 
        user_id, 
        total_spent,
        -- Running total of 'total_spent' across all users, sorted descending by 'total_spent'
        SUM(total_spent) OVER (ORDER BY total_spent DESC) AS running_total,
        -- Grand total of 'total_spent' across all users
        SUM(total_spent) OVER () AS grand_total
    FROM RevenueByUser
)
-- Step 3: Select only those users whose running total is within 80% of the grand total.
-- Sort the result by 'total_spent' in descending order to identify the largest contributors first.
SELECT 
    user_id, 
    running_total / grand_total AS revenue_percentage
FROM CumulativeRevenue
WHERE running_total <= 0.8 * grand_total
ORDER BY total_spent DESC;

-- Option 3: Assume Fetch Power Users are the ones contributing 80% of total transactions.
	-- This query identifies users who contribute 80% of transactions (pareto analysis)
WITH user_transactions AS (
    -- Step 1: Aggregate the total number of transactions per user.
    -- Here, simply count all receipt IDs associated with each user.
    SELECT 
        USER_ID AS user_id,
        COUNT(RECEIPT_ID) AS transaction_count
    FROM 
        transactions
    GROUP BY 
        USER_ID
),
transactions_with_running_total AS (
    -- Step 2: For each user, compute a running total (descending) of transaction counts and the grand total of all transactions.
    --    SUM(transaction_count) OVER (ORDER BY transaction_count DESC)
    --    gives a cumulative sum of transaction counts from highest to lowest.
    --    SUM(transaction_count) OVER ()
    --    calculates the grand total of transactions across all users.
    SELECT 
        user_id,
        transaction_count,
        SUM(transaction_count) OVER (ORDER BY transaction_count DESC) AS running_total,
        SUM(transaction_count) OVER () AS grand_total
    FROM 
        user_transactions
)
	-- Step 3: Select the users whose cumulative transaction counts fall within 80% of the grand total.
	--     Order the results by transaction_count in descending order.
SELECT 
user_id,
    (running_total / grand_total * 100) AS cumulative_percentage
FROM 
    transactions_with_running_total
WHERE 
    running_total <= 0.8 * grand_total
ORDER BY 
    transaction_count DESC;

-- TASK 3: Identify leading brand in the Dips & Salsa category?
-- Assumption - leading brand is determined by a combination of the total number of units sold and revenue the brand generates.

-- Step 1: Clean and preprocess the transaction data
WITH Transactions_Cleaned AS (
    SELECT 
        t.BARCODE,  -- Keep only relevant columns (BARCODE needed for join)
       
        -- Convert FINAL_QUANTITY to a numeric value
        -- If 'zero', set it to 0
        -- If NULL or an empty string, keep it NULL
        -- Otherwise, cast it as an integer
        CASE 
            WHEN t.FINAL_QUANTITY = 'zero' THEN 0
            WHEN t.FINAL_QUANTITY IS NULL OR t.FINAL_QUANTITY = '' THEN NULL
            ELSE CAST(t.FINAL_QUANTITY AS UNSIGNED)
        END AS FINAL_QUANTITY_NUMERIC,

        -- Convert FINAL_SALE to a decimal value
        -- If NULL or empty, keep it NULL
        -- Otherwise, cast it as a decimal (to maintain precision)
        CASE 
            WHEN t.FINAL_SALE IS NULL OR t.FINAL_SALE = '' THEN NULL
            ELSE CAST(t.FINAL_SALE AS DECIMAL(10,2))
        END AS FINAL_SALE_AMOUNT
    FROM Transactions t  -- Transactions table containing purchase data
),

-- Step 2: Aggregate total sales revenue and units sold per brand
Brand_Sales AS (
    SELECT  
        p.brand,  -- Get brand name from the Products table

        -- Calculate total units sold for each brand
        SUM(tc.FINAL_QUANTITY_NUMERIC) AS total_units_sold,

        -- Calculate total sales revenue (quantity * sale amount)
        SUM(tc.FINAL_QUANTITY_NUMERIC * tc.FINAL_SALE_AMOUNT) AS total_sales_revenue
    FROM 
        Products p  -- Products table contains brand and category info
    JOIN 
        Transactions_Cleaned tc ON p.BARCODE = tc.BARCODE  -- Join transactions with products

    -- Filter data to ensure accuracy
    WHERE 
        p.category_2 = 'Dips & Salsa'  -- Only include items from 'Dips & Salsa' category
        AND tc.FINAL_QUANTITY_NUMERIC IS NOT NULL  -- Exclude missing quantities
        AND tc.FINAL_QUANTITY_NUMERIC > 0  -- Ignore zero-quantity sales
        AND tc.FINAL_SALE_AMOUNT IS NOT NULL  -- Exclude transactions with missing prices
        AND p.brand IS NOT NULL  -- Ensure brand names exist
        AND p.brand <> ''  
    GROUP BY 
        p.brand  -- Aggregate by brand name
),
-- Step 3: Identify top brands by revenue and units sold
Top_Brands AS (
    -- Get the top 5 brands ranked by total sales revenue
    (SELECT brand FROM Brand_Sales 
     ORDER BY total_sales_revenue DESC 
     LIMIT 1)
    
    UNION  -- Combine results from both rankings

    -- Get the top 5 brands ranked by total units sold
    (SELECT brand FROM Brand_Sales 
     ORDER BY total_units_sold DESC 
     LIMIT 1)
)
-- Step 4: Select unique brand names from both rankings
SELECT DISTINCT brand FROM Top_Brands;

    