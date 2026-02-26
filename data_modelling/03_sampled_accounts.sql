-- This SQL code creates a new table called "sampled_accounts" by selecting distinct "scenario" and "from_account" from the "stg_transactions" table. It then filters the accounts to include only those where the absolute value of the hash of "from_account" modulo 100 is less than 5, effectively sampling approximately 5% of the accounts.
-- the entire dataset is quite large, so we create a smaller sample of accounts to work with for testing and analysis purposes. This allows us to run queries and perform analyses more quickly while still maintaining a representative subset of the data.
-- The "sampled_accounts" table will contain a subset of accounts from the "stg_transactions" table, which can be used for further analysis or testing while reducing the size of the dataset.

CREATE OR REPLACE TABLE sampled_accounts AS
WITH accounts AS (
  SELECT DISTINCT scenario, from_account
  FROM stg_transactions
)
SELECT scenario, from_account
FROM accounts
WHERE (abs(hash(from_account)) % 100) < 5;