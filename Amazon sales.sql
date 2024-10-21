
CREATE DATABASE  AMAZON;

USE AMAZON;
-- Data Wrangling
-- checking null values so null values are present in this dataset.
CREATE TABLE amazon_sales_data(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL,
quantity INT(20) NOT NULL,
tax_pct FLOAT(6,4) NOT NULL,
total DECIMAL(12, 4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment VARCHAR(15) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
gross_margin_pct FLOAT(11,9),
gross_income DECIMAL(12, 4),
rating FLOAT(2, 1)
);

-- Feature Engineering
-- 2.1 Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. This will help answer the question on which part of the day most sales are ma        

SELECT time,

(CASE 
	WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
	WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
    WHEN `time` BETWEEN "17:01:00" AND "20:00:00" THEN "EVENING"
	ELSE "NIGHT" 
END) AS time_of_day
FROM AMAZON_sales_data ;

ALTER TABLE AMAZON_sales_data ADD COLUMN time_of_day VARCHAR(20);

UPDATE AMAZON_sales_data
SET time_of_day = (
	CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		WHEN `time` BETWEEN "17:01:00" AND "20:00:00" THEN "EVENING"
	ELSE "NIGHT" 
	END
);
 -- 2.2 Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each branch is busiest.
select date,dayname(date) from amazon_sales_data;
ALTER TABLE AMAZON_sales_data ADD COLUMN day_name VARCHAR(10);
UPDATE AMAZON_sales_data set day_name=dayname(date);
UPDATE AMAZON_sales_data
SET date= date_format(str_to_date(date,'%d-%m-%Y'), '%Y-%m-%d');


-- 2.3 Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit.        

ALTER TABLE AMAZON_sales_data ADD COLUMN month_name VARCHAR(10);

UPDATE AMAZON_sales_data
SET month_name = MONTHNAME(date);

select * from amazon_sales_data;

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
) ranked_cogs
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
FROM day_branch_ratings
ORDER BY avg_rating DESC;







