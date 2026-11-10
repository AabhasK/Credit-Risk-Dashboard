-- baseline is 2019 only, then 2020 is tested against it
DROP TABLE IF EXISTS kri_thresholds CASCADE;

CREATE TABLE kri_thresholds AS
SELECT 'fraud_rate' AS kri_name,
       ROUND(AVG(fraud_rate) + 2 * STDDEV(fraud_rate), 6) AS threshold
FROM v_kri_monthly
WHERE txn_month < '2020-01-01'
UNION ALL
SELECT 'high_value_share',
       ROUND(AVG(high_value_share) + 2 * STDDEV(high_value_share), 6)
FROM v_kri_monthly
WHERE txn_month < '2020-01-01';

CREATE OR REPLACE VIEW v_kri_breach AS
SELECT
    m.txn_month,
    m.fraud_rate,
    f.threshold AS fraud_threshold,
    m.fraud_rate > f.threshold AS fraud_breach,
    m.high_value_share,
    h.threshold AS high_value_threshold,
    m.high_value_share > h.threshold AS high_value_breach
FROM v_kri_monthly m
JOIN kri_thresholds f ON f.kri_name = 'fraud_rate'
JOIN kri_thresholds h ON h.kri_name = 'high_value_share'
ORDER BY m.txn_month;
