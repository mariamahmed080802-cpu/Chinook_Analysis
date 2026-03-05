USE Chinook


SELECT * 
FROM MediaType

SELECT COUNT(State)
FROM Customer
WHERE State IS NULL 


SELECT State ,COUNT(*)
FROM Customer
group by State


------------------------------------------------------------------------------------------------------------------------------------------------
-- Executive Sales Overview

-- What is the total revenue

SELECT SUM(TOTAL) AS TOTAL_REVENUE
FROM Invoice


-- How many units were sold 

SELECT SUM(Quantity) AS TOTAL_UNITS
FROM InvoiceLine



-- What is the Average Order Value (AOV)

SELECT ROUND(SUM(Total) / COUNT(InvoiceId), 2) AS AOV
FROM Invoice 

-----------------------------------------------------------------------------------------------------------------------

-- Product Performance Analysis


-- What are the top selling tracks by revenue and quantity
-- there are 102 tracks are the highest for both revenue and quantity 

SELECT  
    T.TrackId,
    T.Name AS TRACK_NAME,
    A.Name AS ARTIST_NAME,
    SUM(I.Quantity * I.UnitPrice) AS REVENUE,
    DENSE_RANK() OVER(ORDER BY SUM(I.Quantity * I.UnitPrice) DESC) AS REVENUE_RNK, 
    SUM(I.Quantity) AS QUANTITY ,
    DENSE_RANK() OVER(ORDER BY SUM(I.Quantity) DESC) AS QUANTITY_RNK


FROM Track AS T 
JOIN  InvoiceLine AS I 
ON T.TrackId = I.TrackId
JOIN Album AS AL 
ON T.AlbumId = AL.AlbumId
JOIN Artist AS A 
ON A.ArtistId = AL.ArtistId
GROUP BY T.TrackId,  T.Name, A.Name, T.UnitPrice
ORDER BY REVENUE DESC




-- Which Artist generates the most revenue
-- The Artist with the most revenue doesn't have the top selling tracks
SELECT  
    A.Name AS ARTIST_NAME,
    SUM(I.Quantity * I.UnitPrice) AS REVENUE,
    DENSE_RANK() OVER(ORDER BY SUM(I.Quantity * I.UnitPrice) DESC) AS REVENUE_RNK 

FROM Track AS T 
JOIN  InvoiceLine AS I 
ON T.TrackId = I.TrackId
JOIN Album AS AL 
ON T.AlbumId = AL.AlbumId
JOIN Artist AS A 
ON A.ArtistId = AL.ArtistId
GROUP BY A.ArtistId, A.Name
ORDER BY REVENUE DESC




-- Which Genres contribute the highest sales 
-- ROCK contributes the highest sales with a huge difference 
SELECT 
    G.GenreId, 
    G.Name AS GENRE_NAME,
    SUM(I.Quantity * I.UnitPrice) AS REVENUE
FROM InvoiceLine AS I 
JOIN Track AS T 
ON T.TrackId = I.TrackId
JOIN Genre AS G 
ON T.GenreId = G.GenreId

GROUP BY G.GenreId, G.Name 
ORDER BY REVENUE DESC




-- Which genres contribute the highest sales
-- MPEG audio file contributes the highest sales, and Purchased AAC audio file and AAC audio file make no sales

SELECT 
    M.MediaTypeId, 
    M.Name AS MediaType_NAME,
    SUM(I.Quantity * I.UnitPrice) AS REVENUE
FROM InvoiceLine AS I 
JOIN Track AS T 
ON T.TrackId = I.TrackId
JOIN MediaType AS M
ON T.MediaTypeId = M.MediaTypeId

GROUP BY M.MediaTypeId, M.Name 
ORDER BY REVENUE DESC




-- Check Pareto Principle
-- 81% of Sales come from 6 Genre

WITH GenreRevenue AS (
    SELECT 
        G.Name AS GenreName,
        SUM(I.Quantity * I.UnitPrice) AS Revenue
    FROM InvoiceLine I
    JOIN Track T ON T.TrackId = I.TrackId
    JOIN Genre G ON T.GenreId = G.GenreId
    GROUP BY G.Name
),
RevenueCumulative AS (
    SELECT 
        GenreName,
        Revenue,
        SUM(Revenue) OVER (ORDER BY Revenue DESC) AS CumulativeRevenue
    FROM GenreRevenue
)
SELECT 
    GenreName,
    Revenue,
    CumulativeRevenue,
    CumulativeRevenue * 100.0 / SUM(Revenue) OVER() AS CumulativePercentage
FROM RevenueCumulative
ORDER BY Revenue DESC




-- Genres with sales less than 5%
WITH GenreRevenue AS (
    SELECT 
        G.Name AS GenreName,
        SUM(I.Quantity * I.UnitPrice) AS Revenue
    FROM InvoiceLine I
    JOIN Track T ON T.TrackId = I.TrackId
    JOIN Genre G ON T.GenreId = G.GenreId
    GROUP BY G.Name
),
RevenueWithPercentage AS (
    SELECT 
        GenreName,
        Revenue,
        Revenue * 100.0 / SUM(Revenue) OVER() AS RevenuePercentage
    FROM GenreRevenue
)
SELECT 
    GenreName,
    Revenue,
    RevenuePercentage
FROM RevenueWithPercentage
WHERE RevenuePercentage < 5
ORDER BY RevenuePercentage ASC



---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Geographic & Market Expansion Analysis

-- Revenue by Country 
-- USA and Canda are the top 2

SELECT
    C.Country, 
    SUM(I.Total) AS Revenue
FROM Customer AS C
JOIN Invoice AS I
ON C.CustomerId = I.CustomerId
GROUP BY C.Country
ORDER BY Revenue DESC


-- Problem Statement: We’ve just signed a deal with a new boutique label that specializes in Jazz, Blues, Pop, and Rock. We have budget to promote three of these four genres in the USA.
-- The highest sales genres in USA 
-- Rock is the highest sales genre in USA 
-- From those four genres, the highest 3 are Rock, Jazz, and Blues otherwise the revenue of Jazz and Blues is weak

SELECT 
    G.Name, 
    SUM(Il.Quantity * IL.UnitPrice) AS Revenue
FROM Customer AS C
JOIN Invoice AS I
ON C.CustomerId = I.CustomerId
JOIN InvoiceLine AS IL
ON IL.InvoiceId = I.InvoiceId
JOIN Track AS T 
ON T.TrackId = IL.TrackId 
JOIN Genre AS G
ON G.GenreId = T.GenreId
WHERE C.Country = 'USA' AND G.Name IN ('Rock','Pop','Blues','Jazz')
GROUP BY G.Name
ORDER BY Revenue DESC 




-- How does USA genre distribution compare globally

WITH USA_Genre AS (
    SELECT 
        g.Name AS Genre,
        SUM(il.UnitPrice * il.Quantity) AS USA_Revenue
    FROM InvoiceLine il
    JOIN Invoice i ON il.InvoiceId = i.InvoiceId
    JOIN Customer c ON i.CustomerId = c.CustomerId
    JOIN Track t ON il.TrackId = t.TrackId
    JOIN Genre g ON t.GenreId = g.GenreId
    WHERE c.Country = 'USA'
    GROUP BY g.Name
),
Global_Genre AS (
    SELECT 
        g.Name AS Genre,
        SUM(il.UnitPrice * il.Quantity) AS Global_Revenue
    FROM InvoiceLine il
    JOIN Track t ON il.TrackId = t.TrackId
    JOIN Genre g ON t.GenreId = g.GenreId
    GROUP BY g.Name
)

SELECT 
    u.Genre,
    u.USA_Revenue,
    g.Global_Revenue,
    ROUND(u.USA_Revenue * 100.0 / SUM(u.USA_Revenue) OVER (), 2) AS USA_Percentage,
    ROUND(g.Global_Revenue * 100.0 / SUM(g.Global_Revenue) OVER (), 2) AS Global_Percentage,
    ROUND(
        (u.USA_Revenue * 100.0 / SUM(u.USA_Revenue) OVER ()) -
        (g.Global_Revenue * 100.0 / SUM(g.Global_Revenue) OVER ()),
        2
    ) AS Percentage_Difference
FROM USA_Genre u
JOIN Global_Genre g ON u.Genre = g.Genre
ORDER BY Percentage_Difference DESC



----------------------------------------------------------------------------------------------------------------
-- Customer Behavior Analysis

-- Revenue per Customer 

SELECT
    C.CustomerId,
    C.FirstName + ' ' + C.LastName AS Customer_Name, 
    SUM(Total) AS Revenue
FROM Customer AS C 
JOIN Invoice AS I 
ON C.CustomerId = I.CustomerId
GROUP BY C.CustomerId, C.FirstName, C.LastName
ORDER BY Revenue DESC


-- Top Cutomers by Country 
-- Czech Republic has the highest revenue 

WITH Customer_Revenue AS (
SELECT 
    C.Country, 
    C.CustomerId, 
    C.FirstName + ' ' + C.LastName AS Customer_Name, 
    SUM(I.Total) AS Revenue
FROM Customer AS C 
JOIN Invoice AS I 
ON C.CustomerId = I.CustomerId
GROUP BY 
    C.Country, 
    C.CustomerId, 
    C.FirstName, C.LastName
), 

Top_Customers AS 
( 
SELECT Country, Customer_Name, Revenue, DENSE_RANK() OVER(PARTITION BY Country ORDER BY Revenue DESC) AS RNK
FROM Customer_Revenue
)

SELECT * 
FROM Top_Customers
WHERE RNK = 1
ORDER BY Revenue DESC



-- Repeat Purchase Rate 
-- All customers in the dataset made more than one purchase, indicating strong customer retention behavior 
WITH Customer_Purchases AS (
    SELECT 
        CustomerId,
        COUNT(InvoiceId) AS Purchase_Count
    FROM Invoice
    GROUP BY CustomerId
)
SELECT 
    SUM(CASE WHEN Purchase_Count = 1 THEN 1 ELSE 0 END) AS One_Time_Customers,
    SUM(CASE WHEN Purchase_Count >= 2 THEN 1 ELSE 0 END) AS Repeat_Customers,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Purchase_Count >= 2 THEN 1 ELSE 0 END) * 1.0 * 100 
        / COUNT(*) AS Repeat_Purchase_Rate
FROM Customer_Purchases


-- Customer Lifetime Value

WITH CustomerLifespan AS (
    SELECT 
        CustomerId,
        DATEDIFF(DAY, MIN(InvoiceDate), MAX(InvoiceDate)) / 365.0 AS LifespanYears
    FROM Invoice
    GROUP BY CustomerId
),
Metrics AS (
    SELECT
        SUM(Total) * 1.0 / COUNT(InvoiceId) AS Avg_Purchase_Value,
        COUNT(InvoiceId) * 1.0 / COUNT(DISTINCT I.CustomerId) AS Purchase_Frequency,
        AVG(LifespanYears) AS Avg_Lifespan
    FROM Invoice I
    JOIN CustomerLifespan CL ON I.CustomerId = CL.CustomerId
)
SELECT 
    Avg_Purchase_Value,
    Purchase_Frequency,
    Avg_Lifespan,
    Avg_Purchase_Value * Purchase_Frequency * Avg_Lifespan AS CLV
FROM Metrics




-- All Customers have orders above average sales
SELECT   
    C.CustomerId,
    C.FirstName, 
    C.LastName, 
    I.InvoiceId, 
    I.InvoiceDate, 
    Total
FROM Invoice AS I 
JOIN Customer AS C 
ON C.CustomerId = I.CustomerId
WHERE Total > (SELECT AVG(Total) FROM Invoice)



-- Customer Segmentation 
WITH Customer_Revenue AS (
SELECT  
    C.CustomerId, 
    C.FirstName + ' ' + C.LastName AS Customer_Name, 
    SUM(I.Total) AS Revenue
FROM Customer AS C 
JOIN Invoice AS I 
ON C.CustomerId = I.CustomerId
GROUP BY 
    C.Country, 
    C.CustomerId, 
    C.FirstName, C.LastName
),
Customer_Segment AS
(
SELECT 
    CustomerId,  
    Revenue, 
    CASE WHEN Revenue > 45 THEN 'Diamond'
    WHEN Revenue BETWEEN 40 AND 45 THEN 'Gold'
    ELSE 'Silver'
    END AS Segment
FROM Customer_Revenue
)

SELECT 
    Segment, 
    COUNT(CustomerId) AS Total_Customers,
    SUM(Revenue) AS Total_Revenue, 
    AVG(Revenue) AS Avg_Revenue

FROM Customer_Segment
GROUP BY Segment
--------------------------------------------------------------------------------------------------------------------------

-- Sales Agent Performance

-- Total sales associated with each sales agent
-- Only 3 Employees handle the customers

SELECT 
    E.EmployeeId, 
    E.FirstName+ ' ' + E.LastName AS Employee_Name, 
    SUM(Total) AS Sales
FROM Invoice AS I 
JOIN Customer AS C
ON I.CustomerId = C.CustomerId
JOIN Employee AS E
ON C.SupportRepId = E.EmployeeId
GROUP BY E.EmployeeId, E.FirstName, E.LastName



-- Number of Customers handled per agent 
-- The workload is almost evenly distributed among the 3 employees 
SELECT 
    E.EmployeeId, 
    E.FirstName+ ' ' + E.LastName AS Employee_Name, 
    COUNT(DISTINCT C.CustomerId) AS Number_of_Customers
FROM Customer AS C
JOIN Employee AS E
ON C.SupportRepId = E.EmployeeId
GROUP BY E.EmployeeId, E.FirstName, E.LastName


-- Average Revenue per Customer per Agent 

SELECT 
    E.EmployeeId, 
    E.FirstName+ ' ' + E.LastName AS Employee_Name, 
    COUNT(DISTINCT C.CustomerId) AS Number_of_Customers,
    SUM(Total) / COUNT(DISTINCT C.CustomerId) AS Avg_Sales
FROM Invoice AS I 
JOIN Customer AS C
ON I.CustomerId = C.CustomerId
JOIN Employee AS E
ON C.SupportRepId = E.EmployeeId
GROUP BY E.EmployeeId, E.FirstName, E.LastName

-----------------------------------------------------------------------------------------

-- Monthly Performance

-- Monthly Revenue Trend 

SELECT 
    YEAR(I.InvoiceDate) AS Year,
    MONTH(I.InvoiceDate) AS Month,
    SUM(I.Total) AS Monthly_Revenue
FROM Invoice I
GROUP BY YEAR(I.InvoiceDate), MONTH(I.InvoiceDate)
ORDER BY Year, Month


-- MOM Growth Rate 

WITH Monthly_Revenue AS 
(
SELECT 
    YEAR(I.InvoiceDate) AS Year,
    MONTH(I.InvoiceDate) AS Month,
    SUM(I.Total) AS Revenue
FROM Invoice I
GROUP BY YEAR(I.InvoiceDate), MONTH(I.InvoiceDate)
), 

last_Month_Revenue AS
(
SELECT 
    Year, 
    Month, 
    Revenue, 
    LAG(Revenue) OVER(ORDER BY Year, Month) Prev_Month_Revenue
FROM Monthly_Revenue
)

SELECT 
    Year, 
    Month, 
    Revenue,
    Prev_Month_Revenue,
    ROUND(((Revenue - Prev_Month_Revenue) / Prev_Month_Revenue) * 100.0, 2) AS MoM_Rate
FROM last_Month_Revenue



-- Monthly New Customers 
-- There is no new customers since August, 2022
WITH First_Purchase AS (
    SELECT 
        CustomerId,
        MIN(InvoiceDate) AS First_Invoice_Date
    FROM Invoice
    GROUP BY CustomerId
)
SELECT
    YEAR(First_Invoice_Date) AS Year,
    MONTH(First_Invoice_Date) AS Month,
    COUNT(CustomerId) AS New_Customers
FROM First_Purchase
GROUP BY YEAR(First_Invoice_Date), MONTH(First_Invoice_Date)
ORDER BY Year, Month


-- Are new customers driving revenue spikes ?
-- Months with Spikes didn't have many new customers

WITH Monthly_Revenue AS (
    SELECT 
        YEAR(InvoiceDate) AS Year,
        MONTH(InvoiceDate) AS Month,
        SUM(Total) AS Revenue
    FROM Invoice
    GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
),
First_Purchase AS (
    SELECT 
        CustomerId,
        MIN(InvoiceDate) AS First_Invoice_Date
    FROM Invoice
    GROUP BY CustomerId
),
Monthly_New_Customers AS (
    SELECT 
        YEAR(First_Invoice_Date) AS Year,
        MONTH(First_Invoice_Date) AS Month,
        COUNT(CustomerId) AS New_Customers
    FROM First_Purchase
    GROUP BY CustomerId, YEAR(First_Invoice_Date), MONTH(First_Invoice_Date)
)

SELECT
    R.Year,
    R.Month,
    R.Revenue,
    ISNULL(NC.New_Customers, 0) AS New_Customers
FROM Monthly_Revenue AS R
LEFT JOIN (
    SELECT Year, Month, SUM(New_Customers) AS New_Customers
    FROM Monthly_New_Customers
    GROUP BY Year, Month
) AS NC
ON R.Year = NC.Year AND R.Month = NC.Month
ORDER BY R.Year, R.Month





-- The spike in 4/2023 and 11/2025 comes from orders with high sales 
-- The spike other months is because of the drop in the month before it
-- For most months, there is no change. 

SELECT TOP 10 
    C.CustomerId,
    C.FirstName + ' ' + C.LastName AS Customer_Name,
    SUM(I.Total) AS Revenue
FROM Invoice I
JOIN Customer C ON I.CustomerId = C.CustomerId
WHERE YEAR(I.InvoiceDate) = 2023 AND MONTH(I.InvoiceDate) = 4 -- replace with spike month
GROUP BY C.CustomerId, C.FirstName, C.LastName
ORDER BY Revenue DESC



-- Are the high sales orders from loyal customers?
-- The orders that caused the spike were special case

SELECT 
    C.CustomerId,
    C.FirstName, 
    C.LastName, 
    I.InvoiceId, 
    I.InvoiceDate, 
    Total
FROM Customer AS C 
JOIN Invoice AS I 
ON C.CustomerId = I.CustomerId
WHERE C.CustomerId = 46






-- What caused the drop in sales 
-- Months when drop occured 

WITH Monthly_Revenue AS (
    SELECT 
        YEAR(InvoiceDate) AS Year,
        MONTH(InvoiceDate) AS Month,
        SUM(Total) AS Revenue
    FROM Invoice
    GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
),
Revenue_With_Lag AS (
    SELECT *,
        LAG(Revenue) OVER (ORDER BY Year, Month) AS Prev_Revenue
    FROM Monthly_Revenue
)
SELECT *,
       (Revenue - Prev_Revenue) * 100.0 / Prev_Revenue AS Drop_Percentage
FROM Revenue_With_Lag
WHERE Revenue < Prev_Revenue
ORDER BY Year, Month




-- Check if fewer customers caused the drop 
-- 9/2022 and 9/2024 are less by 1 customer than other months
-- 2/2025 and 4/2025 are less by 2 customers than other months
SELECT 
    YEAR(InvoiceDate) AS Year,
    MONTH(InvoiceDate) AS Month,
    COUNT(DISTINCT CustomerId) AS Active_Customers
FROM Invoice
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY Year, Month


-- Check if fewer orders caused the drop 
-- 9/2022 and 9/2024 and 11/2023 are less by 1 order than other months
SELECT 
    YEAR(InvoiceDate) AS Year,
    MONTH(InvoiceDate) AS Month,
    COUNT(InvoiceId) AS Number_of_Orders
FROM Invoice
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY Year, Month




-- Revenue by genre (percentage)
SELECT 
    G.Name AS Genre,
    SUM(IL.Quantity * IL.UnitPrice) AS Total_Revenue,
    SUM(IL.Quantity * IL.UnitPrice) * 100.0 
        / SUM(SUM(IL.Quantity * IL.UnitPrice)) OVER() AS Revenue_Percentage
FROM InvoiceLine IL
JOIN Track T ON IL.TrackId = T.TrackId
JOIN Genre G ON T.GenreId = G.GenreId
GROUP BY G.Name
ORDER BY Total_Revenue DESC





-- Find which genres caused revenue drops
-- The largest revenue drops occurred in months where Rock sales were minimal or absent, confirming that Rock is the primary driver of revenue performance
WITH GenreMonthlyRevenue AS (
    SELECT 
        YEAR(I.InvoiceDate) AS Year,
        MONTH(I.InvoiceDate) AS Month,
        G.Name AS Genre,
        SUM(IL.Quantity * IL.UnitPrice) AS Revenue
    FROM Invoice I
    JOIN InvoiceLine IL ON I.InvoiceId = IL.InvoiceId
    JOIN Track T ON IL.TrackId = T.TrackId
    JOIN Genre G ON T.GenreId = G.GenreId
    GROUP BY YEAR(I.InvoiceDate), MONTH(I.InvoiceDate), G.Name
),
GenreWithLag AS (
    SELECT *,
        LAG(Revenue) OVER (PARTITION BY Genre ORDER BY Year, Month) AS Prev_Revenue
    FROM GenreMonthlyRevenue
)
SELECT *
FROM GenreWithLag
WHERE Revenue < Prev_Revenue
ORDER BY Year, Month





















