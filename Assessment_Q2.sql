WITH all_transactions AS (
    -- Step 1: Combine deposits and withdrawals into one set of successful transactions
    SELECT 
        s.owner_id,
        s.transaction_date
    FROM savings_savingsaccount s
    JOIN users_customuser u ON u.id = s.owner_id
    WHERE s.transaction_status IN ('success', 'successful', 'monnify_success')
      AND u.date_joined <= s.transaction_date

    UNION ALL

    SELECT 
        w.owner_id,
        w.transaction_date
    FROM withdrawals_withdrawal w
    JOIN users_customuser u ON u.id = w.owner_id
    WHERE u.date_joined <= w.transaction_date
),

monthly_txn_counts AS (
    -- Step 2: Count transactions per user per month
    SELECT
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m-01') AS txn_month,
        COUNT(*) AS txn_count
    FROM all_transactions
    GROUP BY owner_id, DATE_FORMAT(transaction_date, '%Y-%m-01')
),

avg_txn_per_month AS (
    -- Step 3: Calculate average monthly transaction count per user
    SELECT
        owner_id,
        AVG(txn_count) AS avg_txn_count_per_month
    FROM monthly_txn_counts
    GROUP BY owner_id
),

categorized_customers AS (
    -- Step 4: Assign frequency category
    SELECT
        owner_id,
        avg_txn_count_per_month,
        CASE 
            WHEN avg_txn_count_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_count_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM avg_txn_per_month
),

final_output AS (
    -- Step 5: Count customers per frequency group and calculate their average transaction/month
    SELECT
        frequency_category,
        COUNT(owner_id) AS customer_count,
        ROUND(AVG(avg_txn_count_per_month), 2) AS avg_transaction_per_month
    FROM categorized_customers
    GROUP BY frequency_category
)

-- Final result
SELECT *
FROM final_output
ORDER BY 
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        ELSE 3
    END;
