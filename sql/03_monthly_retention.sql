-- 03_monthly_retention.sql
-- Monthly cohorts by first observed visit.
-- 2017-08-01 is excluded because the dataset contains only one day of August 2017.

WITH user_months AS (
    SELECT DISTINCT
        fullVisitorId,
        DATE_TRUNC(PARSE_DATE('%Y%m%d', date), MONTH) AS visit_month
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    WHERE PARSE_DATE('%Y%m%d', date) < '2017-08-01'
),

users_with_cohort AS (
    SELECT
        fullVisitorId,
        visit_month,
        MIN(visit_month) OVER (PARTITION BY fullVisitorId) AS cohort_month
    FROM user_months
),

cohort_activity AS (
    SELECT
        fullVisitorId,
        cohort_month,
        DATE_DIFF(visit_month, cohort_month, MONTH) AS month_number
    FROM users_with_cohort
),

cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT fullVisitorId) AS cohort_size
    FROM cohort_activity
    WHERE month_number = 0
    GROUP BY cohort_month
),

retention AS (
    SELECT
        cohort_month,
        month_number,
        COUNT(DISTINCT fullVisitorId) AS active_users
    FROM cohort_activity
    GROUP BY cohort_month, month_number
)

SELECT
    r.cohort_month,
    s.cohort_size,
    r.month_number,
    r.active_users,
    ROUND(100 * SAFE_DIVIDE(r.active_users, s.cohort_size), 2) AS retention_pct
FROM retention r
JOIN cohort_sizes s USING (cohort_month)
ORDER BY cohort_month, month_number;
