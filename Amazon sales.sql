-- Step 1: Create the Amazon database
CREATE DATABASE AMAZON;

-- Step 2: Switch to the Amazon database for use
USE AMAZON;

-- Step 3: Create a table to store sales data, incorporating key sales attributes
CREATE TABLE amazon_sales_data (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,    -- Unique Invoice Identifier
    branch VARCHAR(5) NOT NULL,                     -- Branch code
    city VARCHAR(30) NOT NULL,                      -- City where the transaction occurred
    customer_type VARCHAR(30) NOT NULL,             -- Customer type (Member/Normal)
    gender VARCHAR(10) NOT NULL,                    -- Gender of the customer
    product_line VARCHAR(100) NOT NULL,             -- Product category
    unit_price DECIMAL(10,2) NOT NULL,              -- Price per unit of the product
    quantity INT(20) NOT NULL,                      -- Quantity of product sold
    tax_pct FLOAT(6,4) NOT NULL,                    -- Tax percentage
    total DECIMAL(12, 4) NOT NULL,                  -- Total sales amount (with tax)
    date DATETIME NOT NULL,                         -- Transaction date
    time TIME NOT NULL,                             -- Transaction time
    payment VARCHAR(15) NOT NULL,                   -- Payment method (Cash/Credit)
    cogs DECIMAL(10,2) NOT NULL,                    -- Cost of Goods Sold (COGS)
    gross_margin_pct FLOAT(11,9),                   -- Gross Margin Percentage
    gross_income DECIMAL(12, 4),                    -- Gross income from the sale
    rating FLOAT(2, 1)                              -- Customer rating for the product
);

-- Feature Engineering
-- 1. Time of Day Classification for Sales
      Added a new column time_of_day to classify transactions based on the time of purchase, helping to identify when sales peak (Morning, Afternoon, Evening, Night).

-- Step 1: Classify transactions based on the time of day
           ALTER TABLE amazon_sales_data ADD COLUMN time_of_day VARCHAR(20);

-- Step 2: Update the table to include the time of day
           UPDATE amazon_sales_data
           SET time_of_day = (
    CASE
        WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        WHEN `time` BETWEEN '17:01:00' AND '20:00:00' THEN 'Evening'
        ELSE 'Night'
    END
);
 -- 2. Weekday Analysis
       Added a new column day_name that extracts the day of the week from the transaction date to determine which days are busiest for each branch.

-- Step 1: Add a column for day of the week
           ALTER TABLE amazon_sales_data ADD COLUMN day_name VARCHAR(10);

-- Step 2: Populate the new column with the day of the week derived from the transaction date
           UPDATE amazon_sales_data
           SET day_name = DAYNAME(date);


-- 3. Monthly Analysis
      Added a new column month_name to extract the month of the year from the transaction date, allowing the identification of peak sales months.

-- Step 1: Add a column for the month name
           ALTER TABLE amazon_sales_data ADD COLUMN month_name VARCHAR(10);

-- Step 2: Populate the new column with the month derived from the transaction date
           UPDATE amazon_sales_data
          SET month_name = MONTHNAME(date);

-- Business Questions To Answer:

-- 1. What is the count of distinct cities in the dataset?
      SELECT COUNT(DISTINCT city) AS distinct_cities FROM amazon_sales_data;


-- 2. For each branch, what is the corresponding city?
      SELECT branch, city FROM amazon_sales_data GROUP BY branch, city;

 --3. What is the count of distinct product lines in the dataset?
      SELECT COUNT(DISTINCT product_line) AS distinct_product_lines FROM amazon_sales_data;

-- 4.  Which payment method occurs most frequently?
       WITH payment_counts AS (
       SELECT payment, COUNT(payment) AS payment_count
       FROM amazon_sales_data
       GROUP BY payment
)
       SELECT payment, payment_count
       FROM payment_counts
       ORDER BY payment_count DESC
       LIMIT 1;

-- 5. How much revenue is generated each month?
      SELECT month_name, SUM(total) AS total_revenue 
      FROM amazon_sales_data 
      GROUP BY month_name 
      ORDER BY total_revenue DESC;

-- 6. In which month did the cost of goods sold reach its peak?
      WITH monthly_cogs AS (
    SELECT month_name, SUM(cogs) AS total_cogs
    FROM amazon_sales_data
    GROUP BY month_name
)
    SELECT month_name, total_cogs
    FROM (
    SELECT month_name, total_cogs, 
           RANK() OVER (ORDER BY total_cogs DESC) AS cogs_rank
    FROM monthly_cogs
)   ranked_cogs
    WHERE cogs_rank = 1;

-- 7. Which product line generated the highest revenue?
      SELECT product_line, SUM(total) AS total_revenue
      FROM amazon_sales_data
      GROUP BY product_line
      ORDER BY total_revenue DESC
      LIMIT 1;


-- 8. In which city was the highest revenue recorded?
      WITH city_revenue AS (
      SELECT city, SUM(total) AS total_revenue
      FROM amazon_sales_data
      GROUP BY city
)
      SELECT city, total_revenue
      FROM city_revenue
      ORDER BY total_revenue DESC
      LIMIT 1;
 
 --9. Which product line incurred the highest Value Added 
      SELECT product_line, SUM(tax_pct) AS total_vat
      FROM amazon_sales_data
      GROUP BY product_line
      ORDER BY total_vat DESC
      LIMIT 1;
-- 10. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
       SELECT  AVG(quantity) AS avg_qnty FROM amazon_sales_data;
       SELECT product_line,
       CASE
       WHEN AVG(quantity) > 6 THEN "Good"
       ELSE "Bad"
       END AS remark
       FROM amazon_sales_data
       GROUP BY product_line; 

-- 11. Identify the branch that exceeded the average number of products sold.
       SELECT branch, SUM(quantity) AS total_quantity
       FROM amazon_sales_data
       GROUP BY branch
       HAVING SUM(quantity) > (SELECT AVG(quantity) FROM amazon_sales_data);

    
-- 12. Which product line is most frequently associated with each gender?
       SELECT gender, product_line, COUNT(*) AS total_count
       FROM amazon_sales_data
       GROUP BY gender, product_line
       ORDER BY total_count DESC;
    
-- 13. Calculate the average rating for each product line.
       SELECT product_line, ROUND(AVG(rating), 2) AS avg_rating
       FROM amazon_sales_data
       GROUP BY product_line
       ORDER BY avg_rating DESC;

-- 14. Count the sales occurrences for each time of day on every weekday.
       select time_of_day,count(*) as total_sales
       from amazon_sales_data where day_name = "Sunday"
       group by time_of_day    
       order by total_sales desc;

-- 15. Identify the customer type contributing the highest revenue.
       select customer_type, round (sum(total), 2) as total_revenue
       from amazon_sales_data group by customer_type
       order by total_revenue;
   
-- 16. Determine the city with the highest VAT percentage.
       SELECT city, SUM(tax_PCT) AS total_VAT
       FROM AMAZON_sales_DATA GROUP BY city ORDER BY total_VAT DESC LIMIT 3;

-- 17. Identify the customer type with the highest VAT payments.
       SELECT customer_type, SUM(tax_pct) AS total_vat
       FROM amazon_sales_data
       GROUP BY customer_type
       ORDER BY total_vat DESC
       LIMIT 1;


-- 18. What is the count of distinct customer types in the dataset?
       SELECT COUNT(DISTINCT customer_type) AS distinct_customer_types FROM amazon_sales_data;

-- 19. What is the count of distinct payment methods in the dataset?
       SELECT COUNT(DISTINCT payment) AS distinct_payment_methods FROM amazon_sales_data;

-- 20. Which customer type occurs most frequently?
       SELECT customer_type, SUM(total) as total_sales
       FROM AMAZON_sales_DATA GROUP BY customer_type ORDER BY total_sales LIMIT 1;

-- 21. Identify the customer type with the highest purchase frequency.
       SELECT customer_type, COUNT(customer_type) AS purchase_count
       FROM amazon_sales_data
       GROUP BY customer_type
       ORDER BY purchase_count DESC
       LIMIT 1;

-- 22. Determine the predominant gender among customers.
       SELECT gender, COUNT(*) AS all_genders 
       FROM AMAZON_sales_DATA GROUP BY gender ORDER BY all_genders DESC LIMIT 1;

-- 23. Examine the distribution of genders within each branch.
       SELECT branch, gender, COUNT(*) AS gender_distribution
       FROM amazon_sales_data
       GROUP BY branch, gender
       ORDER BY branch, gender;


-- 24. Identify the time of day when customers provide the most ratings.
       SELECT branch, gender, COUNT(gender) AS gender_distribution
       FROM AMAZON_sales_DATA GROUP BY branch, gender ORDER BY branch;

-- 25. Determine the time of day with the highest customer ratings for each branch.
       WITH avg_ratings AS (
       SELECT branch, time_of_day, AVG(rating) AS avg_rating
       FROM amazon_sales_data
       GROUP BY branch, time_of_day
)
       SELECT branch, time_of_day, avg_rating
       FROM avg_ratings
       ORDER BY avg_rating DESC;

-- 26. Identify the day of the week with the highest average ratings.
       SELECT day_name, AVG(rating) AS average_rating
       FROM AMAZON_sales_DATA GROUP BY day_name ORDER BY average_rating DESC LIMIT 1;

-- 27. Determine the day of the week with the highest average ratings for each branch.
       WITH day_branch_ratings AS (
       SELECT branch, day_name, AVG(rating) AS avg_rating
       FROM amazon_sales_data
       GROUP BY branch, day_name
)
       SELECT branch, day_name, avg_rating
       FROM day_branch_ratings ORDER BY avg_rating DESC;







