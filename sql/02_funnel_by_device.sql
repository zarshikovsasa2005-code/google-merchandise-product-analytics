-- 02_funnel_by_device.sql
-- Session-level e-commerce funnel with device segmentation

WITH session_actions AS (
    SELECT
        device.deviceCategory AS device_category,

        EXISTS (
            SELECT 1
            FROM UNNEST(hits) AS hit
            WHERE hit.eCommerceAction.action_type = '2'
        ) AS product_view,

        EXISTS (
            SELECT 1
            FROM UNNEST(hits) AS hit
            WHERE hit.eCommerceAction.action_type = '3'
        ) AS add_to_cart,

        EXISTS (
            SELECT 1
            FROM UNNEST(hits) AS hit
            WHERE hit.eCommerceAction.action_type = '5'
        ) AS checkout,

        EXISTS (
            SELECT 1
            FROM UNNEST(hits) AS hit
            WHERE hit.eCommerceAction.action_type = '6'
        ) AS purchase

    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
),

device_funnel AS (
    SELECT
        IFNULL(device_category, 'ALL') AS device_category,
        COUNT(*) AS sessions,
        COUNTIF(product_view) AS product_views,
        COUNTIF(add_to_cart) AS add_to_carts,
        COUNTIF(checkout) AS checkouts,
        COUNTIF(purchase) AS purchases
    FROM session_actions
    GROUP BY ROLLUP(device_category)
)

SELECT
    device_category,
    sessions,
    product_views,
    add_to_carts,
    checkouts,
    purchases,
    ROUND(100 * SAFE_DIVIDE(product_views, sessions), 2) AS product_view_rate_pct,
    ROUND(100 * SAFE_DIVIDE(add_to_carts, product_views), 2) AS cart_from_view_pct,
    ROUND(100 * SAFE_DIVIDE(checkouts, add_to_carts), 2) AS checkout_from_cart_pct,
    ROUND(100 * SAFE_DIVIDE(purchases, checkouts), 2) AS purchase_from_checkout_pct,
    ROUND(100 * SAFE_DIVIDE(purchases, sessions), 2) AS session_to_purchase_pct
FROM device_funnel
ORDER BY
    CASE device_category
        WHEN 'ALL' THEN 1
        WHEN 'desktop' THEN 2
        WHEN 'mobile' THEN 3
        WHEN 'tablet' THEN 4
        ELSE 5
    END;
