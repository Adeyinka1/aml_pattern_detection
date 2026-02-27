CREATE OR REPLACE VIEW bi_alert_summary AS
SELECT
  rule_id,
  scenario,
  risk_band,
  COUNT(*) AS alert_count
FROM fact_alerts
GROUP BY 1,2,3;

CREATE OR REPLACE VIEW bi_alert_cases AS
SELECT
  rule_id,
  scenario,
  from_account,
  session_id,
  alert_start,
  alert_end,
  risk_band,
  risk_score,
  txn_count,
  distinct_recipients
FROM fact_alerts;

-- This view filters the alert cases to include only those with HIGH and MEDIUM risk bands for dashboard purposes.
CREATE OR REPLACE VIEW bi_alert_cases_dashboard AS
SELECT *
FROM fact_alerts
WHERE risk_band IN ('HIGH', 'MEDIUM');