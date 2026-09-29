SELECT
    p.category,
    AVG(o.discount) AS average_discount
FROM
    products p
LEFT JOIN orders o ON o.product_id = p.product_id
GROUP BY
    p.category;