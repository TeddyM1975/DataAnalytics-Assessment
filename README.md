# DataAnalytics-Assessment
Data Analyst Assessment for Cowrywise

# SQL Proficiency Assessment

## 1. High-Value Customers with Multiple Products

### 🧠 Problem Scenario

The business wants to identify **customers** who are actively using **both savings and investment products**. This helps target users with cross-selling opportunities.

---

### 📌 Task

Write a query to:

- Find customers who have at least **one funded savings plan** AND **one funded investment plan**
- Include their owner_id, name, count of savings and investment plans, and total deposits
- Only consider savings accounts with **successful transactions**
- Sort results by **total deposits (descending)**

---

### 🛠️ Methodology

#### 1. Data Segmentation via CTEs
Used Common Table Expressions (`WITH`) to separate logic for clarity:
- `savings_summary`: filters users with at least one successful transaction.
- `plan_summary`: aggregates each user's savings and investment plans, including total deposits.

#### 2. Conditional Aggregation
Applied `SUM(CASE WHEN ...)` to count the number of plan types (savings vs. investment) per user.

#### 3. Filtering for Qualified Users
After joining the user and summary tables:
- Only users with both a savings and investment plan were selected (`ps.savings_count > 0 AND ps.investment_count > 0`).

#### 4. Ordering by Business Value
Sorted the results by `total_deposits DESC` to prioritize users contributing the most financially.

---

### ✅ Output Example

| owner_id | name      | savings_count | investment_count | total_deposits |
|----------|-----------|----------------|-------------------|----------------|
| 1001     | John Doe  | 2              | 1                 | 15000.00       |

---

### 🗃️ Tables Used

- `new_users_customer`: customer demographic and contact information.
- `new_savings_savingsaccount`: Records of deposit transactions.
- `new_plans_plan`: Records of plans created by customers.

---

### ⚙️ Challenges Faced & Solutions

#### 1. Lost Connection to MySQL Server
- **Issue**: Query failed with *"Lost connection to MySQL server during query"* after 30 seconds.
- **Root Cause**: MySQL default timeout settings combined with data size (~106,000+ rows in `new_savings_savingsaccount`).
- **Solution**: Attempted to increase client timeout settings. Ultimately optimized the query by:
  - Reducing row operations before the final join using CTEs.
  - Filtering and aggregating earlier to reduce memory and time cost.

#### 2. Boolean Columns Misinterpreted
- **Issue**: `is_a_fund` and `is_regular_savings` returned integers (0/1), not booleans.
- **Solution**: Used `CASE WHEN column = 1 THEN 1 ELSE 0` to ensure clarity and correct aggregation in `SUM()`.

#### 3. Misleading Test Data
- **Issue**: Query showed no results due to test filters like `is_a_fund > 1`, which didn’t match the 0/1 data.
- **Solution**: Corrected the logic to `is_a_fund = 1` and validated with known `owner_id`s.

#### 4. Initial Join Logic Issues
- **Issue**: Earlier query versions joined all tables directly and miscounted savings vs. investment plans.
- **Solution**: Separated logic into CTEs for clarity and efficiency. This prevented data duplication and ensured accurate counts.

---

### 💡 Why This Approach?

- **CTEs** improve readability and separation of concerns.
- **Joins** ensure data completeness across related tables.
- **Business logic** is enforced cleanly: only users who meet both financial engagement criteria are returned.

---

### 🚀 Optimization Note

The query was built to handle performance efficiently, considering filters (`transaction_status = 'success'`) and grouping before final joins.

---

### 📈 Business Use Case

This result can feed directly into:
- Marketing automation tools for **cross-sell campaigns**
- CRM dashboards to highlight **top-tier clients**
- Strategic planning for **financial product bundling**

---

## 2. Transaction Frequency Analysis

### 🧠 Problem Scenario

The finance team wants to analyze how often customers transact to help segment them into tiers such as **frequent**, **moderate**, or **occasional** users.

---

### 📌 Task

Write a query to:

- Calculate the **average number of successful transactions per customer per month**.
- Categorize each customer as:
  - **High Frequency**: ≥10 transactions/month
  - **Medium Frequency**: 3–9 transactions/month
  - **Low Frequency**: ≤2 transactions/month
- Aggregate and return the **count of customers** and the **average monthly transactions** in each segment.

---

### 🛠️ Methodology

#### 1. Aggregation of Customer Transactions
- Used a CTE `customer_transactions` to **count total successful transactions** per customer from `new_savings_savingsaccount`.

#### 2. Monthly Normalization
- Created a second CTE `customer_frequency` to **normalize** total transactions over the available period (**105 months** from Aug 2016 to Apr 2025).
- Used `ROUND(CAST(total_transactions AS DECIMAL) / 105, 2)` to get the monthly average.

#### 3. Frequency Segmentation
- Used a CASE statement in the `categorized_customers` CTE to classify customers into:
  - `"High Frequency"`: `avg >= 10`
  - `"Medium Frequency"`: `avg >= 3 and < 10`
  - `"Low Frequency"`: `< 3`

#### 4. Final Aggregation
- Counted how many customers fell into each category.
- Calculated the **average of their monthly averages** per category using `AVG(avg_transactions_per_month)`.

---

### ✅ Output Example

| frequency_category | customer_count | avg_transactions_per_month |
|--------------------|----------------|-----------------------------|
| High Frequency     | 250            | 15.2                        |
| Medium Frequency   | 1200           | 5.5                         |
| Low Frequency      | 730            | 1.1                         |

---

### 🗃️ Tables Used

- `users_customuser`:  Customer demographic and contact information.
- `new_savings_savingsaccount`:  Records of deposit transactions.

---

### ⚙️ Challenges Faced & Solutions

#### 1. Time Range Spanning Multiple Years
- **Issue**: Some customers had inconsistent activity across years; others had **zero transactions** for certain years.
- **Solution**: Normalized all customers over a **fixed 105-month window** to ensure fair comparison regardless of when they joined or transacted.

#### 2. Name-Based Duplicates
- **Issue**: Same names appeared multiple times with different transaction counts.
- **Solution**: Switched to using `id` instead of `name` as the primary identifier for accuracy.

#### 3. Missing Customer Records
- **Issue**: Some customers didn’t appear due to no transactions.
- **Solution**: Used a **LEFT JOIN** from `users_customuser` to ensure inclusion of all customers even if they had 0 transactions.

#### 4. Misleading Assumptions About Monthly Averages
- **Issue**: Initially considered per-year breakdowns, which could overinflate or underrepresent activity.
- **Solution**: Used a **uniform 105-month period** as the denominator to ensure consistent classification.

---

### 💡 Why This Approach?

- Ensures **consistent segmentation** by calculating average across entire dataset lifespan (Aug 2016 – Apr 2025).
- Avoids bias from missing years by treating no-transaction periods as part of the customer’s activity timeline.
- Uses clear classification logic that can easily plug into dashboards or customer profiles.

---

### 🚀 Optimization Note

- CTEs allow layered logic and clear debugging.
- Aggregation is done in steps to reduce intermediate complexity.
- Can scale easily if data range or thresholds change in the future.

---

### 📈 Business Use Case

Results from this query can inform:
- Customer segmentation for **tiered service plans**
- Frequency-based rewards or loyalty programs
- Early detection of **inactive or churning customers**

---

## 3. Inactive Accounts with No Inflows for over 1 Year

### 🧠 Problem Scenario

The operations team wants to **identify accounts that have not received any inflow transactions over the past year(365 days)**.

---

### 📌 Task

Write a query to:

- Find all accounts that are either **Savings** or **Investment**
- Only consider **inflow transactions** (i.e., `confirmed_amount > 0`)
- Return:
  - `plan_id`
  - `owner_id`
  - Account `type` ("Savings" or "Investment")
  - `last_transaction_date`
  - Number of `inactivity_days`
- Exclude accounts that **have had inflow transactions in the past 365 days**
- Sort results by `inactivity_days` in descending order

---

### 🛠️ Methodology

#### 1. Account Classification
Used conditional logic on boolean columns:
- `is_regular_savings = 1` → **Savings**
- `is_a_fund = 1` → **Investment**

#### 2. Filtering Inflow Transactions
- Joined with the `new_savings_savingsaccount` table
- Included only transactions with `confirmed_amount > 0` to capture **actual inflows**

#### 3. CTE for Activity Summary
Used a Common Table Expression (`WITH`) to:
- Summarize `MAX(transaction_date)` as the most recent inflow per account
- Assign account type
- Group by account ID and owner

#### 4. Inactivity Calculation
- Used `DATEDIFF(CURRENT_DATE, COALESCE(last_transaction_date, CURRENT_DATE))` to calculate days of inactivity
- Accounts with no inflow in **over a year (365 days)** were selected

---

### ✅ Output Example

| plan_id | owner_id | type       | last_transaction_date | inactivity_days |
|---------|----------|------------|------------------------|-----------------|
| 1001    | 305      | Savings    | 2023-08-10             | 370             |
| 1023    | 578      | Investment | 2022-12-25             | 510             |

---

### 🗃️ Tables Used

- `new_plans_plan`: Records of plans created by customers.
- `new_savings_savingsaccount`: Records of deposit transactions.

---

### ⚙️ Challenges Faced & Solutions

#### 1. Function Compatibility
- **Issue**: Tried using `DATE_PART()` which is not supported in MySQL.
- **Solution**: Replaced with `DATEDIFF()` for MySQL compatibility.

#### 2. Ambiguity in Task
- **Issue**: The scenario specified "no inflow", but the task said "no transactions".
- **Solution**: Interpreted based on scenario and filtered only on `confirmed_amount > 0` to focus on inflows.

#### 3. Missing `is_active` Field
- **Issue**: The `is_active` column was in a different table not listed (`new_users_customer`).
- **Solution**: Ignored that constraint since the task restricts us to only the two listed tables.

---

### 💡 Why This Approach?

- **CTE** helps structure logic in layers and improve readability.
- **Conditional classification** ensures correct labeling of accounts.
- **Filtering on inflow** aligns with business requirements to identify dormant value-generating accounts.

---

### 🚀 Optimization Note

The query avoids heavy joins and works efficiently by:
- Filtering and aggregating within the CTE before final selection
- Using `LEFT JOIN` to retain accounts even if they have no transactions

---

### 📈 Business Use Case

This result can be used to:
- Trigger **reactivation campaigns** via SMS, email, or calls
- Understand **customer churn risk**
- Feed into user segmentation for **incentive-based re-engagement**


...

## 4. Customer Lifetime Value (CLV) Estimation

### 🧠 Problem Scenario

The marketing team wants to estimate **Customer Lifetime Value (CLV)** for each customer. The business goal is to understand how valuable each customer is based on how long they've been with the company and their transaction activity.

This simplified CLV model helps prioritize high-value users and inform retention strategies.

---

### 📌 Task

Write a query to:

- Calculate each customer's `account_tenure` in months since signup
- Count the `total_transactions` the customer has made
- Estimate `CLV` using the formula:
$$\text{CLV} = \left( \frac{\text{Total Transactions}}{\text{Tenure Months}} \right) \times 12 \times \text{Avg. Profit per Transaction}$$

  Where:
  - `profit_per_transaction = 0.1% of transaction value`
- Sort the result by `estimated_clv` in descending order

Return the following columns:
- `customer_id`
- `name`
- `tenure_months`
- `total_transactions`
- `estimated_clv`

---

### 🛠️ Methodology

#### 1. Join Customer and Transaction Tables
- Joined `new_users_customer` and `new_savings_savingsaccount` on `owner_id` to get transactions for each user.

#### 2. Calculate Account Tenure
- Used `TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE)` to get the number of months each customer has had an account.

#### 3. Count Transactions
- Used `COUNT(s.id)` to count total transactions per customer.

#### 4. Estimate CLV
- Applied the formula:
  - Monthly transaction rate: `(total_transactions / tenure)`
  - Profit per transaction: `AVG(s.confirmed_amount) * 0.001`
  - Annualize: Multiply by 12
  - Rounded to 2 decimal places using `ROUND(...)`

---

### ✅ Output Example

| customer_id | name      | tenure_months | total_transactions | estimated_clv |
|-------------|-----------|----------------|---------------------|----------------|
| 1001        | John Doe  | 24             | 120                 | 600.00         |

---

### 🗃️ Tables Used

- `new_users_customer`: customer demographic and contact information.
- `new_savings_savingsaccount`: records of deposit transactions.

---

### ⚙️ Challenges Faced & Solutions

#### 1. SQL Function Misuse
- **Issue**: Used `DATEDIFF(MONTH, ...)`, which is invalid in MySQL.
- **Solution**: Replaced with `TIMESTAMPDIFF(MONTH, ...)` for compatibility.

#### 2. Aggregation Accuracy
- **Issue**: `AVG(confirmed_amount)` must be grouped correctly to avoid skewed results.
- **Solution**: Ensured aggregation was done per customer before computing `CLV`.

---

### 💡 Why This Approach?

- **Direct calculation** allows a simplified CLV model without external tools.
- **MySQL-native functions** like `TIMESTAMPDIFF` ensure compatibility.
- **Aggregation with GROUP BY** provides concise and scalable metrics.

---

### 🚀 Optimization Note

- **Indexes** on `owner_id` and `date_joined` can significantly improve join and filter performance.
- Filtering out extremely short tenure (<1 month) might give more reliable CLV values.

---

### 📈 Business Use Case

This CLV estimate helps the business:
- **Identify high-value customers** for loyalty campaigns
- **Segment users** for personalized marketing
- **Forecast revenue** based on customer cohorts

---

# ✅ Final Note
This solution was developed as part of a Data Analyst assessment for Cowrywise. It demonstrates my ability to interpret business scenarios, translate them into structured SQL queries, and communicate insights clearly using data-driven logic. All queries were written with performance, readability, and business alignment in mind.
> Thank you for the opportunity to showcase my analytical skills.
