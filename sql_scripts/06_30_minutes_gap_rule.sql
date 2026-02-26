-- 06_30_minutes_gap_rule.sql
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