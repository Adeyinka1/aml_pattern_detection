-- 10_unified_alert_layer.sql
-- This script creates a unified alert layer by combining the evaluated velocity sessions with their assigned risk bands. 
-- It prepares the final alert data structure that can be used for downstream consumption, such as reporting or integration with alert management systems.

CREATE OR REPLACE TABLE fact_alerts_velocity AS
SELECT
  rule_id,
  scenario,
  from_account,
  NULL::VARCHAR AS to_account,           -- session-level alert
  session_id,
  session_start,
  session_end,
  duration_mins,
  txn_count,
  distinct_recipients,
  velocity_score AS risk_score,
  risk_band,
  session_has_laundering,
  laundering_txn_count
FROM alert_cases_velocity_banded;