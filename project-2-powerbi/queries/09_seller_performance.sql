/*
========================================
QUERY 9: TECH SELLER PERFORMANCE
========================================

Business Question:
Which sellers drive the most tech revenue? How reliable are they in terms 
of delivery? Which sellers are worth prioritizing for partnerships and 
which are underperforming?

Description:
Profiles individual seller performance combining commercial and operational 
metrics. Joins revenue, delivery, and review data across multiple CTEs to 
create a composite seller tier classification. Demonstrates ability to build 
vendor scorecards that balance revenue contribution with reliability — 
essential for marketplace and dropship business models common in Shopify 
tech stores.

Key Metrics:
- Total revenue per seller
- Number of orders per seller
- Average product price per seller
- Average delivery days per seller
- On-time delivery rate per seller
- Number of tech categories covered per seller
- Average review score per seller

SQL Techniques Demonstrated:
- Multi-table JOINs across sellers, orders, and reviews
- Performance scoring combining revenue and reliability
- CASE statements for seller tier classification
- Aggregations across seller and category dimensions
- Combining operational and commercial metrics
- Multiple CTEs for progressive seller profiling

Business Value:
For tech stores with multiple suppliers or marketplace sellers, identifying 
top performers enables smarter partnership decisions. A seller with high 
revenue but poor delivery damages your store's reputation. This query 
surfaces the balance between commercial and operational performance.

Dataset Finding:
Only 10.08% of 476 tech sellers qualify as Elite — defined as high revenue 
AND high reliability combined. The top seller generates $222K, nearly 4x 
the second-place seller at $53K, revealing extreme revenue concentration. 
Average review score of 3.9/5 across all sellers indicates meaningful room 
for seller quality improvement. Notably, no sellers fell into the 
High Revenue / Low Reliability tier — suggesting that in this dataset, 
high-revenue sellers tend to also maintain good delivery standards.
========================================
*/

WITH tech_seller_metrics AS (
  SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) as total_orders,
    COUNT(DISTINCT oi.product_id) as unique_products,
    COUNT(DISTINCT COALESCE(t.product_category_name_english, p.product_category_name)) as categories_covered,
    ROUND(SUM(oi.price), 2) as total_revenue,
    ROUND(AVG(oi.price), 2) as avg_product_price,
    ROUND(SUM(oi.freight_value), 2) as total_freight,
    ROUND(AVG(oi.freight_value), 2) as avg_freight
  FROM `olist-ecommerce-483517.olist_ecommerce.order_items` oi
  JOIN `olist-ecommerce-483517.olist_ecommerce.products` p
    ON oi.product_id = p.product_id
  LEFT JOIN `olist-ecommerce-483517.olist_ecommerce.product_category_translation` t
    ON p.product_category_name = t.product_category_name
  WHERE COALESCE(t.product_category_name_english, p.product_category_name)
    IN (
      'computers_accessories',
      'electronics',
      'telephony',
      'computers',
      'tablets_printing_image',
      'audio',
      'consoles_games'
    )
  GROUP BY oi.seller_id
),

seller_delivery AS (
  SELECT
    oi.seller_id,
    ROUND(AVG(DATE_DIFF(
      DATE(o.order_delivered_customer_date),
      DATE(o.order_purchase_timestamp), DAY
    )), 1) as avg_delivery_days,
    ROUND(COUNTIF(o.order_delivered_customer_date <= o.order_estimated_delivery_date) /
      COUNT(DISTINCT o.order_id) * 100, 2) as on_time_rate_pct
  FROM `olist-ecommerce-483517.olist_ecommerce.order_items` oi
  JOIN `olist-ecommerce-483517.olist_ecommerce.orders` o
    ON oi.order_id = o.order_id
  JOIN `olist-ecommerce-483517.olist_ecommerce.products` p
    ON oi.product_id = p.product_id
  LEFT JOIN `olist-ecommerce-483517.olist_ecommerce.product_category_translation` t
    ON p.product_category_name = t.product_category_name
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
  GROUP BY oi.seller_id
),

seller_reviews AS (
  SELECT
    oi.seller_id,
    ROUND(AVG(r.review_score), 2) as avg_review_score,
    COUNT(DISTINCT r.review_id) as total_reviews
  FROM `olist-ecommerce-483517.olist_ecommerce.order_items` oi
  JOIN `olist-ecommerce-483517.olist_ecommerce.orders` o
    ON oi.order_id = o.order_id
  JOIN `olist-ecommerce-483517.olist_ecommerce.reviews` r
    ON o.order_id = r.order_id
  JOIN `olist-ecommerce-483517.olist_ecommerce.products` p
    ON oi.product_id = p.product_id
  LEFT JOIN `olist-ecommerce-483517.olist_ecommerce.product_category_translation` t
    ON p.product_category_name = t.product_category_name
  WHERE COALESCE(t.product_category_name_english, p.product_category_name)
    IN (
      'computers_accessories',
      'electronics',
      'telephony',
      'computers',
      'tablets_printing_image',
      'audio',
      'consoles_games'
    )
  GROUP BY oi.seller_id
)

SELECT
  sm.seller_id,
  sm.total_orders,
  sm.unique_products,
  sm.categories_covered,
  sm.total_revenue,
  sm.avg_product_price,
  sm.total_freight,
  sm.avg_freight,
  sd.avg_delivery_days,
  sd.on_time_rate_pct,
  sr.avg_review_score,
  sr.total_reviews,
  CASE
    WHEN sm.total_revenue >= 10000 AND sd.on_time_rate_pct >= 70 THEN 'Elite Seller'
    WHEN sm.total_revenue >= 10000 AND sd.on_time_rate_pct < 70 THEN 'High Revenue / Low Reliability'
    WHEN sm.total_revenue < 10000 AND sd.on_time_rate_pct >= 70 THEN 'Reliable / Low Volume'
    ELSE 'Needs Improvement'
  END as seller_tier
FROM tech_seller_metrics sm
LEFT JOIN seller_delivery sd ON sm.seller_id = sd.seller_id
LEFT JOIN seller_reviews sr ON sm.seller_id = sr.seller_id
ORDER BY sm.total_revenue DESC;
