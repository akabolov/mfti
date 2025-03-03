SELECT 
    job_industry_category AS "Job Category",
    COUNT(*) AS "Customer count"
FROM 
    customer
WHERE 
    job_industry_category IS NOT NULL
GROUP BY 
    job_industry_category
ORDER BY 
    COUNT(*) DESC;

SELECT 
    TO_CHAR(TO_DATE(t.transaction_date, 'DD.MM.YYYY'), 'YYYY') AS year,
    TO_CHAR(TO_DATE(t.transaction_date, 'DD.MM.YYYY'), 'MM') AS month,
    c.job_industry_category,
    SUM(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) AS transaction_sum
FROM 
    transaction t
JOIN 
    customer c ON t.customer_id = c.customer_id
WHERE 
    c.job_industry_category IS NOT NULL
GROUP BY 
    TO_CHAR(TO_DATE(t.transaction_date, 'DD.MM.YYYY'), 'YYYY'),
    TO_CHAR(TO_DATE(t.transaction_date, 'DD.MM.YYYY'), 'MM'),
    c.job_industry_category
ORDER BY 
    year,
    month,
    c.job_industry_category;


SELECT 
    t.brand,
    COUNT(*) AS online_orders_count
FROM 
    transaction t
JOIN 
    customer c ON t.customer_id = c.customer_id
WHERE 
    c.job_industry_category = 'IT' 
    AND t.order_status = 'Approved'
    AND t.online_order = 'True'
GROUP BY 
    t.brand
ORDER BY 
    online_orders_count DESC;

-- Используя GROUP BY
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) AS total_sum,
    MAX(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) AS max_price,
    MIN(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) AS min_price,
    COUNT(*) AS transactions_count
FROM 
    transaction t
JOIN 
    customer c ON t.customer_id = c.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name
ORDER BY 
    total_sum DESC, 
    transactions_count DESC;

-- Используя оконные функции
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) OVER (PARTITION BY c.customer_id) AS total_sum,
        MAX(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) OVER (PARTITION BY c.customer_id) AS max_price,
        MIN(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) OVER (PARTITION BY c.customer_id) AS min_price,
        COUNT(*) OVER (PARTITION BY c.customer_id) AS transactions_count
    FROM 
        transaction t
    JOIN 
        customer c ON t.customer_id = c.customer_id
)
SELECT DISTINCT
    customer_id,
    first_name,
    last_name,
    total_sum,
    max_price,
    min_price,
    transactions_count
FROM 
    customer_metrics
ORDER BY 
    total_sum DESC, 
    transactions_count DESC;

-- max
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) AS total_sum
FROM 
    transaction t
JOIN 
    customer c ON t.customer_id = c.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name
HAVING 
    SUM(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) IS NOT NULL
ORDER BY 
    total_sum ASC
LIMIT 1;

-- min
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) AS total_sum
FROM 
    transaction t
JOIN 
    customer c ON t.customer_id = c.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name
HAVING 
    SUM(CAST(REPLACE(t.list_price, ',', '.') AS NUMERIC)) IS NOT NULL
ORDER BY 
    total_sum DESC
LIMIT 1;

WITH ranked_transactions AS (
    SELECT 
        t.transaction_id,
        t.customer_id,
        c.first_name,
        c.last_name,
        t.transaction_date,
        t.brand,
        t.product_line,
        t.list_price,
        ROW_NUMBER() OVER (PARTITION BY t.customer_id ORDER BY TO_DATE(t.transaction_date, 'DD.MM.YYYY') ASC) AS transaction_rank
    FROM 
        transaction t
    JOIN 
        customer c ON t.customer_id = c.customer_id
)
SELECT 
    transaction_id,
    customer_id,
    first_name,
    last_name,
    transaction_date,
    brand,
    product_line,
    list_price
FROM 
    ranked_transactions
WHERE 
    transaction_rank = 1
ORDER BY 
    customer_id;

WITH transaction_intervals AS (
    SELECT 
        t1.customer_id,
        c.first_name,
        c.last_name,
        c.job_title,
        t1.transaction_date as first_date,
        t2.transaction_date as next_date,
        TO_DATE(t2.transaction_date, 'DD.MM.YYYY') - TO_DATE(t1.transaction_date, 'DD.MM.YYYY') AS days_interval
    FROM 
        transaction t1
    JOIN 
        transaction t2 ON t1.customer_id = t2.customer_id
        AND TO_DATE(t1.transaction_date, 'DD.MM.YYYY') < TO_DATE(t2.transaction_date, 'DD.MM.YYYY')
    JOIN 
        customer c ON t1.customer_id = c.customer_id
    WHERE 
        NOT EXISTS (
            SELECT 1
            FROM transaction t3
            WHERE t3.customer_id = t1.customer_id
            AND TO_DATE(t3.transaction_date, 'DD.MM.YYYY') > TO_DATE(t1.transaction_date, 'DD.MM.YYYY')
            AND TO_DATE(t3.transaction_date, 'DD.MM.YYYY') < TO_DATE(t2.transaction_date, 'DD.MM.YYYY')
        )
)
SELECT 
    customer_id,
    first_name,
    last_name,
    job_title,
    first_date,
    next_date,
    days_interval
FROM 
    transaction_intervals
WHERE 
    days_interval = (SELECT MAX(days_interval) FROM transaction_intervals)
ORDER BY 
    customer_id;
