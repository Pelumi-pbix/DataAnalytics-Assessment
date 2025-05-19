SELECT
  p.id AS plan_id,                                              -- Unique identifier for the plan
  p.owner_id,                                             -- Owner of the plan
  CASE
    WHEN p.is_regular_savings = 1 THEN 'Savings'                       -- Classify as Saving if saving flag is set
    WHEN p.is_a_fund = 1 THEN 'Investment'               -- Classify as Investment if investment flag is set
  END AS plan_type,
  MAX(s.transaction_date) AS last_transaction_date,       -- Get the most recent successful transaction date  
  DATEDIFF(CURRENT_DATE, MAX(s.transaction_date)) AS inactivity_days  -- Days since last successful transaction
FROM
  plans_plan p
JOIN
  savings_savingsaccount s ON p.id = s.plan_id                     -- Link plans to their transactions
WHERE
  -- Only include plans that are either Saving or Investment (not both or neither)
  ((p.is_regular_savings = 1 AND p.is_a_fund = 0) OR (p.is_regular_savings = 0 AND p.is_a_fund = 1))
  AND p.is_deleted = 0                                   -- Exclude deleted plans
  AND p.is_archived = 0                                  -- Exclude archived plans
  AND s.transaction_status IN ('success', 'successful', 'monnify_success')   -- Only count successful deposits
  AND s.confirmed_amount > 0                              -- Only count actual deposits (amount > 0)
GROUP BY
  p.id,
  p.owner_id,
  plan_type
HAVING
  DATEDIFF(CURRENT_DATE, MAX(s.transaction_date)) > 365   -- Filter for plans inactive > 365 days
ORDER BY
  inactivity_days DESC;                                  -- Sort from longest inactivity to shortest
