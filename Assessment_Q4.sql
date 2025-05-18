SELECT 
u.id AS customer_id,
name,

-- Calculate account tenure in months from the date the customer joined till today
TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE) AS account_tenure,

-- Count the total number of transactions for the customer
COUNT(s.id) AS total_transaction,

-- Estimate CLV using the formula:
-- CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
-- where profit_per_transaction = 0.1% of confirmed_amount
ROUND(
(COUNT(s.id) / TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE)) *
12
* (AVG(s.confirmed_amount) * 0.001), 
2) AS estimated_clv
FROM new_users_customer u 

-- Join with savings account transactions
JOIN new_savings_savingsaccount s 
	ON u.id = s.owner_id 

-- Group results by customer
GROUP BY u.id

-- Sort customers by the number of transactions, descending
ORDER BY total_transaction DESC