-- 02_sequential_funnel_by_device.sql
-- Strict session funnel: each stage must occur AFTER the previous stage in hit order.

WITH session_view AS (
    SELECT
        fullVisitorId,
        visitId,
        visitStartTime,
        device.deviceCategory AS device_category,
        hits,
        (
            SELECT MIN(h.hitNumber)
            FROM UNNEST(hits) AS h
            WHERE h.eCommerceAction.action_type = '2'
        ) AS product_view_hit
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
),

session_cart AS (
    SELECT
        *,
        (
            SELECT MIN(h.hitNumber)
            FROM UNNEST(hits) AS h
            WHERE h.eCommerceAction.action_type = '3'
              AND h.hitNumber > product_view_hit
        ) AS add_to_cart_hit
    FROM session_view
),

session_checkout AS (
    SELECT
        *,
        (
            SELECT MIN(h.hitNumber)
            FROM UNNEST(hits) AS h
            WHERE h.eCommerceAction.action_type = '5'
              AND h.hitNumber > add_to_cart_hit
        ) AS checkout_hit
    FROM session_cart
),

session_purchase AS (
    SELECT
        *,
        (
            SELECT MIN(h.hitNumber)
            FROM UNNEST(hits) AS h
            WHERE h.eCommerceAction.action_type = '6'
              AND h.hitNumber > checkout_hit
        ) AS purchase_hit
    FROM session_checkout
),

device_funnel AS (
    SELECT
        IFNULL(device_category, 'ALL') AS device_category,
        COUNT(*) AS sessions,
        COUNTIF(product_view_hit IS NOT NULL) AS product_views,
        COUNTIF(add_to_cart_hit IS NOT NULL) AS add_to_carts,
        COUNTIF(checkout_hit IS NOT NULL) AS checkouts,
        COUNTIF(purchase_hit IS NOT NULL) AS purchases
    FROM session_purchase
    GROUP BY ROLLUP(device_category)
)

SELECT
    device_category,
    sessions,
    product_views,
    add_to_carts,
    checkouts,
    purchases,
    ROUND(100 * SAFE_DIVIDE(product_views, sessions), 2) AS session_to_view_pct,
    ROUND(100 * SAFE_DIVIDE(add_to_carts, product_views), 2) AS view_to_cart_pct,
    ROUND(100 * SAFE_DIVIDE(checkouts, add_to_carts), 2) AS cart_to_checkout_pct,
    ROUND(100 * SAFE_DIVIDE(purchases, checkouts), 2) AS checkout_to_purchase_pct,
    ROUND(100 * SAFE_DIVIDE(purchases, sessions), 2) AS sequential_completion_pct
FROM device_funnel
ORDER BY
    CASE device_category
        WHEN 'ALL' THEN 1
        WHEN 'desktop' THEN 2
        WHEN 'mobile' THEN 3
        WHEN 'tablet' THEN 4
        ELSE 5
    END;
