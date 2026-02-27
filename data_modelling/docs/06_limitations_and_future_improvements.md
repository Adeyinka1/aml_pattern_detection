# Limitations & Future Improvements

## Current Limitations

### 1. Synthetic Dataset Constraints

The IBM AML dataset is synthetic.  
While useful for controlled evaluation, it may not fully reflect:

- Real-world transaction noise
- Multi-layer laundering strategies
- Adversarial behaviour
- Operational banking constraints

As a result, precision metrics should be interpreted as architectural validation rather than production performance benchmarks.

---

### 2. Velocity Rule Standalone Weakness

Velocity burst detection demonstrated low standalone precision.

This is expected because:

- High-frequency legitimate behaviour exists (e.g., corporate payment runs)
- Behavioural signals alone lack context
- Transaction count does not imply illicit intent

This reinforces the need for multi-signal layering.

---

### 3. No Network Graph Modelling

Current detection rules operate at the account-level only.

The system does not yet incorporate:

- Graph-based money flow dispersion
- Circular transaction detection
- Community detection
- Hub-and-spoke structuring patterns

Network analysis could significantly enhance behavioural detection strength.

---

### 4. No Time-Decay Risk Modelling

Risk signals are treated statically.

The system does not currently:
- Apply decay weighting to historical alerts
- Model risk accumulation over time
- Track behavioural drift

In real AML systems, time-aware risk scoring is critical.

---

### 5. No Machine Learning Layer

The architecture is rule-based and explainable.

While this supports interpretability, it does not:
- Capture nonlinear feature interactions
- Learn adaptive thresholds
- Optimise for precision-recall tradeoffs

A supervised ML model could be layered on top of engineered features.

---

## Future Improvements

### 1. Graph-Based Feature Engineering

Introduce features such as:
- Out-degree centrality
- Transaction clustering coefficient
- Rapid fund dispersion metrics
- Multi-hop fund tracing

---

### 2. Combined Risk Scoring

Develop a unified risk score:

Final_Risk = Structuring_Score + Velocity_Score + Overlap_Bonus

This would prioritise accounts flagged by multiple rules.

---

### 3. Adaptive Threshold Calibration

Replace static percentile bands with:
- Scenario-specific optimisation
- Precision-target calibration
- Dynamic threshold tuning

---

### 4. Migration to Distributed Processing

If scaled beyond local constraints, migrate to:
- Spark / Databricks
- Distributed sessionisation
- Scalable feature pipelines

---

### 5. ML-Based Anomaly Layer

Add a model trained on:
- Aggregated behavioural features
- Network features
- Historical alert patterns

This would transform the system into a hybrid rule + ML AML engine.