SELECT
  u.id AS customer_id,
  CONCAT(u.first_name, ' ', u.last_name) AS name,
  TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months,

  -- Total transaction count
  COALESCE(d.deposit_count, 0) + COALESCE(w.withdrawal_count, 0) AS total_transaction_count,

  -- CLV rounded to 2 decimal places
  ROUND(
    CASE 
      WHEN TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) > 0 THEN
        (
          (COALESCE(d.deposit_count, 0) + COALESCE(w.withdrawal_count, 0)) /
          TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE)
        ) * 12 *
        (
          CASE 
            WHEN (COALESCE(d.deposit_count, 0) + COALESCE(w.withdrawal_count, 0)) > 0 THEN
              (
                (COALESCE(d.total_deposit, 0) + COALESCE(w.total_withdrawal, 0)) * 0.001
              ) / (COALESCE(d.deposit_count, 0) + COALESCE(w.withdrawal_count, 0))
            ELSE 0
          END
        )
      ELSE 0
    END,
    2
  ) AS CLV

FROM users_customuser u

-- Deposit summary
LEFT JOIN (
  SELECT 
    owner_id,
    COUNT(*) AS deposit_count,
    SUM(COALESCE(confirmed_amount, 0)) AS total_deposit
  FROM savings_savingsaccount
  WHERE transaction_status = 'success'
  GROUP BY owner_id
) AS d ON u.id = d.owner_id

-- Withdrawal summary
LEFT JOIN (
  SELECT 
    owner_id,
    COUNT(*) AS withdrawal_count,
    SUM(COALESCE(amount_withdrawn, 0)) AS total_withdrawal
  FROM withdrawals_withdrawal
  GROUP BY owner_id
) AS w ON u.id = w.owner_id

-- Order by CLV descending
ORDER BY CLV DESC;

