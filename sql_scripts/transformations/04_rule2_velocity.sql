-- create_lean_table.sql
-- This script creates a lean version of the transactions table, containing only the essential columns needed for analysis. 
-- This helps to optimize storage and query performance while retaining the necessary information for analysis.
PRAGMA threads=6;
PRAGMA memory_limit='12GB';
PRAGMA enable_progress_bar=true;

-- The r2_events table is a lean version of the transactions data, containing only the scenario, from_account, to_account, and time_stamp columns.
-- This helps to Removes unused numeric/currency columns, Reduces memory during partition operations and Improves sort efficiency
CREATE OR REPLACE TABLE r2_events AS
SELECT
  scenario,
  from_account,
  to_account,
  time_stamp
FROM clean_fact_transactions_sample
WHERE time_stamp IS NOT NULL;


-- This script implements the 30 minutes gap rule to identify sessions of transactions.
-- A new session is started if there is a gap of more than 30 minutes between transactions for the same scenario and from_account.
CREATE OR REPLACE TABLE r2_sessionized AS
WITH base AS (
  SELECT
    scenario,
    from_account,
    to_account,
    time_stamp,
    lag(time_stamp) OVER (
      PARTITION BY scenario, from_account
      ORDER BY time_stamp
    ) AS prev_ts
  FROM r2_events
),
flags AS (
  SELECT
    *,
    CASE
      WHEN prev_ts IS NULL THEN 1
      WHEN (epoch(time_stamp) - epoch(prev_ts)) > (30 * 60) THEN 1
      ELSE 0
    END AS is_new_session
  FROM base
),
sessions AS (
  SELECT
    *,
    SUM(is_new_session) OVER (
      PARTITION BY scenario, from_account
      ORDER BY time_stamp
      ROWS UNBOUNDED PRECEDING
    ) AS session_id
  FROM flags
)
SELECT
  scenario,
  from_account,
  session_id,
  time_stamp,
  to_account
FROM sessions;


-- This script identifies alert cases based on velocity burst thresholds.
-- It groups transactions into sessions based on the scenario and from_account, and calculates the session duration
CREATE OR REPLACE TABLE alert_cases_velocity_sessions AS
SELECT
  scenario,
  from_account,
  session_id,
  MIN(time_stamp) AS session_start,
  MAX(time_stamp) AS session_end,
  (MAX(epoch(time_stamp)) - MIN(epoch(time_stamp))) / 60.0 AS duration_mins,
  COUNT(*) AS txn_count,
  COUNT(DISTINCT to_account) AS distinct_recipients
FROM r2_sessionized
GROUP BY 1,2,3
HAVING
  (MAX(epoch(time_stamp)) - MIN(epoch(time_stamp))) <= (60 * 60)
  AND COUNT(*) >= 8
  AND COUNT(DISTINCT to_account) >= 3;


  -- This script assigns a risk band (HIGH, MEDIUM, LOW) to each session based on the evaluated metrics such as transaction count, distinct recipients, and session duration. 
-- It also computes a velocity score for each session to provide an explainable severity score.

CREATE OR REPLACE TABLE alert_cases_velocity_banded AS
SELECT
  *,
  -- simple severity score (explainable, monotonic)
  (txn_count * 1.0)
  + (distinct_recipients * 2.0)
  + (CASE WHEN duration_mins <= 15 THEN 8
          WHEN duration_mins <= 30 THEN 5
          ELSE 2 END) AS velocity_score,

  CASE
    WHEN txn_count >= 15 AND distinct_recipients >= 6 AND duration_mins <= 30 THEN 'HIGH'
    WHEN txn_count >= 10 AND distinct_recipients >= 4 AND duration_mins <= 60 THEN 'MEDIUM'
    ELSE 'LOW'
  END AS risk_band,

  'RULE_2_VELOCITY' AS rule_id
FROM alert_cases_velocity_sessions_final;