
-- Product Analysis

-- 1. What is the count of distinct cities in the dataset?
      select count(distinct city)from amazon_sales_data;
      
-- 2. For each branch, what is the corresponding city?
      select branch,city from amazon_sales_data;
      
-- 3. What is the count of distinct product lines in the dataset?
	  select count(distinct product_line )from amazon_sales_data;
      
-- 4. Which payment method occurs most frequently?
      SELECT payment, COUNT(payment) AS common_payment_method 
      FROM amazon_sales_data GROUP BY payment ORDER BY common_payment_method DESC LIMIT 1;
      
-- 5. How much revenue is generated each month?
      Select month_name as Month,sum(total) as Total_Revenue from amazon_sales_data group by month_name
      order by Total_Revenue Desc ;
    
-- 6. In which month did the cost of goods sold reach its peak?
      select  month_name as month,sum(cogs) as cogs from amazon_sales_data group by month_name order by cogs desc;
  
-- 7. Which product line generated the highest revenue?
      select Product_line,    sum(total) as Total_revenue from amazon_sales_data
      group by Product_line order by Total_revenue  desc limit 1;
 
-- 8.  In which city was the highest revenue recorded?
	   select city, sum(total) as Total_revenue  from amazon_sales_data 
       group by city order by Total_revenue  desc;
 
-- 9.  Which product line incurred the highest Value Added Tax?
       SELECT product_line, SUM(tax_pct) as VAT 
       FROM amazon_sales_data GROUP BY product_line ORDER BY VAT DESC LIMIT 1;

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
	   SELECT  branch,SUM(quantity) AS quantities FROM amazon_sales_data
       GROUP BY branch HAVING SUM(quantity) > (SELECT AVG(quantity) FROM amazon_sales_data);
    
-- 12. Which product line is most frequently associated with each gender?
      SELECT gender,product_line,COUNT(gender) AS total_cnt
      FROM amazon_sales_data GROUP BY gender, product_line
      ORDER BY total_cnt DESC;   
    
-- 13. Calculate the average rating for each product line.
       SELECT ROUND(AVG(rating), 2) as avg_rating, product_line
       FROM amazon_sales_data GROUP BY product_line
       ORDER BY avg_rating DESC;  
       
