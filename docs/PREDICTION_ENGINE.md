# Prediction Engine Spec (DRAFT)

**Problem:** PCOS cycles are irregular; a 28-day model is harmful.

**Approach:**
1. Cold start (<3 cycles): show "gathering data" — no date prediction.
2. ≥3 cycles: weighted moving average of last 6 cycle lengths, weight recent higher.
3. Confidence band = ±(1 std dev), clamped to [21, 45] days.
4. Flag anomalies (cycle >90d or <21d) with "talk to your provider" CTA.
5. **Every prediction UI must render `MedicalDisclaimer`.**

**Explicitly out of scope:** ovulation/fertility prediction for contraception.
