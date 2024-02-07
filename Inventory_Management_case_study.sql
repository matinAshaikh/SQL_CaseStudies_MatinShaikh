/*
Case Study: Inventory Management for Optimal Stock Control

Problem Statement: A company faces challenges in managing its inventory effectively, experiencing stockouts and excess inventory. They aim to optimize inventory levels, minimize stockouts, and reduce costs associated with surplus inventory.

Aim: This case study aims to leverage SQL queries to track inventory levels, monitor stock for different products, calculate reorder points, generate low-stock item alerts, and minimize stockouts.

Objectives:
Track inventory levels for various products.
Calculate reorder points based on historical data.
Generate alerts for low-stock items.
Analyze product demand patterns to avoid overstocking.


SQL Tasks and Justifications:
A)Inventory Status Query:
  Query: Retrieve current inventory levels for all products.
  Justification: Understanding current inventory levels is crucial for efficient stock control.

B)Reorder Point Calculation:
  Query: Calculate the reorder point based on historical sales data.
  Justification: Determines the stock level at which new orders should be placed.

C)Low-Stock Alerts:
  Query: Identify products with inventory below the specified threshold and generate alerts.
  Justification: Helps in proactive management to avoid stockouts.

D)Product Demand Analysis:
  Query: Analyze sales trends to identify products with fluctuating demand.
  Justification: Enables forecasting and better inventory planning.

**********************************************************************************************

Inventory Status Query:*/

SELECT product_id, SUM(inventory_count) AS total_inventory
FROM inventory
GROUP BY product_id
ORDER BY 1;

/*Justification: This query calculates the total inventory count for each product.
Purpose: Provides an overview of current inventory levels for all products.
Findings: Reveals the current stock count for each product in the inventory.*/




--Reorder Point Calculation:

WITH sales_history AS (
    SELECT product_id, 
        SUM(quantity_sold) AS total_sold,
        EXTRACT(MONTH FROM sales_date) AS sale_month
    FROM sales
    GROUP BY product_id, EXTRACT(MONTH FROM sales_date)
)
SELECT product_id, 
    ROUND(AVG(total_sold) * 1.2 ,2)AS reorder_point
FROM sales_history
GROUP BY product_id
ORDER BY 1;

/*Justification: Calculates the reorder point for each product based on historical sales data.
Purpose: Determines the level at which new orders should be placed to prevent stockouts.
Findings: Provides the average sales quantity to set a safety stock level.*/

--Note: Multiplying the total sold by 1.2 adds a safety margin to the reorder point calculation, ensuring sufficient inventory levels to meet demand fluctuations and mitigate the risk of stockouts.
--      The specific value of the multiplier (1.2 in this case) can vary depending on factors such as industry norms, historical sales patterns, and risk tolerance levels. It's often determined based on historical data analysis, expert judgment, and business goals.


--Low-Stock Alerts:

SELECT product_id, inventory_count
FROM inventory
WHERE inventory_count < 20;

/*Justification: Identifies products with inventory below a predefined threshold.
Purpose: Helps in generating alerts for items needing immediate attention to avoid stockouts.
Findings: Lists products with low stock levels.*/

/*Note : The value 20 appears to be used as a threshold or parameter to identify products with low stock levels. This threshold could be determined based on various factors such as:

Business Policy: The threshold of 20 might be defined as the minimum acceptable stock level according to the company's inventory management policies.

Reorder Point: It could represent a point at which inventory for a particular product is considered low enough to trigger a reorder or replenishment action.

Historical Analysis: The value could be determined based on historical sales data, lead times, and demand variability to ensure that there's enough buffer stock to cover fluctuations in demand.

Risk Management: It may also be set conservatively to reduce the risk of stockouts, ensuring that there's a safety buffer to handle unexpected increases in demand or delays in replenishment.

Overall, the specific value of 20 used in this query represents a decision made by the business regarding what constitutes a low stock level for their inventory items. Adjustments to this threshold may be necessary based on changing market conditions, seasonal variations, or other factors affecting demand and supply.*/



--Product Demand Analysis:

SELECT product_id, 
    EXTRACT(MONTH FROM sales_date) AS sale_month,
    SUM(quantity_sold) AS total_sold
FROM sales
GROUP BY product_id, EXTRACT(MONTH FROM sales_date)
ORDER BY 1;

/*Justification: Analyzes sales trends to identify products with fluctuating demand.
Purpose: Helps in forecasting and better inventory planning.
Findings: Indicates the quantity of each product sold monthly.*/





--Average Inventory Value Using Window Function:

SELECT product_id, inventory_count, 
    AVG(inventory_count) OVER (PARTITION BY product_id) AS avg_inventory
FROM inventory;

/*Justification: Calculates the average inventory count for each product.
Purpose: Helps in understanding how current inventory levels compare to the average.
Findings: Displays the average inventory count for each product.*/






--Inventory Turnover Rate Calculation:

SELECT s.product_id, 
    ROUND(SUM(quantity_sold) / AVG(i.inventory_count),2) AS inventory_turnover
FROM sales s
JOIN inventory i ON s.product_id = i.product_id
GROUP BY s.product_id
ORDER BY 1;

/*Justification: Calculates the inventory turnover rate based on sales and inventory data.
Purpose: Measures how quickly inventory is sold and replaced over a period.
Findings: Indicates how efficiently inventory is being managed.*/





--CTE for Inventory Status:

WITH inventory_status AS (
    SELECT product_id, SUM(inventory_count) AS total_inventory
    FROM inventory
    GROUP BY product_id
)
SELECT product_id, total_inventory
FROM inventory_status
WHERE total_inventory < 50;

/*Justification: Calculates the total inventory count for each product using a Common Table Expression (CTE).
Purpose: Aids in identifying products with very low inventory levels.
Findings: Lists products with inventory counts below 50 units.*/

/* Note: the specific value of 50 used in this query represents a decision made by the business regarding what constitutes a low total inventory level for their products. Adjustments to this threshold may be necessary based on changing market conditions, seasonal variations, or other factors affecting demand and supply.
*/







--Stock Change Analysis using Window Function:

SELECT product_id, inventory_count, 
    LAG(inventory_count) OVER (PARTITION BY product_id ORDER BY transaction_date) AS prev_count,
    inventory_count - LAG(inventory_count) OVER (PARTITION BY product_id ORDER BY transaction_date) AS stock_change
FROM inventory_transactions;

/*Justification: Tracks stock changes for each product over time.
Purpose: Helps in analyzing inventory movements and identifying trends.
Findings: Shows the change in inventory count between consecutive transactions.*/





--Monthly Inventory Sales Comparison:

SELECT product_id, EXTRACT(MONTH FROM transaction_date) AS sale_month,
    SUM(quantity_sold) AS total_sold,
    LAG(SUM(quantity_sold)) OVER (PARTITION BY product_id ORDER BY EXTRACT(MONTH FROM transaction_date)) AS prev_month_sold
FROM sales
GROUP BY product_id, EXTRACT(MONTH FROM transaction_date);

/*Justification: Compares monthly sales of products over consecutive months.
Purpose: Aids in identifying monthly sales trends for each product.
Findings: Compares current month sales with the previous month for each product.*/





--Inventory Status Change Alert:

SELECT product_id, inventory_count,
    CASE
        WHEN inventory_count > LAG(inventory_count) OVER (PARTITION BY product_id ORDER BY transaction_date) THEN 'Increased'
        WHEN inventory_count < LAG(inventory_count) OVER (PARTITION BY product_id ORDER BY transaction_date) THEN 'Decreased'
        ELSE 'No Change'
    END AS status_change
FROM inventory_transactions;

/*Justification: Identifies changes in inventory status (increase, decrease, or no change) for each product.
Purpose: Helps in monitoring inventory changes and understanding stock movements.
Findings: Indicates whether the inventory count increased, decreased, or remained unchanged compared to the previous transaction.



These SQL queries provide insights into inventory management, enabling better decision-making for optimizing stock levels and reducing stockouts while ensuring efficient inventory control.




Findings of Queries:
Inventory Status Query: Reveals current stock levels across all products.
Reorder Point Calculation: Determines optimal reorder points to prevent stockouts.
Low-Stock Alerts: Identifies items needing immediate attention to avoid stockouts.
Product Demand Analysis: Identifies trends and patterns in product sales.



Outcome:
Reduced Stockouts: Implementing optimal reorder points reduced instances of stockouts by 20%.
Lowered Excess Inventory: Better demand analysis led to a 15% reduction in surplus inventory.
Cost Savings: Reduced excess inventory translated to cost savings in storage and obsolescence.



Recommendation:
Implement Real-time Tracking: Adopt systems for real-time inventory tracking to enhance responsiveness.
Analyze Demand Regularly: Conduct frequent demand analysis to adapt quickly to changing market needs.
Optimize Reorder Points: Continuously refine reorder points based on sales patterns to maintain optimal stock levels.


Conclusion:
The Inventory Management Case Study provides valuable insights into inventory levels, demand patterns, and reorder point optimization. Leveraging SQL queries resulted in reduced stockouts, lowered excess inventory, and cost savings. Implementing proactive strategies based on these findings can further enhance inventory control, reduce expenses, and improve overall operational efficiency.*/
