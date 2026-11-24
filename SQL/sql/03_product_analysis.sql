-- Project: Fuzzy Factory E-commerce Analysis
-- Analysis: Product Performance
-- SQL Server (T-SQL) | Revenue and gross profit before refunds.
-- Data ends March 19, 2015; March 2015 is incomplete.
USE FuzzyDB;
GO
SET NOCOUNT ON;

-- 1. Product catalog.
SELECT product_id, product_name, created_at AS Launch_Date
FROM dbo.products
ORDER BY created_at;

-- 2. Monthly product performance (Power BI input candidate).
SELECT DATEFROMPARTS(YEAR(i.created_at), MONTH(i.created_at), 1) AS Month_date,
    p.product_id, p.product_name,
    COUNT(i.order_item_id) AS Units_Sold,
    SUM(i.price_usd) AS Revenue,
    SUM(i.cogs_usd) AS COGS,
    SUM(i.price_usd - i.cogs_usd) AS Gross_Profit,
    ROUND(100.0 * SUM(i.price_usd - i.cogs_usd) / NULLIF(SUM(i.price_usd), 0), 2) AS Gross_Margin_Pct
FROM dbo.order_items AS i
JOIN dbo.products AS p ON i.product_id = p.product_id
GROUP BY DATEFROMPARTS(YEAR(i.created_at), MONTH(i.created_at), 1), p.product_id, p.product_name
ORDER BY Month_date, Revenue DESC;

-- 3. Compare product sales over equal periods, January 1 through March 18.
;WITH sales AS (
    SELECT p.product_name, YEAR(i.created_at) AS Analysis_Year,
        COUNT(*) AS Units_Sold
    FROM dbo.order_items AS i
    JOIN dbo.products AS p ON i.product_id = p.product_id
    WHERE ((i.created_at >= '20140101' AND i.created_at < '20140319')
        OR (i.created_at >= '20150101' AND i.created_at < '20150319'))
        AND p.product_id IN (1, 3)
    GROUP BY p.product_name, YEAR(i.created_at)
), comparison AS (
    SELECT *, LAG(Units_Sold) OVER (PARTITION BY product_name ORDER BY Analysis_Year) AS Previous_Units
    FROM sales
)
SELECT *, ROUND(100.0 * (Units_Sold - Previous_Units) / NULLIF(Previous_Units, 0), 2) AS Growth_Pct
FROM comparison
ORDER BY product_name, Analysis_Year;

-- 4. Validate repeated refund records per order item.
SELECT order_item_id, COUNT(*) AS Refund_Records
FROM dbo.order_item_refunds
GROUP BY order_item_id
HAVING COUNT(*) > 1;

-- 5. Refund rate by product (all available history).
-- Aggregate refunds first to prevent duplicate order items after joining.
;WITH refunds AS (
    SELECT order_item_id, SUM(refund_amount_usd) AS Refund_Amount
    FROM dbo.order_item_refunds
    GROUP BY order_item_id
)
SELECT p.product_name, COUNT(i.order_item_id) AS Units_Sold,
    COUNT(r.order_item_id) AS Refunded_Items,
    ROUND(100.0 * COUNT(r.order_item_id) / NULLIF(COUNT(i.order_item_id), 0), 2) AS Refund_Rate_Pct,
    COALESCE(SUM(r.Refund_Amount), 0) AS Total_Refund_Amount
FROM dbo.order_items AS i
JOIN dbo.products AS p ON i.product_id = p.product_id
LEFT JOIN refunds AS r ON i.order_item_id = r.order_item_id
GROUP BY p.product_name
ORDER BY Total_Refund_Amount DESC;
