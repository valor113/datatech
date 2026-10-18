-- Active: 1790427590514@@127.0.0.1@5432@superstore
--1
with new_orders as(
    SELECT c.customer_name, o.order_id, o.order_date,
           ROW_NUMBER() OVER (PARTITION BY c.customer_name ORDER BY o.order_date) AS order_rank
    FROM orders o
    INNER JOIN customers c ON o.customer_id = c.customer_id
)
SELECT 
customer_name, order_id, order_date 
from 
new_orders
where 
order_rank <=2;

--2
with customer_orders as (
    select c.region,c.customer_name, sum(o.profit) as total_profit
    from orders o
    inner join customers c on o.customer_id = c.customer_id
     group by c.region, c.customer_name
)
select region, customer_name, total_profit,
    rank() over (partition by region order by total_profit desc) as profit_rank,
    dense_rank() over (partition by region order by total_profit desc) as profit_dense_rank
from customer_orders;

--3
with customer_orders as (
    select c.customer_name, sum(o.sales) as total_sales
    from orders o
    inner join customers c on o.customer_id = c.customer_id
    group by c.customer_name
)
select customer_name,total_sales,
ntile(4) over(order by total_sales DESC) as quartile
from customer_orders;

--4
with month_sales as(
    select date_trunc('month', order_date) as month, sum(sales) as monthly_sales
    from orders 
    group by month
)
select month,monthly_sales,
lag(monthly_sales) over(order by month) as prev_month_sales,
lead(monthly_sales) over(order by month) as next_month_sales
from month_sales
order by month ASC;

--5
SELECT 
    p.category,
    p.product_name,
    SUM(o.sales) AS product_sales,
    SUM(SUM(o.sales)) OVER (PARTITION BY p.category) AS category_total,
    ROUND(
        SUM(o.sales) * 100.0 /
        SUM(SUM(o.sales)) OVER (PARTITION BY p.category),
        2
    ) AS pct_of_category
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category, p.product_name;

with category_sales as (
    SELECT p.category,p.product_name,SUM(o.sales) AS product_sales
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.product_name, p.category
),category_totals as (
select category, product_name, product_sales,
sum(product_sales) over(partition by category) as category_total
from category_sales
)
select category, product_name, product_sales, category_total,
ROUND(product_sales* 100.0 /category_total,2) AS pct_of_category
from category_totals;

--6
with last_orders as(
    select c.customer_id, c.customer_name, 
    max(o.order_date) over(partition by c.customer_id) as last_order_date,
    max(o.order_date) over() as latest_order_date
    from orders o
    inner join customers c on o.customer_id=c.customer_id
)
Select customer_id, customer_name, last_order_date
from last_orders 
where last_order_date> latest_order_date - INTERVAL '90 days' 
ORDER BY last_order_date ASC;
    
--7
with month_sales as(
    select date_trunc('month', order_date) as month, sum(sales) as monthly_sales
    from orders 
    group by month
),month_sales_with_lag as(
    select month, monthly_sales,
    lag(monthly_sales) over(order by month) as prev_month_sales
    from month_sales
)
select month,monthly_sales,prev_month_sales,
monthly_sales - prev_month_sales as sales_change,
round(((monthly_sales - prev_month_sales)
 / prev_month_sales) * 100,2) as growth_percentage
 from month_sales_with_lag;


--8
with first_orders as(
    select customer_id, date_trunc('month', order_date) as month, 
    min(order_date) over(partition by customer_id) as first_order_date
    from orders 
),filtered_first_orders as(
    select customer_id, month, first_order_date
    from first_orders
    where first_order_date <= '2024-06-01' and first_order_date >= '2024-06-30'
)
select count(distinct f.customer_id) as filtered_customers
from filtered_first_orders f
inner join orders o on f.customer_id=o.customer_id
where f.first_order_date<o.order_date;
