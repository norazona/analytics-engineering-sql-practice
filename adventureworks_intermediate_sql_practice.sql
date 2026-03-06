-- AdventureWorksDW2022 Intermediate SQL Questions

-- Advanced JOINs
-- 13.	Find all products that have never been sold (LEFT JOIN with FactInternetSales).
SELECT 
	p.ProductKey,
	p.EnglishProductName
FROM DimProduct p
LEFT JOIN FactInternetSales s
	ON p.ProductKey = s.ProductKey
WHERE s.ProductKey IS NULL;

-- 14.	Show customers who have made purchases in multiple years.
WITH multiple_years AS (
	SELECT 
		CustomerKey,
		DATEPART(year,OrderDate) AS Year,
		COUNT(SalesOrderNumber) AS TotalOrders,
		ROW_NUMBER() OVER (PARTITION BY CustomerKey ORDER BY DATEPART(year,OrderDate)) AS row_num
	FROM FactInternetSales
	GROUP BY CustomerKey, DATEPART(year,OrderDate)
)
SELECT 
	CustomerKey
FROM multiple_years
WHERE row_num > 1;

-- 15.	Display sales territories with no internet sales recorded.
SELECT
    st.SalesTerritoryKey,
    st.SalesTerritoryRegion,
    st.SalesTerritoryCountry,
    st.SalesTerritoryGroup
FROM DimSalesTerritory st
LEFT JOIN FactInternetSales s
	ON st.SalesTerritoryKey = s.SalesTerritoryKey
WHERE s.SalesTerritoryKey IS NULL;

-- CASE Statements
-- 16.	Categorize products as 'Budget' (< $500), 'Mid-Range' ($500-$1500), or 'Premium' (> $1500).
SELECT 
	ProductKey,
	EnglishProductName,
	CASE
		WHEN ListPrice < 500 THEN 'Budget'
		WHEN ListPrice > 500 AND ListPrice < 1501 THEN 'Mid-Range'
		WHEN ListPrice >= 1501 THEN 'Premium'
	END AS Budget
FROM DimProduct
WHERE ListPrice IS NOT NULL;

-- 17.	Create a customer segment based on total purchases: 
--		'High Value' (> $10,000), 'Medium Value' ($2,000-$10,000), 'Low Value' (< $2,000).
SELECT 
	CustomerKey,
	SUM(SalesAmount) AS Total,
	CASE 
		WHEN SUM(SalesAmount) > 10000 THEN 'High Value'
		WHEN SUM(SalesAmount) <= 10000 AND SUM(SalesAmount) >= 2000 THEN 'Medium Value'
		WHEN SUM(SalesAmount) < 2000 THEN 'Low Value'
	END AS CustomerValue
FROM FactInternetSales
GROUP BY CustomerKey;

-- Date Functions
-- 18.	Calculate the number of days between OrderDate and ShipDate in FactInternetSales.
SELECT 
	SalesOrderNumber,
	OrderDate,
	ShipDate,
	DATEDIFF(day, OrderDate, ShipDate) AS DaysBetween
FROM FactInternetSales;

-- 19.	Extract year, quarter, and month from OrderDate and aggregate sales accordingly.
SELECT
	OrderDate,
	DATEPART(year, OrderDate) AS Year,
	DATEPART(quarter, OrderDate) AS Quarter,
	DATEPART(month, OrderDate) AS Month,
	SUM(SalesAmount) AS TotalSales
FROM FactInternetSales
GROUP BY 
	OrderDate,
	DATEPART(year, OrderDate),
	DATEPART(quarter, OrderDate),
	DATEPART(month, OrderDate)
ORDER BY 
	Year,
	Quarter,
	Month
;

-- 20.	Find all sales that occurred on weekends.
SELECT 
	SalesOrderNumber,
	OrderDate,
	DATENAME(WEEKDAY, OrderDate) AS DayOfWeek,
	CustomerKey,
	ProductKey,
	SalesAmount,
	TaxAmt,
	Freight,
	SalesAmount + TaxAmt + Freight AS TotalRevenue
FROM FactInternetSales
WHERE DATENAME(WEEKDAY, OrderDate) IN ('Saturday','Sunday')
ORDER BY OrderDate;