-- Advanced SQL - Running Totals and Moving Averages

-- Running Totals
-- 1. Calculate a running total of sales within each year. Reset the running total at the start of each year.
SELECT 
    [Invoice Date Key],
    YEAR([Invoice Date Key]) AS SaleYear,
    SUM([Total Excluding Tax]) AS DailySales,
    SUM(SUM([Total Excluding Tax])) OVER (
        PARTITION BY YEAR([Invoice Date Key]) 
        ORDER BY [Invoice Date Key]
    ) AS RunningTotalByYear
FROM [Fact].[Sale]
GROUP BY [Invoice Date Key]
ORDER BY [Invoice Date Key];

-- 2. For each customer, calculate their lifetime cumulative sales ordered by invoice date.
SELECT
    [Customer Key],
    [Invoice Date Key] AS Date,
    SUM([Total Excluding Tax]) AS TotalSales,
    SUM(SUM([Total Excluding Tax])) OVER(PARTITION BY [Customer Key] ORDER BY [Invoice Date Key]) AS RunningTotal
FROM Fact.Sale
WHERE [Customer Key] <> 0 -- Exclude 'Unknown' Customers
GROUP BY [Customer Key], [Invoice Date Key]
ORDER BY [Customer Key], [Invoice Date Key];

-- Moving Averages and Rolling Metrics

-- 3. Calculate a 7-day moving average of daily sales
SELECT 
    [Invoice Date Key] AS Date,
    SUM([Total Excluding Tax]) AS DailySales,
    AVG(SUM([Total Excluding Tax])) OVER (ORDER BY [Invoice Date Key] 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS MovingAverage
FROM Fact.Sale
GROUP BY [Invoice Date Key];

-- 4. Calculate rolling 30-day revenue
SELECT 
    [Invoice Date Key] AS Date,
    SUM([Total Excluding Tax]) AS DailySales,
    SUM(SUM([Total Excluding Tax])) OVER (ORDER BY [Invoice Date Key]
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS RollingTotal_30Days
FROM Fact.Sale
GROUP BY [Invoice Date Key];

-- Query that accounts for days with no revenue and generates a complete daily calendar
WITH AllDates AS (
    -- Create complete date range
    SELECT TOP (DATEDIFF(DAY, 
                (SELECT MIN(CAST([Invoice Date Key] AS DATE)) 
                 FROM [Fact].[Sale] 
                 WHERE [Invoice Date Key] IS NOT NULL), 
                (SELECT MAX(CAST([Invoice Date Key] AS DATE)) 
                 FROM [Fact].[Sale] 
                 WHERE [Invoice Date Key] IS NOT NULL)) + 1)
        DATEADD(DAY, 
                ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1,
                (SELECT MIN(CAST([Invoice Date Key] AS DATE)) 
                 FROM [Fact].[Sale] 
                 WHERE [Invoice Date Key] IS NOT NULL)) AS CalendarDate
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
),
DailyRevenue AS (
    SELECT 
        CAST([Invoice Date Key] AS DATE) AS SaleDate,
        SUM([Total Including Tax]) AS DailyRevenue
    FROM [Fact].[Sale]
    WHERE [Invoice Date Key] IS NOT NULL
    GROUP BY CAST([Invoice Date Key] AS DATE)
)
SELECT 
    ad.CalendarDate,
    COALESCE(dr.DailyRevenue, 0) AS DailyRevenue,
    SUM(COALESCE(dr.DailyRevenue, 0)) OVER (
        ORDER BY ad.CalendarDate 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS Rolling30DayRevenue
FROM AllDates ad
LEFT JOIN DailyRevenue dr 
    ON ad.CalendarDate = dr.SaleDate
ORDER BY ad.CalendarDate;