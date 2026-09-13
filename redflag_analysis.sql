-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║          🚨  R E D F L A G  —  F R A U D  D E T E C T I O N  🚨             ║
-- ║                                                                              ║
-- ║         The Unlox Academy  ·  DA / DS Track  ·  Week 3 Minor Project         ║
-- ║                                                                              ║
-- ║   Dataset : 200,000 synthetic transactions · PayFast (Fictional FinTech)     ║
-- ║   Period  : 01 Jan 2024 — 30 Jun 2024 · 20 Indian Cities                     ║
-- ║   Author  : Manya                                                            ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

-- ============================================================
--  TABLE OF CONTENTS
--  ---------------------------------------------------------
--  SECTION 0  · Database Setup & Verification
--  SECTION 1  · Basic Exploration         (Q1  - Q5)
--  SECTION 2  · Aggregations & Grouping   (Q6  - Q10)
--  SECTION 3  · Filtering & Conditions    (Q11 - Q15)
--  SECTION 4  · Window Functions          (Q16 - Q20)
--  SECTION 5  · Fraud / Red-Flag Detection(Q21 - Q25)
--  SECTION 6  · Advanced Analysis         (Q26 - Q30)
--  BONUS      · Executive Summary Dashboard
-- ============================================================


USE redflag;

SELECT 'Total Rows'        AS metric, COUNT(*)                AS value FROM transactions
UNION ALL
SELECT 'Unique Users',                COUNT(DISTINCT user_id)           FROM transactions
UNION ALL
SELECT 'Unique Merchants',            COUNT(DISTINCT merchant_id)       FROM transactions
UNION ALL
SELECT 'Unique Cities',               COUNT(DISTINCT city)              FROM transactions;

SELECT
    MIN(txn_time)                          AS dataset_start,
    MAX(txn_time)                          AS dataset_end,
    DATEDIFF(MAX(txn_time), MIN(txn_time)) AS days_covered
FROM transactions;


-- Q1. Preview the Dataset
SELECT *
FROM   transactions
LIMIT  10;


-- Q2. Count Transactions by Status
SELECT
    status,
    COUNT(*)                                               AS total_txns,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)    AS pct_share
FROM   transactions
GROUP  BY status
ORDER  BY total_txns DESC;


-- Q3. Count Transactions by Payment Mode
SELECT
    payment_mode,
    COUNT(*)              AS total_txns,
    ROUND(AVG(amount), 2) AS avg_txn_amount
FROM   transactions
GROUP  BY payment_mode
ORDER  BY total_txns DESC;


-- Q4. Count Transactions by Transaction Type
SELECT
    txn_type,
    COUNT(*)              AS total_txns,
    ROUND(SUM(amount), 2) AS total_amount
FROM   transactions
GROUP  BY txn_type
ORDER  BY total_txns DESC;


-- Q5. Overall Amount Statistics
SELECT
    ROUND(MIN(amount), 2) AS min_amount,
    ROUND(MAX(amount), 2) AS max_amount,
    ROUND(AVG(amount), 2) AS avg_amount,
    ROUND(SUM(amount), 2) AS total_volume,
    COUNT(*)              AS total_transactions
FROM   transactions;


-- Q6. Total Transaction Volume by City
SELECT
    city,
    COUNT(*)              AS total_txns,
    ROUND(SUM(amount), 2) AS total_volume,
    ROUND(AVG(amount), 2) AS avg_txn_amount
FROM   transactions
GROUP  BY city
ORDER  BY total_volume DESC;


-- Q7. Monthly Transaction Trends
SELECT
    DATE_FORMAT(txn_time, '%Y-%m')                AS txn_month,
    COUNT(*)                                      AS total_txns,
    ROUND(SUM(amount), 2)                         AS total_volume,
    ROUND(AVG(amount), 2)                         AS avg_txn_amount,
    COUNT(CASE WHEN status = 'FAILED' THEN 1 END) AS failed_txns
FROM   transactions
GROUP  BY DATE_FORMAT(txn_time, '%Y-%m')
ORDER  BY txn_month;


-- Q8. Hourly Transaction Patterns
SELECT
    HOUR(txn_time)        AS hour_of_day,
    COUNT(*)              AS total_txns,
    ROUND(SUM(amount), 2) AS total_volume
FROM   transactions
GROUP  BY HOUR(txn_time)
ORDER  BY hour_of_day;


-- Q9. Top 10 Merchants by Transaction Volume
SELECT
    merchant_id,
    COUNT(*)                AS total_txns,
    ROUND(SUM(amount), 2)   AS total_volume,
    ROUND(AVG(amount), 2)   AS avg_amount,
    COUNT(DISTINCT user_id) AS unique_customers
FROM   transactions
GROUP  BY merchant_id
ORDER  BY total_volume DESC
LIMIT  10;


-- Q10. Top 10 High-Value Users by Total Spending
SELECT
    user_id,
    COUNT(*)              AS total_txns,
    ROUND(SUM(amount), 2) AS total_spent,
    ROUND(AVG(amount), 2) AS avg_txn_amount,
    COUNT(DISTINCT city)  AS cities_transacted_in
FROM   transactions
WHERE  status = 'SUCCESS'
GROUP  BY user_id
ORDER  BY total_spent DESC
LIMIT  10;


-- Q11. Large Transactions Above Rs 30000
SELECT
    txn_id,
    user_id,
    merchant_id,
    amount,
    txn_time,
    status,
    payment_mode,
    city,
    txn_type
FROM   transactions
WHERE  amount > 30000
ORDER  BY amount DESC;


-- Q12. Failed Transactions Analysis
SELECT
    txn_id,
    user_id,
    amount,
    txn_time,
    payment_mode,
    city
FROM   transactions
WHERE  status = 'FAILED'
ORDER  BY amount DESC
LIMIT  50;

SELECT
    city,
    COUNT(*)                                                          AS total_txns,
    COUNT(CASE WHEN status = 'FAILED' THEN 1 END)                     AS failed_txns,
    ROUND(
        COUNT(CASE WHEN status = 'FAILED' THEN 1 END) * 100.0 / COUNT(*),
        2
    )                                                                 AS failure_rate_pct
FROM   transactions
GROUP  BY city
ORDER  BY failure_rate_pct DESC;


-- Q13. Late-Night Transactions (Midnight to 4 AM)
SELECT
    txn_id,
    user_id,
    merchant_id,
    amount,
    txn_time,
    HOUR(txn_time) AS txn_hour,
    status,
    payment_mode,
    city
FROM   transactions
WHERE  HOUR(txn_time) BETWEEN 0 AND 3
ORDER  BY amount DESC
LIMIT  100;

SELECT
    HOUR(txn_time)        AS hour,
    COUNT(*)              AS night_txns,
    ROUND(AVG(amount), 2) AS avg_amount
FROM   transactions
WHERE  HOUR(txn_time) BETWEEN 0 AND 3
GROUP  BY HOUR(txn_time)
ORDER  BY hour;


-- Q14. Users with Both SUCCESS and FAILED Transactions
SELECT
    user_id,
    COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) AS success_count,
    COUNT(CASE WHEN status = 'FAILED'  THEN 1 END) AS failed_count,
    COUNT(*)                                        AS total_txns
FROM   transactions
GROUP  BY user_id
HAVING success_count > 0 AND failed_count > 0
ORDER  BY failed_count DESC
LIMIT  20;


-- Q15. Refund Analysis by City
SELECT
    city,
    COUNT(*)              AS refund_count,
    ROUND(SUM(amount), 2) AS total_refund_amount,
    ROUND(AVG(amount), 2) AS avg_refund_amount
FROM   transactions
WHERE  txn_type = 'REFUND'
GROUP  BY city
ORDER  BY refund_count DESC;


-- Q16. Rank Users by Total Spending
SELECT
    user_id,
    ROUND(SUM(amount), 2)                         AS total_spent,
    COUNT(*)                                      AS txn_count,
    DENSE_RANK() OVER (ORDER BY SUM(amount) DESC) AS spending_rank
FROM   transactions
WHERE  status = 'SUCCESS'
GROUP  BY user_id
ORDER  BY spending_rank
LIMIT  20;


-- Q17. Running Total of Transaction Volume by Date
SELECT
    txn_date,
    daily_volume,
    ROUND(SUM(daily_volume) OVER (ORDER BY txn_date), 2) AS cumulative_volume
FROM (
    SELECT
        DATE(txn_time)  AS txn_date,
        SUM(amount)     AS daily_volume
    FROM   transactions
    WHERE  status = 'SUCCESS'
    GROUP  BY DATE(txn_time)
) daily_summary
ORDER  BY txn_date;


-- Q18. Top 3 Merchants within Each City
WITH merchant_city AS (
    SELECT
        city,
        merchant_id,
        COUNT(*) AS txn_count
    FROM   transactions
    WHERE  status = 'SUCCESS'
    GROUP  BY city, merchant_id
),
ranked AS (
    SELECT
        city,
        merchant_id,
        txn_count,
        RANK() OVER (PARTITION BY city ORDER BY txn_count DESC) AS city_rank
    FROM   merchant_city
)
SELECT *
FROM   ranked
WHERE  city_rank <= 3
ORDER  BY city, city_rank;


-- Q19. Time Gap Between Consecutive Transactions per User
WITH ordered_txns AS (
    SELECT
        txn_id,
        user_id,
        amount,
        txn_time,
        LAG(txn_time) OVER (PARTITION BY user_id ORDER BY txn_time) AS prev_txn_time
    FROM transactions
)
SELECT
    txn_id,
    user_id,
    amount,
    txn_time,
    prev_txn_time,
    TIMESTAMPDIFF(SECOND, prev_txn_time, txn_time) AS gap_seconds
FROM   ordered_txns
WHERE  prev_txn_time IS NOT NULL
ORDER  BY gap_seconds ASC
LIMIT  30;


-- Q20. Transaction Amount Buckets
SELECT
    CASE
        WHEN amount < 1000               THEN '1 - Low       (below Rs 1K)'
        WHEN amount BETWEEN 1000 AND 4999 THEN '2 - Medium    (Rs 1K to Rs 5K)'
        WHEN amount BETWEEN 5000 AND 14999 THEN '3 - High      (Rs 5K to Rs 15K)'
        ELSE                                   '4 - Very High (Rs 15K and above)'
    END                   AS amount_bucket,
    COUNT(*)              AS txn_count,
    ROUND(SUM(amount), 2) AS total_volume,
    ROUND(AVG(amount), 2) AS avg_amount
FROM   transactions
GROUP  BY amount_bucket
ORDER  BY amount_bucket;


-- Q21. RED FLAG 1 - Velocity Check
SELECT
    user_id,
    DATE_FORMAT(txn_time, '%Y-%m-%d %H:00') AS txn_hour,
    COUNT(*)                                 AS txns_in_hour,
    ROUND(SUM(amount), 2)                    AS amount_in_hour
FROM   transactions
GROUP  BY user_id, DATE_FORMAT(txn_time, '%Y-%m-%d %H:00')
HAVING txns_in_hour > 10
ORDER  BY txns_in_hour DESC;


-- Q22. RED FLAG 2 - Multi-City Activity in 24 Hours
SELECT
    user_id,
    DATE(txn_time)                                           AS txn_date,
    COUNT(DISTINCT city)                                     AS cities_used,
    GROUP_CONCAT(DISTINCT city ORDER BY city SEPARATOR ', ') AS city_list,
    COUNT(*)                                                 AS total_txns_that_day
FROM   transactions
GROUP  BY user_id, DATE(txn_time)
HAVING cities_used > 2
ORDER  BY cities_used DESC, total_txns_that_day DESC
LIMIT  50;


-- Q23. RED FLAG 3 - Rapid Repeat Transactions
WITH consecutive AS (
    SELECT
        txn_id,
        user_id,
        merchant_id,
        amount,
        txn_time,
        LAG(txn_time) OVER (PARTITION BY user_id, merchant_id ORDER BY txn_time) AS prev_time,
        LAG(txn_id)   OVER (PARTITION BY user_id, merchant_id ORDER BY txn_time) AS prev_txn_id,
        LAG(amount)   OVER (PARTITION BY user_id, merchant_id ORDER BY txn_time) AS prev_amount
    FROM transactions
)
SELECT
    txn_id,
    prev_txn_id,
    user_id,
    merchant_id,
    amount,
    prev_amount,
    txn_time,
    prev_time,
    TIMESTAMPDIFF(SECOND, prev_time, txn_time) AS gap_seconds
FROM   consecutive
WHERE  prev_time IS NOT NULL
  AND  TIMESTAMPDIFF(SECOND, prev_time, txn_time) <= 120
ORDER  BY gap_seconds ASC;


-- Q24. RED FLAG 4 - Failed to Success Retry Pattern
WITH flagged AS (
    SELECT
        txn_id,
        user_id,
        merchant_id,
        amount,
        txn_time,
        status,
        LEAD(status)   OVER (PARTITION BY user_id, merchant_id ORDER BY txn_time) AS next_status,
        LEAD(txn_time) OVER (PARTITION BY user_id, merchant_id ORDER BY txn_time) AS next_time,
        LEAD(txn_id)   OVER (PARTITION BY user_id, merchant_id ORDER BY txn_time) AS next_txn_id
    FROM transactions
)
SELECT
    txn_id      AS failed_txn_id,
    next_txn_id AS success_txn_id,
    user_id,
    merchant_id,
    amount,
    txn_time    AS failed_at,
    next_time   AS succeeded_at,
    TIMESTAMPDIFF(SECOND, txn_time, next_time) AS retry_gap_seconds
FROM   flagged
WHERE  status      = 'FAILED'
  AND  next_status = 'SUCCESS'
  AND  TIMESTAMPDIFF(SECOND, txn_time, next_time) <= 300
ORDER  BY retry_gap_seconds ASC;


-- Q25. RED FLAG 5 - Statistical Outlier Amounts (Z-Score Method)
WITH user_stats AS (
    SELECT
        user_id,
        AVG(amount)    AS avg_amt,
        STDDEV(amount) AS std_amt
    FROM   transactions
    WHERE  status = 'SUCCESS'
    GROUP  BY user_id
    HAVING COUNT(*) >= 5
)
SELECT
    t.txn_id,
    t.user_id,
    t.amount,
    t.txn_time,
    t.city,
    t.payment_mode,
    ROUND(s.avg_amt, 2)                                      AS user_avg_amount,
    ROUND(s.std_amt, 2)                                      AS user_std_amount,
    ROUND((t.amount - s.avg_amt) / NULLIF(s.std_amt, 0), 2) AS z_score
FROM   transactions t
JOIN   user_stats   s ON t.user_id = s.user_id
WHERE  t.status = 'SUCCESS'
  AND  (t.amount - s.avg_amt) / NULLIF(s.std_amt, 0) > 3
ORDER  BY z_score DESC
LIMIT  50;


-- Q26. Dominant Payment Mode by City
WITH city_mode_counts AS (
    SELECT
        city,
        payment_mode,
        COUNT(*) AS mode_count
    FROM   transactions
    GROUP  BY city, payment_mode
),
ranked_modes AS (
    SELECT
        city,
        payment_mode,
        mode_count,
        RANK() OVER (PARTITION BY city ORDER BY mode_count DESC) AS mode_rank
    FROM   city_mode_counts
)
SELECT
    city,
    payment_mode AS dominant_payment_mode,
    mode_count   AS txn_count
FROM   ranked_modes
WHERE  mode_rank = 1
ORDER  BY city;


-- Q27. Week-over-Week Growth in Transaction Volume
WITH weekly AS (
    SELECT
        YEARWEEK(txn_time, 1) AS yr_week,
        MIN(DATE(txn_time))   AS week_start,
        COUNT(*)              AS total_txns,
        ROUND(SUM(amount), 2) AS weekly_volume
    FROM   transactions
    WHERE  status = 'SUCCESS'
    GROUP  BY YEARWEEK(txn_time, 1)
)
SELECT
    yr_week,
    week_start,
    total_txns,
    weekly_volume,
    LAG(weekly_volume) OVER (ORDER BY yr_week) AS prev_week_volume,
    ROUND(
        (weekly_volume - LAG(weekly_volume) OVER (ORDER BY yr_week))
        / NULLIF(LAG(weekly_volume) OVER (ORDER BY yr_week), 0) * 100,
        2
    )                                          AS wow_growth_pct
FROM   weekly
ORDER  BY yr_week;


-- Q28. Users with High Failed Transaction Ratio
SELECT
    user_id,
    COUNT(*)                                               AS total_txns,
    COUNT(CASE WHEN status = 'FAILED'  THEN 1 END)         AS failed_count,
    COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END)         AS success_count,
    ROUND(
        COUNT(CASE WHEN status = 'FAILED' THEN 1 END) * 100.0
        / COUNT(*),
        2
    )                                                      AS failure_rate_pct
FROM   transactions
GROUP  BY user_id
HAVING total_txns >= 5
   AND failure_rate_pct > 30
ORDER  BY failure_rate_pct DESC
LIMIT  30;


-- Q29. Top 5 Merchants with Highest Average Transaction Value
SELECT
    merchant_id,
    COUNT(*)              AS total_txns,
    ROUND(SUM(amount), 2) AS total_volume,
    ROUND(AVG(amount), 2) AS avg_txn_value,
    ROUND(MAX(amount), 2) AS max_single_txn
FROM   transactions
WHERE  status = 'SUCCESS'
GROUP  BY merchant_id
HAVING total_txns >= 50
ORDER  BY avg_txn_value DESC
LIMIT  5;


-- Q30. Comprehensive Red-Flag Risk Score Card
WITH velocity_flag AS (
    SELECT DISTINCT user_id,
        3                             AS score,
        'High Velocity (>10 txns/hr)' AS reason
    FROM (
        SELECT
            user_id,
            DATE_FORMAT(txn_time, '%Y-%m-%d %H:00') AS hr,
            COUNT(*) AS c
        FROM   transactions
        GROUP  BY user_id, hr
        HAVING c > 10
    ) v
),
multicity_flag AS (
    SELECT DISTINCT user_id,
        2                            AS score,
        'Multi-City (>2 cities/day)' AS reason
    FROM (
        SELECT
            user_id,
            DATE(txn_time)       AS d,
            COUNT(DISTINCT city) AS cc
        FROM   transactions
        GROUP  BY user_id, d
        HAVING cc > 2
    ) m
),
failrate_flag AS (
    SELECT
        user_id,
        2                          AS score,
        'High Failure Rate (>30%)' AS reason
    FROM (
        SELECT
            user_id,
            COUNT(CASE WHEN status = 'FAILED' THEN 1 END) * 100.0 / COUNT(*) AS fr,
            COUNT(*) AS total
        FROM   transactions
        GROUP  BY user_id
        HAVING total >= 5 AND fr > 30
    ) f
),
large_txn_flag AS (
    SELECT DISTINCT user_id,
        1                            AS score,
        'Large Transaction (>Rs 30K)' AS reason
    FROM   transactions
    WHERE  amount > 30000
),
nightowl_flag AS (
    SELECT DISTINCT user_id,
        1                              AS score,
        'Late-Night Activity (00-03h)' AS reason
    FROM   transactions
    WHERE  HOUR(txn_time) BETWEEN 0 AND 3
),
all_flags AS (
    SELECT * FROM velocity_flag
    UNION ALL
    SELECT * FROM multicity_flag
    UNION ALL
    SELECT * FROM failrate_flag
    UNION ALL
    SELECT * FROM large_txn_flag
    UNION ALL
    SELECT * FROM nightowl_flag
)
SELECT
    user_id,
    SUM(score)                                               AS risk_score,
    GROUP_CONCAT(reason ORDER BY score DESC SEPARATOR ' | ') AS red_flags_triggered,
    CASE
        WHEN SUM(score) >= 6 THEN 'CRITICAL'
        WHEN SUM(score) >= 4 THEN 'HIGH'
        WHEN SUM(score) >= 2 THEN 'MEDIUM'
        ELSE                      'LOW'
    END                                                      AS risk_level
FROM   all_flags
GROUP  BY user_id
ORDER  BY risk_score DESC
LIMIT  50;


-- BONUS: Executive Summary Dashboard
SELECT
    COUNT(*)                                                    AS total_transactions,
    COUNT(DISTINCT user_id)                                     AS unique_users,
    COUNT(DISTINCT merchant_id)                                 AS unique_merchants,
    ROUND(SUM(amount), 2)                                       AS total_volume_INR,
    ROUND(AVG(amount), 2)                                       AS avg_txn_amount,
    COUNT(CASE WHEN status   = 'FAILED' THEN 1 END)             AS failed_transactions,
    COUNT(CASE WHEN txn_type = 'REFUND' THEN 1 END)             AS refunds_issued,
    COUNT(CASE WHEN amount   > 30000    THEN 1 END)             AS large_txns_over_30K,
    COUNT(CASE WHEN HOUR(txn_time) BETWEEN 0 AND 3 THEN 1 END) AS late_night_txns
FROM   transactions;
