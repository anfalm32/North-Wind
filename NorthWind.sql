select * from Categories
select * from CustomerCustomerDemo 
select * from CustomerDemographics 
select * from Customers
select * from Employees
select * from EmployeeTerritories
select * from [Order Details]
select * from Orders
select * from Products
select * from Region
select * from Shippers
select * from Suppliers
select * from Territories;
--------------------------------------------------------------------------
SELECT P.ProductName, 
       SUM(OD.Quantity * OD.UnitPrice) AS TotalRevenue
FROM dbo.[Order Details] AS OD
JOIN dbo.Products AS P ON OD.ProductID = P.ProductID
GROUP BY P.ProductName
ORDER BY TotalRevenue DESC;
---------------------------------------------------------------------------
SELECT C.CustomerID, C.CompanyName, 
       SUM(OD.Quantity * OD.UnitPrice) AS TotalSpend
FROM dbo.Orders AS O
JOIN dbo.[Order Details] AS OD ON O.OrderID = OD.OrderID
JOIN dbo.Customers AS C ON O.CustomerID = C.CustomerID
GROUP BY C.CustomerID, C.CompanyName
ORDER BY TotalSpend DESC;
----------------------------------------------------------------------------
WITH CustomerProductSales AS (
    SELECT C.CustomerID, C.CompanyName, P.ProductName,
           SUM(OD.Quantity * OD.UnitPrice) AS TotalSpend,
           SUM(OD.Quantity) AS TotalQuantity,
           ROW_NUMBER() OVER (PARTITION BY C.CustomerID ORDER BY SUM(OD.Quantity) DESC) AS RowNum
    FROM dbo.Orders AS O
    JOIN dbo.[Order Details] AS OD ON O.OrderID = OD.OrderID
    JOIN dbo.Customers AS C ON O.CustomerID = C.CustomerID
    JOIN dbo.Products AS P ON OD.ProductID = P.ProductID
    GROUP BY C.CustomerID, C.CompanyName, P.ProductName
)
SELECT CustomerID, CompanyName, ProductName, TotalSpend, TotalQuantity
FROM CustomerProductSales
WHERE RowNum = 1
ORDER BY TotalSpend DESC;
-------------------------------------------------------------------------
SELECT E.EmployeeID,E.FirstName +' '+ E.LastName As [Full Name],
       COUNT(O.OrderID) AS TotalOrders
FROM dbo.Orders AS O
JOIN dbo.Employees AS E ON O.EmployeeID = E.EmployeeID
GROUP BY E.EmployeeID, E.LastName, E.FirstName
ORDER BY TotalOrders DESC;
----------------------------------------------------------------------
SELECT E.EmployeeID, E.FirstName +' '+ E.LastName As [Full Name], 
       SUM(OD.Quantity * OD.UnitPrice) AS TotalSales
FROM dbo.Orders AS O
JOIN dbo.[Order Details] AS OD ON O.OrderID = OD.OrderID
JOIN dbo.Employees AS E ON O.EmployeeID = E.EmployeeID
GROUP BY E.EmployeeID, E.LastName, E.FirstName
ORDER BY TotalSales DESC;
---------------------------------------------------------------------
SELECT YEAR(O.OrderDate) AS OrderYear, 
       MONTH(O.OrderDate) AS OrderMonth,
       SUM(OD.Quantity * OD.UnitPrice) AS TotalSales
FROM dbo.Orders AS O
JOIN dbo.[Order Details] AS OD ON O.OrderID = OD.OrderID
GROUP BY YEAR(O.OrderDate), MONTH(O.OrderDate)
ORDER BY OrderYear, OrderMonth
----------------------------------------------------------------------
SELECT S.CompanyName, O.ShipCountry,
       AVG(DATEDIFF(DAY, O.OrderDate, O.ShippedDate)) AS AvgShippingTime,
	   Avg(O.Freight) As AvgFreight
FROM dbo.Orders AS O
JOIN dbo.Shippers AS S ON O.ShipVia = S.ShipperID
WHERE O.ShippedDate IS NOT NULL
GROUP BY S.CompanyName, O.ShipCountry
ORDER BY S.CompanyName, AvgShippingTime ASC;
-------------------------------------------------------------------------
SELECT P.ProductName, 
       SUM((OD.UnitPrice - P.UnitPrice) * OD.Quantity) AS TotalProfit
FROM dbo.[Order Details] AS OD
JOIN dbo.Products AS P ON OD.ProductID = P.ProductID
GROUP BY P.ProductName
ORDER BY TotalProfit DESC;
----------------------------------------------------------------------------
SELECT 
    o.OrderID,
    o.OrderDate,
    o.RequiredDate,
    o.ShippedDate,
    CASE 
        WHEN o.ShippedDate > o.RequiredDate THEN 'Late'
        WHEN o.ShippedDate IS NULL THEN 'Cancelled'
        ELSE 'On Time'
    END AS OrderStatus
FROM 
    Orders o;
------------------------------------------------------------------------------
