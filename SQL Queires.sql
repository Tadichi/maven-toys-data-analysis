

-- Sales gross profit by location by category
SELECT 
      p.Product_Category,  st.Store_Location,
     ROUND(SUM(s.Units * (p.Product_Price - p.Product_Cost)), 2) AS Gross_Profit
FROM sales s
JOIN products p ON s.Product_ID = p.Product_ID
INNER JOIN stores st ON s.Store_ID = st.Store_ID
GROUP BY  p.Product_Category,st.Store_Location 
ORDER BY p.Product_Category ASC,Gross_Profit DESC;


-- TOP 5 profitable Products
SELECT TOP(5)
	Product_Name, 
	ROUND(SUM(s.Units * p.Product_Price),0) as SalesAmount
FROM products p INNER JOIN sales s 
	ON p.Product_ID = s.Product_ID
GROUP BY Product_Name
ORDER BY SalesAmount DESC;


-- SalesToInventoryPercentage-Products
SELECT 
	p.Product_Name, 
	SUM(s.Units) AS SalesVolume,
	SUM(i.Stock_On_Hand) as Inventory,
	ROUND(CAST(SUM(s.Units) AS FLOAT)/CAST(SUM(i.Stock_On_Hand) AS FLOAT),2) AS SalesToInventory
FROM products p LEFT JOIN sales s
	ON p.Product_ID = s.Product_ID
	INNER JOIN inventory i
	ON p.Product_ID = i.Product_ID
GROUP BY p.Product_Name
ORDER BY SalesToInventory DESC;


-- SalesToInventoryPercentage-category
SELECT 
	p.Product_Category, 
	SUM(s.Units) AS SalesVolume,
	SUM(i.Stock_On_Hand) as Inventory,
	ROUND(CAST(SUM(s.Units) AS FLOAT)/CAST(SUM(i.Stock_On_Hand) AS FLOAT),2) AS SalesToInventory
FROM products p LEFT JOIN sales s
	ON p.Product_ID = s.Product_ID
	INNER JOIN inventory i
	ON p.Product_ID = i.Product_ID
GROUP BY p.Product_Category
ORDER BY SalesToInventory DESC;


-- Gross Profit by Product Category for each month
SELECT 
    pr.Product_Category,
    d.Month AS Month,
    SUM((pr.Product_Price - pr.Product_Cost) * s.Units) AS Gross_Profit
FROM 
    sales s
JOIN 
    products pr ON s.Product_ID = pr.Product_ID
JOIN 
    date d ON s.Date = d.Date
GROUP BY 
    pr.Product_Category, d.Month
ORDER BY 
    d.Month, pr.Product_Category DESC;
	
	
--  Quarter-On-Quarter (QoQ) trends for Sales, Costs, and Gross Profit
WITH SalesData AS (
    SELECT
        d.Quarter_Year,
        d.Quarter,
        SUM((pr.Product_Price * s.Units)) AS Total_Sales,
        SUM((pr.Product_Cost * s.Units)) AS Total_Cost,
        SUM((pr.Product_Price - pr.Product_Cost) * s.Units) AS Gross_Profit
    FROM 
        sales s
    JOIN 
        products pr ON s.Product_ID = pr.Product_ID
    JOIN 
        date d ON s.Date = d.Date
    GROUP BY
        d.Quarter_Year, d.Quarter
)
SELECT 
    Quarter_Year,
    Quarter,
    Total_Sales,
    Total_Cost,
    Gross_Profit
 FROM 
    SalesData
ORDER BY 
    Quarter_Year, Quarter;
	
	
-- Top 10 Store Sales Contribution 
WITH StoreSales AS (
    SELECT
        st.Store_ID,
        st.Store_Name,
        SUM(pr.Product_Price * s.Units) AS Total_Sales
    FROM 
        sales s
    JOIN 
        stores st ON s.Store_ID = st.Store_ID
    JOIN 
        products pr ON s.Product_ID = pr.Product_ID
    GROUP BY 
        st.Store_ID, st.Store_Name
),
TotalSales AS (
    SELECT SUM(Total_Sales) AS All_Stores_Sales
    FROM StoreSales
)
SELECT 
    ss.Store_Name,
    ss.Total_Sales,
    (ss.Total_Sales / ts.All_Stores_Sales) * 100 AS Sales_Contribution_Percentage
FROM 
    StoreSales ss
CROSS JOIN 
    TotalSales ts
ORDER BY 
    ss.Total_Sales DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;
