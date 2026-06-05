# Business Intelligence Conclusion Report
## Olist Brazilian E-Commerce — Cross-Project Executive Summary

**Author:** AuggieMontePic  
**Projects Covered:** Project 1 (Data Studio — Sales & Customer Analytics) · Project 2 (Power BI — Tech E-Commerce Operations)  
**Dataset Period:** October 2016 – August 2018  
**Audience:** Directive Board / Executive Stakeholders  

---

## Preamble

This document synthesises the analytical findings produced across both BI projects in this portfolio into a unified executive conclusion. Where Project 1 examined the full marketplace — revenue, customer value, and geography — Project 2 zoomed into the tech vertical to interrogate product margins, delivery operations, and seller quality. Together, the two dashboards tell a coherent story about a business with strong acquisition mechanics, promising operational foundations, and several structural vulnerabilities that require strategic attention.

The following report is structured around five business themes that emerge from the combined dataset. Each theme is followed by a concrete recommendation addressed to decision-makers.

---

## Section 1 — The Revenue Picture

### What the Data Shows

The Olist marketplace generated **$15.4M in total revenue across 96,500 delivered orders** between 2017 and 2018. Tech categories — computers, electronics, telephony, accessories, audio, tablets, and gaming — contributed **$1.83M of that figure**, representing approximately **11.9% of total revenue** while accounting for a concentrated pool of higher-margin products.

Monthly sales data (Q1) reveals that revenue growth was not linear. The 2017-to-2018 period showed meaningful acceleration, suggesting the platform was scaling during the window under analysis. Applying the LAG window function to track month-over-month changes confirmed the presence of seasonal spikes, likely tied to Brazilian retail events such as Black Friday and Natal (Christmas).

Within the tech vertical specifically, **Computer Accessories led in absolute revenue at $911K**, driven by high order volume. However, **Computers achieved the highest margin at 9.56%** despite lower sales counts — a telling divergence between volume leadership and profitability leadership.

### Recommendation to the Board

> **Prioritise margin-weighted growth over volume metrics.** The instinct to celebrate Computer Accessories as the star category is understandable given its $911K revenue contribution, but the board should shift attention toward **Computers as the margin engine**. A targeted strategy to grow Computers — through assortment expansion, better placement, or seller incentives — would improve the overall profitability profile of the tech vertical without requiring proportional increases in order volume. Introduce blended margin dashboards as a standard executive KPI to avoid volume-only decision-making.

---

## Section 2 — The Customer Retention Crisis

### What the Data Shows

The most structurally significant finding across both projects is also the least comfortable: **the business is almost entirely acquisition-dependent**.

Cohort retention analysis (Q5) revealed a **near-zero repeat purchase rate** across all customer cohorts analysed. A customer acquired in Month 1 was statistically unlikely to place a second order in any subsequent month. This is not a data quality artefact — it was confirmed by using `customer_unique_id` as the correct cross-order identifier, and the finding held consistently across every cohort window tested.

RFM segmentation (Q3) produced equally stark results. The **top 25% of customers generated 59.1% of total revenue** — but the label applied to this group was "High-Value One-Timers," not loyal customers. These were customers who spent significantly on a single occasion and then did not return. This makes the revenue base fragile: it is constantly renewed by new high-value acquirees rather than compounded by returning ones.

The data is consistent with what is known about marketplace dynamics in Brazil during this period: multi-vendor platforms like Olist functioned partly as transactional search engines rather than loyalty destinations. But this structural context does not reduce the urgency of the finding — it sharpens it.

### Recommendation to the Board

> **Build a retention infrastructure before scaling acquisition spend.** Every dollar invested in acquiring a new customer currently produces, on average, one transaction. There is no compounding effect. The board should commission a **Customer Lifetime Value (CLV) uplift programme** with three components: (1) a post-purchase re-engagement sequence triggered 30–60 days after first delivery, (2) a loyalty or subscription mechanic for the High-Value One-Timer segment identified in Q3, and (3) a repeat purchase rate KPI introduced as a top-line board metric — not buried in operations reporting. Until repeat rate moves meaningfully above zero, acquisition ROI will remain a single-transaction calculation.

---

## Section 3 — Geographic Concentration and Opportunity

### What the Data Shows

Geographic distribution analysis (Q4) confirmed that **São Paulo generated $2.7M in revenue — nearly double the $1.4M of second-place Rio de Janeiro**. The top states by revenue are overwhelmingly concentrated in Brazil's South and Southeast, mirroring the country's broader economic geography.

This concentration is simultaneously a strength and a risk. São Paulo's dominance reflects deep market penetration in the country's largest consumer economy. But the same data reveals that large swathes of Brazil — the Northeast, the Centre-West, the North — are significantly underserved relative to their population size, even accounting for logistical challenges.

Cross-referencing with delivery data from Q8 adds nuance: **orders were delivered an average of 12+ days ahead of the estimated delivery date**. This suggests that Olist's logistics partners systematically set conservative delivery estimates — a practice that inflates customer satisfaction scores artificially while obscuring the actual delivery capability the platform could credibly promise. The 92% on-time delivery rate in the tech vertical is genuine, but it is measured against an intentionally conservative benchmark.

### Recommendation to the Board

> **Two actions are warranted simultaneously.** First, **recalibrate delivery estimates** to reflect actual delivery performance more accurately. Systematically over-delivering against a conservative promise is a missed opportunity — customers who receive orders 12 days early are not being told they received orders 12 days early. Tighter estimates, honestly communicated, allow the platform to market its logistical edge rather than quietly absorb it. Second, **map the geographic revenue gap against logistics capability** to identify which underserved states have the infrastructure to support expansion. The Northeast, in particular, represents a large consumer base where early mover advantage is still available.

---

## Section 4 — Seller Quality and the Elite Concentration Problem

### What the Data Shows

Seller performance analysis (Q9) across the tech vertical produced a striking finding: **only 10.08% of 476 active sellers qualified as Elite** — defined by a composite scorecard of revenue, reliability, and review scores. The remaining ~90% of sellers occupied Standard or lower tiers.

The average seller review score across tech orders sat at **3.9 out of 5** — a figure that, while above the midpoint, masks considerable variance. A marketplace average of 3.9 means a meaningful proportion of sellers are operating below that mark, generating customer experiences that damage platform trust even if they represent a minority of orders.

This quality concentration creates two structural risks. First, the Elite tier is small enough that losing even a handful of top sellers could measurably impact the tech vertical's revenue and customer experience. Second, the large Standard seller population is not being actively differentiated — customers cannot reliably identify quality sellers at the point of purchase, which suppresses willingness to pay and limits conversion rates on higher-priced tech items.

### Recommendation to the Board

> **Implement a tiered seller development programme with visible consumer-facing signals.** On the supply side, the board should invest in an Elite Seller growth track — structured support, preferential placement, and performance coaching aimed at moving Standard sellers into Elite. The target should be to at least double Elite representation within 18 months. On the demand side, Elite status should be **surfaced to consumers at the point of purchase** — a visible quality badge that allows buyers to self-select toward better experiences. This simultaneously rewards quality sellers, improves platform NPS, and creates a defensible competitive moat for the marketplace as a whole.

---

## Section 5 — The Tech Vertical as a Strategic Lever

### What the Data Shows

Analysed in isolation, the tech vertical (Project 2) generated $1.83M across 15,110 orders with a 92% on-time delivery rate. These are solid numbers — but the more interesting question is what tech categories signal about the broader platform strategy.

Tech products are characterised by higher average order values, margin potential (Computers at 9.56%), and purchase decisions that require more consumer trust. They are also more vulnerable to seller quality variance — a low-rated seller on a commodity household item is a minor inconvenience; the same seller on a laptop purchase erodes platform credibility significantly.

The fact that tech categories represent only ~12% of total revenue while demanding disproportionate quality vigilance suggests they are currently under-optimised. The operational infrastructure — delivery rates, seller review mechanisms, category analytics — is already in place. What is missing is a deliberate category strategy that treats tech as a premium destination rather than one vertical among many.

### Recommendation to the Board

> **Position tech as the platform's premium flagship vertical.** The operational groundwork is done: delivery is reliable, the data infrastructure is mature, and margin leaders like Computers have been identified. The board should now invest in elevating tech's **share of revenue from 12% to 20%+** through three levers: (1) curated tech storefronts that highlight Elite sellers and premium products, (2) category-specific buyer protections and return policies that reduce purchase anxiety on high-value items, and (3) a seller acquisition campaign targeting reputable tech retailers currently absent from the platform. Tech is where platform trust converts into premium AOV — it deserves a dedicated growth mandate.

---

## Summary of Recommendations

| Priority | Theme | Action | Time Horizon |
|----------|-------|--------|--------------|
| 🔴 Critical | Customer Retention | Launch CLV uplift programme; introduce repeat rate as a board KPI | 0–6 months |
| 🔴 Critical | Seller Quality | Build tiered seller development programme; surface quality to consumers | 0–6 months |
| 🟡 High | Revenue Strategy | Shift executive focus to margin-weighted metrics; grow Computers category | 3–9 months |
| 🟡 High | Tech Vertical | Elevate tech to flagship status; target 20%+ revenue share | 6–18 months |
| 🟢 Medium | Geographic Expansion | Recalibrate delivery estimates; map Northeast expansion opportunity | 6–18 months |

---

## Closing Note on Data Confidence

All findings in this report are grounded in 96,500+ delivered orders across a 22-month period, processed through a documented ETL pipeline with explicit data quality controls. Key methodological decisions — delivered-only filters, customer identity disambiguation via `customer_unique_id`, payment fan-out prevention, and delivery rate deduplication — were made deliberately to ensure that the numbers presented to stakeholders reflect genuine business performance rather than analytical artefacts.

One limitation should be noted: the near-zero repeat purchase rate, while analytically confirmed, may partially reflect characteristics of the Olist marketplace model during 2016–2018 rather than exclusively representing a failure of retention strategy. Cross-referencing these findings with post-2018 platform data, where available, would strengthen the confidence of the retention recommendation before committing to a full programme.

---

*Analysis based on the Olist Brazilian E-Commerce Public Dataset (Kaggle) · October 2016 – August 2018*  
*Projects: [Project 1 — Data Studio](./project-1-looker-studio) · [Project 2 — Power BI](./project-2-powerbi)*  
*Pipeline documentation: [pipeline_overview.md](./pipeline_overview.md) · [data_model.md](./data_model.md)*
