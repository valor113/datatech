-- Active: 1790427590514@@127.0.0.1@5432@datacraftinglab_db
--cv1
WITH daily_sales AS (
    SELECT
        sale_date,
        SUM(total_amount) AS daily_total
    FROM flourmills_sales
    GROUP BY sale_date
)
SELECT
    sale_date,
    daily_total
FROM daily_sales
WHERE daily_total > 3000000
ORDER BY daily_total DESC
LIMIT 5;

--cv2
WITH category_sales AS (
    SELECT
        product_category,
        SUM(total_amount) AS total_sales
    FROM flourmills_sales
    GROUP BY product_category
)
SELECT
    product_category,
    total_sales
FROM category_sales
ORDER BY total_sales DESC;

--cv3
WITH product_sales AS (
    SELECT
        product_category,
        SUM(total_amount) AS total_product_sales
    FROM flourmills_sales
    GROUP BY product_category, product_name
),
ranked_products AS (
    SELECT
        product_category,
        total_product_sales,
        RANK() OVER (
            PARTITION BY product_category
            ORDER BY total_product_sales DESC
        ) AS category_rank
    FROM product_sales
)
SELECT
    product_category,
    total_product_sales,
    category_rank
FROM ranked_products
WHERE category_rank BETWEEN 1 AND 3
ORDER BY product_category, category_rank
LIMIT 10;

--cv4
WITH customer_revenue AS (
    SELECT
        customer_type,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY customer_type
),
revenue_analysis AS (
    SELECT
        customer_type,
        revenue,
        SUM(revenue) OVER () AS total_revenue,
        ROUND(
            100.0 * revenue / SUM(revenue) OVER (),
            2
        ) AS revenue_percentage
    FROM customer_revenue
)
SELECT
    customer_type,
    revenue,
    total_revenue,
    revenue_percentage
FROM revenue_analysis
ORDER BY revenue DESC;

--cv5
WITH ranked_sales AS (
    SELECT
        customer_id,
        product_name,
        sale_date,
        total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY sale_date DESC
        ) AS rn
    FROM flourmills_sales
)
SELECT
    customer_id,
    product_name,
    sale_date,
    total_amount
FROM ranked_sales
WHERE rn = 1
ORDER BY customer_id ASC
LIMIT 5;

--cv6
WITH RECURSIVE date_bounds AS (
    SELECT
        MIN(sale_date) AS start_date,
        MAX(sale_date) AS end_date
    FROM flourmills_sales
),
calendar AS (
    SELECT start_date AS sale_date
    FROM date_bounds
    WHERE start_date IS NOT NULL

    UNION ALL

    SELECT (c.sale_date + INTERVAL '1 day')::DATE
    FROM calendar c
    CROSS JOIN date_bounds d
    WHERE c.sale_date < d.end_date
)
SELECT sale_date
FROM calendar
ORDER BY sale_date ASC;

--cv7
WITH RECURSIVE monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', sale_date)::DATE AS month,
        SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY DATE_TRUNC('month', sale_date)
),
ordered_months AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY month) AS rn,
        month,
        revenue
    FROM monthly_revenue
),
cumulative_target AS (
    SELECT
        rn,
        month,
        revenue,
        revenue AS cumulative_revenue
    FROM ordered_months
    WHERE rn = 1

    UNION ALL

    SELECT
        next_month.rn,
        next_month.month,
        next_month.revenue,
        current_month.cumulative_revenue + next_month.revenue
    FROM cumulative_target current_month
    JOIN ordered_months next_month
        ON next_month.rn = current_month.rn + 1
    WHERE current_month.cumulative_revenue < 500000000
)
SELECT
    rn,
    month,
    revenue,
    cumulative_revenue
FROM cumulative_target
WHERE cumulative_revenue >= 500000000
ORDER BY rn
LIMIT 1;