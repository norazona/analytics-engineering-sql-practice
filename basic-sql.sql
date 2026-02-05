-- BASIC SQL Practice

USE WideWorldImporters;

-- 1. Retrieve the names of all customers in the Customers table.
SELECT CustomerName
FROM Sales.Customers;

-- 2. List all stock items that are currently marked as “ChillerStock” in Warehouse.StockItems
SELECT *
FROM Warehouse.StockItems
WHERE IsChillerStock = 1;

-- 3. (Sorting) Show the top 10 most expensive stock items by UnitPrice
SELECT *
FROM Warehouse.StockItems
ORDER BY UnitPrice DESC;

-- 4. (Simple JOIN) List all orders along with the customer name for each order
SELECT sc.CustomerName, *
FROM Sales.Orders so
JOIN Sales.Customers sc
	ON so.CustomerID = sc.CustomerID;

-- 5. (Basic Aggregation) Count how many orders were placed in 2015
SELECT COUNT(OrderID) AS 'Total Orders'
FROM Sales.Orders
WHERE YEAR(OrderDate) = 2015; 

SELECT COUNT(OrderID) AS 'Total Orders'
FROM Sales.Orders;

-- INTERMEDIATE SQL

-- 6. (Multi-table JOIN) Find all orders that include stock items supplied by “Fabrikam, Inc.” (a supplier in Purchasing.Suppliers)
SELECT 
	so.OrderID,
	so.OrderDate,
	ol.Description,
	ol.Quantity,
	ol.UnitPrice,
	sup.SupplierName
FROM Sales.Orders so
JOIN Sales.OrderLines ol
	ON so.OrderID = ol.OrderID
JOIN Warehouse.StockItems si
	ON ol.StockItemID = si.StockItemID
JOIN Purchasing.Suppliers sup
	ON si.SupplierId = sup.SupplierID
WHERE sup.SupplierName = 'Fabrikam, Inc.';

-- 7. (GROUP BY with HAVING) Show customers who have placed more than 20 orders
SELECT
	sc.CustomerName,
	COUNT(so.OrderID) AS Total_Orders
FROM Sales.Customers sc
JOIN Sales.Orders so
	ON sc.CustomerID = so.CustomerID
GROUP BY sc.CustomerName
HAVING COUNT(so.OrderID) > 20
ORDER BY COUNT(so.OrderID) DESC;

-- 8. (Date Functions) List all orders placed on weekends
SELECT
	OrderID,
	OrderDate,
	DATENAME(weekday, OrderDate) AS weekday_dn,
	DATEPART(dw, OrderDate)
FROM Sales.Orders
-- Filter for only Saturday and Sunday
WHERE DATEPART(dw, OrderDate) IN (1,7);

-- 9. (Subqueries) Find stock items that have never been ordered
SELECT StockItemName
FROM Warehouse.StockItems
WHERE StockItemID IN (
	SELECT StockItemID
	FROM Sales.OrderLines
	WHERE OrderID IS NOT NULL);

-- 10. (Calculated Columns) For each order line, calculate the total line value (Quantity × UnitPrice) and return the top 20 highest‑value lines
SELECT TOP 20
	OrderLineID,
	Quantity * UnitPrice AS total_price
FROM Sales.OrderLines 
ORDER BY (Quantity * UnitPrice) DESC;

-- 11. (DISTINCT) List all distinct cities where customers are located
SELECT DISTINCT
	ac.CityName
FROM Sales.Customers sc
JOIN Application.Cities ac
	ON sc.PostalCityID = ac.CityID;