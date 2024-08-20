-- creating  database named capstone 

CREATE DATABASE capstone;
USE capstone;

-- creating amazon table and importing amazon data using Table data import wizard
CREATE TABLE  amazon(
  invoice_id VARCHAR(30) NOT NULL,
  branch VARCHAR(5) NOT NULL,
  city VARCHAR(30) NOT NULL,
  customer_type VARCHAR(30) NOT NULL,
  gender VARCHAR(10) NOT NULL,
  product_line VARCHAR(100) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  quantity INT NOT NULL,
  VAT FLOAT(6,4) NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  date DATE NOT NULL,
  time TIME NOT NULL,
  payment_method VARCHAR(20) NOT NULL,
  cogs DECIMAL(10,2) NOT NULL,
  gross_margin_percentage FLOAT(11,9) NOT NULL,
  gross_income DECIMAL(10,2) NOT NULL,
  rating FLOAT(4,2) NOT NULL,
  PRIMARY KEY (invoice_id));

-- fetching data 
SELECT * FROM amazon;

-- to deactivate sql_safe_update mode for updating ,inserting values
SET SQL_SAFE_UPDATES = 0;

 -- Add a new column named timeofday to give insight related time 
ALTER TABLE amazon
ADD COLUMN timeofday VARCHAR(20) NOT NULL;

-- Update the values 'timeofday' column based on the time of day
UPDATE amazon
SET timeofday = CASE
    WHEN EXTRACT(HOUR FROM Time) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM Time) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN EXTRACT(HOUR FROM Time) BETWEEN 18 AND 23 THEN 'Evening'
    ELSE 'Late Night'
END;

-- Add a new column named dayname that contains the extracted days of the week
ALTER TABLE amazon
ADD COLUMN dayname VARCHAR(20) NOT NULL;

-- update table and set values in dayname column using DML command
UPDATE amazon
SET dayname = DAYNAME(date);

-- removing 'day' from dayname by updating value using DML command
UPDATE amazon
SET dayname = REPLACE(dayname, 'day', '');

-- Add a new column named monthname that contains the extracted months of the year
ALTER TABLE amazon
ADD COLUMN monthname VARCHAR(20) NOT NULL;

-- Inserting values in columm monthname using DML command
UPDATE amazon
SET monthname = LEFT(MONTHNAME(date), 3);

UPDATE amazon
SET dayname = 'Wed' where dayname='Wednes';

-- Check the updated table after adding columns
SELECT * FROM amazon;
DESCRIBE amazon;

-- (1) What is the count of distinct cities in the dataset?
SELECT  COUNT(DISTINCT City)Count FROM amazon;

-- (2) For each branch, what is the corresponding city?
SELECT DISTINCT Branch,city FROM amazon;

-- (3) What is the count of distinct product lines in the dataset?
SELECT  count(Distinct Product_line)distinct_product_lines_count FROM amazon;

-- Name of distinct product_line
SELECT DISTINCT product_line FROM amazon;

-- (4) Which payment method occurs most frequently?
SELECT count(payment_method) Payment_count,payment_method FROM amazon
GROUP BY payment_method 
ORDER BY Payment_count DESC LIMIT 1;

-- Comparing with other payment_method
SELECT count(payment_method) Payment_count,payment_method FROM amazon
GROUP BY payment_method 
ORDER BY Payment_count DESC;

-- (5) Which product line has the highest sales?
SELECT Product_line ,sum(Quantity) total_sale FROM amazon
GROUP BY Product_line
ORDER BY total_sale DESC LIMIT 1;

-- Comparing with other product_line sales
SELECT Product_line ,sum(Quantity) total_sale FROM amazon
GROUP BY Product_line
ORDER BY total_sale DESC;

-- (6) How much revenue is generated each month?
SELECT monthname,sum(total) AS revenue FROM amazon 
GROUP BY monthname ;

-- (7) In which month did the cost of goods sold reach its peak?
SELECT cogs ,monthname FROM amazon
ORDER BY cogs DESC LIMIT 1;

-- (8) Which product line generated the highest revenue? 
SELECT product_line,sum(total) Highest_revenue FROM amazon
GROUP BY product_line
ORDER BY Highest_revenue DESC LIMIT 1;

-- Comparing revenue with other product line
SELECT product_line,sum(total) revenue FROM amazon
GROUP BY product_line
ORDER BY revenue DESC;

-- (9) In which city was the highest revenue recorded?
SELECT sum(total)  as Highest_revenue ,City FROM amazon
GROUP BY City
ORDER BY Highest_revenue DESC LIMIT 1;

-- Comparing revenue with other cities
SELECT sum(total) Revenue ,City FROM amazon
GROUP BY City
ORDER BY Revenue DESC;

-- (10) Which product line incurred the highest Value Added Tax?
SELECT Product_line,sum(VAT) Highest_VAT FROM amazon
GROUP BY Product_line 
ORDER BY Highest_VAT desc limit 1;


-- (11)For each product line, add a column indicating "Good" if its sales are above average,
-- otherwise "Bad."

WITH ProductLineSales AS 
(SELECT product_line, SUM(total) AS total_sales FROM amazon
GROUP By product_line
),
AverageSales AS (
    SELECT AVG(total_sales) AS avg_sales
    FROM ProductLineSales
)
SELECT pls.product_line, pls.total_sales,
    CASE
        WHEN pls.total_sales > avg_sales THEN 'Good'
        ELSE 'Bad'
    END AS sales_quality
FROM
    ProductLineSales pls
INNER JOIN
    AverageSales;

-- (12) Identify the branch that exceeded the average number of products sold.
select Branch ,sum(Quantity) total_quantity_sold from amazon
group by Branch
having total_quantity_sold>
(with cte as
(select sum(Quantity) q  from amazon
group by Branch)
select avg(q) from cte);

-- (13)Which product line is most frequently associated with each gender?
WITH GenderProductCounts AS (
    SELECT gender, product_line, COUNT(*) AS product_count
    FROM amazon
    GROUP BY gender, product_line
),
RankedGenderProducts AS (
    SELECT gender, product_line,product_count,
        ROW_NUMBER() OVER (PARTITION BY gender ORDER BY product_count DESC) AS rn
    FROM GenderProductCounts
)
SELECT gender,product_line,product_count
FROM RankedGenderProducts
WHERE rn = 1;

 ----- another way to solve  
(select count(gender)female_count, Product_line,gender from amazon where gender='Female'
group by Product_line order by female_count desc limit 1)
union
(select count(gender)male_count,Product_line,gender from amazon where gender='Male'
group by Product_line order by male_count desc limit 1);

-- (14) Calculate the average rating for each product line.
select Product_line,avg(Rating) average_rating from amazon
group by Product_line order by average_rating desc;  

-- (15)Count the sales occurrences for each time of day on every weekday.
select timeofday,dayname,count(*)sales_occurrence from amazon
group by dayname,timeofday order by dayname;

-- (16) Identify the customer type contributing the highest revenue.
select Customer_type,sum(Total) highest_revenue from amazon 
group by Customer_type 
order by highest_revenue desc limit 1; 

-- Comparing with other customer type
select Customer_type,sum(Total) total_revenue from amazon 
group by Customer_type 
order by total_revenue desc; 

-- (17)Determine the city with the highest VAT percentage.
select City,sum(VAT)as highest_Total_VAT from amazon group by City 
order by highest_Total_VAT desc limit 1;

-- (18)Identify the customer type with the highest VAT payments.
select Customer_type,sum(VAT)as Total_VAT from amazon group by Customer_type 
order by Total_VAT desc limit 1;

-- (19)What is the count of distinct customer types in the dataset?
select Customer_type,count(Customer_type)Count from amazon
group by Customer_type;

-- (20)What is the count of distinct payment methods in the dataset?
select payment_method,count(payment_method) Count from amazon group by payment_method;

-- (21)Which customer type occurs most frequently?
select Customer_type,count(Customer_type)count from amazon
group by Customer_type order by count desc limit 1 ;

-- (22)Identify the customer type with highest purchase frequency.
select Customer_type ,count(payment_method) highest_purchase_frequency from amazon
group by Customer_type order by highest_purchase_frequency desc limit 1;

-- (23)Determine the predominant gender among customers.
select gender ,count(*) count from amazon 
group by gender;

SELECT
    (CASE WHEN male_count > female_count THEN 'Male'
        WHEN male_count < female_count THEN 'Female'
        ELSE 'Equal' 
    END) AS predominant_gender,male_count,female_count
FROM (
    SELECT
        SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS male_count,
        SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS female_count
    FROM amazon
) AS gender_counts;

-- (24)Examine the distribution of genders within each branch.
select branch,
sum(case when Gender="Male" then 1 else 0 end) as Male_count,
sum(case when Gender="Female" then 1 else 0 end) as Female_count
from amazon group by branch order by branch;

-- (25)Identify the time of day when customers provide the most ratings.
select timeofday ,COUNT(Rating)as rating_count from amazon 
GROUP BY timeofday
ORDER BY timeofday LIMIT 1 ;

-- (26) Determine the time of day with the highest customer ratings for each branch.

select distinct branch,timeofday,rating_count
from (select branch,timeofday,count(rating) OVER (PARTITION BY timeofday, branch ORDER BY branch ) AS rating_count
FROM amazon )as rating_rank limit 3;

-- another method:
select branch,timeofday,count(rating)count_rating from amazon
group by timeofday,branch order by count_rating desc limit 3 ;

-- (27) Identify the day of the week with the highest average ratings.
select avg(rating) avg_rating,dayname from amazon
group by dayname order by avg_rating desc limit 1 ;

-- (28) Determine the day of the week with the highest average ratings for each branch.
(select branch,avg(rating) highest_avg_rating ,dayname from amazon where branch="A"
group by dayname order by highest_avg_rating desc limit 1)
union
(select branch ,avg(rating) highest_avg_rating,dayname from amazon where branch="B"
group by dayname order by highest_avg_rating desc limit 1 )
union
(select branch,avg(rating) highest_avg_rating,dayname from amazon where branch="C"
group by dayname order by highest_avg_rating desc limit 1 );

-- Branch wise gross income:
(SELECT branch,product_line,sum(gross_income) Total_gross_income FROM amazon where branch="A"
GROUP BY product_line order by Total_gross_income desc); 

(SELECT branch,product_line,sum(gross_income) Total_gross_income FROM amazon where branch="B"
GROUP BY product_line order by Total_gross_income desc);

(SELECT branch,product_line,sum(gross_income) Total_gross_income FROM amazon where branch="c"
GROUP BY product_line order by Total_gross_income desc)
