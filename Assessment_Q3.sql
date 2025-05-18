-- Step 1: Create a Common Table Expression (CTE) to get latest transaction per plan
WITH account_activity as(
    SELECT 
        p.id AS plan_id,
        p.owner_id,
		
        -- Classify the account as 'Savings', 'Investment', or 'Unknown'
        CASE 
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Unknown'
        END AS type,
		
        -- Get the most recent transaction date for inflows only
        MAX(s.transaction_date) AS last_transaction_date
    FROM new_plans_plan p
    
	-- Join to savings transactions, but only where confirmed_amount > 0 (i.e., inflow)
    LEFT JOIN new_savings_savingsaccount s 
        ON p.id = s.plan_id AND s.confirmed_amount > 0
	
	-- Filter to only include savings or investment plans
    WHERE p.is_regular_savings = 1 OR p.is_a_fund = 1
    GROUP BY p.id, p.owner_id
)

-- Step 2: Query plans with no inflows in the last 365 days
SELECT 
    plan_id,
    owner_id,
    type,
    
	-- Format the last transaction date for clarity
    DATE_FORMAT(last_transaction_date, '%Y-%m-%d') AS last_transaction_date,
	
    -- Calculate number of days since last inflow (or 0 if never)
    DATEDIFF(CURRENT_DATE, COALESCE(last_transaction_date, CURRENT_DATE)) AS inactivity_days
FROM account_activity

-- Only return accounts with no inflows in the past 1 year (365+ days)
WHERE DATEDIFF(CURRENT_DATE, COALESCE(last_transaction_date, CURRENT_DATE)) >= 365
ORDER BY inactivity_days DESC;