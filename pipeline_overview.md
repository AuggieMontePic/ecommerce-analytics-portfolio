# Pipeline Overview
## Olist E-Commerce — End-to-End Analytics Pipeline

A production-style data pipeline built on the [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data), demonstrating the full journey from raw relational data to business intelligence dashboards.

---

## Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        EXTRACT                              │
│                                                             │
│   Kaggle CSV Export (8 relational tables, 100K+ orders)     │
│              │                                              │
│              ▼                                              │
│   Google BigQuery (raw ingestion layer)                     │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       TRANSFORM                             │
│                                                             │
│   BigQuery SQL — 9 queries across 2 analytical domains      │
│                                                             │
│   Data quality checks        Schema validation              │
│   Deduplication              NULL handling (COALESCE)       │
│   Business logic             Metric calculations            │
│   Category filtering         Segmentation & ranking         │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                         LOAD                                │
│                                                             │
│   Clean analytical tables in BigQuery                       │
│   Star-schema aligned, BI-ready output                      │
│   Documented transformation logic per query                 │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       VISUALISE                             │
│                                                             │
│   Project 1 → Looker Studio (sales & customer analytics)    │
│   Project 2 → Power BI (tech e-commerce operations)        │
└─────────────────────────────────────────────────────────────┘
```

---

## Extract

**Source:** Olist Brazilian E-Commerce Public Dataset (Kaggle)
**Format:** 8 CSV files exported and ingested into Google BigQuery as raw tables
**Period:** October 2016 – August 2018
**Volume:** 100K+ orders, 8 relational tables

Raw tables ingested:

| Table | Description |
|-------|-------------|
| `orders` | Central fact table — one row per order |
| `customers` | Customer registry — city, state, unique ID |
| `order_items` | Line-item grain — one row per item per order |
| `payments` | Payment events — supports split payment methods |
| `products` | Product catalogue with Portuguese category names |
| `sellers` | Seller registry — location data |
| `reviews` | Post-delivery customer review scores |
| `product_category_translation` | Portuguese → English category name lookup |

---

## Transform

All transformation logic lives in BigQuery SQL. Nine queries across two analytical projects handle cleaning, joining, deduplication, business logic, and metric calculation.

### Data quality decisions

**Delivered orders filter**
Base filter `WHERE order_status = 'delivered'` applied across all queries. Excludes cancelled, processing, and in-transit orders — ensuring only completed transactions flow into the analytical layer.

**COALESCE for null category handling**
The translation table does not cover every category. Rather than dropping unmatched rows, all queries apply a waterfall:
```sql
COALESCE(t.product_category_name_english, p.product_category_name, 'Uncategorized')
```
Prioritises English translation → falls back to Portuguese → assigns 'Uncategorized' only as last resort.

**Payment fan-out prevention**
The `payments` table holds multiple rows per order for split payment methods. All queries aggregate `SUM(payment_value)` at order level before joining to prevent double-counting revenue.

**Customer identity disambiguation**
`customer_id` in the `customers` table is order-scoped, not person-scoped. Repeat purchase and cohort queries use `customer_unique_id` to correctly track individual customers across multiple orders.

**Delivery rate deduplication (bug catch)**
During development, on-time delivery rates returned values above 100% — a fan-out caused by joining `order_items` (item grain) to `orders` (order grain) without deduplication. Resolved by adding `SELECT DISTINCT order_id` at the CTE level before rate calculation, confirming a correct 92% on-time rate across tech orders. Full write-up in [`data_model.md`](./data_model.md).

### SQL techniques demonstrated

| Technique | Queries |
|-----------|---------|
| CTEs (Common Table Expressions) | All queries |
| Window functions — `LAG`, `ROW_NUMBER`, `NTILE`, `DENSE_RANK` | Q1, Q3, Q4, Q6 |
| `ARRAY_AGG` and `ARRAY_LENGTH` | Q2, Q7 |
| Date functions — `DATE_DIFF`, `DATE_TRUNC`, `FORMAT_DATE` | Q1, Q3, Q5, Q8 |
| RFM analysis framework | Q3 |
| Cohort analysis methodology | Q5 |
| Multi-table JOINs (up to 6 tables) | All queries |
| Margin and profitability calculations | Q6, Q7 |
| Composite vendor scorecard logic | Q9 |
| `COUNTIF` for conditional aggregation | Q8, Q9 |
| `DISTINCT` deduplication for data integrity | Q8 |

---

## Load

Transformed query outputs are materialised as clean analytical tables in BigQuery, structured around a star-schema pattern:

- `orders` as the central fact table
- `customers`, `products`, `sellers` as dimension tables
- `order_items` as the bridge between fact and dimensions
- `payments` and `reviews` as supplementary fact tables

Each table is documented in [`data_model.md`](./data_model.md) with field descriptions, grain definitions, and known edge cases.

---

## Visualise

Two BI dashboards consume the transformed BigQuery output directly via live connector.

### Project 1 — Looker Studio
**Focus:** Sales performance, customer segmentation, geographic distribution
**Pages:** Executive summary · Customer value analysis · Geographic sales analysis
**Key findings:**
- $15.4M total revenue across 96.5K delivered orders
- 59.1% of revenue generated by the top spending quartile
- São Paulo generates $2.7M — nearly double second-place Rio de Janeiro
- Near-zero repeat purchase rate confirms acquisition-dependent business model

[View Project 1 →](./project-1-looker-studio/)

### Project 2 — Power BI
**Focus:** Tech product performance, delivery operations, seller quality
**Pages:** Product & category performance · Delivery & operations · Seller performance
**Key findings:**
- $1.83M revenue across 15,110 tech orders
- Computers achieve highest margin at 9.56% despite lowest order volume
- 92% on-time delivery rate — Olist systematically sets conservative estimates
- Only 10.08% of 476 sellers qualify as Elite (high revenue + high reliability)

[View Project 2 →](./project-2-powerbi/)

---

## Repository Structure

```
/
├── pipeline_overview.md          ← You are here
├── data_model.md                 ← Schema diagram, table docs, transformation decisions
├── project-1-looker-studio/
│   ├── README.md                 ← Dashboard overview and findings
│   └── queries/
│       ├── 01_monthly_sales_performance.sql
│       ├── 02_top_products_by_revenue.sql
│       ├── 03_customer_segmentation.sql
│       ├── 04_geographic_sales_distribution.sql
│       └── 05_cohort_retention_analysis.sql
└── project-2-powerbi/
    ├── README.md                 ← Dashboard overview and findings
    └── queries/
        ├── 06_tech_category_performance.sql
        ├── 07_tech_top_products.sql
        ├── 08_delivery_operations.sql
        └── 09_seller_performance.sql
```

---

*Dataset: [Olist Brazilian E-Commerce on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data)*
*Tools: Google BigQuery · Looker Studio · Microsoft Power BI*
