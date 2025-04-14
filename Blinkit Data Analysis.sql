use blinkit_db;

-- Creating the table --

create table blinkit_data(
Item_Fat_Content varchar(50) Not Null,
Item_Identifier varchar(50) Not Null,
Item_Type varchar(50) Not Null,
Outlet_Establishment_Year int Not Null,
Outlet_Identifier varchar(50) Not Null,
Outlet_Location_Type varchar(50) Not Null,
Outlet_Size varchar(50) Not Null,
Outlet_Type varchar(50) Not Null,
Item_Visibility float Not Null,
Item_Weight float,
Total_Sales float Not Null,
Rating int Not Null
);

desc blinkit_data;

--- Getting the Information --

SELECT * FROM blinkit_db.data;

select count(*) from blinkit_data;

-- Data Cleaning --

select distinct Item_Fat_Content from blinkit_data;

update blinkit_data
set Item_Fat_Content=
case
when Item_Fat_Content IN ('LF','low fat') THEN 'Low Fat'
when Item_Fat_Content = 'reg' THEN 'Regular'
ELSE Item_Fat_Content
END;

select distinct Item_Fat_Content from blinkit_data;

-- (A). KPIs --

-- (1).Total Sales --

select concat(cast(sum(total_sales)/1000000 AS Decimal(10,2)),"M") AS Total_Sales_Millions from blinkit_data;

-- (2). Average Sales --

select cast(avg(total_sales) AS Decimal(10,1)) AS Avg_Sales from blinkit_data;

-- (3). No of Items --

select count(*) as No_of_Items from blinkit_data;

-- (4). Average Rating --

select cast(avg(rating) as decimal(10,2)) as Avg_Rating from blinkit_data;

-- (B). Total Sales by Fat Content --

select Item_Fat_Content, 
	cast(sum(total_sales) as decimal(10,2)) As Total_Sales
from blinkit_data
group by Item_Fat_Content 
order by Total_Sales desc;

-- (C). Total Sales by Item Type --

SELECT Item_Type, CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM blinkit_data
GROUP BY Item_Type
ORDER BY Total_Sales DESC;

-- (D). Fat Content By Outlet for Total Sales --

SELECT 
    Outlet_Location_Type,
    COALESCE(CAST(SUM(CASE WHEN Item_Fat_Content = 'Low Fat' THEN Total_Sales END) AS DECIMAL(10,2)), 0.00) AS Low_Fat,
    COALESCE(CAST(SUM(CASE WHEN Item_Fat_Content = 'Regular' THEN Total_Sales END) AS DECIMAL(10,2)), 0.00) AS Regular
FROM blinkit_data
GROUP BY Outlet_Location_Type
ORDER BY Outlet_Location_Type;

-- (E). Total Sales by Outlet Establishment Year --

select Outlet_Establishment_Year,
	cast(sum(Total_Sales) as Decimal(10,2)) as Total_Sales
from blinkit_data
group by Outlet_Establishment_Year
order by Outlet_Establishment_Year ASC;

-- (F). Percentage of Sales by Outlet Size --

SELECT 
    Outlet_Size, 
    CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    concat(CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2))," ","%") AS Sales_Percentage
FROM blinkit_data
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;

-- (G). Sales by Outlet Location --

select Outlet_Location_Type, Item_Fat_Content, 
	cast(sum(total_sales) as decimal(10,2)) As Total_Sales,
    cast(avg(total_sales) AS Decimal(10,1)) AS Avg_Sales,
    count(*) as No_of_Items,
    cast(avg(rating) as decimal(10,2)) as Avg_Rating 
from blinkit_data 
group by Outlet_Location_Type, Item_Fat_Content 
order by Outlet_Location_Type;

-- (H). All Metrcis by Outlet Type --

SELECT Outlet_Type, 
	CAST(SUM(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales,
    concat(CAST((SUM(Total_Sales) * 100.0 / SUM(SUM(Total_Sales)) OVER()) AS DECIMAL(10,2))," ","%") AS Sales_Percentage,
	CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales,
    count(*) As No_of_Items,
	CAST(Avg(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_data
GROUP BY Outlet_Type
ORDER BY Total_Sales DESC;