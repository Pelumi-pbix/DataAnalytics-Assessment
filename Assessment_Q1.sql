-- First, summarize all plans by owner: sum of savings (is_regular_savings) and investment (is_a_fund)
WITH PlanSummary AS (
    SELECT
        owner_id,
        SUM(is_regular_savings) AS savings_count,   -- Total savings plans
        SUM(is_a_fund) AS investment_count        -- Total investment plans
    FROM plans_plan
    GROUP BY owner_id
    HAVING SUM(is_regular_savings) >= 1             -- Only include owners with at least one savings plan
       AND SUM(is_a_fund) >= 1               -- And at least one investment plan
),

-- Next, calculate total confirmed deposits per owner where the transaction was successful
DepositSummary AS (
    SELECT
        s.owner_id,
        SUM(s.confirmed_amount) AS total_deposit
    FROM savings_savingsaccount s
    WHERE s.transaction_status IN ('success', 'successful', 'monnify_success')
    GROUP BY s.owner_id
),

-- Check that each owner has at least one funded savings plan (i.e., transaction linked to a plan with quantity > 0)
FundedSavingsOwners AS (
    SELECT DISTINCT ss.owner_id
    FROM savings_savingsaccount ss
    INNER JOIN plans_plan ps ON ss.plan_id = ps.id
    WHERE ss.transaction_status IN ('success', 'successful', 'monnify_success')
      AND ps.is_regular_savings > 0
),

-- Check that each owner has at least one funded investment plan (i.e., transaction linked to a plan with amount > 0)
FundedInvestmentOwners AS (
    SELECT DISTINCT ti.owner_id
    FROM savings_savingsaccount ti
    INNER JOIN plans_plan pi ON ti.plan_id = pi.id
    WHERE ti.transaction_status IN ('success', 'successful', 'monnify_success')
      AND pi.is_a_fund > 0
)

-- Final result: join all filtered data sources together
SELECT
    o.id AS owner_id,                                       -- Owner ID
    CONCAT(o.first_name, ' ', o.last_name) AS name,         -- Full name of owner
    ps.savings_count,                     -- Total savings count (quantity)
    ps.investment_count,                    -- Total investment count (amount)
	ROUND(ds.total_deposit, 2) AS total_deposit        -- Total confirmed deposits
FROM PlanSummary ps
JOIN DepositSummary ds ON ps.owner_id = ds.owner_id  -- Only include owners with confirmed deposits
JOIN FundedSavingsOwners fso ON ps.owner_id = fso.owner_id  -- Only owners with funded savings plan
JOIN FundedInvestmentOwners fio ON ps.owner_id = fio.owner_id  -- Only owners with funded investment plan
JOIN users_customuser o ON o.id = ps.owner_id                  -- Join to Owners table to get full name
ORDER BY total_deposit DESC;  -- Sort by deposit in descending order