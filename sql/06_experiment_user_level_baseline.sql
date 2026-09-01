-- 06_experiment_user_level_baseline.sql
-- User-level baseline aligned with user-level randomization.
-- Metric: whether a user's FIRST eligible mobile product-view session
-- contains an Add-to-cart event after the product-view event.

WITH mobile_sessions AS (
    SELECT
        fullVisitorId,
        visitStartTime,
        (
            SELECT MIN(h.hitNumber)
            FROM UNNEST(hits) AS h
            WHERE h.eCommerceAction.action_type = '2'
        ) AS product_view_hit,
        hits
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    WHERE device.deviceCategory = 'mobile'
),

eligible_sessions AS (
    SELECT
        fullVisitorId,
        visitStartTime,
        (
            SELECT MIN(h.hitNumber)
            FROM UNNEST(hits) AS h
            WHERE h.eCommerceAction.action_type = '3'
              AND h.hitNumber > product_view_hit
        ) AS add_to_cart_hit
    FROM mobile_sessions
    WHERE product_view_hit IS NOT NULL
),

first_eligible_session AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY fullVisitorId
            ORDER BY visitStartTime
        ) AS rn
    FROM eligible_sessions
)

SELECT
    COUNT(*) AS eligible_users,
    COUNTIF(add_to_cart_hit IS NOT NULL) AS converted_users,
    ROUND(
        100 * SAFE_DIVIDE(
            COUNTIF(add_to_cart_hit IS NOT NULL),
            COUNT(*)
        ),
        2
    ) AS user_conversion_pct
FROM first_eligible_session
WHERE rn = 1;
