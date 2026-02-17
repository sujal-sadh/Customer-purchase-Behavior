/*
Project: Customer Purchase Behavior
Database: PostgreSQL
Objective: Analyze customer purchasing patterns, revenue distribution,
           subscription behavior, and product performance.
*/

------------------------------------------------------------
-- Q1. Total Revenue by Gender
------------------------------------------------------------
SELECT 
    gender,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY gender
ORDER BY total_revenue DESC;


------------------------------------------------------------
-- Q2. Customers Who Used Discount but Spent Above Average
------------------------------------------------------------
SELECT 
    customer_id,
    purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
AND purchase_amount >= (
    SELECT AVG(purchase_amount) FROM customer
);


------------------------------------------------------------
-- Q3. Top 5 Products by Average Review Rating
------------------------------------------------------------
SELECT 
    item_purchased,
    ROUND(AVG(review_rating)::NUMERIC, 2) AS average_rating
FROM customer
GROUP BY item_purchased
ORDER BY average_rating DESC
LIMIT 5;


------------------------------------------------------------
-- Q4. Average Purchase Amount by Shipping Type
------------------------------------------------------------
SELECT 
    shipping_type,
    ROUND(AVG(purchase_amount), 2) AS avg_purchase_amount
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type
ORDER BY avg_purchase_amount DESC;


------------------------------------------------------------
-- Q5. Spending Analysis: Subscribers vs Non-Subscribers
------------------------------------------------------------
SELECT 
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS average_spend,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC;


------------------------------------------------------------
-- Q6. Top 5 Products with Highest Discount Usage Rate
------------------------------------------------------------
SELECT 
    item_purchased,
    ROUND(
        100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS discount_percentage
FROM customer
GROUP BY item_purchased
ORDER BY discount_percentage DESC
LIMIT 5;


------------------------------------------------------------
-- Q7. Customer Segmentation (New, Returning, Loyal)
------------------------------------------------------------
WITH customer_segments AS (
    SELECT 
        customer_id,
        previous_purchases,
        CASE
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer
)
SELECT 
    customer_segment,
    COUNT(*) AS total_customers
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;


------------------------------------------------------------
-- Q8. Top 3 Most Purchased Products in Each Category
------------------------------------------------------------
WITH ranked_products AS (
    SELECT 
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(customer_id) DESC
        ) AS product_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT 
    category,
    item_purchased,
    total_orders,
    product_rank
FROM ranked_products
WHERE product_rank <= 3;


------------------------------------------------------------
-- Q9. Repeat Buyers vs Subscription Status
------------------------------------------------------------
SELECT 
    subscription_status,
    COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status
ORDER BY repeat_buyers DESC;


------------------------------------------------------------
-- Q10. Revenue Contribution by Age Group
------------------------------------------------------------
SELECT 
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;
