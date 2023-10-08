use [sales_instacart];

SELECT * from [dbo].[Aisles];
select * from [dbo].[Departments_];
select * from [dbo].[order_Prod_Prior];
select * from [dbo].[Order_Prod_Train];
select * from [dbo].[orders_main];
select * from [dbo].[products_main];
select * from [dbo].[sample_sumb];


-->1. Ordering patterns:-
- I was interested in knowing more about whether more people place orders on a weekly or monthly basis, to find this out, I wrote the following query.

SELECT days_since_prior_order, COUNT(userssm_id) as no_of_users 
FROM [dbo].[orders_main]
GROUP BY days_since_prior_order;


-->2. Coke Vs Pepsi:-
Who is the heavyweight champion of soda? I wanted to know what was more popular among the customers between Coke and Pepsi.
        
SELECT products.product_name, COUNT(*) as no_of_purchases 
FROM [dbo].[Order_Prod_Train] train
LEFT JOIN [dbo].[products_main] products
ON train.product_id=products.product_id
WHERE products.product_name LIKE '%coke%' or products.product_name LIKE '%pepsi%'
GROUP BY products.product_name
ORDER BY count(*) desc;


-->3.Top Products by Department:-
Instacart has over 20 departments and over 49000 products listed, I was interested in seeing what the top 20 products were for each dept and how many of each product was bought.
        
SELECT product_name,department,no_of_purchases,product_rank FROM(
SELECT * FROM 
(
SELECT p.product_name,p.department_id, purchases.no_of_purchases,
ROW_NUMBER() OVER(PARTITION BY department_id ORDER BY no_of_purchases DESC) AS product_rank
FROM
(
SELECT products.product_id, COUNT(*) AS no_of_purchases
FROM [dbo].[Order_Prod_Train] train
LEFT JOIN [dbo].[products_main] products
ON train.product_id=products.product_id
GROUP BY products.product_id
)purchases
JOIN [dbo].[products_main] p
ON p.product_id=purchases.product_id
)dept_ranks
WHERE dept_ranks.product_rank <=20) top_in_dept
JOIN [dbo].[Departments_] dept
ON top_in_dept.department_id=dept.department_id;


--> 4. Top 20 Types of Cookies Purchased
I'm a huge fan of the cookies and Instacart has its own sales legacy. I structured out what were the most favorite cookies bought by the customers.
        
WITH cte AS(
SELECT 
products.product_name, COUNT(*) AS no_of_cookies_bought
FROM [dbo].[Order_Prod_Train] train
LEFT JOIN [dbo].[products_main] products
ON train.product_id=products.product_id
WHERE products.product_name LIKE '%cookie%'
GROUP BY products.product_name),
cte2 AS(
SELECT *,
RANK() OVER(ORDER BY no_of_cookies_bought DESC) AS cookie_rank
FROM cte)
SELECT
product_name, no_of_cookies_bought
FROM cte2 
WHERE cookie_rank <=20;


-->5. Number of Orders Per Day and Per Hour:-
Let's be honest, We've always wondered how many orders are purchased every hour of the day in a week. Tada! I've queried below to know how many purchases were made.
        
WITH cte AS(
SELECT COUNT(*) AS no_of_purchases, order_hour_of_day AS hour_of_the_day,
(CASE 
        WHEN DATEPART(dw, order_dow) = 1 THEN 'Sunday'
        WHEN DATEPART(dw, order_dow) = 2 THEN 'Monday'
        WHEN DATEPART(dw, order_dow) = 3 THEN 'Tuesday'
        WHEN DATEPART(dw, order_dow) = 4 THEN 'Wednesday'
        WHEN DATEPART(dw, order_dow) = 5 THEN 'Thursday'
        WHEN DATEPART(dw, order_dow) = 6 THEN 'Friday'
        WHEN DATEPART(dw, order_dow) = 7 THEN 'Saturday'
    END) AS DayOfWeekName
FROM
[dbo].[orders_main]
GROUP BY order_hour_of_day,order_dow)
SELECT
SUM(no_of_purchases) OVER(PARTITION BY DayOfWeekName) AS total_no_of_purchases,
DayOfWeekName, hour_of_the_day
FROM cte
GROUP BY DayOfWeekName, hour_of_the_day,no_of_purchases;




--> Setting up of Primary and Foreign Keys:
alter table [dbo].[products_main] alter column product_id float not null;
alter table [dbo].[products_main] alter column aisle_id float not null;
alter table [dbo].[products_main] alter column department_id float not null;

alter table [dbo].[Order_Prod_Train] alter column product_id float not null;
alter table [dbo].[Order_Prod_Train] alter column orderss_id float not null;

alter table [dbo].[orders_main] alter column order_id float not null;
alter table [dbo].[orders_main] alter column user_id float not null;  --> MAIN KEY

alter table [dbo].[Aisles] alter column aisle_id float not null;
alter table [dbo].[Departments_] alter column department_id float not null;

alter table [dbo].[sample_sumb] alter column order_id float not null;


alter table [dbo].[Aisles]
add constraint pk_mainkeyaisles primary key (aisle_id);

alter table [dbo].[Departments_]
add constraint pk_mainkeydepts primary key (department_id);

alter table [dbo].[products_main]
add constraint pk_mainkeyprds primary key (product_id);

alter table [dbo].[products_main]   
add constraint fk_aislesbabe
foreign key (aisle_id) references [dbo].[Aisles] (aisle_id);

alter table [dbo].[products_main]   
add constraint fk_deptsbabe
foreign key (department_id) references [dbo].[Departments_] (department_id);

alter table [dbo].[Order_Prod_Train]
add constraint pk_ordersbth primary key (orderss_id);

alter table [dbo].[Order_Prod_Train]   
add constraint fk_prodsbabe
foreign key (product_id) references [dbo].[products_main] (product_id);

alter table [dbo].[orders_main]
add constraint pk_mainkeyusersb primary key (userssm_id);

alter table [dbo].[orders_main]   
add constraint fk_ordersbabe
foreign key (orderss_id) references [dbo].[Order_Prod_Train] (orderss_id);

















