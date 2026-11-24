-- Project: Fuzzy Factory E-commerce Analysis
-- Analysis: Growth Overview
-- SQL Server (T-SQL) | Revenue and gross profit before refunds.
-- Data ends March 19, 2015; March 2015 is incomplete.
USE FuzzyDB;
GO
SET NOCOUNT ON;

-- 1. Monthly KPIs and month-over-month growth (session-month attribution).
;WITH monthly AS (
    SELECT DATEFROMPARTS(YEAR(s.created_at), MONTH(s.created_at), 1) AS Month_date,
    COUNT(DISTINCT s.website_session_id) AS Total_Sessions,
    COUNT(DISTINCT o.website_session_id) AS Converted_Sessions,
    COUNT(o.order_id) AS Total_Orders,
    COALESCE(SUM(o.price_usd), 0) AS Revenue,
    COALESCE(SUM(o.price_usd - o.cogs_usd), 0) AS Gross_Profit
FROM dbo.website_sessions AS s
LEFT JOIN dbo.orders AS o ON s.website_session_id = o.website_session_id
GROUP BY DATEFROMPARTS(YEAR(s.created_at), MONTH(s.created_at), 1)
), previous_month AS (
    SELECT *, LAG(Revenue) OVER (ORDER BY Month_date) AS Previous_Revenue,
        LAG(Total_Orders) OVER (ORDER BY Month_date) AS Previous_Orders
    FROM monthly
)
SELECT *,
    ROUND(100.0 * Converted_Sessions / NULLIF(Total_Sessions, 0), 2) AS CVR_Pct,
    ROUND(1.0 * Revenue / NULLIF(Total_Orders, 0), 2) AS AOV,
    ROUND(100.0 * (Revenue - Previous_Revenue) / NULLIF(Previous_Revenue, 0), 2) AS Revenue_MoM_Pct,
    ROUND(100.0 * (Total_Orders - Previous_Orders) / NULLIF(Previous_Orders, 0), 2) AS Orders_MoM_Pct
FROM previous_month
ORDER BY Month_date;

-- 2. Investigate the traffic decline between December 2012 and January 2013.
SELECT DATEFROMPARTS(YEAR(s.created_at), MONTH(s.created_at), 1) AS Month_date, s.utm_source, s.utm_campaign,
    COUNT(*) AS Total_Sessions
FROM dbo.website_sessions AS s
WHERE s.created_at >= '20121201' AND s.created_at < '20130201'
GROUP BY DATEFROMPARTS(YEAR(s.created_at), MONTH(s.created_at), 1), s.utm_source, s.utm_campaign
ORDER BY Month_date, Total_Sessions DESC;

-- 3. Monthly gsearch nonbrand performance, including the decline period.
SELECT DATEFROMPARTS(YEAR(s.created_at), MONTH(s.created_at), 1) AS Month_date,
    COUNT(DISTINCT s.website_session_id) AS Total_Sessions,
    COUNT(DISTINCT o.website_session_id) AS Converted_Sessions,
    COUNT(o.order_id) AS Total_Orders,
    COALESCE(SUM(o.price_usd), 0) AS Revenue,
    COALESCE(SUM(o.price_usd - o.cogs_usd), 0) AS Gross_Profit,
    ROUND(100.0 * COUNT(DISTINCT o.website_session_id) / NULLIF(COUNT(DISTINCT s.website_session_id), 0), 2) AS CVR_Pct,
    ROUND(1.0 * SUM(o.price_usd) / NULLIF(COUNT(o.order_id), 0), 2) AS AOV
FROM dbo.website_sessions AS s
LEFT JOIN dbo.orders AS o ON s.website_session_id = o.website_session_id
WHERE s.utm_source = 'gsearch' AND s.utm_campaign = 'nonbrand'
GROUP BY DATEFROMPARTS(YEAR(s.created_at), MONTH(s.created_at), 1)
ORDER BY Month_date;

-- 4. Comparable January 1 through March 18 periods (exclude partial March 19).
SELECT YEAR(s.created_at) AS Analysis_Year,
    COUNT(DISTINCT s.website_session_id) AS Total_Sessions,
    COUNT(DISTINCT o.website_session_id) AS Converted_Sessions,
    COUNT(o.order_id) AS Total_Orders,
    COALESCE(SUM(o.price_usd), 0) AS Revenue,
    COALESCE(SUM(o.price_usd - o.cogs_usd), 0) AS Gross_Profit,
    ROUND(100.0 * COUNT(DISTINCT o.website_session_id) / NULLIF(COUNT(DISTINCT s.website_session_id), 0), 2) AS CVR_Pct,
    ROUND(100.0 * SUM(o.price_usd - o.cogs_usd) / NULLIF(SUM(o.price_usd), 0), 2) AS Gross_Margin_Pct
FROM dbo.website_sessions AS s
LEFT JOIN dbo.orders AS o ON s.website_session_id = o.website_session_id
WHERE s.utm_source = 'gsearch' AND s.utm_campaign = 'nonbrand'
    AND YEAR(s.created_at) BETWEEN 2013 AND 2015
    AND s.created_at < DATEFROMPARTS(YEAR(s.created_at), 3, 19)
GROUP BY YEAR(s.created_at)
ORDER BY Analysis_Year;
