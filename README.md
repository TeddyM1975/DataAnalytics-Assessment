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

## 3. [Next Problem Placeholder]
...

## 4. [Final Problem Placeholder]
...


