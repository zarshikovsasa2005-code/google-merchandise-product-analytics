-- 04_new_vs_returning_by_device.sql
-- Purchase conversion segmented by user type and device.

WITH session_level AS (
    SELECT
        CASE
            WHEN totals.newVisits = 1 THEN 'new'
            ELSE 'returning'
        END AS user_type,
        device.deviceCategory AS device_category,
        EXISTS (
            SELECT 1
            FROM UNNEST(hits) AS hit
            WHERE hit.eCommerceAction.action_type = '6'
        ) AS purchase
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
)

SELECT
    user_type,
    device_category,
    COUNT(*) AS sessions,
    COUNTIF(purchase) AS purchases,
    ROUND(100 * SAFE_DIVIDE(COUNTIF(purchase), COUNT(*)), 2) AS purchase_conversion_pct
FROM session_level
GROUP BY user_type, device_category
ORDER BY user_type, sessions DESC;
