SELECT
    c.region,
    SUM(o.sales) AS total_sales,
    AVG(o.discount) AS average_discount,
    COUNT(o.order_id) AS total_orders
FROM
    orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY
    c.region;