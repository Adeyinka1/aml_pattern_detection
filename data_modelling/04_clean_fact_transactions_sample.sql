-- 04_clean_fact_transactions_sample.sql
-- This script creates a cleaned fact table for transactions, filtered to include only those transactions that involve accounts present in the sampled_accounts table. 
-- This allows for focused analysis on a subset of transactions while maintaining the integrity of the data for analysis.

CREATE OR REPLACE TABLE clean_fact_transactions_sample AS
SELECT
  t.scenario,
  t.time_stamp,
  t.from_bank,
  t.to_bank,
  t.from_account,
  t.to_account,
  t.amount_paid,
  t.amount_received,
  t.payment_currency,
  t.receiving_currency,
  t.payment_format,
  t.is_laundering
FROM stg_transactions t
JOIN sampled_accounts s
  ON t.scenario = s.scenario
 AND t.from_account = s.from_account;
