
-- Customer Analysis:
-- This section focuses on customer demographics, behaviors, and engagement metrics.
-- It examines age distribution, gender split, regional concentration, purchase frequency, retention rates, and the mix of new vs. repeat customers.

USE sales_analysis;

-- What is the average, min, max age of our customers?
SELECT CustomerGender, 
	   AVG(DATEDIFF(YEAR, CustomerDOB, GETDATE())) AS AverageAge,
	   MIN(DATEDIFF(YEAR, CustomerDOB, GETDATE())) AS MinAge,
	   MAX(DATEDIFF(YEAR, CustomerDOB, GETDATE())) AS MaxAge
FROM customer
GROUP BY CustomerGender;

-- How many unique customers do we have?
SELECT DISTINCT COUNT(CustomerID) 
FROM customer;

-- Which states/regions do our customers live in most?
SELECT cg.CustomerState, COUNT(DISTINCT(c.CustomerID)) AS UniqueCustomer
FROM customer c
JOIN customer_geolocation cg ON c.CustomerGeoID = cg.CustomerGeoID
GROUP BY cg.CustomerState
ORDER BY UniqueCustomer DESC;

-- What is the distribution of customers by gender?
SELECT CustomerGender, COUNT(DISTINCT(CustomerID)) AS UniqueCustomer
FROM customer
GROUP BY CustomerGender
ORDER BY UniqueCustomer DESC;

-- What are the age groups who make the most purchases?
SELECT 
	CASE
		WHEN DATEDIFF(YEAR, c.CustomerDOB, GETDATE()) BETWEEN 18 AND 24 THEN '18 - 24'
		WHEN DATEDIFF(YEAR, c.CustomerDOB, GETDATE()) BETWEEN 25 AND 34 THEN '25 - 34'
		WHEN DATEDIFF(YEAR, c.CustomerDOB, GETDATE()) BETWEEN 35 AND 44 THEN '35 - 44'
		WHEN DATEDIFF(YEAR, c.CustomerDOB, GETDATE()) BETWEEN 45 AND 54 THEN '45 - 54'
		WHEN DATEDIFF(YEAR, c.CustomerDOB, GETDATE()) BETWEEN 55 AND 64 THEN '55 - 64'
		WHEN DATEDIFF(YEAR, c.CustomerDOB, GETDATE()) >= 65 THEN '65+'
		ELSE 'Unknown'
	END AS AgeGroup,
	SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS TotalRevenue
FROM order_line_items oli
JOIN orders o ON oli.OrderNumber = o.OrderNumber
JOIN customer c ON o.CustomerID = c.CustomerID
JOIN product p ON oli.ProductID = p.ProductID
GROUP BY
	CASE
		WHEN DATEDIFF(YEAR, c.CustomerDOB, GETDATE()) BETWEEN 18 AND 24 THEN '18 - 24'
		WHEN DATEDIFF(YEAR, c.CustomerDOB, GETDATE()) BETWEEN 25 AND 34 THEN '25 - 34'
		WHEN DATEDIFF(YEAR, c.CustomerDOB, GETDATE()) BETWEEN 35 AND 44 THEN '35 - 44'
		WHEN DATEDIFF(YEAR, c.CustomerDOB, GETDATE()) BETWEEN 45 AND 54 THEN '45 - 54'
		WHEN DATEDIFF(YEAR, c.CustomerDOB, GETDATE()) BETWEEN 55 AND 64 THEN '55 - 64'
		WHEN DATEDIFF(YEAR, c.CustomerDOB, GETDATE()) >= 65 THEN '65+'
		ELSE 'Unknown'
	END
ORDER BY TotalRevenue DESC;

-- What is the average time between a customers first and last purchase?
SELECT 
    AVG(DATEDIFF(DAY, FirstPurchase, LastPurchase)) AS AvgDaysBetweenPurchases
FROM (
    SELECT 
        CustomerID,
        MIN(OrderDate) AS FirstPurchase,
        MAX(OrderDate) AS LastPurchase
    FROM orders
    GROUP BY CustomerID
) AS CustomerPurchases;

-- What percentage of sales come from repeat customers vs. new customers?
WITH CustomerOrderCount AS (
    SELECT 
        o.CustomerID,
        COUNT(o.OrderNumber) AS OrderCount
    FROM orders o
    GROUP BY o.CustomerID
),
CustomerType AS (
    SELECT 
        CustomerID,
        CASE 
            WHEN OrderCount = 1 THEN 'New Customer'
            ELSE 'Repeat Customer'
        END AS CustomerStatus
    FROM CustomerOrderCount
)
SELECT 
    ct.CustomerStatus,
    SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) AS TotalRevenue,
    ROUND(
        (SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0)) * 100.0) / 
        SUM(SUM(COALESCE(oli.Quantity, 0) * COALESCE(p.ProductPrice, 0))) OVER (), 2
    ) AS PercentageOfSales
FROM CustomerType ct
JOIN orders o ON ct.CustomerID = o.CustomerID
JOIN order_line_items oli ON o.OrderNumber = oli.OrderNumber
JOIN product p ON oli.ProductID = p.ProductID
GROUP BY ct.CustomerStatus
ORDER BY PercentageOfSales DESC;

-- What is the average number of orders per customer?
SELECT 
    AVG(OrderCount) AS AvgOrdersPerCustomer
FROM (
    SELECT 
        CustomerID, 
        COUNT(OrderNumber) AS OrderCount
    FROM orders 
    GROUP BY CustomerID
) AS CustomerOrders;

-- What is the customer retention rate?
WITH CustomerYearlyOrders AS (
    SELECT 
        c.CustomerID,
        YEAR(o.OrderDate) AS OrderYear
    FROM orders o
    JOIN customer c ON o.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, YEAR(o.OrderDate)
),
RetainedCustomers AS (
    SELECT 
        c1.CustomerID,
        c1.OrderYear AS PreviousYear,
        c2.OrderYear AS CurrentYear
    FROM CustomerYearlyOrders c1
    JOIN CustomerYearlyOrders c2 
        ON c1.CustomerID = c2.CustomerID 
        AND c2.OrderYear = c1.OrderYear + 1
)
SELECT 
    rc.PreviousYear,
    COUNT(DISTINCT rc.CustomerID) AS RetainedCustomers,
    (SELECT COUNT(DISTINCT CustomerID) 
     FROM CustomerYearlyOrders 
     WHERE OrderYear = rc.PreviousYear) AS TotalCustomersPreviousYear,
    (COUNT(DISTINCT rc.CustomerID) * 100.0) / 
    (SELECT COUNT(DISTINCT CustomerID) 
     FROM CustomerYearlyOrders 
     WHERE OrderYear = rc.PreviousYear) AS RetentionRate
FROM RetainedCustomers rc
GROUP BY rc.PreviousYear
ORDER BY rc.PreviousYear;

-- What are my sales by gender?
SELECT c.CustomerGender, SUM(oli.Quantity * p.ProductPrice) AS OrderValue
FROM order_line_items oli
JOIN product p ON oli.ProductID = p.ProductID
JOIN orders o ON oli.OrderNumber = o.OrderNumber
JOIN customer c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerGender
ORDER BY OrderValue DESC;