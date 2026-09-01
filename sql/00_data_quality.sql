-- 00_data_quality.sql
-- Validate session uniqueness and investigate apparent duplicates.
--
-- Important finding:
-- (fullVisitorId, visitId) alone is not unique in this public sample.
-- 898 pairs repeat, but every repeated pair has a different visitStartTime and date.
-- The composite key (fullVisitorId, visitId, visitStartTime) is unique for all 903,653 rows.

WITH base AS (
    SELECT
        fullVisitorId,
        visitId,
        visitStartTime,
        date
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
),

pair_stats AS (
    SELECT
        fullVisitorId,
        visitId,
        COUNT(*) AS row_count,
        COUNT(DISTINCT visitStartTime) AS visit_start_times,
        COUNT(DISTINCT date) AS dates
    FROM base
    GROUP BY fullVisitorId, visitId
),

summary AS (
    SELECT
        COUNT(*) AS rows_total,
        COUNT(DISTINCT CONCAT(
            fullVisitorId, '-',
            CAST(visitId AS STRING), '-',
            CAST(visitStartTime AS STRING)
        )) AS unique_session_keys
    FROM base
)

SELECT
    s.rows_total,
    s.unique_session_keys,
    s.rows_total - s.unique_session_keys AS duplicate_rows,
    COUNTIF(p.row_count > 1) AS repeated_visitor_visit_keys,
    SUM(IF(p.row_count > 1, p.row_count - 1, 0)) AS extra_rows_under_visitor_visit_key,
    COUNTIF(p.row_count > 1 AND p.visit_start_times > 1) AS repeated_keys_with_different_start_time,
    COUNTIF(p.row_count > 1 AND p.dates > 1) AS repeated_keys_with_different_date
FROM summary s
CROSS JOIN pair_stats p
GROUP BY s.rows_total, s.unique_session_keys;
