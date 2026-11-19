-- Monthly retention cohorts: first observed month in accessible dataset.
-- August 2017 is excluded because only one day is available.
CREATE OR REPLACE TABLE `product-analytics-pet.product_analytics.dashboard_retention` AS
WITH monthly_activity AS (
  SELECT DISTINCT
    user_id, DATE_TRUNC(session_date, MONTH) AS activity_month
  FROM `product-analytics-pet.product_analytics.dashboard_sessions`
  WHERE session_date >= DATE '2016-08-01'
    AND session_date < DATE '2017-08-01'
),
cohorts AS (
  SELECT user_id, MIN(activity_month) AS cohort_month
  FROM monthly_activity
  GROUP BY user_id
),
cohort_sizes AS (
  SELECT cohort_month, COUNT(*) AS cohort_size
  FROM cohorts
  GROUP BY cohort_month
),
retained_users AS (
  SELECT
    c.cohort_month,
    DATE_DIFF(a.activity_month, c.cohort_month, MONTH) AS month_number,
    COUNT(*) AS active_users
  FROM cohorts c
  JOIN monthly_activity a USING (user_id)
  GROUP BY 1, 2
),
cohort_grid AS (
  SELECT c.cohort_month, c.cohort_size, month_number
  FROM cohort_sizes c
  CROSS JOIN UNNEST(GENERATE_ARRAY(
    0, DATE_DIFF(DATE '2017-07-01', c.cohort_month, MONTH)
  )) AS month_number
)
SELECT
  g.cohort_month,
  FORMAT_DATE('%Y-%m', g.cohort_month) AS cohort_label,
  g.month_number,
  g.cohort_size,
  COALESCE(r.active_users, 0) AS active_users,
  ROUND(100.0 * SAFE_DIVIDE(COALESCE(r.active_users, 0), g.cohort_size), 2)
    AS retention_pct
FROM cohort_grid g
LEFT JOIN retained_users r USING (cohort_month, month_number);
