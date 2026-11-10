-- fact view at month x category x state grain, Power BI slicers need these columns
CREATE OR REPLACE VIEW v_kri_fact AS
WITH p AS (
    SELECT percentile_cont(0.99) WITHIN GROUP (ORDER BY amount) AS p99
    FROM v_txn
)
SELECT
    t.txn_month,
    t.category,
    t.state,
    COUNT(*) AS txn_count,
    SUM(t.is_fraud) AS fraud_count,
    SUM(CASE WHEN t.is_fraud = 1 THEN t.amount ELSE 0 END) AS fraud_amt,
    SUM(t.amount) AS total_amt,
    SUM(CASE WHEN t.amount > p.p99 THEN t.amount ELSE 0 END) AS high_value_amt,
    SUM(CASE WHEN t.amount <= 0
              OR t.dob > t.txn_timestamp::date
              OR t.lat NOT BETWEEN -90 AND 90
              OR t.longitude NOT BETWEEN -180 AND 180
              OR t.merch_lat NOT BETWEEN -90 AND 90
              OR t.merch_long NOT BETWEEN -180 AND 180
              OR t.txn_id IS NULL
              OR t.amount IS NULL
              OR t.category IS NULL
              OR t.state IS NULL
             THEN 1 ELSE 0 END) AS invalid_count
FROM v_txn t
CROSS JOIN p
GROUP BY t.txn_month, t.category, t.state;

-- one row per month with the 4 KRI values
CREATE OR REPLACE VIEW v_kri_monthly AS
WITH cat AS (
    SELECT txn_month, category, SUM(fraud_amt) AS fa
    FROM v_kri_fact
    GROUP BY txn_month, category
),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY txn_month ORDER BY fa DESC) AS rn
    FROM cat
),
top3 AS (
    SELECT txn_month,
           SUM(fa) FILTER (WHERE rn <= 3) / NULLIF(SUM(fa), 0) AS top3_fraud_share
    FROM ranked
    GROUP BY txn_month
)
SELECT
    f.txn_month,
    SUM(f.txn_count) AS txn_count,
    SUM(f.fraud_count)::numeric / SUM(f.txn_count) AS fraud_rate,
    SUM(f.high_value_amt) / SUM(f.total_amt) AS high_value_share,
    SUM(f.invalid_count)::numeric / SUM(f.txn_count) AS invalid_rate,
    t.top3_fraud_share
FROM v_kri_fact f
JOIN top3 t USING (txn_month)
GROUP BY f.txn_month, t.top3_fraud_share
ORDER BY f.txn_month;
