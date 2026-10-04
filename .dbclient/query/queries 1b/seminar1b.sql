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

