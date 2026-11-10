--clean base view for all KRIs and dashboard analysis.
CREATE OR REPLACE VIEW v_txn AS
SELECT
    trans_num AS txn_id,
    trans_date_trans_time AS txn_timestamp,

    -- Extract transaction month
    DATE_TRUNC('month', trans_date_trans_time)::DATE AS txn_month,

    category,
    state,
    amt AS amount,
    is_fraud,

    -- Columns required for validity checks
    dob,
    lat,
    "long" AS longitude,
    merch_lat,
    merch_long

FROM raw_txn;

-- Verify monthly transaction counts
SELECT
    txn_month,
    COUNT(*)
FROM v_txn
GROUP BY txn_month
ORDER BY txn_month;