-- Session-level semantic layer for Apache Superset.
-- Observed purchase CR = sessions with a transaction / all sessions.
CREATE OR REPLACE VIEW `product-analytics-pet.product_analytics.dashboard_sessions` AS
SELECT
  PARSE_DATE('%Y%m%d', date) AS session_date,
  fullVisitorId AS user_id,
  CONCAT(fullVisitorId, '_', CAST(visitId AS STRING), '_', CAST(visitStartTime AS STRING)) AS session_id,
  device.deviceCategory AS device,
  channelGrouping AS channel,
  trafficSource.source AS source,
  trafficSource.medium AS medium,
  CASE WHEN totals.newVisits = 1 THEN 'New' ELSE 'Returning' END AS user_type,
  COALESCE(totals.transactions, 0) AS transactions,
  IF(COALESCE(totals.transactions, 0) > 0, 1, 0) AS purchase_session
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801';
