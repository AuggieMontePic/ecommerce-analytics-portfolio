/*
========================================
QUERY 1: MONTHLY SALES PERFORMANCE
========================================

Business Question:
How are sales trending month-over-month? Which months show growth or decline?

Description:
Analyzes sales trends over time with month-over-month growth calculations. 
Uses CTEs for clean data organization and window functions (LAG) to calculate 
revenue growth percentages. Demonstrates ability to track KPIs (orders, revenue, 
AOV, unique customers) and identify business trends for strategic decision-making.

Key Metrics:
- Total orders per month
- Total revenue per month
- Average order value (AOV)
- Unique customers
- Month-over-month revenue growth %

SQL Techniques Demonstrated:
- CTEs (Common Table Expressions)
- Window functions (LAG)
- Date formatting (FORMAT_DATE)
- Percentage calculations

Business Value:
Enables identification of seasonal trends and periods requiring intervention.
========================================
*/

WITH monthly_sales AS (
  SELECT
    FORMAT_DATE('%Y-%m', DATE(o.order_purchase_timestamp)) as month,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(p.payment_value), 2) as total_revenue,
    ROUND(AVG(p.payment_value), 2) as avg_order_value,
    COUNT(DISTINCT o.customer_id) as unique_customers
  FROM `olist-ecommerce-483517.olist_ecommerce.orders` o
  JOIN `olist-ecommerce-483517.olist_ecommerce.payments` p
    ON o.order_id = p.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY month
)

SELECT
  month,
  total_orders,
  total_revenue,
  avg_order_value,
  unique_customers,
  LAG(total_revenue) OVER (ORDER BY month) as prev_month_revenue,
  ROUND(
    (total_revenue - LAG(total_revenue) OVER (ORDER BY month)) /
    LAG(total_revenue) OVER (ORDER BY month) * 100,
    2
  ) as revenue_growth_pct
FROM monthly_sales
ORDER BY month;
