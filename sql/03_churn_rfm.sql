-- ============================================
-- Project 1, Phase 2: Churn Definition + RFM Segmentation
-- Part A: Flags each customer as Churned/Active based on days since last order
-- Part B: Segments customers into Recency/Frequency/Monetary quartiles
--         and combines them into a single rfm_score for churn-risk ranking
-- Note: Uses customer_unique_id throughout (true per-person ID),
--       NOT customer_id (which is per-transaction in this dataset)
-- ============================================

-- ============================================
-- PART A: Churn Definition
-- Rule: customer is "Churned" if their last order was more than
-- 90 days before the dataset's own max order date
-- ============================================

WITH customer_last_order AS (
    -- Step 1: Find each customer's most recent order date
    SELECT c.customer_unique_id, MAX(o.order_purchase_timestamp) AS last_order_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
dataset_max_date AS (
    -- Step 2: Get the single reference date (dataset's latest order, not real-world "today")
    SELECT MAX(order_purchase_timestamp) AS max_date FROM orders
),
churn_flagged AS (
    -- Step 3: Calculate days since last order and assign churn status
    SELECT clo.customer_unique_id,
           clo.last_order_date,
           dmd.max_date,
           (dmd.max_date - clo.last_order_date) AS days_since_last_order,
           CASE 
    		WHEN (dmd.max_date - clo.last_order_date) > INTERVAL '90 days' THEN 'Churned'
    		ELSE 'Active'
	   END AS churn_status
    FROM customer_last_order clo
    CROSS JOIN dataset_max_date dmd
)
-- Final output A1: full per-customer churn detail
SELECT * FROM churn_flagged;

Output:

"347dc668e37fdec762bbc337aff5bb12"	"2017-01-30 20:27:40"	"2018-10-17 17:30:18"	"624 days 21:02:38"	"Churned"
"a46e277a383f4389ce5e0b642902c72c"	"2018-01-12 22:44:11"	"2018-10-17 17:30:18"	"277 days 18:46:07"	"Churned"
"6ead799d8a12f9095ab29409be2aa075"	"2017-06-18 12:16:28"	"2018-10-17 17:30:18"	"486 days 05:13:50"	"Churned"
"dd4d20c4fb1f0f3706d0e1e66b049a3f"	"2017-10-10 20:44:59"	"2018-10-17 17:30:18"	"371 days 20:45:19"	"Churned"
"10b6d571eedd3e1bbf10521ee704dcd4"	"2018-02-13 18:36:46"	"2018-10-17 17:30:18"	"245 days 22:53:32"	"Churned"
"ed91e29ad9cf4fad5935469b0e91e792"	"2018-06-11 12:37:05"	"2018-10-17 17:30:18"	"128 days 04:53:13"	"Churned"
"f172e87cb8cd89e4e34bce37f28ce713"	"2017-02-01 11:53:55"	"2018-10-17 17:30:18"	"623 days 05:36:23"	"Churned"
"3f5e1e19d480a0e4683b1e52dcd0f257"	"2017-09-24 16:51:14"	"2018-10-17 17:30:18"	"388 days 00:39:04"	"Churned"
"012216caf4f1082ba3fc02e584de9a29"	"2017-10-17 23:47:22"	"2018-10-17 17:30:18"	"364 days 17:42:56"	"Churned"
"8f76029e5de1f119feece36c04d34371"	"2017-10-10 16:44:43"	"2018-10-17 17:30:18"	"372 days 00:45:35"	"Churned"

Total rows: 96096
Query complete 00:00:00.335
Rows selected: 10
CRLF
Ln 28, Col 1



-- ============================================
-- PART A2: Overall churn rate summary
-- (Run separately, or as a second statement — summarizes Part A into headline %)
-- ============================================

WITH customer_last_order AS (
    SELECT c.customer_unique_id, MAX(o.order_purchase_timestamp) AS last_order_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),
dataset_max_date AS (
    SELECT MAX(order_purchase_timestamp) AS max_date FROM orders
),
churn_flagged AS (
    SELECT clo.customer_unique_id,
           CASE 
               WHEN (dmd.max_date - clo.last_order_date) > INTERVAL '90 days' THEN 'Churned'
               ELSE 'Active'
           END AS churn_status
    FROM customer_last_order clo
    CROSS JOIN dataset_max_date dmd
)
SELECT churn_status, 
       COUNT(*) AS customer_count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM churn_flagged
GROUP BY churn_status;

Output:

"Churned"	86684	90.21
"Active"	9412	9.79

Total rows: 2
Query complete 00:00:00.202
Rows selected: 2
CRLF
Ln 22, Col 19


-- ============================================
-- PART B: RFM Segmentation
-- Splits customers into quartiles on Recency, Frequency, and Monetary value,
-- then combines them into one rfm_score (3 = best possible, 12 = worst possible)
-- ============================================

WITH customer_metrics AS (
    SELECT c.customer_unique_id,
           MAX(o.order_purchase_timestamp) AS last_order_date,
           COUNT(DISTINCT o.order_id) AS frequency,
           COALESCE(SUM(oi.price), 0) AS monetary
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
),
rfm AS (
    SELECT customer_unique_id,
           NTILE(4) OVER (ORDER BY last_order_date DESC NULLS LAST, customer_unique_id ASC) AS recency_quartile,
           NTILE(4) OVER (ORDER BY frequency DESC, customer_unique_id ASC) AS frequency_quartile,
           NTILE(4) OVER (ORDER BY monetary DESC, customer_unique_id ASC) AS monetary_quartile
    FROM customer_metrics
)
SELECT customer_unique_id, 
       recency_quartile, 
       frequency_quartile, 
       monetary_quartile,
       (recency_quartile + frequency_quartile + monetary_quartile) AS rfm_score
FROM rfm
ORDER BY rfm_score ASC;

output:

"0074a1d3f1995ff0538dc7197500973c"	1	1	1	3
"baad97a77fafd04f72a7f874dd67b37e"	1	1	1	3
"3184857361deb56be5aaa646f2737994"	1	1	1	3
"297671736648f96db5d0fc8a2a1fb30d"	1	1	1	3
"35694662ee96ef8cd104c2e9e9f2156c"	1	1	1	3
"0ee8c10ba5bf1fd978741e98bd9449b9"	1	1	1	3
"10ade705ca843fba444f2ef385bfa214"	1	1	1	3
"32326030f94a88d5f606830e9f528349"	1	1	1	3
"021ac5734c4f62601583998bf0de4e03"	1	1	1	3
"860f75391be5698f015d3b234e7576d6"	1	1	1	3

Total rows: 96096
Query complete 00:00:01.274
Rows selected: 10
CRLF
Ln 24, Col 24