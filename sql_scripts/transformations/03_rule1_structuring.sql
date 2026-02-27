-- daily aggregation of outgoing transactions for each account
-- This SQL script creates a new table `r1_daily_outgoing` that aggregates transaction data on a daily basis for each account. It includes the total number of transactions, the number of distinct recipients, the total amount paid, the average amount paid, and whether any of the transactions were flagged as laundering.
CREATE OR REPLACE TABLE r1_daily_outgoing AS
SELECT
  scenario,
  from_account,
  CAST(time_stamp AS DATE) AS txn_date,
  COUNT(*) AS txn_count,
  COUNT(DISTINCT to_account) AS distinct_recipients,
  SUM(amount_paid) AS total_amount_paid,
  AVG(amount_paid) AS avg_amount_paid,
  MAX(is_laundering) AS any_laundering_txn
FROM clean_fact_transactions_sample
GROUP BY 1,2,3;


-- Percentile thresholds per scenario per day
-- structuring rule application, this uses percentile thresholds to assign risk bands based on the daily transaction count and total amount paid for each account. The resulting table `alert_cases_structuring_daily` includes the assigned risk band and a calculated risk score for each account on a daily basis.
CREATE OR REPLACE TABLE alert_cases_structuring_daily AS
WITH thresholds AS (
  SELECT
    scenario,
    txn_date,
    quantile_cont(txn_count, 0.99) AS p99_txn_count,
    quantile_cont(txn_count, 0.95) AS p95_txn_count,
    quantile_cont(total_amount_paid, 0.99) AS p99_total_amount,
    quantile_cont(total_amount_paid, 0.95) AS p95_total_amount
  FROM r1_daily_outgoing
  GROUP BY 1,2
),
scored AS (
  SELECT
    d.*,
    t.p99_txn_count, t.p95_txn_count,
    t.p99_total_amount, t.p95_total_amount
  FROM r1_daily_outgoing d
  JOIN thresholds t
    ON d.scenario = t.scenario
   AND d.txn_date = t.txn_date
)
SELECT
  'RULE_1_STRUCTURING' AS rule_id,
  scenario,
  from_account,
  txn_date AS alert_date,
  txn_count,
  distinct_recipients,
  total_amount_paid,
  avg_amount_paid,
  any_laundering_txn,
  CASE
    WHEN txn_count >= p99_txn_count AND total_amount_paid >= p99_total_amount THEN 'HIGH'
    WHEN txn_count >= p95_txn_count AND total_amount_paid >= p95_total_amount THEN 'MEDIUM'
    ELSE 'LOW'
  END AS risk_band,
  -- simple explainable score
  (txn_count * 1.0) + (LN(1 + total_amount_paid)) AS risk_score
FROM scored;


-- summary of alerts by risk band
SELECT risk_band, COUNT(*) n
FROM alert_cases_structuring_daily
GROUP BY 1
ORDER BY 1;