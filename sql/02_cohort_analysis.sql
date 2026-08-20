-- ============================================
-- Project 1, Phase 2: Cohort Retention Analysis
-- Assigns each customer to a cohort (month of first purchase),
-- then tracks month-over-month retention using CTEs + window functions
-- ============================================

WITH first_purchase AS (
    -- Step 1: Find each customer's earliest purchase date
    SELECT customer_unique_id, MIN(order_purchase_timestamp) AS first_purchase_date
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY customer_unique_id
),
cohort_assignment AS (
    -- Step 2: Assign each customer to a cohort month
    SELECT customer_unique_id, DATE_TRUNC('month', first_purchase_date) AS cohort_month
    FROM first_purchase
),
customer_orders AS (
    -- Step 3: Get every order each customer made, tagged by month
    SELECT c.customer_unique_id, DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
),
cohort_activity AS (
    -- Step 4: Calculate how many months after their cohort start each order happened
    SELECT ca.cohort_month, co.order_month,
           EXTRACT(YEAR FROM AGE(co.order_month, ca.cohort_month)) * 12 +
           EXTRACT(MONTH FROM AGE(co.order_month, ca.cohort_month)) AS month_number,
           ca.customer_unique_id
    FROM cohort_assignment ca
    JOIN customer_orders co ON ca.customer_unique_id = co.customer_unique_id
)
-- Final output: retention matrix — cohort_month × month_number × active customer count
SELECT cohort_month, month_number, COUNT(DISTINCT customer_unique_id) AS active_customers
FROM cohort_activity
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number;

output:
cohort_month            month_number   active_customers
"2016-09-01 00:00:00"	0	       4
"2016-10-01 00:00:00"	0	       321
"2016-10-01 00:00:00"	6	       1
"2016-10-01 00:00:00"	9	       1
"2016-10-01 00:00:00"	11	       1
"2016-10-01 00:00:00"	13	       1
"2016-10-01 00:00:00"	15	       1
"2016-10-01 00:00:00"	17	       1
"2016-10-01 00:00:00"	19	       2
"2016-10-01 00:00:00"	20	       2