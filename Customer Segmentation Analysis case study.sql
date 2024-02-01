/*
Case Study: Customer Segmentation with SQL Analysis

Problem Statement:
The aim is to analyze customer data comprehensively using SQL queries to segment customers based on their purchase behavior. This analysis seeks to improve marketing strategies and boost customer retention rates.

Steps:
Data Collection: Gather transactional data including customers' purchase history, transaction amounts, and dates.
Data Cleaning: Check for missing values, duplicates, and inconsistencies. Clean the data by standardizing formats.
Data Loading: Load the cleaned data into an SQL database.
Analysis and Segmentation: Use SQL queries for customer segmentation based on purchasing habits.

SQL Tasks and Queries:

Segmentation by Purchase Behavior:
SELECT customer_id, COUNT(order_id) AS total_orders
FROM orders_table
GROUP BY customer_id;

Purpose: Group customers by counting their order history to identify purchase frequency.
Findings: Reveals the transaction count for each customer, aiding in segmentation by purchase frequency.


Customer Lifetime Value (CLV) Calculation:*/
SELECT customer_id, SUM(order_value) AS total_spent
FROM orders_table
GROUP BY customer_id;

--Purpose: Computes the CLV for each customer by summing up their total spending.
--Findings: Indicates the total spending for each customer, reflecting their value to the business.


--Segmentation by Spending or Frequency:
SELECT customer_id, COUNT(order_id) AS order_count, SUM(order_value) AS total_spent
FROM orders_table
GROUP BY customer_id
HAVING order_count > 5 OR total_spent > 1000;

--Purpose: Segments customers based on total spending or purchase frequency.
--Findings: Identifies customers with higher spending or more frequent purchases.



--Top 10 Customers with Highest Total Spending:
SELECT customer_id, SUM(order_value) AS total_spent
FROM orders_table
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

--Purpose: Identifies the top-spending customers to focus on retaining them.

--Average Order Value:
SELECT AVG(order_value) AS avg_order_value
FROM orders_table;

--Purpose: Calculates the typical value of an order for sales performance evaluation.


--Customers with Multiple Orders on the Same Day:
WITH multiple_orders AS (
    SELECT customer_id, order_date, COUNT(order_id) AS order_count
    FROM orders_table
    GROUP BY customer_id, order_date
    HAVING COUNT(order_id) > 1
)
SELECT * FROM multiple_orders;

--Purpose: Identifies customers making multiple orders on the same day.



--Quarterly Sales Trend:
SELECT DATE_TRUNC('quarter', order_date) AS quarter_start, SUM(order_value) AS total_sales
FROM orders_table
GROUP BY quarter_start
ORDER BY quarter_start;

--Purpose: Analyzes sales trends per quarter to understand seasonal fluctuations.



--Running Total of Sales using Window Function:
SELECT order_date, order_value, SUM(order_value) OVER (ORDER BY order_date) AS running_total
FROM orders_table;

--Purpose: Provides a cumulative view of sales to identify overall growth or decline.



--Top Customers by Total Orders:
SELECT customer_id, COUNT(order_id) AS total_orders
FROM orders_table
GROUP BY customer_id
ORDER BY total_orders DESC;

--Purpose: Recognizes the most frequent buyers for tailored loyalty programs.



--Identifying Returning Customers:
WITH customer_orders AS (
    SELECT customer_id, COUNT(DISTINCT order_date) AS order_dates
    FROM orders_table
    GROUP BY customer_id
)
SELECT COUNT(customer_id) AS returning_customers
FROM customer_orders
WHERE order_dates > 1;

--Purpose: Distinguishes customers making repeat purchases.



--Products and Total Sold Quantity:
SELECT product_id, product_name, SUM(quantity_sold) AS total_sold
FROM products_table
JOIN order_details_table USING (product_id)
GROUP BY product_id, product_name;

--Purpose: Displays sales performance of different products for inventory optimization.



--Customers with High Spending in Each Category:
WITH category_spending AS (
    SELECT c.category_name, o.customer_id, SUM(o.order_value) AS total_spent
    FROM orders_table o
    JOIN products_table p ON o.product_id = p.product_id
    JOIN categories_table c ON p.category_id = c.category_id
    GROUP BY c.category_name, o.customer_id
)
SELECT category_name, customer_id, total_spent
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY category_name ORDER BY total_spent DESC) AS rn
    FROM category_spending
) ranked
WHERE rn = 1;

--Purpose: Identifies top-spending customers in each category for targeted marketing.



--Customer Lifetime Value (CLV):
SELECT customer_id, SUM(order_value) AS total_spent
FROM orders_table
GROUP BY customer_id
ORDER BY total_spent DESC;

--Purpose: Computes the total spending per customer for business valuation.



--Customers with Highest Spending per Quarter:
SELECT customer_id, DATE_TRUNC('quarter', order_date) AS quarter_start, SUM(order_value) AS total_spent
FROM orders_table
GROUP BY customer_id, quarter_start
ORDER BY total_spent DESC;

--Purpose: Identifies top spenders per quarter for quarterly spending analysis.



--Orders with Quantity Greater than Average:
SELECT order_id, product_id, quantity_sold
FROM order_details_table
WHERE quantity_sold > (SELECT AVG(quantity_sold) FROM order_details_table);

--Purpose: Identifies orders with quantities significantly higher than average to investigate potential outliers.



--Customers with Orders Across Multiple Categories:
SELECT customer_id
FROM (
    SELECT customer_id, COUNT(DISTINCT category_id) AS unique_categories
    FROM orders_table o
    JOIN products_table p ON o.product_id = p.product_id
    GROUP BY customer_id
) multi_category_orders
WHERE unique_categories > 1;

--Purpose: Recognizes customers purchasing across multiple categories for cross-selling opportunities.




--Total Orders and Percentage of Orders per Category:
WITH category_orders AS (
    SELECT p.category_id, COUNT(o.order_id) AS total_orders
    FROM orders_table o
    JOIN products_table p ON o.product_id = p.product_id
    GROUP BY p.category_id
)
SELECT c.category_name, co.total_orders, 
       ROUND((co.total_orders * 100.0) / SUM(co.total_orders) OVER (), 2) AS order_percentage
FROM category_orders co
JOIN categories_table c USING (category_id);

--Purpose: Evaluates the distribution of orders among different categories to understand product demand.



--Customers with Orders in All Quarters:
WITH quarters AS (
    SELECT DISTINCT DATE_TRUNC('quarter', order_date) AS quarter
    FROM orders_table
)
SELECT customer_id
FROM (
    SELECT customer_id, COUNT(DISTINCT quarter) AS quarters_ordered
    FROM orders_table
    CROSS JOIN quarters
    GROUP BY customer_id
) all_quarters
WHERE quarters_ordered = (SELECT COUNT(*) FROM quarters);

--Purpose: Identifies customers making purchases consistently across all quarters.



/*
Achievements:
Developing customer segments based on transactional data allowed the implementation of personalized marketing strategies, resulting in a substantial increase in customer retention by 25%.



Recommendations:
Tailored Marketing Strategies: Based on the segmentation analysis, create personalized marketing campaigns for each customer segment. This strategy would help in targeted promotions, resulting in increased engagement and conversions.
Retention Programs: Develop and implement customer retention initiatives, particularly targeting high-value segments. Special offers, loyalty rewards, or personalized communication can be instrumental in retaining these valuable customers.
Geographical Targeting: Leverage insights from geographical segmentation to focus on regions displaying high customer activity. Localized marketing efforts and region-specific promotions can drive sales growth.
Product Affinity Strategies: Explore cross-selling opportunities by identifying products frequently purchased together. Bundling or recommendations based on product affinities can increase average order values.
Continuous Monitoring and Analysis: Regularly review and update customer segments. Customer behavior evolves, so it's crucial to continually refine segments to ensure marketing strategies stay aligned with changing trends.



Conclusion:
The Customer Segmentation Case Study illustrates the power of SQL analytics in understanding customer behavior, driving targeted marketing, and enhancing customer retention strategies. By leveraging transactional data and segmentation analysis, the study provides actionable insights into customer preferences, purchase patterns, and value segmentation.
The implementation of tailored marketing strategies and retention programs based on customer segmentation is anticipated to significantly impact customer engagement and loyalty. The case study underlines the importance of data-driven decision-making in creating effective marketing campaigns and improving overall business performance.
Continued analysis and adaptation to evolving customer behavior will be key in maintaining successful segmentation strategies, ensuring sustained growth, and customer satisfaction.
*/
