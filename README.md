# Data Analytics Assessment

This repository contains a concise explanation of the approach taken to answer each question.

---

## Question 1 – Identifying Financially Engaged Customers

**Objective:**
Generate a refined list of customers with both savings and investment plans, backed by confirmed deposits.

**Approach:**

* Queried the `plans_plan` table to group and count savings (`is_regular_savings`) and investment (`is_a_fund`) plans by `owner_id`.
* Filtered to include only users with **at least one of each type**.
* Queried the `savings_savingsaccount` table to sum confirmed deposits by user (`owner_id`), considering only successful transactions (`success`, `successful`, `monnify_success`).
* Joined plan and deposit data to confirm each customer had **funded** at least one savings and one investment plan.
* Merged with `users_customuser` for customer names and formatted the output.
* Sorted results by total deposit in descending order.

---

## Question 2 – Transaction Frequency Categorization

**Objective:**
Calculate average monthly transaction frequency per customer and group them into frequency bands.

**Approach:**

* Combined deposit and withdrawal transactions from `savings_savingsaccount` and `withdrawals_withdrawal` into a unified dataset via a CTE.
* Included only successful transactions and ensured they occurred after the user’s `date_joined`.
* Grouped transactions by customer and month to compute monthly counts.
* Calculated average monthly transactions per user.
* Categorized users into **High** (≥10), **Medium** (3–9), and **Low** (≤2) frequency groups.
* Aggregated the number of users and average frequency per group in the final output.

---

## Question 3 – Identifying Inactive Financial Plans

**Objective:**
Identify user-created financial plans with no successful deposits in over 365 days.

**Approach:**

* Queried `plans_plan` to classify valid savings or investment plans.
* Joined with `savings_savingsaccount` to find successful transactions using valid statuses and `confirmed_amount > 0`.
* Calculated days since the last successful transaction using `DATEDIFF`.
* Filtered plans with **no transaction in over 365 days**.
* Excluded deleted (`is_deleted = 1`) and archived (`is_archived = 1`) plans.
* Sorted by inactivity duration in descending order.

---

## Question 4 – Customer Lifetime Value (CLV)

**Objective:**
Calculate each customer’s CLV using transaction history and account tenure.

**Approach:**

* Extracted customer profile and tenure (in months) from `users_customuser` using `date_joined`.
* Aggregated deposit and withdrawal amounts per user, applying a 0.1% profit rate.
* Calculated total transaction count and profit per customer.
* Applied the formula:
  `CLV = (transaction count / tenure) × 12 × avg. profit per transaction`
* Handled edge cases (e.g., zero tenure) to avoid division errors.
* Displayed results with CLV formatted to two decimal places and sorted by value.

---

## Challenges Faced

* **Identifying successful transactions:**
  There were multiple values for transaction status. I resolved this by including all descriptions that indicated success: `'success'`, `'successful'`, and `'monnify_success'`.

* **Withdrawal status inconsistency:**
  The `withdrawals_withdrawal` table lacked a transaction status column but had a status ID instead. I assumed all recorded withdrawals were successful for consistency.

* **Determining active plans:**
  It was unclear which plans should be treated as active. I excluded any plan marked as deleted (`is_deleted = 1`) or archived (`is_archived = 1`), and ensured at least one successful transaction existed for the plan.

---

