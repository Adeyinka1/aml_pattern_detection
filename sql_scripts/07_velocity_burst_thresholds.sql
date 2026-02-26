-- 07_velocity_burst_thresholds.sql
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