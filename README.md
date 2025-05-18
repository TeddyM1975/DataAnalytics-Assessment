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

## 2. [Next Problem Placeholder]
*(To be completed...)*

## 3. [Next Problem Placeholder]
...

## 4. [Final Problem Placeholder]
...


