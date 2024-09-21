use AdventureWorks2019


--1. Retrieve the top 5 products with the highest total quantity ordered
SELECT TOP 5 P.Name AS ProductName, SUM(SOD.OrderQty) AS TotalQuantityOrdered
FROM Production.Product P
JOIN Sales.SalesOrderDetail SOD ON P.ProductID = SOD.ProductID
GROUP BY P.Name
ORDER BY SUM(SOD.OrderQty) DESC;



--2. Find products that have not been ordered yet
SELECT P.Name AS ProductName
FROM Production.Product P
WHERE P.ProductID NOT IN (
						SELECT SOD.ProductID 
						FROM Sales.SalesOrderDetail SOD);



--3. List customers who have placed orders worth more than the average order total.
SELECT C.FirstName + ' ' + C.LastName AS CustomerName
FROM Sales.Customer CU
JOIN Person.Person C ON CU.PersonID = C.BusinessEntityID
WHERE CU.CustomerID IN (
    SELECT SOH.CustomerID 
    FROM Sales.SalesOrderHeader SOH
    WHERE SOH.TotalDue > (SELECT AVG(TotalDue) FROM Sales.SalesOrderHeader));



--4. Retrieve the name of the department with the most employees.
SELECT D.Name AS DepartmentName
FROM HumanResources.Department D
WHERE D.DepartmentID = (
    SELECT TOP 1 EDH.DepartmentID
    FROM HumanResources.EmployeeDepartmentHistory EDH
    GROUP BY EDH.DepartmentID
    ORDER BY COUNT(EDH.BusinessEntityID) DESC);



--5. Find the salesperson who made the highest total sales.
SELECT P.FirstName + ' ' + P.LastName AS SalesPersonName
FROM Sales.SalesPerson SP
JOIN Person.Person P ON SP.BusinessEntityID = P.BusinessEntityID
WHERE SP.BusinessEntityID = (
    SELECT  SOH.SalesPersonID
    FROM Sales.SalesOrderHeader SOH
    GROUP BY SOH.SalesPersonID
    ORDER BY SUM(SOH.TotalDue) DESC);



--6. List products whose prices are above the average price in their subcategory.
SELECT P.Name AS ProductName, P.ListPrice
FROM Production.Product P
WHERE P.ListPrice > (
    SELECT AVG(P2.ListPrice)
    FROM Production.Product P2
    WHERE P2.ProductSubcategoryID = P.ProductSubcategoryID);



--7.  Get the top 5 highest-selling products.
WITH ProductSales AS (
    SELECT P.ProductID, P.Name, SUM(SOD.OrderQty) AS TotalQuantity
    FROM Production.Product P
    JOIN Sales.SalesOrderDetail SOD ON P.ProductID = SOD.ProductID
    GROUP BY P.ProductID, P.Name)
SELECT TOP 5 Name, TotalQuantity
FROM ProductSales
ORDER BY TotalQuantity DESC;



--8. Retrieve products with prices higher than the average price.
WITH AvgPrice AS (
    SELECT AVG(ListPrice) AS AveragePrice
    FROM Production.Product)
SELECT P.Name, P.ListPrice
FROM Production.Product P, AvgPrice
WHERE P.ListPrice > AvgPrice.AveragePrice;



--9. Find salespeople with total sales above the company average.
WITH SalesData AS (
    SELECT SOH.SalesPersonID, SUM(SOH.TotalDue) AS TotalSales
    FROM Sales.SalesOrderHeader SOH
    GROUP BY SOH.SalesPersonID),
	AvgSales AS (
    SELECT AVG(TotalSales) AS AverageSales
    FROM SalesData)
SELECT P.FirstName + ' ' + P.LastName AS SalesPersonName, SD.TotalSales
FROM SalesData SD
JOIN Person.Person P ON SD.SalesPersonID = P.BusinessEntityID, AvgSales
WHERE SD.TotalSales > AvgSales.AverageSales;



--10.List departments with more than 10 employees.
WITH DepartmentCounts AS (
    SELECT EDH.DepartmentID, COUNT(EDH.BusinessEntityID) AS EmployeeCount
    FROM HumanResources.EmployeeDepartmentHistory EDH
    WHERE EDH.EndDate IS NULL
    GROUP BY EDH.DepartmentID)
SELECT D.Name AS DepartmentName, DC.EmployeeCount
FROM DepartmentCounts DC
JOIN HumanResources.Department D ON DC.DepartmentID = D.DepartmentID
WHERE DC.EmployeeCount > 10;



--11.List customers with the highest number of orders.
WITH CustomerOrderCounts AS (
    SELECT SOH.CustomerID, COUNT(SOH.SalesOrderID) AS OrderCount
    FROM Sales.SalesOrderHeader SOH
    GROUP BY SOH.CustomerID)
SELECT C.FirstName + ' ' + C.LastName AS CustomerName, CO.OrderCount
FROM CustomerOrderCounts CO
JOIN Person.Person C ON CO.CustomerID = C.BusinessEntityID
ORDER BY CO.OrderCount DESC;
