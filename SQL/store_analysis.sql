
-- Store Performance Analysis:
-- This section evaluates store-level performance, including revenue trends by year and country, store profitability per square meter, and customer reach.
-- It also covers seasonality, first-month vs. average sales, and operational metrics like order-to-delivery time.

USE sales_analysis;

-- What is the revenue by year?
SELECT YEAR(o.OrderDate) AS [Year], SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS TotalRevenue
FROM order_line_items oli
JOIN product p ON oli.ProductID = p.ProductID
JOIN orders o ON oli.OrderNumber = o.OrderNumber
GROUP BY YEAR(o.OrderDate)
ORDER BY TotalRevenue DESC;

-- Revenue trend
WITH RevenueCTE AS (
    SELECT YEAR(o.OrderDate) AS Year,
           SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS Revenue
    FROM order_line_items oli
    JOIN product p ON oli.ProductID = p.ProductID
    JOIN orders o ON oli.OrderNumber = o.OrderNumber
    GROUP BY YEAR(o.OrderDate)
)
SELECT Year,
       Revenue,
       LAG(Revenue) OVER(ORDER BY Year) AS RevenuePrevYear,
       CASE 
           WHEN LAG(Revenue) OVER(ORDER BY Year) = 0 THEN NULL
           ELSE (Revenue - LAG(Revenue) OVER(ORDER BY Year)) / LAG(Revenue) OVER(ORDER BY Year) * 100
       END AS YoY_Percentage
FROM RevenueCTE;

-- What is the revenue by country?
SELECT s.StoreCountry, SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS TotalRevenue
FROM order_line_items oli
JOIN product p ON oli.ProductID = p.ProductID
JOIN orders o ON oli.OrderNumber = o.OrderNumber
JOIN store s ON s.StoreID = o.StoreID
GROUP BY s.StoreCountry
ORDER BY TotalRevenue DESC;

-- What is the seasonality of sales?
SELECT 
    DATENAME(MONTH, o.OrderDate) AS MonthName, 
    SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS TotalRevenue
FROM order_line_items oli
JOIN product p ON oli.ProductID = p.ProductID
JOIN orders o ON oli.OrderNumber = o.OrderNumber
GROUP BY DATENAME(MONTH, o.OrderDate)
ORDER BY TotalRevenue DESC;

SELECT 
    CASE
        WHEN MONTH(o.OrderDate) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(o.OrderDate) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(o.OrderDate) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(o.OrderDate) IN (9, 10, 11) THEN 'Autumn'
        ELSE 'Unknown'
    END AS Season,
    SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS TotalRevenue
FROM order_line_items oli
JOIN product p ON oli.ProductID = p.ProductID
JOIN orders o ON oli.OrderNumber = o.OrderNumber
GROUP BY 
    CASE
        WHEN MONTH(o.OrderDate) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(o.OrderDate) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(o.OrderDate) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(o.OrderDate) IN (9, 10, 11) THEN 'Autumn'
        ELSE 'Unknown'
    END
ORDER BY TotalRevenue DESC;

-- What are our top 5 stores?
SELECT TOP 5 
	s.StoreID, 
	s.StoreCountry, 
	s.StoreState, 
	SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS TotalRevenue
FROM order_line_items oli
JOIN orders o ON oli.OrderNumber = o.OrderNumber
JOIN store s ON o.StoreID = s.StoreID
JOIN product p ON oli.ProductID = p.ProductID
GROUP BY s.StoreID, 
	s.StoreCountry, 
	s.StoreState
ORDER BY 
	TotalRevenue DESC;

	-- What is the revenue per sq meter for each store?
SELECT 
    s.StoreID,
	s.StoreOpenDate,
    s.StoreSqMeters, 
    SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS TotalRevenue,
    (SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) * 1.0) / NULLIF(s.StoreSqMeters, 0) AS RevenuePerSqMeter
FROM order_line_items oli
JOIN orders o ON oli.OrderNumber = o.OrderNumber
JOIN store s ON o.StoreID = s.StoreID
JOIN product p ON oli.ProductID = p.ProductID
WHERE
	YEAR(o.OrderDate) = 2018
GROUP BY 
    s.StoreID,
	s.StoreOpenDate,
    s.StoreSqMeters
ORDER BY 
    RevenuePerSqMeter DESC;

-- Which stores have the highest number of unique customers?
SELECT s.StoreID, COUNT(DISTINCT(c.CustomerID)) AS UniqueCustomer
FROM store s
JOIN orders o ON s.StoreID = o.StoreID
JOIN customer c ON o.CustomerID = c.CustomerID
GROUP BY s.StoreID
ORDER BY UniqueCustomer DESC;

-- What is the average time between order date and delivery date?
SELECT AVG(DATEDIFF(DAY, OrderDate, DeliveryDate)) AS DaysUntilDelivery
FROM orders
WHERE DeliveryDate IS NOT NULL;

SELECT cg.CustomerCountry, 
	AVG(DATEDIFF(DAY, o.OrderDate, o.DeliveryDate)) AS DaysUntilDelivery,
	MIN(DATEDIFF(DAY, o.OrderDate, o.DeliveryDate)) AS MinDaysUntilDelivery,
	MAX(DATEDIFF(DAY, o.OrderDate, o.DeliveryDate)) AS MaxDaysUntilDelivery
FROM orders o
JOIN customer_geolocation cg ON c.CustomerGeoID = cg.CustomerGeoID
GROUP BY cg.CustomerCountry;

-- What are first month opening sales vs monthly average sales for each store?
WITH FirstOrderDate AS (
    SELECT 
        StoreID,
        MIN(OrderDate) AS FirstOrderDate
    FROM orders
    GROUP BY StoreID
),
First30DaysSales AS (
    SELECT 
        o.StoreID,
        SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS First30DaysRevenue
    FROM orders o
    JOIN order_line_items oli ON o.OrderNumber = oli.OrderNumber
    JOIN product p ON oli.ProductID = p.ProductID
    JOIN FirstOrderDate fod ON o.StoreID = fod.StoreID
    WHERE 
        o.OrderDate BETWEEN fod.FirstOrderDate AND DATEADD(DAY, 29, fod.FirstOrderDate)
    GROUP BY o.StoreID
),
MonthlyAverageSales AS (
    SELECT 
        StoreID,
        AVG(MonthlyRevenue) AS AvgMonthlyRevenue
    FROM (
        SELECT 
            o.StoreID,
            YEAR(o.OrderDate) AS SalesYear,
            MONTH(o.OrderDate) AS SalesMonth,
            SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS MonthlyRevenue
        FROM orders o
        JOIN order_line_items oli ON o.OrderNumber = oli.OrderNumber
        JOIN product p ON oli.ProductID = p.ProductID
        GROUP BY o.StoreID, YEAR(o.OrderDate), MONTH(o.OrderDate)
    ) AS MonthlySales
    GROUP BY StoreID
)
SELECT 
    f30.StoreID,
    f30.First30DaysRevenue,
    mas.AvgMonthlyRevenue
FROM First30DaysSales f30
JOIN MonthlyAverageSales mas ON f30.StoreID = mas.StoreID
ORDER BY f30.First30DaysRevenue DESC;