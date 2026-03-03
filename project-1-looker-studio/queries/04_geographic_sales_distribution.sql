/*
========================================
QUERY 4: GEOGRAPHIC SALES DISTRIBUTION
========================================

Business Question:
Which states and cities generate the most revenue? Where should we focus
marketing spend and shipping partnerships? What are the top markets within
each state?

Description:
Analyzes sales performance across Brazilian states and cities using geographic 
segmentation. Uses ROW_NUMBER with PARTITION BY to rank top-performing cities 
within each state. Demonstrates ability to provide location-based insights for 
market expansion and regional sales optimization strategies.

Key Metrics:
- Total orders by state and city
- Total revenue by geographic region
- Unique customers by location
- Average order value by region
- Top 5 cities within each state (ranked)

SQL Techniques Demonstrated:
- Multiple CTEs for state and city-level aggregations
- ROW_NUMBER window function for ranking
- PARTITION BY for state-based grouping
- Geographic aggregation and filtering
- Top-N query pattern (rank <= 5)

Business Value:
Identifies high-value markets for targeted advertising and partnership
opportunities (shipping, warehousing). Reveals underserved markets with
growth potential. Informs decisions about regional inventory distribution
and localized marketing campaigns.

Dataset Finding:
São Paulo generates $2.7M — nearly double second-place Rio de Janeiro at 
$1.41M. The top 2 states account for over 50% of total revenue, revealing 
extreme geographic concentration that has direct implications for shipping 
partnerships and marketing budget allocation.
========================================
*/

WITH state_performance AS (
  SELECT
    c.customer_state as state,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    ROUND(SUM(p.payment_value), 2) as total_revenue,
    ROUND(AVG(p.payment_value), 2) as avg_order_value
  FROM `olist-ecommerce-483517.olist_ecommerce.orders` o
  JOIN `olist-ecommerce-483517.olist_ecommerce.customers` c
    ON o.customer_id = c.customer_id
  JOIN `olist-ecommerce-483517.olist_ecommerce.payments` p
    ON o.order_id = p.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY state
),

city_performance AS (
  SELECT
    c.customer_city as city,
    c.customer_state as state,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(p.payment_value), 2) as total_revenue,
    ROW_NUMBER() OVER (
      PARTITION BY c.customer_state 
      ORDER BY SUM(p.payment_value) DESC
    ) as rank_in_state
  FROM `olist-ecommerce-483517.olist_ecommerce.orders` o
  JOIN `olist-ecommerce-483517.olist_ecommerce.customers` c
    ON o.customer_id = c.customer_id
  JOIN `olist-ecommerce-483517.olist_ecommerce.payments` p
    ON o.order_id = p.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY city, state
)

SELECT
  city,
  state,
  total_orders,
  total_revenue,
  rank_in_state
FROM city_performance
WHERE rank_in_state <= 5
ORDER BY state, rank_in_state;
