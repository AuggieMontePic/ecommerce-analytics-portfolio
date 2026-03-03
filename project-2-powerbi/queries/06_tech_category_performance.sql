/*
========================================
QUERY 6: TECH CATEGORY PERFORMANCE
========================================

Business Question:
Which tech categories are most profitable? What are the margin profiles
across categories? Where should a tech store expand vs consolidate its catalog?

Description:
Evaluates profitability and performance metrics across product categories. 
Calculates contribution margins by incorporating shipping costs and uses 
DENSE_RANK for category ranking. Demonstrates ability to analyze P&L components, 
identify most profitable product lines, and provide actionable recommendations 
for inventory and pricing strategies.

Key Metrics:
- Revenue by tech category
- Number of orders per category
- Number of unique products per category
- Total and average shipping costs per category
- Net revenue (revenue minus shipping)
- Contribution margin percentage
- Category ranking by revenue

SQL Techniques Demonstrated:
- Category-level aggregations with tech filter
- Profit margin calculations (revenue - costs)
- DENSE_RANK for ranking with ties
- Multiple aggregations in single query
- Financial metric calculations
- Translation table joins for English category names

Business Value:
Identifies which tech categories are revenue drivers vs profit drivers.
Reveals categories with high shipping costs eroding margins — particularly 
relevant for tech, where items like computers ship at higher freight costs 
than accessories. Informs inventory allocation and supplier negotiations.

Dataset Finding:
Computers category shows $48 average shipping cost — more than double any 
other tech category. Despite lower order volume (181 orders), Computers 
achieve the highest margin at 9.56%, making them the most profitable category 
per unit sold. Computer Accessories dominates by volume and total revenue 
but at a lower margin of 8.39%.
========================================
*/

WITH tech_category_metrics AS (
  SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'Uncategorized') as category,
    COUNT(DISTINCT oi.order_id) as num_orders,
    COUNT(DISTINCT oi.product_id) as num_products,
    SUM(oi.price) as total_revenue,
    SUM(oi.freight_value) as total_shipping,
    ROUND(AVG(oi.price), 2) as avg_product_price,
    ROUND(AVG(oi.freight_value), 2) as avg_shipping_cost
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
  GROUP BY category
)

SELECT
  category,
  num_orders,
  num_products,
  ROUND(total_revenue, 2) as revenue,
  ROUND(total_shipping, 2) as shipping_costs,
  ROUND(total_revenue - total_shipping, 2) as net_revenue,
  avg_product_price,
  avg_shipping_cost,
  ROUND((total_revenue - total_shipping) / total_revenue * 100, 2) as margin_pct,
  DENSE_RANK() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM tech_category_metrics
WHERE category IS NOT NULL
ORDER BY revenue DESC;
