-- Active: 1790427590514@@127.0.0.1@5432@datacraftinglab_db
SELECT
    product_name,
    total_amount
FROM
    
    flourmills_sales
WHERE
    total_amount > (
        SELECT AVG(total_amount) 
        FROM flourmills_sales
        );

SELECT *
FROM 
    flourmills_sales
WHERE 
    product_category = (
    SELECT 
        product_category
    FROM 
        flourmills_sales
    GROUP BY product_category
    ORDER BY SUM(total_amount) DESC
    LIMIT 1
)
ORDER BY sales_id ASC;

SELECT 
    product_name,S
    total_amount,
    (SELECT AVG(total_amount) FROM flourmills_sales) AS avg_amount
FROM 
    flourmills_sales
WHERE 
    total_amount = 9511208.41;

SELECT 
    product_name,
    total_amount,
    total_amount / (SELECT SUM(total_amount) FROM flourmills_sales) AS amount_share
FROM 
    flourmills_sales;

SELECT 
    month,
    monthly_sales
FROM (
    SELECT 
        EXTRACT(MONTH FROM sale_date) AS month,
        SUM(total_amount) AS monthly_sales
    FROM 
        flourmills_sales
    GROUP BY 
        EXTRACT(MONTH FROM sale_date)
) AS monthly_summary
ORDER BY 
    monthly_sales DESC;

SELECT 
    product_category,
    total_sales
FROM (
    SELECT 
        product_category,
        SUM(total_amount) AS total_sales
    FROM 
        flourmills_sales
    GROUP BY 
        product_category
) AS category_summary
WHERE 
    total_sales > 50000000
ORDER BY 
    total_sales DESC;

SELECT 
    COUNT(*) 
FROM 
    flourmills_sales t1
WHERE 
    t1.total_amount > (
        SELECT AVG(t2.total_amount)
        FROM flourmills_sales t2
        WHERE t2.product_category = t1.product_category
    );

SELECT 
    t1.product_name,
    t1.region,
    t1.total_amount,
    (
        SELECT MIN(t2.total_amount)
        FROM flourmills_sales t2
        WHERE t2.region = t1.region
    ) AS region_min_amount
FROM 
    flourmills_sales t1;

SELECT 
    t1.sales_id,
    t1.product_name,
    t1.sale_date,
    t1.total_amount
FROM 
    flourmills_sales t1
WHERE 
    EXISTS (
        SELECT 1
        FROM flourmills_sales t2
        WHERE t2.product_name = t1.product_name
        GROUP BY t2.product_name
        HAVING COUNT(DISTINCT EXTRACT(MONTH FROM t2.sale_date)) > 1
    );

SELECT 
    t1.sales_id,
    t1.product_category,
    t1.product_name,  
    t1.total_amount
FROM 
    flourmills_sales t1
WHERE 
    EXISTS (
        SELECT 1
        FROM flourmills_sales t2
        WHERE t2.product_category = t1.product_category
          AND t2.total_amount > 200000
    );

SELECT DISTINCT t1.product_category
FROM flourmills_sales t1
WHERE EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.product_category = t1.product_category
    GROUP BY t2.product_category
    HAVING COUNT(DISTINCT t2.region) > 3
);

SELECT 
    t1.sales_id,
    t1.product_name,
    t1.region,
    t1.sale_date,
    t1.total_amount
FROM 
    flourmills_sales t1
WHERE 
    EXISTS (
        SELECT 1
        FROM flourmills_sales t2
        WHERE t2.region = t1.region
          AND EXTRACT(YEAR FROM t2.sale_date) = 2024
    );

SELECT COUNT(DISTINCT t1.product_category)
FROM flourmills_sales t1
WHERE NOT EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.product_category = t1.product_category
      AND t2.total_amount > 500000
);

SELECT DISTINCT t1.region
FROM flourmills_sales t1
WHERE NOT EXISTS (
    SELECT 1
    FROM flourmills_sales t2
    WHERE t2.region = t1.region
      AND t2.product_category = 'Flour'
);