-- CTE 1: Calculate total number of successful transactions per customer
WITH customer_transactions AS (
    SELECT 
        u.id AS customer_id,
        u.name,
        COUNT(s.id) AS total_transactions
    FROM new_users_customer u
        -- Join savings accounts only with 'success' transaction status
    LEFT JOIN new_savings_savingsaccount s 
        ON u.id = s.owner_id AND s.transaction_status = 'success'
    GROUP BY u.id, u.name
),

-- CTE 2: Calculate average transactions per month over a 105-month period (min = 2016-08 to max = 2025-04)
customer_frequency AS (
    SELECT 
        customer_id,
        name,
        total_transactions,
        ROUND(CAST(total_transactions AS DECIMAL) / 105, 2) AS avg_transactions_per_month
    FROM customer_transactions
),

categorized_customers AS (
    SELECT 
        *,
        CASE 
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM customer_frequency
)

-- Final result: count of customers per category and their average transactions per month
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM categorized_customers
GROUP BY frequency_category
ORDER BY avg_transactions_per_month DESC;