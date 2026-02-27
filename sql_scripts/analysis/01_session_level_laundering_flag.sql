--  08a_session_level_laundering_flag.sql
-- This script joins the sessionized transactions with the labeled transactions to assign a laundering flag at the session level. 
-- Each session will be labeled as laundering if any transaction within that session is labeled as laundering.
CREATE OR REPLACE TABLE r2_sessionized_labeled AS
SELECT
  s.scenario,
  s.from_account,
  s.session_id,
  s.time_stamp,
  s.to_account,
  t.is_laundering
FROM r2_sessionized s
JOIN clean_fact_transactions_sample t
  ON  t.scenario     = s.scenario
  AND t.from_account = s.from_account
  AND t.to_account   = s.to_account
  AND t.time_stamp   = s.time_stamp;