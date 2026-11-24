-- Project: Fuzzy Factory E-commerce Analysis
-- Analysis: Marketing and Campaign Performance
-- SQL Server (T-SQL) | Revenue and gross profit before refunds.
-- Data ends March 19, 2015; March 2015 is incomplete.
USE FuzzyDB;
GO
SET NOCOUNT ON;

-- 1. Validate SQL NULL versus literal text NULL before grouping traffic.
SELECT
    SUM(CASE WHEN utm_source IS NULL THEN 1 ELSE 0 END) AS Source_SQL_NULL,
    SUM(CASE WHEN utm_source = 'NULL' THEN 1 ELSE 0 END) AS Source_Text_NULL,
    SUM(CASE WHEN http_referer IS NULL THEN 1 ELSE 0 END) AS Referer_SQL_NULL,
    SUM(CASE WHEN http_referer = 'NULL' THEN 1 ELSE 0 END) AS Referer_Text_NULL
FROM dbo.website_sessions;

-- 2. Monthly source/campaign performance (Power BI input candidate).
-- Missing source/campaign labels do not establish direct traffic.
SELECT DATEFROMPARTS(YEAR(s.created_at), MONTH(s.created_at), 1) AS Month_date,
    COALESCE(NULLIF(s.utm_source, 'NULL'), 'Unattributed') AS Sources,
    COALESCE(NULLIF(s.utm_campaign, 'NULL'), 'Unattributed') AS Campaigns,
    COUNT(DISTINCT s.website_session_id) AS Total_Sessions,
    COUNT(DISTINCT o.website_session_id) AS Converted_Sessions,
    COUNT(o.order_id) AS Total_Orders,
    COALESCE(SUM(o.price_usd), 0) AS Revenue,
    COALESCE(SUM(o.price_usd - o.cogs_usd), 0) AS Gross_Profit,
    ROUND(100.0 * COUNT(DISTINCT o.website_session_id) / NULLIF(COUNT(DISTINCT s.website_session_id), 0), 2) AS CVR_Pct
FROM dbo.website_sessions AS s
LEFT JOIN dbo.orders AS o ON s.website_session_id = o.website_session_id
GROUP BY DATEFROMPARTS(YEAR(s.created_at), MONTH(s.created_at), 1), COALESCE(NULLIF(s.utm_source, 'NULL'), 'Unattributed'),
    COALESCE(NULLIF(s.utm_campaign, 'NULL'), 'Unattributed')
ORDER BY Month_date, Sources, Campaigns;

-- 3. Socialbook campaign activity periods.
SELECT utm_campaign AS Campaigns, MIN(created_at) AS First_Session,
    MAX(created_at) AS Last_Session, COUNT(*) AS Total_Sessions
FROM dbo.website_sessions
WHERE utm_source = 'socialbook'
GROUP BY utm_campaign
ORDER BY First_Session;

-- 4. Socialbook campaign and device conversion performance.
SELECT s.utm_campaign AS Campaigns, s.device_type AS Device,
    COUNT(DISTINCT s.website_session_id) AS Total_Sessions,
    COUNT(DISTINCT o.website_session_id) AS Converted_Sessions,
    COUNT(o.order_id) AS Total_Orders,
    COALESCE(SUM(o.price_usd), 0) AS Revenue,
    COALESCE(SUM(o.price_usd - o.cogs_usd), 0) AS Gross_Profit,
    ROUND(100.0 * COUNT(DISTINCT o.website_session_id) / NULLIF(COUNT(DISTINCT s.website_session_id), 0), 2) AS CVR_Pct
FROM dbo.website_sessions AS s
LEFT JOIN dbo.orders AS o ON s.website_session_id = o.website_session_id
WHERE s.utm_source = 'socialbook'
GROUP BY s.utm_campaign, s.device_type
ORDER BY Campaigns, Device;

-- 5. Compare device conversion during the original pilot comparison window.
-- All traffic sources are included; this is not a pilot-only estimate.
SELECT s.device_type AS Device, COUNT(DISTINCT s.website_session_id) AS Total_Sessions,
    COUNT(DISTINCT o.website_session_id) AS Converted_Sessions,
    COUNT(o.order_id) AS Total_Orders,
    COALESCE(SUM(o.price_usd), 0) AS Revenue,
    COALESCE(SUM(o.price_usd - o.cogs_usd), 0) AS Gross_Profit,
    ROUND(100.0 * COUNT(DISTINCT o.website_session_id) / NULLIF(COUNT(DISTINCT s.website_session_id), 0), 2) AS CVR_Pct
FROM dbo.website_sessions AS s
LEFT JOIN dbo.orders AS o ON s.website_session_id = o.website_session_id
WHERE s.created_at >= '20140112' AND s.created_at < '20140316'
GROUP BY s.device_type;
-- Advertising costs are unavailable: ROAS and ROI are not calculated.
