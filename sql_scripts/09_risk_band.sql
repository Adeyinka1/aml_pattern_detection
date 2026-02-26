-- 09_risk_band.sql
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