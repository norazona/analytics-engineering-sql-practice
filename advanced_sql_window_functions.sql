-- ADVANCED SQL - Window Functions

USE WideWorldImportersDW;
-- ROW_NUMBER() 
-- 1. List all customers with a row number partitioned by their buying group, ordered by customer name within each group
SELECT 
	Customer,
	"Buying Group",
	ROW_NUMBER() OVER(PARTITION BY "Buying Group" ORDER BY Customer) AS row_num
FROM Dimension.Customer;

-- 2. Find the top 3 orders by total excluding tax for each salesperson in the Fact.Orders table
WITH rank_order AS (
	SELECT 
		[WWI Order ID] AS Order_ID,
		Quantity * [Unit Price] AS OrderTotal,
		ROW_NUMBER() OVER(ORDER BY Quantity * [Unit Price] DESC) AS Order_Rank
	FROM Fact.Orders
)
SELECT 
	Order_ID,
	OrderTotal,
	Order_Rank
FROM rank_order
WHERE Order_Rank <= 3;

-- RANK() and DENSE_RANK()
-- 3. Rank cities by their total sales amount (from Fact.Sale), showing both RANK() and DENSE_RANK() to see how they handle ties differently

WITH CitySales AS (
	SELECT 
		[City Key] as city_key,
		SUM([Total Excluding Tax]) AS total
	FROM Fact.Sale 
	GROUP BY [City Key]
)
SELECT 
	city_key,
	total,
	RANK() OVER(ORDER BY total DESC) AS SalesRank,
	DENSE_RANK() OVER(ORDER BY total DESC) AS DenseSalesRank
FROM CitySales
ORDER BY total DESC;

-- 4. Within each stock item, rank all sale transactions by quantity sold, using DENSE_RANK(). 
-- Show the stock item description, sale date, quantity, and rank
SELECT *
FROM Dimension.StockItem;

WITH StockItemSales AS (
	SELECT 
		[Stock Item Key] AS StockItemKey,
		[Invoice Date Key] AS InvoiceDate,
		Description,
		SUM(Quantity) as TotalQuantity
	FROM Fact.Sale
	GROUP BY [Stock Item Key], [Invoice Date Key], Description
)
SELECT
	s.StockItemKey,
	s.InvoiceDate,
	s.Description,
	s.TotalQuantity,
	DENSE_RANK() OVER(ORDER BY s.TotalQuantity DESC) AS Sales_Rank
FROM StockItemSales s;

-- ROW_NUMBER (De-duplication and Ordering)
-- 5. For each customer, assign a sequential number to their orders ordered by OrderDate.

WITH filtered_customers AS (
	SELECT 
		[Customer Key] AS CustomerKey,
		[Order Key] AS OrderKey,
		[Order Date Key] AS OrderDate
	FROM Fact.Orders
	-- Remove the Unknown Customers (Customer Key = 0)
	WHERE [Customer Key] <> 0
)
SELECT 
	CustomerKey,
	OrderKey,
	ROW_NUMBER() OVER(PARTITION BY CustomerKey ORDER BY OrderDate) AS row_num
FROM filtered_customers;

-- 6. Return only the first order for each customer
WITH removed_customers AS (
	SELECT 
		[Customer Key] AS CustomerKey,
		[Order Key] AS OrderKey,
		[Order Date Key] AS OrderDate
	FROM Fact.Orders
	-- Remove the Unknown Customers (Customer Key = 0)
	WHERE [Customer Key] <> 0
),
rn_customers AS (
	SELECT
		CustomerKey,
		OrderKey,
		OrderDate,
		ROW_NUMBER() OVER(PARTITION BY CustomerKey ORDER BY OrderDate ASC) as rn
	FROM removed_customers
)
SELECT 
	CustomerKey,
	OrderKey,
	OrderDate,
	rn
FROM rn_customers
WHERE rn = 1;

-- 7. For each stock item, return the most recent sale based on InvoiceDate.
WITH RankedSales AS (
	SELECT 
		s.[Stock Item Key] AS SaleStockItemKey,
		s.[Invoice Date Key] AS InvoiceDate,
		si.StockItem,
		s.Quantity,
		s.[Unit Price],
		s.[Total Excluding Tax],
		s.[Tax Amount],
		s.Profit,
		ROW_NUMBER() OVER(PARTITION BY si.[Stock Item Key] ORDER BY s.[Invoice Date Key] DESC) AS rn
	FROM Fact.Sale s
	INNER JOIN Dimension.StockItem si
		ON s.[Stock Item Key] = si.[Stock Item Key]
)
SELECT
	SaleStockItemKey,
	InvoiceDate,
	StockItem
FROM RankedSales
WHERE rn = 1;

-- RANK vs DENSE_RANK
/* 
8. Rank stock items by total quantity sold within each year.
Return: Year, StockItem, TotalQuantity, Rank  */

SELECT 
	s.[Stock Item Key] AS StockItemKey,
	d.[Calendar Year] AS Year,
	SUM(s.Quantity) AS TotalQuantity,
	RANK() OVER(PARTITION BY d.[Calendar Year] ORDER BY SUM(s.Quantity) DESC) AS Rank
FROM Fact.Sale s
INNER JOIN Dimension.StockItem si
	ON s.[Stock Item Key] = si.[Stock Item Key]
INNER JOIN Dimension.Date d
	ON s.[Invoice Date Key] = d.Date
GROUP BY 
	d.[Calendar Year],
	s.[Stock Item Key]
ORDER BY 
	Year,
	Rank;

-- 9. Show stock items where multiple items share the same revenue rank within a given year

SELECT
	s.[Stock Item Key] AS StockItemKey,
	d.[Calendar Year] AS Year,
	SUM(s.[Total Excluding Tax]) AS TotalRevenue,
	DENSE_RANK() OVER(PARTITION BY d.[Calendar Year] ORDER BY SUM(s.[Total Excluding Tax]) DESC) AS DenseRank
FROM Fact.Sale s
INNER JOIN Dimension.StockItem si
	ON s.[Stock Item Key] = si.[Stock Item Key]
INNER JOIN Dimension.Date d
	ON s.[Invoice Date Key] = d.Date
GROUP BY 
	s.[Stock Item Key],
	d.[Calendar Year]
ORDER BY 
	Year,
	DenseRank;

-- LAG and LEAD
-- 10. For each date: Show total daily sales amount, previous day's sales, day-over-day difference
SELECT
	[Invoice Date Key] AS Date,
	SUM([Total Excluding Tax]) AS Current_Day_Sales,
	LAG(SUM([Total Excluding Tax]), 1) OVER(ORDER BY [Invoice Date Key]) AS Previous_Day_Sales,
	SUM([Total Excluding Tax]) - LAG(SUM([Total Excluding Tax]), 1) OVER(ORDER BY [Invoice Date Key]) AS DoD_Difference
FROM Fact.Sale 
GROUP BY [Invoice Date Key];

-- 11. Calculate month-over-month sales growth percentage
-- Include: YearMonth, SalesAmount, PreviousMonthSales, GrowthPercentage
SELECT
	FORMAT([Invoice Date Key], 'yyyy-MM') AS YearMonth,
	SUM([Total Excluding Tax]) AS SalesAmount,
	LAG(SUM([Total Excluding Tax]), 1) OVER(ORDER BY FORMAT([Invoice Date Key], 'yyyy-MM')) AS PreviousMonthSales,
	((SUM([Total Excluding Tax]) - LAG(SUM([Total Excluding Tax]), 1) OVER(ORDER BY FORMAT([Invoice Date Key], 'yyyy-MM'))) /
		LAG(SUM([Total Excluding Tax]), 1) OVER(ORDER BY FORMAT([Invoice Date Key], 'yyyy-MM'))) * 100 AS GrowthPercentage
FROM Fact.Sale
GROUP BY FORMAT([Invoice Date Key], 'yyyy-MM');