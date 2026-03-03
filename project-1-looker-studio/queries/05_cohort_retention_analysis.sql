/*
========================================
QUERY 5: COHORT RETENTION ANALYSIS
========================================

Business Question:
Do customers come back after their first purchase? What's our retention rate
by acquisition cohort? How quickly does retention decay?

Description:
Tracks customer retention by acquisition cohort using month-over-month retention 
rates. Employs multiple CTEs, self-joins, and date functions (DATE_TRUNC, 
DATE_DIFF) to measure customer lifecycle behavior. Demonstrates advanced analytics 
concepts (cohort analysis) critical for understanding customer engagement patterns 
and informing retention marketing strategies.

Key Metrics:
- Cohort size (customers acquired each month)
- Active customers per cohort per month
- Retention percentage by months since first purchase
- Retention curves over customer lifecycle

SQL Techniques Demonstrated:
- Cohort analysis methodology (advanced analytics concept)
- Self-joins to connect first purchase with subsequent purchases
- DATE_TRUNC for monthly cohort grouping
- DATE_DIFF for calculating months since acquisition
- Multiple CTEs for complex multi-step logic

Business Value:
Reveals the reality of e-commerce retention and helps set realistic 
expectations. Identifies which cohorts have better or worse retention,
informing what acquisition channels or promotions drive quality customers.
Critical for calculating true customer lifetime value (LTV).

Dataset Finding:
This query revealed near-zero repeat purchase rates across all cohorts —
confirming that the Olist marketplace operates almost entirely on new customer
acquisition rather than retention. This honest finding demonstrates analytical
integrity and was used to reframe the dashboard narrative around acquisition
quality rather than retention metrics. A valuable real-world lesson in
letting data tell its true story.
========================================
*/

WITH first_purchase AS (
  SELECT
    customer_id,
    DATE_TRUNC(MIN(DATE(order_purchase_timestamp)), MONTH) as cohort_month
  FROM `olist-ecommerce-483517.olist_ecommerce.orders`
  WHERE order_status = 'delivered'
  GROUP BY customer_id
),

all_purchase_months AS (
  SELECT DISTINCT
    o.customer_id,
    DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) as purchase_month
  FROM `olist-ecommerce-483517.olist_ecommerce.orders` o
  WHERE o.order_status = 'delivered'
),

cohort_size AS (
  SELECT
    cohort_month,
    COUNT(DISTINCT customer_id) as cohort_customers
  FROM first_purchase
  GROUP BY cohort_month
),

cohort_activity AS (
  SELECT
    fp.cohort_month,
    pm.purchase_month,
    DATE_DIFF(pm.purchase_month, fp.cohort_month, MONTH) as months_since_first,
    COUNT(DISTINCT fp.customer_id) as active_customers
  FROM first_purchase fp
  JOIN all_purchase_months pm
    ON fp.customer_id = pm.customer_id
  GROUP BY cohort_month, purchase_month, months_since_first
)

SELECT
  ca.cohort_month,
  ca.months_since_first,
  cs.cohort_customers,
  ca.active_customers,
  ROUND(ca.active_customers / cs.cohort_customers * 100, 2) as retention_pct
FROM cohort_activity ca
JOIN cohort_size cs
  ON ca.cohort_month = cs.co
