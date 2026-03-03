/*
========================================
QUERY 3: CUSTOMER SEGMENTATION (RFM ANALYSIS)
========================================

Business Question:
Who are our most valuable customers? How should we segment our customer base
for targeted marketing? What's the distribution of one-time vs repeat buyers?

Description:
Segments customers based on purchase behavior using spending quartiles and 
order frequency. Employs NTILE window function for quartile rankings and complex 
CASE logic to create actionable customer segments (loyal, repeat, high-value 
one-timers). Demonstrates understanding of marketing analytics and customer 
lifetime value concepts for targeted retention strategies.

Key Metrics:
- Total orders per customer
- Total lifetime spend per customer
- Average order value per customer
- Days since last purchase (recency)
- Spending quartile ranking
- Customer lifespan (days between first and last order)

SQL Techniques Demonstrated:
- RFM analysis framework (Recency, Frequency, Monetary)
- NTILE window function for quartile segmentation
- DATE_DIFF for calculating time periods
- Complex CASE statements for multi-criteria segmentation logic
- Nested CTEs for progressive data transformation

Business Value:
Enables targeted marketing campaigns based on customer value and behavior.
Identifies VIP customers deserving special treatment and at-risk customers
needing re-engagement. Reveals the reality that most e-commerce customers
are one-time buyers, informing realistic retention strategies.

Dataset Finding:
Analysis revealed near-zero repeat purchase rates in this dataset — a common
reality in Brazilian e-commerce marketplaces. This finding informed the 
decision to pivot from retention analysis to customer value segmentation,
demonstrating adaptive analytical thinking.
========================================
*/

WITH customer_metrics AS (
  SELECT
    o.customer_id,
    c.customer_city,
    c.customer_state,
    DATE_DIFF(DATE '2018-10-17', MAX(DATE(o.order_purchase_timestamp)), DAY) as days_since_last_order,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(p.payment_value), 2) as total_spent,
    ROUND(AVG(p.payment_value), 2) as avg_order_value,
    MIN(DATE(o.order_purchase_timestamp)) as first_order_date,
    MAX(DATE(o.order_purchase_timestamp)) as last_order_date
  FROM `olist-ecommerce-483517.olist_ecommerce.orders` o
  JOIN `olist-ecommerce-483517.olist_ecommerce.customers` c
    ON o.customer_id = c.customer_id
  JOIN `olist-ecommerce-483517.olist_ecommerce.payments` p
    ON o.order_id = p.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY o.customer_id, c.customer_city, c.customer_state
),

customer_ranked AS (
  SELECT
    *,
    NTILE(4) OVER (ORDER BY total_spent) as spending_quartile
  FROM customer_metrics
)

SELECT
  customer_id,
  customer_city,
  customer_state,
  total_orders,
  total_spent,
  avg_order_value,
  days_since_last_order,
  spending_quartile,
  first_order_date,
  last_order_date,
  CASE
    WHEN total_orders >= 5 THEN 'Super Loyal (5+ orders)'
    WHEN total_orders >= 3 THEN 'Loyal Customer (3-4 orders)'
    WHEN total_orders = 2 THEN 'Repeat Buyer (2 orders)'
    WHEN total_orders = 1 AND spending_quartile = 4 THEN 'High-Value One-Timer'
    WHEN total_orders = 1 AND spending_quartile >= 2 THEN 'Medium-Value One-Timer'
    ELSE 'Low-Value One-Timer'
  END as customer_segment,
  DATE_DIFF(last_order_date, first_order_date, DAY) as customer_lifespan_days
FROM customer_ranked
ORDER BY total_spent DESC;
