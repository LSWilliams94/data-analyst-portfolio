USE sales_analysis;

--
-- Create a staging table to import CSV file
--

CREATE TABLE staging_sales(
	TransactionID VARCHAR(255),
	OrderNumber VARCHAR(255),
	LineItem VARCHAR(255),
	OrderDate VARCHAR(255),
	DeliveryDate VARCHAR(255),
	Quantity VARCHAR(255),
	CustomerID VARCHAR(255),
	CustomerGender VARCHAR(255),
	CustomerName VARCHAR(255),
	CustomerCity VARCHAR(255),
	CustomerStateCode VARCHAR(255),
	CustomerState VARCHAR(255),
	CustomerZip VARCHAR(255),
	CustomerCountry VARCHAR(255),
	CustomerContinent VARCHAR(255),
	CustomerDOB VARCHAR(255),
	StoreID VARCHAR(255),
	StoreCountry VARCHAR(255),
	StoreState VARCHAR(255),
	StoreSqMeters VARCHAR(255),
	StoreOpenDate VARCHAR(255),
	ProductID VARCHAR(255),
	ProductName VARCHAR(255),
	ProductBrand VARCHAR(255),
	ProductColor VARCHAR(255),
	ProductCost VARCHAR(255),
	ProductPrice VARCHAR(255),
	ProductSubcategoryID VARCHAR(255),
	ProductSubcategory VARCHAR(255),
	ProductCategoryID VARCHAR(255),
	ProductCategory VARCHAR(255)
);

--
-- Create a target table for cleaned data
--

CREATE TABLE transaction_data(
	TransactionID INT PRIMARY KEY,
	OrderNumber INT,
	LineItem INT,
	OrderDate DATE,
	DeliveryDate DATE,
	Quantity INT,
	CustomerID INT,
	CustomerGender VARCHAR(10),
	CustomerName VARCHAR(100),
	CustomerCity VARCHAR(50),
	CustomerStateCode VARCHAR(50),
	CustomerState VARCHAR(50),
	CustomerZip VARCHAR(50),
	CustomerCountry VARCHAR(50),
	CustomerContinent VARCHAR(50),
	CustomerDOB DATE,
	StoreID INT,
	StoreCountry VARCHAR(50),
	StoreState VARCHAR(50),
	StoreSqMeters INT,
	StoreOpenDate DATE,
	ProductID INT,
	ProductName VARCHAR(100),
	ProductBrand VARCHAR(50),
	ProductColor VARCHAR(50),
	ProductCost DECIMAL(10, 2),
	ProductPrice DECIMAL(10, 2),
	ProductSubcategoryID INT,
	ProductSubcategory VARCHAR(100),
	ProductCategoryID INT,
	ProductCategory VARCHAR(100)
);

--
-- Insert data into staging table
--

BULK INSERT staging_sales
FROM 'C:\Users\lksau\OneDrive\Documents\Data Analyst Portfolio\SQL\Transactions.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
);

--
-- Clean the data
--

UPDATE staging_sales
SET 
    ProductCost = TRY_CAST(REPLACE(REPLACE(ProductCost, '$', ''), ',', '') AS DECIMAL(10,2)),
    ProductPrice = TRY_CAST(REPLACE(REPLACE(ProductPrice, '$', ''), ',', '') AS DECIMAL(10,2)),
    OrderDate = TRY_CONVERT(DATE, OrderDate, 120),
    DeliveryDate = CASE WHEN DeliveryDate <> '' THEN TRY_CONVERT(DATE, DeliveryDate, 120) ELSE NULL END,
    CustomerDOB = TRY_CONVERT(DATE, CustomerDOB, 120),
    StoreOpenDate = TRY_CONVERT(DATE, StoreOpenDate, 120),
    Quantity = TRY_CAST(Quantity AS INT),
    StoreSqMeters = TRY_CAST(StoreSqMeters AS INT),
    ProductCategoryID = TRY_CAST(LTRIM(ProductCategoryID) AS INT),
    ProductSubcategoryID = TRY_CAST(LTRIM(ProductSubcategoryID) AS INT);

--
-- Check columns for dirtiness
--

SELECT -- Check for duplicates in TransactionID (primary key)
    TransactionID,  
    COUNT(TransactionID) AS DuplicateCount
FROM staging_sales
GROUP BY TransactionID
HAVING COUNT(TransactionID) > 1;

SELECT 'Min' AS ValueType, -- Check for any anomalies with min/max
	MIN(Quantity) AS Quantity,
	MIN(StoreSqMeters) AS StoreSqMeters,
	MIN(ProductCost) AS ProductCost,
	MIN(ProductPrice) AS ProductPrice
FROM staging_sales

UNION ALL

SELECT 'Max',
	MAX(Quantity) AS Quantity,
	MAX(StoreSqMeters) AS StoreSqMeters,
	MAX(ProductCost) AS ProductCost,
	MAX(ProductPrice) AS ProductPrice
FROM staging_sales;

SELECT DISTINCT CustomerGender -- Check if gender values are correct
FROM staging_sales;

--
-- Transfer cleaned data to target table
--

INSERT INTO transaction_data ( -- TEST WITH 10 ROWS
    TransactionID, OrderNumber, LineItem, OrderDate, DeliveryDate, Quantity, 
    CustomerID, CustomerGender, CustomerName, CustomerCity, CustomerStateCode, 
    CustomerState, CustomerZip, CustomerCountry, CustomerContinent, CustomerDOB, 
    StoreID, StoreCountry, StoreState, StoreSqMeters, StoreOpenDate, 
    ProductID, ProductName, ProductBrand, ProductColor, ProductCost, ProductPrice, 
    ProductSubcategoryID, ProductSubcategory, ProductCategoryID, ProductCategory
)
SELECT TOP 10
    TRY_CAST(TransactionID AS INT), 
    OrderNumber, LineItem, 
    TRY_CONVERT(DATE, OrderDate, 120), 
    TRY_CONVERT(DATE, DeliveryDate, 120), 
    TRY_CAST(Quantity AS INT), 
    TRY_CAST(CustomerID AS INT), 
    CustomerGender, CustomerName, 
    CustomerCity, CustomerStateCode, CustomerState, CustomerZip, 
    CustomerCountry, CustomerContinent, 
    TRY_CONVERT(DATE, CustomerDOB, 120), 
    TRY_CAST(StoreID AS INT), StoreCountry, StoreState, 
    TRY_CAST(StoreSqMeters AS INT), 
    TRY_CONVERT(DATE, StoreOpenDate, 120), 
    TRY_CAST(ProductID AS INT), ProductName, ProductBrand, ProductColor, 
    TRY_CAST(ProductCost AS DECIMAL(10,2)), 
    TRY_CAST(ProductPrice AS DECIMAL(10,2)), 
    TRY_CAST(ProductSubcategoryID AS INT), 
    ProductSubcategory, 
    TRY_CAST(ProductCategoryID AS INT), 
    ProductCategory
FROM staging_sales;

SELECT * FROM transaction_data;

INSERT INTO transaction_data ( -- MERGE REST OF DATA
    TransactionID, OrderNumber, LineItem, OrderDate, DeliveryDate, Quantity, 
    CustomerID, CustomerGender, CustomerName, CustomerCity, CustomerStateCode, 
    CustomerState, CustomerZip, CustomerCountry, CustomerContinent, CustomerDOB, 
    StoreID, StoreCountry, StoreState, StoreSqMeters, StoreOpenDate, 
    ProductID, ProductName, ProductBrand, ProductColor, ProductCost, ProductPrice, 
    ProductSubcategoryID, ProductSubcategory, ProductCategoryID, ProductCategory
)
SELECT 
    TRY_CAST(TransactionID AS INT), 
    OrderNumber, LineItem, 
    TRY_CONVERT(DATE, OrderDate, 120), 
    TRY_CONVERT(DATE, DeliveryDate, 120), 
    TRY_CAST(Quantity AS INT), 
    TRY_CAST(CustomerID AS INT), 
    CustomerGender, CustomerName, 
    CustomerCity, CustomerStateCode, CustomerState, CustomerZip, 
    CustomerCountry, CustomerContinent, 
    TRY_CONVERT(DATE, CustomerDOB, 120), 
    TRY_CAST(StoreID AS INT), StoreCountry, StoreState, 
    TRY_CAST(StoreSqMeters AS INT), 
    TRY_CONVERT(DATE, StoreOpenDate, 120), 
    TRY_CAST(ProductID AS INT), ProductName, ProductBrand, ProductColor, 
    TRY_CAST(ProductCost AS DECIMAL(10,2)), 
    TRY_CAST(ProductPrice AS DECIMAL(10,2)), 
    TRY_CAST(ProductSubcategoryID AS INT), 
    ProductSubcategory, 
    TRY_CAST(ProductCategoryID AS INT), 
    ProductCategory
FROM staging_sales s
WHERE NOT EXISTS (
    SELECT 1 FROM transaction_data t 
    WHERE s.TransactionID = t.TransactionID
);

SELECT COUNT(*) FROM staging_sales; --- Check if all rows transferred successfully
SELECT COUNT(*) FROM transaction_data;

TRUNCATE TABLE staging_sales; -- REMOVE ALL ROWS FROM STAGING TABLE

--
-- Feature Engineering
--

ALTER TABLE transaction_data
ADD  ProfitMargin DECIMAL(10, 2), 
	 OrderValue DECIMAL(10, 2),
	 Profit DECIMAL(10,2);

UPDATE transaction_data
SET
	Profit = (ProductPrice - ProductCost) * Quantity,
	ProfitMargin = (ProductPrice - ProductCost) / ProductPrice * 100,
	OrderValue = Quantity * ProductPrice;

ALTER TABLE transaction_data
ADD StoreTier VARCHAR(20);

UPDATE transaction_data
SET StoreTier =
	CASE
		WHEN StoreSqMeters >= 1500 THEN 'Flagship'
		WHEN StoreSqMeters BETWEEN 1000 AND 1499 THEN 'Large'
		WHEN StoreSqMeters BETWEEN 500 AND 999 THEN 'Medium'
		WHEN StoreSqMeters BETWEEN 100 AND 499 THEN 'Small'
		WHEN StoreSqMeters > 0 AND StoreSqMeters < 100 THEN 'Kiosk'
		WHEN StoreSqMeters = 0 THEN 'Online'
		ELSE 'Unknown'
	END;

--
-- Normalise the data
--

CREATE TABLE customer
(
	CustomerID INT NOT NULL PRIMARY KEY,
	CustomerGender VARCHAR(10) NOT NULL,
	CustomerName VARCHAR(100) NOT NULL,
	CustomerCity VARCHAR(50) NOT NULL,
	CustomerStateCode VARCHAR(50) NOT NULL,
	CustomerState VARCHAR(50) NOT NULL,
	CustomerZip VARCHAR(50) NOT NULL,
	CustomerCountry VARCHAR(50) NOT NULL,
	CustomerContinent VARCHAR(50) NOT NULL,
	CustomerDOB DATE NOT NULL
);

CREATE TABLE store
(
	StoreID INT NOT NULL PRIMARY KEY,
	StoreCountry VARCHAR(50) NOT NULL,
	StoreState VARCHAR(50) NOT NULL,
	StoreSqMeters INT NOT NULL,
	StoreOpenDate DATE NOT NULL
);

CREATE TABLE product_category
(
	ProductCategoryID INT NOT NULL PRIMARY KEY,
	ProductCategory VARCHAR(100) NOT NULL
);

CREATE TABLE product_subcategory
(
	ProductSubcategoryID INT NOT NULL PRIMARY KEY,
	ProductSubcategory VARCHAR(100) NOT NULL,
	ProductCategoryID INT NOT NULL,
	FOREIGN KEY (ProductCategoryID) REFERENCES product_category(ProductCategoryID)
);

CREATE TABLE product
(
	ProductID INT NOT NULL PRIMARY KEY,
	ProductName VARCHAR(100) NOT NULL,
	ProductBrand VARCHAR(50) NOT NULL,
	ProductColor VARCHAR(50) NOT NULL,
	ProductCost DECIMAL(10, 2) NOT NULL,
	ProductPrice DECIMAL(10, 2) NOT NULL,
	ProductSubcategoryID INT NOT NULL,
	FOREIGN KEY (ProductSubcategoryID) REFERENCES product_subcategory(ProductSubcategoryID)
);

CREATE TABLE orders
(
	OrderNumber INT NOT NULL PRIMARY KEY,
	OrderDate DATE NOT NULL,
	DeliveryDate DATE NULL,
	CustomerID INT NOT NULL,
	StoreID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES customer(CustomerID),
    FOREIGN KEY (StoreID) REFERENCES store(StoreID)
);	

CREATE TABLE order_line_items
(
    TransactionID INT NOT NULL PRIMARY KEY,
    OrderNumber INT NOT NULL,
    LineItem INT NOT NULL,
    Quantity INT NOT NULL,
    ProductID INT NOT NULL,
    FOREIGN KEY (OrderNumber) REFERENCES orders(OrderNumber),
    FOREIGN KEY (ProductID) REFERENCES product(ProductID)
);

CREATE TABLE product_colour (
	ProductColorID INT PRIMARY KEY IDENTITY(1, 1),
	ProductColor VARCHAR(50) NOT NULL
);

CREATE TABLE product_brand (
	ProductBrandID INT PRIMARY KEY IDENTITY(1, 1),
	ProductBrand VARCHAR(50) NOT NULL
);

CREATE TABLE customer_geolocation (
	CustomerGeoID INT PRIMARY KEY IDENTITY(1, 1),
	CustomerZip VARCHAR(20) NOT NULL,
	CustomerCity VARCHAR(50) NOT NULL,
	CustomerStateCode VARCHAR(50) NOT NULL,
	CustomerState VARCHAR(50) NOT NULL,
	CustomerCountry VARCHAR(50) NOT NULL,
	CustomerContinent VARCHAR(50) NOT NULL
);

--
-- Populate tables
--

INSERT INTO product_category (ProductCategoryID, ProductCategory)
SELECT DISTINCT
    ProductCategoryID,
    ProductCategory
FROM transaction_data;

INSERT INTO product_subcategory (ProductSubcategoryID, ProductSubcategory, ProductCategoryID)
SELECT DISTINCT
    ProductSubcategoryID,
    ProductSubcategory,
	ProductCategoryID
FROM transaction_data;

INSERT INTO product (ProductID, ProductName, ProductBrand, ProductColor, ProductCost, ProductPrice, ProductSubcategoryID)
SELECT DISTINCT
    ProductID,
    ProductName,
	ProductBrand,
	ProductColor,
	ProductCost,
	ProductPrice,
	ProductSubcategoryID
FROM transaction_data;

INSERT INTO store (StoreID, StoreCountry, StoreState, StoreSqMeters, StoreOpenDate)
SELECT DISTINCT
    StoreID,
    StoreCountry,
	StoreState,
	StoreSqMeters,
	StoreOpenDate
FROM transaction_data;

INSERT INTO customer (CustomerID, CustomerGender, CustomerName, CustomerCity, CustomerStateCode, CustomerState, CustomerZip, CustomerCountry, CustomerContinent, CustomerDOB)
SELECT DISTINCT
    CustomerID,
    CustomerGender,
	CustomerName,
	CustomerCity,
	CustomerStateCode,
	CustomerState,
	CustomerZip,
	CustomerCountry,
	CustomerContinent,
	CustomerDOB
FROM transaction_data;

INSERT INTO orders (OrderNumber, OrderDate, DeliveryDate, CustomerID, StoreID)
SELECT DISTINCT
    OrderNumber,
    OrderDate,
	DeliveryDate,
	CustomerID,
	StoreID
FROM transaction_data;

INSERT INTO order_line_items (TransactionID, OrderNumber, LineItem, Quantity, ProductID)
SELECT DISTINCT
    TransactionID,
    OrderNumber,
	LineItem,
	Quantity,
	ProductID
FROM transaction_data;

INSERT INTO product_colour (ProductColor)
SELECT DISTINCT ProductColor
FROM transaction_data;

INSERT INTO product_brand (ProductBrand)
SELECT DISTINCT ProductBrand
FROM transaction_data;

INSERT INTO customer_geolocation(CustomerZip, CustomerCity, CustomerStateCode, CustomerState, CustomerCountry, CustomerContinent)
SELECT DISTINCT
    CustomerZip,
    CustomerCity,
	CustomerStateCode,
	CustomerState,
	CustomerCountry,
	CustomerContinent
FROM customer;

ALTER TABLE product
ADD ProductBrandID INT,
	ProductColorID INT;

UPDATE p
SET p.ProductBrandID = pb.ProductBrandID
FROM product p
JOIN product_brand pb ON p.ProductBrand = pb.ProductBrand;

UPDATE p
SET p.ProductColorID = pb.ProductColorID
FROM product p
JOIN product_colour pb ON p.ProductColor = pb.ProductColor;

ALTER TABLE product
ADD CONSTRAINT FK_ProductBrand FOREIGN KEY (ProductBrandID) REFERENCES product_brand(ProductBrandID),
	CONSTRAINT FK_ProductColor FOREIGN KEY (ProductColorID) REFERENCES product_colour(ProductColorID);

ALTER TABLE product
DROP COLUMN ProductColor, ProductBrand;

ALTER TABLE store
ADD StoreTier VARCHAR(20);

UPDATE store
SET StoreTier =
	CASE
		WHEN StoreSqMeters >= 1500 THEN 'Flagship'
		WHEN StoreSqMeters BETWEEN 1000 AND 1499 THEN 'Large'
		WHEN StoreSqMeters BETWEEN 500 AND 999 THEN 'Medium'
		WHEN StoreSqMeters BETWEEN 100 AND 499 THEN 'Small'
		WHEN StoreSqMeters > 0 AND StoreSqMeters < 100 THEN 'Kiosk'
		WHEN StoreSqMeters = 0 THEN 'Online'
		ELSE 'Unknown'
	END;

ALTER TABLE customer
ADD CustomerGeoID INT FOREIGN KEY REFERENCES customer_geolocation(CustomerGeoID);

ALTER TABLE customer
DROP COLUMN CustomerCity, CustomerStateCode, CustomerState, CustomerZip, CustomerCountry, CustomerContinent;

SELECT * FROM product WHERE ProductSubcategoryID NOT IN (SELECT ProductSubcategoryID FROM product_subcategory);
SELECT * FROM orders WHERE CustomerID NOT IN (SELECT CustomerID FROM customer);
SELECT * FROM order_line_items WHERE ProductID NOT IN (SELECT ProductID FROM product);

--
-- Create indexes to speed up query performance
--

-- Indexes for frequently queried columns
CREATE NONCLUSTERED INDEX idx_product_category ON product_category(ProductCategory);
CREATE NONCLUSTERED INDEX idx_customer_city ON customer_geolocation(CustomerCity);
CREATE NONCLUSTERED INDEX idx_customer_name ON customer(CustomerName);
CREATE NONCLUSTERED INDEX idx_order_date ON orders(OrderDate);
CREATE NONCLUSTERED INDEX idx_product_name ON product(ProductName);

-- Composite index
CREATE NONCLUSTERED INDEX idx_orders_city_date ON orders(OrderDate, StoreID);

