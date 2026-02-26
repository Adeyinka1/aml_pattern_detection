-- 05_creat_lean_table.sql
-- This script creates a lean version of the transactions table, containing only the essential columns needed for analysis. 
-- This helps to optimize storage and query performance while retaining the necessary information for analysis.
PRAGMA threads=6;
PRAGMA memory_limit='12GB';
PRAGMA enable_progress_bar=true;

-- The r2_events table is a lean version of the transactions data, containing only the scenario, from_account, to_account, and time_stamp columns.
-- This helps to Removes unused numeric/currency columns, Reduces memory during partition operations and Improves sort efficiency
CREATE OR REPLACE TABLE r2_events AS
SELECT
  scenario,
  from_account,
  to_account,
  time_stamp
FROM clean_fact_transactions_sample
WHERE time_stamp IS NOT NULL;