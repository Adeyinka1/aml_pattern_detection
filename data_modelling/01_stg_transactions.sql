--`stg_transactions.sql
-- This view reads the processed parquet files and provides a staging area for transactions data.

CREATE OR REPLACE VIEW stg_transactions AS
SELECT
  scenario,
  time_stamp,
  from_bank,
  from_account,
  to_bank,
  to_account,
  is_laundering,
  payment_format,
  payment_currency,
  receiving_currency,
  amount_paid,
  amount_received
FROM read_parquet('data/processed/parquet/*_Trans.parquet');