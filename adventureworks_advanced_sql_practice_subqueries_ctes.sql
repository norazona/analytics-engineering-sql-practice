-- AdventureWorksDW2022 Advanced SQL Questions - Subqueries and CTEs

-- Subqueries AND CTEs
-- 21.	Find customers whose total purchases exceed the average customer purchase amount.
SELECT
    CustomerKey,
    COUNT(*) AS TotalOrders,
    SUM(SalesAmount) AS TotalPurchases,
    AVG(SalesAmount) AS AvgOrderValue
FROM FactInternetSales
GROUP BY CustomerKey
HAVING SUM(SalesAmount) > (
    SELECT AVG(CustomerTotal)
    FROM (
        SELECT 
            CustomerKey,
            SUM(SalesAmount) AS CustomerTotal
        FROM FactInternetSales
        GROUP BY CustomerKey
    ) AS CustomerTotals
)
ORDER BY TotalPurchases DESC;

-- 22.	List products whose ListPrice is higher than the average ListPrice in their category.
WITH RefinedProducts AS (
    SELECT
        dp.ProductKey AS ProductKey,
        dp.EnglishProductName AS ProductName,
        dpc.ProductCategoryKey AS ProductCategoryKey,
        dpc.EnglishProductCategoryName AS ProductCategory,
        dp.ListPrice AS ListPrice
    FROM DimProduct dp
    INNER JOIN DimProductSubcategory dps
        ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey
    INNER JOIN DimProductCategory dpc
        ON dps.ProductCategoryKey = dpc.ProductCategoryKey
    WHERE ListPrice IS NOT NULL
),
AvgListPrice AS (
    SELECT
        ProductCategoryKey,
        AVG(ListPrice) AS AvgListPrice
    FROM RefinedProducts
    GROUP BY ProductCategoryKey
)
SELECT 
    ProductKey,
    ProductName,
    alp.ProductCategoryKey,
    ListPrice,
    AvgListPrice
FROM RefinedProducts rp
INNER JOIN AvgListPrice alp
    ON rp.ProductCategoryKey = alp.ProductCategoryKey
WHERE ListPrice > AvgListPrice
ORDER BY ProductKey;

-- 23.	Identify the top 5 sales days (by total SalesAmount) and show all transactions from those days.
WITH TopFiveSalesDays AS (
    SELECT TOP 5
        OrderDateKey,
        DATETRUNC(DAY,OrderDate) AS Day,
        SUM(SalesAmount) AS TotalSales
    FROM FactInternetSales
    GROUP BY DATETRUNC(DAY,OrderDate), OrderDateKey
    ORDER BY TotalSales DESC
)
SELECT 
    OrderDateKey,
    OrderDate,
    SalesOrderNumber,
    OrderQuantity,
    UnitPrice,
    SalesAmount,
    TaxAmt,
    Freight,
    ROUND((SalesAmount + TaxAmt + Freight), 2) AS TotalPrice
FROM FactInternetSales 
WHERE OrderDateKey IN (
    SELECT OrderDateKey FROM TopFiveSalesDays
);

-- 24.	Find products that have been sold more times than the median sales frequency across all products.


-- 25.	Show customers who purchased all products in a specific subcategory (relational division).


-- 26.	Use a CTE to calculate each customer's total purchases, then find customers in the top 10%.


-- 27.	Create a recursive CTE to show the employee hierarchy from DimEmployee.


-- 28.	Build a CTE that calculates year-over-year sales growth by product.


-- 29.	Use multiple CTEs to compare internet sales vs. reseller sales by territory.


-- 30.	Create a CTE to identify customers with gaps of more than 365 days between purchases.
