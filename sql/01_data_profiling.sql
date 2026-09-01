-- 01_data_profiling.sql
-- Google Merchandise Store public sample

SELECT
    MIN(PARSE_DATE('%Y%m%d', date)) AS min_date,
    MAX(PARSE_DATE('%Y%m%d', date)) AS max_date,
    COUNT(*) AS sessions,
    COUNT(DISTINCT fullVisitorId) AS users,
    COUNTIF(totals.transactions > 0) AS sessions_with_purchase,
    SUM(IFNULL(totals.transactions, 0)) AS transactions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`;
