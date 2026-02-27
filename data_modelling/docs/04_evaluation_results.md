# Evaluation Results

Evaluation uses synthetic `is_laundering` labels provided in the dataset.
These labels are used strictly for model assessment and not in rule construction.

---

## Rule 1 – Structuring

| Risk Band | Alerts | Laundering Alerts | Precision |
|-----------|--------|------------------|-----------|
| HIGH      | 5,381  | 325              | 6.04%     |
| MEDIUM    | 63,992 | 190              | 0.30%     |
| LOW       | 6,143,627 | 15,217       | 0.25%     |

Interpretation:

- The HIGH band demonstrates materially higher precision.
- MEDIUM and LOW bands behave close to baseline.
- Threshold calibration effectively concentrates risk in the HIGH band.

Conclusion:
Rule 1 provides a strong primary detection layer.

---

## Rule 2 – Velocity

| Risk Band | Alerts | Laundering Alerts | Precision |
|-----------|--------|------------------|-----------|
| HIGH      | 5      | 0                | 0.00%     |
| MEDIUM    | 1,094  | 1                | 0.09%     |
| LOW       | 9,568  | 14               | 0.15%     |

Interpretation:

- Velocity bursts occur frequently in legitimate behaviour.
- Standalone precision is low.
- Behavioural rules are better suited as secondary risk multipliers.

Conclusion:
Velocity detection should augment deterministic signals rather than act independently.