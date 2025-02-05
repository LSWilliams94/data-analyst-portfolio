
-- Product Analysis:
-- This section explores product performance by analyzing category mixes, profitability, popular colors, and sales trends.
-- It identifies top and bottom performers, commonly purchased products, and evaluates average order value, annual revenue, and quantity sold.

USE sales_analysis;

-- What is the average order value?
SELECT AVG(oli.Quantity * p.ProductPrice) AS AverageOrderValue
FROM order_line_items oli
JOIN product p ON oli.ProductID = p.ProductID;

-- What are our product category mixes?
SELECT pc.ProductCategory, 
       SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS TotalRevenue,
       ROUND( 
           (SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) * 100.0) / 
           SUM(SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0))) OVER (), 
       2) AS PercentageOfTotal
FROM order_line_items oli
JOIN product p ON oli.ProductID = p.ProductID
JOIN product_subcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN product_category pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.ProductCategory
ORDER BY TotalRevenue DESC;

-- What are our most profitable products?
SELECT ProductName, ProductCost, ProductPrice, (ProductCost / ProductPrice) * 100 AS ProfitMarginPercentage
FROM product
ORDER BY ProfitMarginPercentage DESC;

-- What are our top 5 and bottom 5 products by revenue?
WITH RankedProducts AS (
    SELECT p.ProductName, 
           SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS TotalRevenue,
           RANK() OVER (ORDER BY SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) DESC) AS ProductRank
    FROM order_line_items oli
    JOIN product p ON oli.ProductID = p.ProductID
    GROUP BY p.ProductName
)
SELECT ProductName, TotalRevenue, ProductRank
FROM RankedProducts
WHERE ProductRank <= 5 -- Top 5
   OR ProductRank > (SELECT MAX(ProductRank) - 5 FROM RankedProducts) -- Bottom 5
ORDER BY ProductRank;

-- What product colours are most popular?
SELECT pc.ProductColor, 
       SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS TotalRevenue,
       COUNT(DISTINCT p.ProductID) AS ProductCount,
	   SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) / COUNT(DISTINCT p.ProductID) AS AverageRevenueByColor
FROM order_line_items oli
JOIN product p ON oli.ProductID = p.ProductID
JOIN product_colour pc ON p.ProductColorID = pc.ProductColorID
GROUP BY pc.ProductColor
ORDER BY TotalRevenue DESC;

-- What products are commonly purchased together?
SELECT 
    p1.ProductName AS ProductA,
    p2.ProductName AS ProductB,
    COUNT(*) AS TimesPurchasedTogether
FROM order_line_items oli1
JOIN order_line_items oli2 
    ON oli1.OrderNumber = oli2.OrderNumber
   AND oli1.ProductID < oli2.ProductID
JOIN product p1 ON oli1.ProductID = p1.ProductID
JOIN product p2 ON oli2.ProductID = p2.ProductID
GROUP BY p1.ProductName, p2.ProductName
ORDER BY TimesPurchasedTogether DESC;

-- Which product categories have the highest order quantities?
SELECT pc.ProductCategory, SUM(oli.Quantity) AS TotalQuantity
FROM order_line_items oli
JOIN product p ON oli.ProductID = p.ProductID
JOIN product_subcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN product_category pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.ProductCategory
ORDER BY TotalQuantity DESC;

-- What is our average annual revenue and quantity?
SELECT 
    AVG(AnnualRevenue) AS AvgAnnualRevenue,
    AVG(AnnualQuantity) AS AvgAnnualQuantity,
    AVG(AverageSellingPrice) AS AvgSellingPrice
FROM (
    SELECT 
        YEAR(o.OrderDate) AS OrderYear,
        SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS AnnualRevenue,
        SUM(oli.Quantity) AS AnnualQuantity,
        SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) / NULLIF(SUM(oli.Quantity), 0) AS AverageSellingPrice
    FROM order_line_items oli
    JOIN product p ON oli.ProductID = p.ProductID
    JOIN orders o ON oli.OrderNumber = o.OrderNumber
    GROUP BY YEAR(o.OrderDate)
) AS YearlyData;

-- What is our latest annual revenue and quantity?
SELECT 
    YEAR(o.OrderDate) AS OrderYear,
    SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS AnnualRevenue,
    SUM(oli.Quantity) AS AnnualQuantity,
    SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) / NULLIF(SUM(oli.Quantity), 0) AS AverageSellingPrice
FROM order_line_items oli
JOIN product p ON oli.ProductID = p.ProductID
JOIN orders o ON oli.OrderNumber = o.OrderNumber
GROUP BY YEAR(o.OrderDate)
ORDER BY YEAR(o.OrderDate) DESC;