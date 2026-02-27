-- dataset originally comes as csv files, we convert them to parquet for better performance and easier handling in the next steps of the pipeline

-- All Accounts for dim are loaded as is, with an additional column to identify the scenario (LI_SMALL)
-- each scenario has its own parquet file, so we can easily read them separately if needed, or together by using a wildcard in the path
COPY (
  SELECT *, 'LI_SMALL' AS scenario
  FROM read_csv_auto('data/raw/LI-Small_accounts.csv')
)
TO 'data/processed/parquet/LI-Small_accounts.parquet'
(FORMAT PARQUET);

-- All Trans data for fact_trans are loaded as is, with an additional column to identify the scenario (LI_MEDIUM)
-- each scenario has its own parquet file, so we can easily read them separately if needed, or together by using a wildcard in the path
COPY (
  SELECT

    TimeStamp AS time_stamp,
    "From Bank" AS from_bank,
    "To Bank" AS to_bank,
    Account AS from_account,
    Account_1 AS to_account,
    "Amount Received" AS amount_received,
    "Receiving Currency" AS receiving_currency,
    "Amount Paid" AS amount_paid,
    "Payment Currency" AS payment_currency,
    "Payment Format" AS payment_format,
    "Is Laundering" AS is_laundering,
    'LI_MEDIUM' AS scenario,
    
  FROM read_csv_auto('data/raw/LI-Medium_Trans.csv')
)
TO 'data/processed/parquet/LI-Medium_Trans.parquet'
(FORMAT PARQUET);

-- we can check that the data was loaded correctly by reading the parquet files and counting the number of records for each scenario  
SELECT scenario, COUNT(*) n
FROM read_parquet('data/processed/parquet/*.parquet')
GROUP BY 1
ORDER BY 1;
