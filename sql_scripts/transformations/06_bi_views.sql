-- This SQL script creates several views in the BI schema to facilitate analysis and reporting on the alerts data. These views aggregate and filter the data from the fact_alerts table to provide insights into alert counts, cases, behavioral metrics, and precision of the rules.
CREATE OR REPLACE VIEW bi_alert_summary AS
SELECT
  rule_id,
  scenario,
  risk_band,
  COUNT(*) AS alert_count
FROM fact_alerts
GROUP BY 1,2,3;

-- This view provides a summary of alert cases by rule_id, scenario, and risk_band, which can be used for high-level analysis and reporting.
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

-- This view filters the alert cases to include only those with HIGH and MEDIUM risk bands for dashboard purposes, and also casts the alert_start to a date for easier aggregation.
CREATE OR REPLACE VIEW bi_alert_cases_dashboard_v2 AS
SELECT
  rule_id,
  scenario,
  from_account,
  session_id,
  STRFTIME(alert_start, '%d-%m-%Y') AS alert_date,
  txn_count,
  distinct_recipients,
  risk_score,
  risk_band,
  label_has_laundering,
  label_laundering_txns
FROM fact_alerts
WHERE risk_band IN ('HIGH', 'MEDIUM');

-- This view creates an investigation queue by calculating the age of the alerts and categorizing them into priority buckets based on their risk band and risk score. It also includes a cross join to get the maximum alert date for calculating the age of the alerts.
CREATE OR REPLACE VIEW bi_investigation_queue AS
WITH max_date AS (
  SELECT MAX(CAST(alert_start AS DATE)) AS max_alert_date
  FROM fact_alerts
)
SELECT
  f.from_account,
  f.rule_id,
  f.scenario,
  f.risk_band,
  f.risk_score,
  f.alert_start,
  DATE_DIFF('day', CAST(f.alert_start AS DATE), m.max_alert_date) AS alert_age_days,
  CASE
    WHEN f.risk_band = 'HIGH' AND f.risk_score >= 200 THEN 'Urgent'
    WHEN f.risk_band = 'HIGH' THEN 'High Priority'
    WHEN f.risk_band = 'MEDIUM' THEN 'Review'
    ELSE 'Monitor'
  END AS priority_bucket
FROM fact_alerts f
CROSS JOIN max_date m
WHERE f.risk_band IN ('HIGH', 'MEDIUM');

-- This view identifies suspicious networks by aggregating the transactions between accounts that have triggered HIGH risk alerts, counting the number of transactions, summing the total amount paid, and taking the maximum risk score for each from_account and to_account pair.
CREATE OR REPLACE VIEW bi_suspicious_network AS
SELECT
    t.from_account,
    t.to_account,
    t.scenario,
    COUNT(*) AS txn_count,
    SUM(t.amount_paid) AS total_amount,
    MAX(a.risk_score) AS max_risk_score
FROM clean_fact_transactions_sample t
JOIN fact_alerts a
ON t.from_account = a.from_account
WHERE a.risk_band = 'HIGH'
GROUP BY
    t.from_account,
    t.to_account,
    t.scenario;

-- This view provides a summary of suspicious networks by from_account, counting the distinct recipients, total edges in the network, total amount sent, and maximum risk score. This can be used to identify accounts that are involved in multiple suspicious transactions and may require further investigation.
CREATE OR REPLACE VIEW bi_suspicious_network_summary AS
SELECT
    from_account,
    COUNT(DISTINCT to_account) AS distinct_recipients,
    COUNT(*) AS network_edges,
    SUM(total_amount) AS total_amount_sent,
    MAX(max_risk_score) AS max_risk_score
FROM bi_suspicious_network
GROUP BY from_account;


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