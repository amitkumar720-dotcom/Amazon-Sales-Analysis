-- Sales Analysis

-- 1. Count the sales occurrences for each time of day on every weekday.
       select time_of_day,count(*) as total_sales
       from amazon_sales_data where day_name = "Sunday"
       group by time_of_day    
       order by total_sales desc;

-- 2. Identify the customer type contributing the highest revenue.
       select customer_type, round (sum(total), 2) as total_revenue
       from amazon_sales_data group by customer_type
       order by total_revenue;
   
-- 3. Determine the city with the highest VAT percentage.
       SELECT city, SUM(tax_PCT) AS total_VAT
       FROM AMAZON_sales_DATA GROUP BY city ORDER BY total_VAT DESC LIMIT 3;

-- 4. Identify the customer type with the highest VAT payments.
       SELECT customer_type, SUM(TAX_PCT) AS total_VAT
       FROM AMAZON_sales_DATA GROUP BY customer_type ORDER BY total_VAT DESC LIMIT 1;

-- 5. What is the count of distinct customer types in the dataset?
       SELECT COUNT(DISTINCT customer_type) FROM AMAZON_sales_DATA;
      
-- 5.. What is the count of distinct payment methods in the dataset?
        SELECT COUNT(DISTINCT PAYMENT) FROM AMAZON_sales_DATA;

-- 6. Which customer type occurs most frequently?
       SELECT customer_type, SUM(total) as total_sales
       FROM AMAZON_sales_DATA GROUP BY customer_type ORDER BY total_sales LIMIT 1;