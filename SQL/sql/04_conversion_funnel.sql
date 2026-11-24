-- Project: Fuzzy Factory E-commerce Analysis
-- Analysis: Conversion Funnel
-- SQL Server (T-SQL) | Revenue and gross profit before refunds.
-- Data ends March 19, 2015; March 2015 is incomplete.
USE FuzzyDB;
GO
SET NOCOUNT ON;

-- 1. Discover page URLs and session counts; verify product detail URLs below.
SELECT pageview_url, COUNT(*) AS Pageviews,
    COUNT(DISTINCT website_session_id) AS Sessions
FROM dbo.website_pageviews
GROUP BY pageview_url
ORDER BY Pageviews DESC;

-- 2. Monthly stage reach (Power BI input candidate).
-- Product detail URL mapping is proposed; validate against query 1 and the PBIX.
-- Stage flags are independent: these are not strictly sequential transitions.
;WITH session_flags AS (
    SELECT s.website_session_id,
        DATEFROMPARTS(YEAR(s.created_at), MONTH(s.created_at), 1) AS Month_date,
        MAX(CASE WHEN v.pageview_url = '/products' THEN 1 ELSE 0 END) AS Products_Flag,
        MAX(CASE WHEN v.pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear', '/the-birthday-sugar-panda', '/the-hudson-river-mini-bear') THEN 1 ELSE 0 END) AS Product_View_Flag,
        MAX(CASE WHEN v.pageview_url = '/cart' THEN 1 ELSE 0 END) AS Cart_Flag,
        MAX(CASE WHEN v.pageview_url = '/shipping' THEN 1 ELSE 0 END) AS Shipping_Flag,
        MAX(CASE WHEN v.pageview_url IN ('/billing', '/billing-2') THEN 1 ELSE 0 END) AS Billing_Flag,
        MAX(CASE WHEN v.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS Thank_You_Flag
    FROM dbo.website_sessions AS s
    LEFT JOIN dbo.website_pageviews AS v ON s.website_session_id = v.website_session_id
    GROUP BY s.website_session_id, DATEFROMPARTS(YEAR(s.created_at), MONTH(s.created_at), 1)
)
SELECT Month_date, COUNT(*) AS Total_Sessions,
    SUM(Products_Flag) AS Products_Sessions,
    SUM(Product_View_Flag) AS Product_View_Sessions,
    SUM(Cart_Flag) AS Cart_Sessions,
    SUM(Shipping_Flag) AS Shipping_Sessions,
    SUM(Billing_Flag) AS Billing_Sessions,
    SUM(Thank_You_Flag) AS Thank_You_Sessions
FROM session_flags
GROUP BY Month_date
ORDER BY Month_date;

-- 3. Ordered transition: Cart to Shipping.
-- Check for any destination pageview after the first source pageview.
;WITH source_stage AS (
    SELECT website_session_id, MIN(created_at) AS First_Visit
    FROM dbo.website_pageviews
    WHERE pageview_url = '/cart'
    GROUP BY website_session_id
), transition AS (
    SELECT a.website_session_id, a.First_Visit,
        MAX(CASE WHEN b.website_session_id IS NOT NULL THEN 1 ELSE 0 END) AS Reached_Next
    FROM source_stage AS a
    LEFT JOIN dbo.website_pageviews AS b
        ON a.website_session_id = b.website_session_id
        AND b.created_at > a.First_Visit
        AND b.pageview_url = '/shipping'
    GROUP BY a.website_session_id, a.First_Visit
)
SELECT YEAR(First_Visit) AS Analysis_Year, COUNT(*) AS Source_Sessions,
    SUM(Reached_Next) AS Converted_Sessions,
    COUNT(*) - SUM(Reached_Next) AS Dropoff_Sessions,
    ROUND(100.0 * (COUNT(*) - SUM(Reached_Next)) / NULLIF(COUNT(*), 0), 2) AS Dropoff_Rate_Pct
FROM transition
GROUP BY YEAR(First_Visit)
ORDER BY Analysis_Year;

-- 4. Ordered transition: Shipping to Billing.
-- Check for any destination pageview after the first source pageview.
;WITH source_stage AS (
    SELECT website_session_id, MIN(created_at) AS First_Visit
    FROM dbo.website_pageviews
    WHERE pageview_url = '/shipping'
    GROUP BY website_session_id
), transition AS (
    SELECT a.website_session_id, a.First_Visit,
        MAX(CASE WHEN b.website_session_id IS NOT NULL THEN 1 ELSE 0 END) AS Reached_Next
    FROM source_stage AS a
    LEFT JOIN dbo.website_pageviews AS b
        ON a.website_session_id = b.website_session_id
        AND b.created_at > a.First_Visit
        AND b.pageview_url IN ('/billing', '/billing-2')
    GROUP BY a.website_session_id, a.First_Visit
)
SELECT YEAR(First_Visit) AS Analysis_Year, COUNT(*) AS Source_Sessions,
    SUM(Reached_Next) AS Converted_Sessions,
    COUNT(*) - SUM(Reached_Next) AS Dropoff_Sessions,
    ROUND(100.0 * (COUNT(*) - SUM(Reached_Next)) / NULLIF(COUNT(*), 0), 2) AS Dropoff_Rate_Pct
FROM transition
GROUP BY YEAR(First_Visit)
ORDER BY Analysis_Year;

-- 5. Ordered transition: Billing to Completed.
-- Check for any destination pageview after the first source pageview.
;WITH source_stage AS (
    SELECT website_session_id, MIN(created_at) AS First_Visit
    FROM dbo.website_pageviews
    WHERE pageview_url IN ('/billing', '/billing-2')
    GROUP BY website_session_id
), transition AS (
    SELECT a.website_session_id, a.First_Visit,
        MAX(CASE WHEN b.website_session_id IS NOT NULL THEN 1 ELSE 0 END) AS Reached_Next
    FROM source_stage AS a
    LEFT JOIN dbo.website_pageviews AS b
        ON a.website_session_id = b.website_session_id
        AND b.created_at > a.First_Visit
        AND b.pageview_url = '/thank-you-for-your-order'
    GROUP BY a.website_session_id, a.First_Visit
)
SELECT YEAR(First_Visit) AS Analysis_Year, COUNT(*) AS Source_Sessions,
    SUM(Reached_Next) AS Converted_Sessions,
    COUNT(*) - SUM(Reached_Next) AS Dropoff_Sessions,
    ROUND(100.0 * (COUNT(*) - SUM(Reached_Next)) / NULLIF(COUNT(*), 0), 2) AS Dropoff_Rate_Pct
FROM transition
GROUP BY YEAR(First_Visit)
ORDER BY Analysis_Year;
