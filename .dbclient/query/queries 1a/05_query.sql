SELECT 
    p.product_name,
    SUM(o.sales)
FROM 
    products p
LEFT JOIN
    orders o ON o.product_id = p.product_id
GROUP BY
    p.product_name;
