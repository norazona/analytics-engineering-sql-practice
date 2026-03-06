-- SQL Practice Using the AdventureWorksDW2022 database schema

-- SELECT & WHERE
-- 1.	Retrieve all columns from the DimCustomer table for customers in the United States.
SELECT *
FROM DimCustomer;

-- 2.	Find all products in DimProduct where the ListPrice is greater than $1000.
SELECT *
FROM DimProduct
WHERE ListPrice > 1000;

-- 3.	List all employees from DimEmployee who are currently employed (Status = 'Current').
SELECT *
FROM DimEmployee
WHERE Status = 'Current';

-- Aggregations & GROUP BY
-- 4.	Count the total number of customers in each country from DimCustomer.
SELECT 
	dg.EnglishCountryRegionName as Country,
	COUNT(dc.CustomerKey) AS TotalCustomers
FROM DimCustomer dc
INNER JOIN DimGeography dg
	ON dc.GeographyKey = dg.GeographyKey
GROUP BY dg.EnglishCountryRegionName;

-- 5.	Calculate the average ListPrice for products in each ProductSubcategoryKey from DimProduct.
SELECT 
	ProductSubcategoryKey,
	AVG(ListPrice) AS AvgListPrice
FROM DimProduct 
WHERE ProductSubcategoryKey IS NOT NULL
GROUP BY ProductSubcategoryKey;

-- 6.	Find the total SalesAmount by SalesTerritoryKey from FactInternetSales.
SELECT 
	SalesTerritoryKey,
	SUM(SalesAmount) AS TotalAmount
FROM FactInternetSales
GROUP BY SalesTerritoryKey;

-- JOINs
-- 7.	Join DimProduct and DimProductSubcategory to show ProductName and SubcategoryName.
SELECT 
	dp.EnglishProductName,
	dps.EnglishProductSubcategoryName
FROM DimProduct dp
INNER JOIN DimProductSubcategory dps
	ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey;

-- 8.	Connect FactInternetSales with DimCustomer to display customer names alongside their sales.
SELECT 
	dc.CustomerKey,
	CONCAT(dc.FirstName, ' ', dc.LastName) AS FullName,
	SUM(fis.SalesAmount) AS TotalAmount
FROM FactInternetSales fis
INNER JOIN DimCustomer dc
	ON fis.CustomerKey = dc.CustomerKey
GROUP BY 
	dc.CustomerKey,
	dc.FirstName,
	dc.LastName;

-- 9.	Create a query showing product sales with Product, Subcategory, and Category names (requires multiple joins).
SELECT 
	pc.EnglishProductCategoryName,
	sc.EnglishProductSubcategoryName,
	p.EnglishProductName,
	s.SalesAmount
FROM FactInternetSales s
INNER JOIN DimProduct p
	ON s.ProductKey = p.ProductKey
INNER JOIN DimProductSubcategory sc
	ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
INNER JOIN DimProductCategory pc
	ON sc.ProductCategoryKey = pc.ProductCategoryKey;

-- Filtering & Sorting
-- 10.	Find the top 10 products by total SalesAmount from FactInternetSales.
SELECT TOP 10
	p.EnglishProductName,
	SUM(s.SalesAmount) AS TotalAmount
FROM FactInternetSales s
INNER JOIN DimProduct p
	ON s.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY TotalAmount;

-- 11.	List all sales orders from FactInternetSales in 2013, ordered by OrderDate.
SELECT *
FROM FactInternetSales
WHERE DATEPART(year,OrderDate) = '2013';

-- 12.	Find customers whose LastName starts with 'S' and FirstName contains 'a'.
SELECT *
FROM DimCustomer
WHERE LastName LIKE 'S%'
AND FirstName LIKE '%a%';