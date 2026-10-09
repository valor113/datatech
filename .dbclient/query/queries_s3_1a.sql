-- Active: 1790427590514@@127.0.0.1@5432@retail_sales
CREATE OR REPLACE VIEW high_value_customers AS
SELECT c.customer_id,
       c.customer_name,
       SUM(o.sales) AS total_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.sales) > 2000;

SELECT *
FROM high_value_customers;

CREATE VIEW regional_mothly_sales AS
SELECT c.region,
       DATE_TRUNC('month', o.order_date) AS month,
       SUM(o.sales) AS monthly_sales
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.region, DATE_TRUNC('month', o.order_date);

SELECT *
FROM regional_mothly_sales;

CREATE OR REPLACE VIEW analyst_orders AS
SELECT o.order_id,
       o.customer_id,
       o.product_id,
       o.sales,
       o.quantity,
       o.discount
FROM orders o;

SELECT *
FROM analyst_orders;

CREATE INDEX idx_orders_customer_id 
ON orders(customer_id);

SELECT *
FROM orders
WHERE customer_id = 'C001';

CREATE INDEX idx_orders_order_date
ON orders(order_date);

SELECT DATE_TRUNC('month', o.order_date) AS month,
       SUM(sales) AS total_sales
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month ASC;

CREATE INDEX idx_orders_region_category
ON orders(customer_id, order_date);

SELECT o.customer_id, SUM(o.profit) AS total_profit
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE c.region = 'West'
AND o.customer_id = 'C025'
AND o.order_date >= '2024-01-01'
GROUP BY o.customer_id;

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 'C001';

SELECT *
FROM orders;

CREATE OR REPLACE PROCEDURE get_customer_sales(p_customer_id VARCHAR(20))
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales DECIMAL(10, 2);
BEGIN
    SELECT SUM(sales) INTO v_total_sales
    FROM orders
    WHERE customer_id = p_customer_id;

    RAISE NOTICE 'Total sales for customer %: %', p_customer_id, v_total_sales;
END;
$$;

call get_customer_sales('CUST00001');

CREATE OR REPLACE PROCEDURE apply_regional_discount(region_name VARCHAR(20), discount_rate DECIMAL(10, 2))
LANGUAGE plpgsql
AS $$
DECLARE
    new_sales DECIMAL(10, 2);
BEGIN
    UPDATE orders
    SET sales = sales * (1 - discount_rate)
    WHERE region = region_name;

    RAISE NOTICE 'Applied a discount of % to all orders in region %', discount_rate, region_name;
END;
$$;

CALL apply_regional_discount('West', 0.10);

CREATE OR REPLACE PROCEDURE get_sales_between(start_date DATE, end_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_sales DECIMAL(10, 2);
BEGIN
    SELECT SUM(sales) INTO v_total_sales
    FROM orders
    WHERE order_date BETWEEN start_date AND end_date;

    RAISE NOTICE 'Total sales between % and %: %', start_date, end_date, v_total_sales;
END;
$$;

call get_sales_between('2024-01-01', '2024-03-31');
