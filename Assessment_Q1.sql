-- Create views for the tables in the database
#create view new_users_customer as select * from users_customuser;
#create view new_plans_plan as select * from plans_plan;
#create view new_savings_savingsaccount as select * from savings_savingsaccount;
#create view new_withdrawals_withdrawal as select * from withdrawals_withdrawal;

-- Update name column in new_users_customer with concatenation of first_name and last_name
#update new_users_customer set name = concat(first_name, ' ', last_name);


-- CTE 1: Select users who have at least one successful savings transaction
WITH savings_summary AS (
    SELECT 
        owner_id
    FROM new_savings_savingsaccount
    WHERE transaction_status = 'success'
    GROUP BY owner_id
),

-- CTE 2: Summarize each user's count of savings & investment plans, and total deposits
plan_summary AS (
    SELECT 
        owner_id,
         -- Count how many savings plans the user has
        SUM(CASE WHEN is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings_count,
        -- Count how many investment plans the user has
        SUM(CASE WHEN is_a_fund = 1 THEN 1 ELSE 0 END) AS investment_count,
        -- Sum all amounts under these plans (investment or savings)
        SUM(amount) AS total_deposits
    FROM new_plans_plan
    WHERE is_a_fund = 1 or is_regular_savings = 1
    GROUP BY owner_id
)

-- Final result: Join user table with the two summaries to get high-value cross-sell targets
SELECT 
    nuc.id AS owner_id,
    nuc.name,
    ps.savings_count,
    ps.investment_count,
    ps.total_deposits
FROM new_users_customer nuc

-- Join summarized plan data
JOIN plan_summary ps ON nuc.id = ps.owner_id

-- Ensure they also have successful savings activity
JOIN savings_summary ss ON nuc.id = ss.owner_id

-- Filter: user must have both savings and investment plans
WHERE ps.savings_count > 0 AND ps.investment_count > 0

-- Sort by how much they’ve deposited
ORDER BY ps.total_deposits DESC;
