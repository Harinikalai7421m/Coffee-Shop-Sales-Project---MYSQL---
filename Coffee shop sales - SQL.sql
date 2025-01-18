Create database coffee;
use coffee;
create table `sql power bi project - coffee`;
describe`sql power bi project - coffee`;
select * from `sql power bi project - coffee`
update `sql power bi project - coffee`
Set transaction_date = str_to_date(transaction_date, '%d-%m-%Y');

alter table `sql power bi project - coffee`
modify column transaction_date date;
describe`sql power bi project - coffee`;
update `sql power bi project - coffee`
set transaction_time = str_to_date(transaction_time, '%H:%i:%s');
alter table `sql power bi project - coffee`
modify column transaction_time time;
select * from `sql power bi project - coffee`

ALTER TABLE `sql power bi project - coffee`
RENAME COLUMN ï»¿transaction_id TO transaction_id;

describe `sql power bi project - coffee`

-- 1. Total sales analysis:
SELECT round(sum(unit_price * transaction_qty)) as total_sales
from `sql power bi project - coffee`
where month(transaction_date) = 5 -- may month

-- selected month / cn - may =5
-- previous month = april =4
Select
    month(transaction_date) AS month, -- number of month
    round(Sum(unit_price * transaction_qty)) AS total_sales,  -- total sales column
    (sum(unit_price * transaction_qty) - lag(sum(unit_price * transaction_qty), 1) -- month sales difference
    over (Order by month(transaction_date))) / lag(sum(unit_price * transaction_qty), 1) -- division by previous sales
    over (Order by month(transaction_date)) * 100 as mom_increase_percentage -- convert into percentage
from `sql power bi project - coffee`
where month(transaction_date) in (4, 5) -- for months of April (pre) and May (curr)
group by month(transaction_date)  
order by month(transaction_date);


-- 2. Total orders analysis: 
select count(transaction_id) as Total_Orders
from `sql power bi project - coffee` 
where month (transaction_date)= 5 -- for month of (CM-May)

-- month on month increase or decrease
select
    month(transaction_date) as month,
    round(count(transaction_id)) as total_orders,
    (count(transaction_id) - lag(count(transaction_id), 1) 
    over (order by month(transaction_date))) / lag(count(transaction_id), 1) 
    over (order by month(transaction_date)) * 100 as mom_increase_percentage
from `sql power bi project - coffee`
where month(transaction_date) IN (4, 5) -- for April and May
group by month(transaction_date)
order by month(transaction_date);
    
-- 3. Total quantity sold analysis:
select sum(transaction_qty) as Total_Quantity_Sold
from `sql power bi project - coffee` 
where month(transaction_date) = 5 -- for month of (CM-May)

-- month on month incresae and difference:
select month (transaction_date) as month,
    round(sum(transaction_qty)) as total_quantity_sold,
    (sum(transaction_qty) - lag(sum(transaction_qty), 1) 
    over (order by month(transaction_date))) / lag(sum(transaction_qty), 1) 
    over (order by month(transaction_date)) * 100 as mom_increase_percentage
from `sql power bi project - coffee`
where month(transaction_date) in (4, 5)   -- for April and May
group by month(transaction_date)
order by month(transaction_date);

-- 4. Calender heat map:
select concat(round(SUM(unit_price * transaction_qty)/1000,1), 'k') as total_sales,
    concat(round(SUM(transaction_qty)/1000,1), 'k') as total_quantity_sold,
    concat(round(COUNT(transaction_id)/1000,1), 'k') as total_orders
from `sql power bi project - coffee`
where transaction_date = '2023-05-18'; -- For 18 May 2023
    
-- 5.Sales analysis by weekdays and weekends:
select
   case when dayofweek(transaction_date) in (1,7) then 'weekends'
   else 'weekdays'
   end as day_type,
   concat(round(sum(unit_price * transaction_qty)/1000,1), 'k') as total_sales
from `sql power bi project - coffee`
where month(transaction_date) = 5 -- may month
group by 
    case when dayofweek(transaction_date) in (1,7) then 'weekends'
   else 'weekdays'
   end  

-- 6.Sales analysis by store location:
SELECT store_location,
	concat(round(SUM(unit_price * transaction_qty)/1000,1), 'k') as Total_Sales
from `sql power bi project - coffee`
where month (transaction_date) =5 -- may
group by store_location
order by sum(unit_price * transaction_qty) DESC

-- 7. Daily sales analysis with average line:
select 
    concat(round(avg(total_sales)/1000,1), 'k') as avg_sales
    from
    (
    select sum(transaction_qty * unit_price) as total_sales 
    from `sql power bi project - coffee`
    where month(transaction_date)=4
    group by transaction_date
    ) as internal_query

select
    day(transaction_date) as day_of_month,
    round(sum(unit_price * transaction_qty),1) as total_sales
from `sql power bi project - coffee`
where month(transaction_date) = 5  -- Filter for May
group by day(transaction_date)
order by day(transaction_date);

select day_of_month,
    case 
        when total_sales > avg_sales then 'Above Average'
        when total_sales < avg_sales then 'Below Average'
        else 'equal to Average'
    end as sales_status,
    total_sales
from (
    select 
        day(transaction_date) as day_of_month,
        sum(unit_price * transaction_qty) as total_sales,
        avg(sum(unit_price * transaction_qty)) over () as avg_sales
    from `sql power bi project - coffee`
    where month(transaction_date) = 5  -- Filter for May
    group by day(transaction_date)
    ) as sales_data
order by day_of_month;
    
-- 8. Sales by product category.
select product_category,
  sum(unit_price * transaction_qty) as total_sales
  from `sql power bi project - coffee`
  where month(transaction_date) = 5
  group by product_category
  order by sum(unit_price * transaction_qty)desc
  
  -- 9.Top 10 products by sales.
select product_type, round(sum(unit_price * transaction_qty),1) as Total_Sales
from `sql power bi project - coffee`
where month(transaction_date) = 5  and product_category = 'coffee'
group by product_type
order by sum(unit_price * transaction_qty) desc
limit 10

-- 10. Sales Analysis by days and hours:
select 
    round(sum(unit_price * transaction_qty)) as Total_Sales,
    sum(transaction_qty) as Total_Quantity,
    count(*) as Total_Orders
from `sql power bi project - coffee`
where dayofweek(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    and hour(transaction_time) = 8 -- Filter for hour number 8
    and month(transaction_date) = 5; -- Filter for May (month number 5)

-- 11. hour of transaction time.
select hour(transaction_time),
  sum(unit_price * transaction_qty) as total_sales
from `sql power bi project - coffee`
where month(transaction_date)=5
group by hour (transaction_time)
order by hour(transaction_time)

-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
select 
    case 
        when dayofweek(transaction_date) = 2 then 'Monday'
        when dayofweek(transaction_date) = 3 then 'Tuesday'
		when dayofweek(transaction_date) = 4 then 'Wednesday'
        when dayofweek(transaction_date) = 5 then 'Thursday'
		when dayofweek(transaction_date) = 6 then 'Friday'
		when dayofweek(transaction_date) = 7 then 'Saturday'
        else 'Sunday'
    end as Day_of_Week,
    round(sum(unit_price * transaction_qty)) as Total_Sales
from `sql power bi project - coffee`
where month(transaction_date) = 5 -- Filter for May (month number 5)
group by 
    case 
        when dayofweek(transaction_date) = 2 then 'Monday'
        when dayofweek(transaction_date) = 3 then 'Tuesday'
		when dayofweek(transaction_date) = 4 then 'Wednesday'
        when dayofweek(transaction_date) = 5 then 'Thursday'
		when dayofweek(transaction_date) = 6 then 'Friday'
		when dayofweek(transaction_date) = 7 then 'Saturday'
        else 'Sunday'
    end;

    
    






    
    

