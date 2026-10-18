-- Active: 1790427590514@@127.0.0.1@5432@retail
-- Active: 1790427590514@@127.0.0.1@5432@retail

SELECT *
FROM retail_sales;

--Uloha2
select customer_id, invoice_no, invoice_date,
quantity, unit_price, unit_price*quantity as revenue, sum(unit_price*quantity)
over(partition by customer_id ORDER BY invoice_date
range BETWEEN INTERVAL '14 days' PRECEDING AND CURRENT ROW) as revenue_last_14_days
from retail_sales where customer_id is not null
order by customer_id, invoice_date;

--Uloha3
select stock_code, country, invoice_date, quantity, round(avg(quantity ) over (partition by stock_code ORDER BY invoice_date
range BETWEEN INTERVAL '7 days' preceding and current row), 2) as avg_quantity_last_7_days 
from retail_sales
where  quantity > 1;

--Uloha4
WITH unique_orders AS (
    SELECT DISTINCT
        customer_id,
        invoice_no,
        invoice_date
    FROM retail_sales
    WHERE customer_id IS NOT NULL
),
next_orders AS (
    SELECT
        customer_id,
        invoice_no,
        invoice_date,
        LEAD(invoice_date) OVER (
            PARTITION BY customer_id
            ORDER BY invoice_date, invoice_no
        ) AS next_invoice_date
    FROM unique_orders
)
SELECT
    customer_id,
    invoice_no,
    invoice_date,
    next_invoice_date,
    next_invoice_date::DATE - invoice_date::DATE AS days_to_next_invoice
FROM next_orders
WHERE next_invoice_date IS NOT NULL
ORDER BY days_to_next_invoice DESC;

--Uloha5
WITH price_comparison AS (
    SELECT stock_code, invoice_date,invoice_no, lag(unit_price) over(PARTITION BY stock_code
    ORDER BY invoice_date, invoice_no) as previous_price, unit_price AS current_price
    from retail_sales
)
select stock_code, invoice_no, previous_price,current_price,
current_price - previous_price as price_difference
from price_comparison WHERE previous_price is not NULL
and current_price<>previous_price
order BY  invoice_date;

--Uloha6
WITH revenue_per_customer AS (
    SELECT customer_id, invoice_date, SUM(unit_price * quantity) AS total_amount
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id, invoice_date
)
select customer_id, total_amount, NTILE(4) over (ORDER BY total_amount DESC)
as sales_quartile from revenue_per_customer;
--Uloha7
--zla verzia
with revenue_per_country as (
    select country, invoice_date, sum(unit_price*quantity) as total_amount
    from retail_sales
    group by country, invoice_date
)
select country,invoice_date, total_amount, NTILE(4) over (partition by country ORDER BY total_amount DESC)
as sales_quartile from revenue_per_country;
--spravna verzia
WITH monthly_sales AS (
    SELECT
        country,
        DATE_TRUNC('month', invoice_date)::DATE AS month,
        SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    GROUP BY
        country,
        DATE_TRUNC('month', invoice_date)::DATE
),
sales_quartiles AS (
    SELECT
        country,
        month,
        total_amount,
        NTILE(4) OVER (
            PARTITION BY country
            ORDER BY total_amount DESC
        ) AS sales_quartile
    FROM monthly_sales
)
SELECT
    country,
    month,
    total_amount,
    sales_quartile
FROM sales_quartiles
ORDER BY country ASC, month ASC;

--Uloha8
WITH ranked_sales AS (
    SELECT
        customer_id,
        invoice_no,
        invoice_date,
        stock_code,
        description,
        quantity,
        unit_price,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY invoice_date
        ) AS row_num
    FROM retail_sales
)
SELECT
    customer_id,
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price,
    row_num
FROM ranked_sales
WHERE row_num = 1;

WITH first_purchases AS (
    SELECT
        customer_id,
        invoice_no,
        invoice_date,
        stock_code,
        description,
        quantity,
        unit_price,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY invoice_date ASC
        ) AS row_num
    FROM retail_sales
)
SELECT
    customer_id,
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price
FROM first_purchases
WHERE row_num = 1
ORDER BY customer_id ASC
LIMIT 5;

--Uloha9
WITH ranked_items AS (SELECT invoice_no,
stock_code,quantity * unit_price AS amount,ROW_NUMBER() OVER (
PARTITION BY invoice_no ORDER BY quantity * unit_price DESC) AS row_num
FROM retail_sales)
SELECT * FROM ranked_items; 

--Uloha10
WITH monthly_customer_sales AS (
    SELECT
        country,
        DATE_TRUNC('month', invoice_date)::DATE AS month,
        customer_id,
        SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY
        country,
        DATE_TRUNC('month', invoice_date)::DATE,
        customer_id
),
ranked_sales AS (
    SELECT
        country,
        month,
        customer_id,
        total_amount,
        DENSE_RANK() OVER (
            PARTITION BY country, month
            ORDER BY total_amount DESC
        ) AS sales_rank
    FROM monthly_customer_sales
)
SELECT
    country,
    month,
    customer_id,
    total_amount,
    sales_rank
FROM ranked_sales
WHERE sales_rank <= 5
ORDER BY
    country ASC,
    month ASC,
    sales_rank ASC,
    customer_id ASC;

--Uloha11
WITH ranked_items AS (
    SELECT
        invoice_no,
        stock_code,
        description,
        quantity,
        unit_price,
        DENSE_RANK() OVER (
            PARTITION BY invoice_no
            ORDER BY unit_price DESC
        ) AS price_rank
    FROM retail_sales
)
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    price_rank
FROM ranked_items
WHERE price_rank <= 5
ORDER BY
    invoice_no ASC,
    price_rank ASC,
    stock_code ASC;