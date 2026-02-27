-- 08b_alert_cases_velocity_sessions_eval.sql
-- This script evaluates the sessions identified in r2_sessionized_labeled to compute various metrics such as session duration, transaction count, distinct recipients, and laundering flags at the session level.

CREATE OR REPLACE TABLE alert_cases_velocity_sessions_eval AS
SELECT
  scenario,
  from_account,
  session_id,
  MIN(time_stamp) AS session_start,
  MAX(time_stamp) AS session_end,
  (MAX(epoch(time_stamp)) - MIN(epoch(time_stamp))) / 60.0 AS duration_mins,
  COUNT(*) AS txn_count,
  COUNT(DISTINCT to_account) AS distinct_recipients,
  MAX(CASE WHEN is_laundering=1 THEN 1 ELSE 0 END) AS session_has_laundering,
  SUM(CASE WHEN is_laundering=1 THEN 1 ELSE 0 END) AS laundering_txn_count
FROM r2_sessionized_labeled
GROUP BY 1,2,3;