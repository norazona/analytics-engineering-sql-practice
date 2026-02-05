-- BASIC SQL Practice

USE WideWorldImportersDW;

-- (Basic SELECT) Retrieve the names of all customers in the Customers table
SELECT Customer
FROM Dimension.Customer;

-- (Filtering) List all stock items that are currently marked as “ChillerStock” in Stock Items
SELECT *
FROM Dimension.[Stock Item]
WHERE [Is Chiller Stock] = 1;

-- (Sorting) Show the top 10 most expensive stock items by UnitPrice
SELECT *
FROM Dimension.[Stock Item]
ORDER BY [Unit Price] DESC;

-- (Simple JOIN) List all orders along with the customer name for each order
SELECT cus.Customer, *
FROM Fact.[Order] fo
JOIN Dimension.Customer cus
	ON fo.[Customer Key] = cus.[Customer Key]
WHERE cus.Customer <> 'Unknown';