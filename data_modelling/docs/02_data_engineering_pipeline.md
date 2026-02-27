# Data Engineering Pipeline

## 1. Parquet Conversion

All raw CSV files were converted to Parquet format.

Rationale:
- Columnar storage improves query performance.
- Reduces disk I/O overhead.
- Enables efficient DuckDB scanning.
- Avoids repeated CSV parsing costs.

---

## 2. Staging Layer

All scenario Parquet files are loaded via a unified staging view (`stg_transactions`).

This allows:
- Scenario-aware partitioning
- Centralised schema management
- Simplified downstream transformations

---

## 3. Account-Level Stratified Sampling

Full sessionisation on ~430M rows caused memory exhaustion.

Instead of random row sampling (which would break behavioural continuity), a deterministic hash-based account sampling strategy was implemented:

- 5% of accounts per scenario selected
- Full transaction history preserved per sampled account
- Laundering rate stability validated

Resulting working dataset: ~20.6M rows

This approach balances:
- Computational feasibility
- Behavioural integrity
- Statistical stability
