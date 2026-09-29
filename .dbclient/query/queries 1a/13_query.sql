SELECT
    c.customer_name,
    SUM(o.sales) AS total_sales,
    AVG(o.discount) AS average_discount,
    COUNT(o.order_id) AS total_orders,
    CASE WHEN SUM(o.sales) > 2500 THEN 'VIP' ELSE 'Regular' END AS customer_status
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id
GROUP BY 
    c.customer_name
ORDER BY 
    total_sales DESC;
