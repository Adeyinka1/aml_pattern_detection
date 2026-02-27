# Detection Rules

## Rule 1 – Structuring Detection

Structuring detection identifies accounts exhibiting unusually high daily outgoing activity.

Methodology:

1. Aggregate daily outgoing behaviour per account.
2. Compute percentile thresholds (95th / 99th) per scenario per day.
3. Assign risk bands based on threshold exceedance.

Why percentile-based?

- Automatically adapts to scenario scale differences.
- Avoids hard-coded numeric thresholds.
- Provides explainable HIGH / MEDIUM / LOW segmentation.

Output:
`alert_cases_structuring_daily`

This rule functions as a primary deterministic signal.

---

## Rule 2 – Velocity Burst Detection

Velocity detection identifies short-duration bursts of transaction activity.

Sessionisation logic:

- Partition by (scenario, from_account)
- Sort by time_stamp
- New session begins after 30-minute inactivity gap

Velocity criteria:

- Duration ≤ 60 minutes
- ≥ 8 transactions
- ≥ 3 distinct recipients

Why session-based instead of rolling windows?

- Deterministic segmentation
- Lower memory overhead
- Clear behavioural interpretation

Output:
`alert_cases_velocity_banded`

This rule functions as a behavioural enrichment signal.