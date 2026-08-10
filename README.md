# E-Commerce Customer Churn & Cohort Analysis

## Objective
Analyze customer purchasing behavior, churn patterns, and cohort retention 
for a Brazilian e-commerce platform (Olist) to identify at-risk customer 
segments and revenue trends.

## Dataset
Brazilian E-Commerce Public Dataset by Olist (Kaggle), ~100k orders across 
9 relational tables (2016–2018).

## Tech Stack
PostgreSQL, Python (Pandas, Matplotlib/Seaborn), Power BI

## Schema
![ER Diagram](images/er_diagram.png)

## Project Status
🚧 In Progress — Phase 1: Data acquisition, schema design, and exploratory 
SQL analysis complete. Cohort/churn logic and Python EDA in progress.

## Key Files
- `/sql/01_exploration.sql` — Initial exploratory queries (order trends, 
  revenue by category, order value by state)

## Findings So Far
- **Delivery performance:** 97.02% of orders were successfully delivered, with only 
  ~3% falling into canceled, unavailable, or other non-delivered statuses — indicating 
  strong platform reliability.
- **Average delivery time:** Orders take an average of 12.09 days from purchase to 
  customer delivery across the platform.
- **Regional delivery gap:** Remote states (AP: 26.73 days, AM: 25.99 days, AL: 24.04 
  days) show significantly longer delivery times compared to logistics-hub states, 
  highlighting a geographic fulfillment disparity worth investigating further.
- **Revenue concentration:** São Paulo (SP) is the dominant market, generating over 
  R$5.2M in total revenue — by far the largest of any state.
- **Revenue growth trend:** Monthly revenue grew steadily from ~R$433K in June 2017 
  to over R$1M by November 2017, reflecting strong platform growth through the 
  dataset's timeframe (Sep 2016–Oct 2018).
- **Payment behavior:** Credit card is the dominant payment method (~74% of all 
  payment records), followed by boleto (~19%) — consistent with typical Brazilian 
  e-commerce payment patterns.
- **Top seller concentration:** The highest-revenue seller generated R$229,472.63, 
  representing roughly 1.6–1.7% of total platform revenue — a healthy, non-monopolized 
  seller distribution across 3,095 sellers.