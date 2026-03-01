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

-- This view aggregates behavioral metrics by rule_id and risk_band for dashboard visualizations.
CREATE OR REPLACE VIEW bi_behavioral_metrics AS
SELECT
  rule_id,
  risk_band,
  AVG(txn_count) AS avg_txns,
  AVG(distinct_recipients) AS avg_recipients,
  AVG(risk_score) AS avg_score
FROM fact_alerts
GROUP BY 1,2;

-- This view calculates the precision of the alerts by rule_id and risk_band, which can be used to evaluate the performance of the rules.
CREATE OR REPLACE VIEW bi_precision_summary AS
SELECT
  rule_id,
  risk_band,
  COUNT(*) AS alerts,
  SUM(CASE WHEN label_has_laundering=1 THEN 1 ELSE 0 END) AS laundering_alerts,
  ROUND(
    SUM(CASE WHEN label_has_laundering=1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*),
    6
  ) AS precision
FROM fact_alerts
GROUP BY 1,2;