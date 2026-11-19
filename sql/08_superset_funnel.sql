-- Strict sequential ecommerce funnel based on hitNumber.
-- This produces 9,072 complete-funnel sessions, distinct from
-- 11,552 observed sessions with a purchase.
CREATE OR REPLACE TABLE `product-analytics-pet.product_analytics.dashboard_funnel` AS
WITH session_events AS (
  SELECT
    PARSE_DATE('%Y%m%d', date) AS session_date,
    device.deviceCategory AS device,
    channelGrouping AS channel,
    ARRAY(
      SELECT AS STRUCT
        h.hitNumber AS hit_number,
        h.eCommerceAction.action_type AS action_type
      FROM UNNEST(hits) AS h
      WHERE h.eCommerceAction.action_type IN ('2', '3', '5', '6')
      ORDER BY h.hitNumber
    ) AS actions
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
),
product_view AS (
  SELECT *, (SELECT MIN(hit_number) FROM UNNEST(actions)
    WHERE action_type = '2') AS view_hit FROM session_events
),
cart AS (
  SELECT *, (SELECT MIN(hit_number) FROM UNNEST(actions)
    WHERE action_type = '3' AND hit_number > view_hit) AS cart_hit
  FROM product_view
),
checkout AS (
  SELECT *, (SELECT MIN(hit_number) FROM UNNEST(actions)
    WHERE action_type = '5' AND hit_number > cart_hit) AS checkout_hit
  FROM cart
),
purchase AS (
  SELECT *, (SELECT MIN(hit_number) FROM UNNEST(actions)
    WHERE action_type = '6' AND hit_number > checkout_hit) AS purchase_hit
  FROM checkout
),
daily AS (
  SELECT
    session_date, device, channel,
    COUNTIF(view_hit IS NOT NULL) AS product_views,
    COUNTIF(cart_hit IS NOT NULL) AS add_to_cart,
    COUNTIF(checkout_hit IS NOT NULL) AS checkouts,
    COUNTIF(purchase_hit IS NOT NULL) AS purchases
  FROM purchase
  GROUP BY 1, 2, 3
)
SELECT
  d.session_date, d.device, d.channel,
  f.step_order, f.step, f.sessions
FROM daily AS d
CROSS JOIN UNNEST([
  STRUCT(1 AS step_order, 'Product View' AS step, product_views AS sessions),
  STRUCT(2 AS step_order, 'Add to Cart' AS step, add_to_cart AS sessions),
  STRUCT(3 AS step_order, 'Checkout' AS step, checkouts AS sessions),
  STRUCT(4 AS step_order, 'Purchase' AS step, purchases AS sessions)
]) AS f;
