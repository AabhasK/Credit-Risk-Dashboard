--load train and test csv files into one raw postgres table.
DROP TABLE IF EXISTS raw_txn;

CREATE TABLE raw_txn (
    row_index BIGINT,
    trans_date_trans_time TIMESTAMP,
    cc_num NUMERIC(20, 0),
    merchant TEXT,
    category TEXT,
    amt NUMERIC(12, 2),
    first TEXT,
    last TEXT,
    gender VARCHAR(10),
    street TEXT,
    city TEXT,
    state VARCHAR(10),
    zip INTEGER,
    lat NUMERIC(10, 6),
    long NUMERIC(10, 6),
    city_pop BIGINT,
    job TEXT,
    dob DATE,
    trans_num VARCHAR(100),
    unix_time BIGINT,
    merch_lat NUMERIC(10, 6),
    merch_long NUMERIC(10, 6),
    is_fraud INTEGER
);

--Load training data
\copy raw_txn FROM 'data/fraudTrain.csv' WITH (FORMAT CSV, HEADER TRUE);

--Load testing data
\copy raw_txn FROM 'data/fraudTest.csv' WITH (FORMAT CSV, HEADER TRUE);

--Verify total rows
SELECT COUNT(*) AS total_rows FROM raw_txn;