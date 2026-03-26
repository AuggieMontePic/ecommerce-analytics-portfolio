# Project 2 — Tech E-Commerce Product & Operations Analytics

**Tool:** Microsoft Power BI Desktop
**Data Warehouse:** Google BigQuery
**Dataset:** Olist Brazilian E-Commerce (2017–2018)
**Dashboard:** 3-page report filtered to 7 tech categories

> This project is part of a larger analytics pipeline.
> See [`pipeline_overview.md`](../pipeline_overview.md) for the full ETL architecture and [`data_model.md`](../data_model.md) for the schema diagram and transformation decisions.

---

## Project Overview

This project analyses 15,110 delivered orders across 7 tech product categories from the Olist Brazilian e-commerce marketplace. The analysis covers product and category performance, delivery operations, and seller quality metrics — tailored specifically for tech store owners and Shopify merchants operating in the electronics and computer accessories space.

**Tech Categories Analysed:**
- Computer Accessories
- Telephony
- Electronics
- Consoles & Games
- Audio
- Computers
- Tablets & Imaging

---

## Dashboard Pages

### Page 1 — Product & Category Performance
Revenue distribution, margin analysis, and product-level performance across all 7 tech categories.

**Key visuals:**
- Revenue Distribution by Tech Category (treemap)
- Margin % by Category (bar chart)
- Product Performance — Price vs Revenue (scatter plot)
- Category Performance Summary (table)

**Key findings:**
- $1.83M total tech revenue across 15K orders
- Computer Accessories leads by volume (6,689 orders) and revenue ($911K)
- Computers achieve highest margin at 9.56% despite only 181 orders
- Computers average $48 shipping cost — more than double any other category
- Strong price vs revenue correlation visible in scatter plot with one high-price outlier around $3,000 avg price

---

### Page 2 — Delivery & Operations Performance
Fulfillment analysis comparing actual vs estimated delivery times across categories and Brazilian states.

**Key visuals:**
- Delivery Status by Category (stacked bar chart)
- Avg Delivery Days by Category (bar chart)
- On-Time Delivery Rate by State (bar chart)

**Key findings:**
- 92% on-time delivery rate across all tech orders
- Orders arrive an average of 12.82 days ahead of estimated date
- Olist systematically sets conservative delivery estimates
- Consoles & Games have longest avg delivery at ~17 days
- Tablets & Imaging fastest at ~15 days
- AP and RR states show highest on-time rates

---

### Page 3 — Seller Performance
Individual seller analysis combining revenue, reliability, and review metrics into a composite performance tier classification.

**Key visuals:**
- Sellers by Tier (donut chart)
- Seller Performance Detail (table)
- Top 15 Sellers by Revenue (bar chart)

**Key findings:**
- 476 active tech sellers identified
- Only 10.08% qualify as Elite Sellers (high revenue + high reliability)
- 78.78% are Reliable / Low Volume — reliable but not yet scaling
- Top seller generates $222K — nearly 4x the second-place seller
- Average review score 3.9/5 indicates room for seller quality improvement
- No sellers fell into High Revenue / Low Reliability tier — high earners tend to maintain good delivery standards

---

## Queries

| # | Query | Description |
|---|-------|-------------|
| 6 | [Tech Category Performance](./queries/06_tech_category_performance.sql) | Margin and profitability analysis with DENSE_RANK |
| 7 | [Tech Top Products](./queries/07_tech_top_products.sql) | Tech-filtered product revenue with ARRAY_AGG |
| 8 | [Delivery & Operations](./queries/08_delivery_operations.sql) | Fulfillment analysis with delay classification and deduplication bug fix |
| 9 | [Seller Performance](./queries/09_seller_performance.sql) | Vendor scorecard with composite tier logic |

---

## SQL Techniques Demonstrated

| Technique | Query |
|-----------|-------|
| CTEs (Common Table Expressions) | All queries |
| `DENSE_RANK` for category ranking | Q6 |
| `ARRAY_AGG` and `ARRAY_LENGTH` | Q7 |
| `DATE_DIFF` for delivery time calculations | Q8 |
| `COUNTIF` for conditional aggregation | Q8, Q9 |
| `DISTINCT` deduplication for data integrity | Q8 |
| `CASE` for delay and tier classification | Q8, Q9 |
| Composite vendor scorecard logic | Q9 |
| Margin and profitability calculations | Q6 |
| Multi-table JOINs across 6 relational tables | All queries |
| Tech category filtering | All queries |

---

## Data Quality Note

Query 8 initially returned on-time delivery rates above 100% — a fan-out bug caused by joining item-grain and order-grain tables without deduplication. The issue was identified, traced to its root cause, and resolved. Full write-up in [`data_model.md`](../data_model.md) under *Data Quality: Bug Identification & Resolution*.

---

## Tech Store Application

This project was built with Shopify tech store owners in mind. Every metric and insight maps directly to decisions a tech merchant makes daily:

- **Which categories to expand** → margin and revenue analysis
- **Which products to feature in ads** → top products by revenue
- **How to set delivery expectations** → actual vs estimated delivery
- **Which suppliers to prioritise** → seller tier classification
- **Where customer experience needs work** → review scores and delay rates

The analytical framework demonstrated here can be adapted to any product vertical by updating the category filter in each query.

---

## Related Docs

- [`pipeline_overview.md`](../pipeline_overview.md) — Full ETL architecture: Extract → Transform → Load → Visualise
- [`data_model.md`](../data_model.md) — Schema diagram, table descriptions, and transformation decisions
- [Project 1 →](../project-1-looker-studio/) — Sales & customer analytics in Looker Studio

---

*Dataset: [Olist Brazilian E-Commerce on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data)*
