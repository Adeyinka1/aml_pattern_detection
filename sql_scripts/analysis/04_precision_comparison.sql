-- Precision-style checks using available labels in fact_alerts
-- NOTE: This is synthetic dataset labeling, used for evaluation only.

SELECT
  rule_id,
  risk_band,
  COUNT(*) AS alerts,
  SUM(CASE WHEN label_has_laundering=1 THEN 1 ELSE 0 END) AS laundering_alerts,
  ROUND(SUM(CASE WHEN label_has_laundering=1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 6) AS precision
FROM fact_alerts
GROUP BY 1,2
ORDER BY 1,2;