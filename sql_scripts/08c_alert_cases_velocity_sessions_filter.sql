-- 08c_alert_cases_velocity_sessions_filter.sql
-- This script filters the evaluated sessions in alert_cases_velocity_sessions_eval to identify potential alert cases.

CREATE OR REPLACE TABLE alert_cases_velocity_sessions_final AS
SELECT *
FROM alert_cases_velocity_sessions_eval
WHERE
  duration_mins <= 60
  AND txn_count >= 8
  AND distinct_recipients >= 3;


-- Summary statistics for the final alert cases
-- This query provides a summary of the total number of velocity sessions identified, how many of those sessions had laundering flags, and the total count of laundering transactions within those sessions.
  SELECT
  COUNT(*) AS total_velocity_sessions,
  SUM(session_has_laundering) AS laundering_positive_sessions,
  SUM(laundering_txn_count) AS laundering_txns_in_velocity_sessions
FROM alert_cases_velocity_sessions_final;