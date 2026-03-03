/*
========================================
QUERY 8: DELIVERY & OPERATIONS PERFORMANCE
========================================

Business Question:
How long does delivery actually take vs the estimated date?
Which tech categories have the worst delays? Is delivery performance
improving or getting worse over time? Which states experience the most delays?

Description:
Analyzes fulfillment performance for tech product categories by calculating 
actual vs estimated delivery times and on-time rates. Uses DATE_DIFF for 
delivery time calculations, CASE statements for delay classification, and 
aggregations across category, state, and monthly dimensions. Demonstrates 
operational analytics skills critical for identifying fulfillment bottlenecks 
and improving customer satisfaction in e-commerce environments.

Key Metrics:
- Actual delivery days (purchase to delivery)
- Estimated delivery days (purchase to estimated date)
- Delay in days (actual minus estimated, positive = late)
- On-time delivery rate per category and state
- Average delivery time by state
- Monthly delivery performance trend

SQL Techniques Demonstrated:
- DATE_DIFF for delivery time calculations
- CASE statements for delay classification
- Aggregations across multiple dimensions
- NULL handling for undelivered orders
- CTEs for multi-step delivery analysis
- COUNTIF for conditional aggregations

Business Value:
Fulfillment directly impacts reviews and repeat purchases in tech stores.
Identifying which categories or regions have systematic delays enables 
proactive customer communication and supplier negotiations. Improving 
delivery predictability is often more impactful than improving average 
delivery speed.

Dataset Finding:
Tech orders arrive an average of 12.82 days ahead of estimated delivery 
date with a 92% on-time rate — suggesting Olist systematically sets 
conservative delivery estimates. Consoles & Games show the longest average 
delivery time at ~17 days while Tablets & Imaging are fastest at ~15 days.
An initial query bug producing on-time rates over 100% was identified and 
resolved by deduplicating orders before calculating rates — demonstrating 
rigorous data validation practices.
========================================
*/

WITH tech_orders AS (
  SELECT
    o.order_id,
    o.customer_id,
    COALESCE(t.product_category_name_english, p.product_category_name) as category,
    DATE(o.order_purchase_timestamp) as purchase_date,
    DATE(o.order_delivered_customer_date) as delivery_date,
    DATE(o.order_estimated_delivery_date) as estimated_date,
    FORMAT_DATE('%Y-%m', DATE(o.order_purchase_timestamp)) as order_month,
    c.customer_state
  FROM `olist-ecommerce-483517.olist_ecommerce.orders` o
  JOIN `olist-ecommerce-483517.olist_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  JOIN `olist-ecommerce-483517.olist_ecommerce.products` p
    ON oi.product_id = p.product_id
  LEFT JOIN `olist-ecommerce-483517.olist_ecommerce.product_category_translation` t
    ON p.product_category_name = t.product_category_name
  JOIN `olist-ecommerce-483517.olist_ecommerce.customers` c
    ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND COALESCE(t.product_category_name_english, p.product_category_name)
      IN (
        'computers_accessories',
        'electronics',
        'telephony',
        'computers',
        'tablets_printing_image',
        'audio',
        'consoles_games'
      )
),

delivery_metrics AS (
  SELECT DISTINCT
    order_id,
    category,
    order_month,
    customer_state,
    DATE_DIFF(delivery_date, purchase_date, DAY) as actual_delivery_days,
    DATE_DIFF(estimated_date, purchase_date, DAY) as estimated_delivery_days,
    DATE_DIFF(delivery_date, estimated_date, DAY) as delay_days,
    CASE
      WHEN delivery_date <= estimated_date THEN 'On Time'
      WHEN DATE_DIFF(delivery_date, estimated_date, DAY) <= 3 THEN 'Slight Delay (1-3 days)'
      WHEN DATE_DIFF(delivery_date, estimated_date, DAY) <= 7 THEN 'Moderate Delay (4-7 days)'
      ELSE 'Severe Delay (7+ days)'
    END as delivery_status
  FROM tech_orders
)

SELECT
  category,
  customer_state,
  order_month,
  COUNT(DISTINCT order_id) as total_orders,
  ROUND(AVG(actual_delivery_days), 1) as avg_actual_days,
  ROUND(AVG(estimated_delivery_days), 1) as avg_estimated_days,
  ROUND(AVG(delay_days), 1) as avg_delay_days,
  COUNTIF(delivery_status = 'On Time') as on_time_orders,
  ROUND(COUNTIF(delivery_status = 'On Time') /
    COUNT(DISTINCT order_id) * 100, 2) as on_time_rate_pct,
  COUNTIF(delivery_status = 'Slight Delay (1-3 days)') as slight_delay_orders,
  COUNTIF(delivery_status = 'Moderate Delay (4-7 days)') as moderate_delay_orders,
  COUNTIF(delivery_status = 'Severe Delay (7+ days)') as severe_delay_orders
FROM delivery_metrics
GROUP BY category, customer_state, order_month
ORDER BY avg_delay_days DESC;
