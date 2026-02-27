WITH r1 AS (
  SELECT scenario, from_account, risk_band AS r1_band
  FROM fact_alerts
  WHERE rule_id='RULE_1_STRUCTURING'
),
r2 AS (
  SELECT scenario, from_account, risk_band AS r2_band
  FROM fact_alerts
  WHERE rule_id='RULE_2_VELOCITY'
)
SELECT
  r1.r1_band,
  r2.r2_band,
  COUNT(*) AS accounts
FROM r1
JOIN r2
  ON r1.scenario = r2.scenario
 AND r1.from_account = r2.from_account
GROUP BY 1,2
ORDER BY 1,2;
