-- 05_channel_performance.sql
-- Traffic mix and purchase conversion by Google Analytics default channel grouping.

WITH session_level AS (
    SELECT
        channelGrouping,
        EXISTS (
            SELECT 1
            FROM UNNEST(hits) AS hit
            WHERE hit.eCommerceAction.action_type = '6'
        ) AS purchase
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
)

SELECT
    channelGrouping AS channel,
    COUNT(*) AS sessions,
    COUNTIF(purchase) AS purchases,
    ROUND(100 * SAFE_DIVIDE(COUNT(*), SUM(COUNT(*)) OVER ()), 2) AS traffic_share_pct,
    ROUND(100 * SAFE_DIVIDE(COUNTIF(purchase), COUNT(*)), 2) AS purchase_conversion_pct
FROM session_level
GROUP BY channelGrouping
ORDER BY sessions DESC;
