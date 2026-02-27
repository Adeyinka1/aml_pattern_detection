## AML Monitoring System – Data Engineering & Sampling Layer

## 1. Project Context
This AML monitoring system is built using the IBM “Transactions for Anti Money Laundering (AML)” dataset (~430M transactions).

The system is designed to:
Detect structuring behavior (Rule 1)
Detect velocity burst sessions (Rule 2)
Produce explainable compliance alerts
Power a drilldown-ready Power BI dashboard

Due to dataset scale and local RAM constraints, a scalable and memory-safe architecture was implemented.

## 2. Raw Dataset Structure
The dataset consists of two logical entities:

2.1 Transaction Files (*_Trans.parquet)

Columns:
scenario
time_stamp
from_bank
from_account
to_bank
to_account
is_laundering
payment_format
payment_currency
receiving_currency
amount_paid
amount_received

2.2 Account Files (*_accounts.parquet)

Columns:
Bank Name
Bank ID
Account Number
Entity ID
Entity Name
Scenario

Transactions and accounts are stored separately to avoid schema collision during glob reads.

3. Staging Layer - ref sql/01_stg_transactions.sql

3.1 Transactions Staging View,
A stagging view was created to:
Reads all transaction parquet files
Avoids schema mismatches and
Creates a clean logical base layer 

3.2 Accounts Staging View - ref sql/02_stg_accounts.sql
This view was created for Column renaming to remove spaces for downstream joins.


## 4. Memory-Safe Sampling Strategy

Why Sampling Was Required
Processing 430M rows for window-based sessionisation caused out-of-memory errors.
Instead of random row sampling (which destroys transaction continuity), a stratified account-level sampling strategy was implemented.

This ensures:
Full transaction history per sampled account
Investigator drill-down realism
Statistical stability
Reduced computational load

## 4.1 Account-Level Stratified Sampling (5%) - ref sql/03_sampled_accounts.sql
This:
Samples ~5% of accounts per scenario
Uses hash-based deterministic sampling
Ensures reproducibility

## 4.2 Sampled Transaction Fact Table - ref sql/04_clean_fact_transactions_sample.sql
Result:
~20,633,261 sampled transactions
Suitable for velocity detection

## 5. Statistical Stability Validation
To ensure sampling did not distort laundering patterns, laundering rate comparison was performed.

Observed Sample Laundering Rates
Scenario	Laundering Rate
HI_LARGE	0.0012186
HI_MEDIUM	0.0010410
HI_SMALL	0.0010812
LI_LARGE	0.0005760
LI_MEDIUM	0.0005021
LI_SMALL	0.0005447

The rates remained stable relative to the full dataset.

This confirms:
Sampling preserved distributional integrity
Detection rules remain representative

## Architectural Impact

This redesign achieved:
Reduced processing load from 430M → 20.6M rows
Preserved laundering distribution
Maintained realistic AML behaviour
Enabled safe session-based Rule 2 implementation
Preserved drilldown capability for compliance investigation