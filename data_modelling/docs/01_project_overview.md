# Project Overview

This project implements a scalable Anti-Money Laundering (AML) monitoring system using the IBM Synthetic AML dataset (~430 million transactions across multiple risk scenarios).

The objective is to simulate a realistic transaction monitoring architecture that:

- Detects suspicious behavioural patterns
- Assigns calibrated risk bands
- Supports compliance investigation workflows
- Remains computationally feasible on local hardware

Two detection rules are implemented:

1. Rule 1 – Structuring Detection (deterministic, threshold-based)
2. Rule 2 – Velocity Burst Detection (session-based behavioural signal)

The system produces a unified alert layer (`fact_alerts`) that functions as a fact table for BI dashboards.

Design principles:
- Simplicity over overengineering
- Explainability over black-box modelling
- Memory-safe execution
- Modular SQL pipeline