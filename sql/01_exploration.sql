-- 1. Total orders by month
SELECT DATE_TRUNC('month', order_purchase_timestamp) AS month, COUNT(*) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;

-- 2. Top 10 product categories by revenue (English names)
SELECT ct.product_category_name_english, SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 10;

-- 3. Average order value by state
SELECT c.customer_state, AVG(order_total) AS avg_order_value
FROM (
    SELECT o.order_id, o.customer_id, SUM(oi.price) AS order_total
    FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id
) t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_order_value DESC;

-- 4. Customer count by state
SELECT customer_state, COUNT(*) AS customer_count
FROM customers
GROUP BY customer_state
ORDER BY customer_count DESC;

-- 5. Payment type distribution
select payment_type , count(*) as payment_count
from order_payments
GROUP BY payment_type;

-- 6. Average review score overall
select p.product_category_name, avg(ors.review_score) as avg_review_score
from order_reviews ors
JOIN order_items oi on ors.order_id=oi.order_id
JOIN products p on oi.product_id=p.product_id
group by p.product_category_name
order by avg_review_score desc;

-- 7. Top 10 sellers by total revenue
select seller_id, sum(price) as revenue
from order_items
group by seller_id
order by revenue desc
limit 10;

-- 8. Order status distribution as a % of total
select order_status, (COUNT(*) * 100.0) / SUM(COUNT(*)) OVER() AS percentage_share
from orders
group by order_status;

-- 9. Average days_to_deliver by state
select c.customer_state, round(avg(extract(day from o.order_delivered_customer_date - o.order_purchase_timestamp)),2) as avg_delivery_time
from orders o
JOIN customers c on o.customer_id=c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
group by customer_state
order by avg_delivery_time DESC;


-- 10. Monthly revenue trend
select DATE_TRUNC('month', o.order_purchase_timestamp)as months, sum(oi.price) as revenue
from orders o
join order_items oi on o.order_id=oi.order_id
group by months
order by months;
