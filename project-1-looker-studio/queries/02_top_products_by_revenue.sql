-- Note: This query covers all product categories.
-- A tech-specific version is available in Project 2 (07_tech_top_products.sql)

/*
========================================
QUERY 2: TOP PRODUCTS BY REVENUE
========================================

Business Question:
Which products drive the most revenue? How do they perform relative to their
category? Which products have multiple sellers competing?

Description:
Identifies top-performing products by revenue with category breakdown and 
multi-seller analysis. Uses ARRAY_AGG to track all sellers offering each product 
and calculates each product's contribution to its category's total revenue. 
Demonstrates advanced SQL: CTEs, array functions, nested aggregations, and 
percentage calculations for product portfolio optimization.

Key Metrics:
- Total revenue per product
- Number of orders per product
- Average product price
- Number of sellers per product (via ARRAY_AGG)
- Product's percentage contribution to category revenue

SQL Techniques Demonstrated:
- Multiple CTEs for step-by-step logic
- ARRAY_AGG for collecting multiple sellers per product
- ARRAY_LENGTH to count aggregated elements
- Complex JOINs across products, order items, and translations
- Nested aggregations (product-level and category-level)
- Percentage calculations for contribution analysis

Business Value:
Identifies star products that deserve increased marketing investment and
inventory priority. Reveals which products face multi-seller competition
vs. single-seller advantage. Helps optimize product portfolio mix.
========================================
*/

WITH product_revenue AS (
  SELECT
    p.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name, 'Uncategorized') as category,
    COUNT(DISTINCT oi.order_id) as num_orders,
    SUM(oi.price) as total_revenue,
    ROUND(AVG(oi.price), 2) as avg_price,
    ARRAY_AGG(DISTINCT oi.seller_id IGNORE NULLS) as seller_list
  FROM `olist-ecommerce-483517.olist_ecommerce.order_items` oi
  JOIN `olist-ecommerce-483517.olist_ecommerce.products` p
    ON oi.product_id = p.product_id
  LEFT JOIN `olist-ecommerce-483517.olist_ecommerce.product_category_translation` t
    ON p.product_category_name = t.product_category_name
  GROUP BY p.product_id, category
),

category_totals AS (
  SELECT
    category,
    SUM(total_revenue) as category_revenue
  FROM product_revenue
  GROUP BY category
)

SELECT
  pr.product_id,
  pr.category,
  pr.num_orders,
  ROUND(pr.total_revenue, 2) as product_revenue,
  pr.avg_price,
  ARRAY_LENGTH(pr.seller_list) as num_sellers,
  ROUND(pr.total_revenue / ct.category_revenue * 100, 2) as pct_of_category
FROM product_revenue pr
JOIN category_totals ct ON pr.category = ct.category
ORDER BY pr.total_revenue DESC
LIMIT 20;
