-- ============================================================
-- ADVANCED SQL ANALYSIS — Classic Models Database
-- Extension: CTEs, Window Functions, Ranking, and Running Totals
-- Author: Vinay Chauhan
-- ============================================================


-- ------------------------------------------------------------
-- 1. TOP 3 BEST-SELLING PRODUCTS PER PRODUCT LINE (RANK + CTE)
-- Uses a CTE to pre-aggregate sales, then RANK() to find top
-- performers within each category (partitioned window function)
-- ------------------------------------------------------------
WITH product_sales AS (
    SELECT
        p.productLine,
        p.productName,
        SUM(od.quantityOrdered) AS total_quantity_sold,
        SUM(od.quantityOrdered * od.priceEach) AS total_revenue
    FROM classicmodels.orderdetails od
    INNER JOIN classicmodels.products p
        ON od.productCode = p.productCode
    GROUP BY p.productLine, p.productName
),
ranked_products AS (
    SELECT
        productLine,
        productName,
        total_quantity_sold,
        total_revenue,
        RANK() OVER (
            PARTITION BY productLine
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM product_sales
)
SELECT *
FROM ranked_products
WHERE revenue_rank <= 3
ORDER BY productLine, revenue_rank;


-- ------------------------------------------------------------
-- 2. MONTH-OVER-MONTH SALES GROWTH (LAG WINDOW FUNCTION)
-- Uses LAG() to compare each month's revenue against the
-- previous month, calculating a rolling growth percentage
-- ------------------------------------------------------------
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(o.orderDate, '%Y-%m') AS order_month,
        SUM(od.quantityOrdered * od.priceEach) AS monthly_revenue
    FROM classicmodels.orders o
    INNER JOIN classicmodels.orderdetails od
        ON o.orderNumber = od.orderNumber
    GROUP BY DATE_FORMAT(o.orderDate, '%Y-%m')
)
SELECT
    order_month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_month))
        / LAG(monthly_revenue) OVER (ORDER BY order_month) * 100, 2
    ) AS mom_growth_pct
FROM monthly_sales
ORDER BY order_month;


-- ------------------------------------------------------------
-- 3. RUNNING TOTAL OF CUMULATIVE REVENUE BY ORDER DATE
-- Uses SUM() OVER (ORDER BY ...) as a running-total window
-- function to track cumulative sales growth over time
-- ------------------------------------------------------------
WITH daily_sales AS (
    SELECT
        o.orderDate,
        SUM(od.quantityOrdered * od.priceEach) AS daily_revenue
    FROM classicmodels.orders o
    INNER JOIN classicmodels.orderdetails od
        ON o.orderNumber = od.orderNumber
    GROUP BY o.orderDate
)
SELECT
    orderDate,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY orderDate) AS running_total_revenue
FROM daily_sales
ORDER BY orderDate;


-- ------------------------------------------------------------
-- 4. CUSTOMER VALUE SEGMENTATION USING A CTE (refactor of the
-- original nested-subquery version into a clean, readable CTE)
-- ------------------------------------------------------------
WITH customer_totals AS (
    SELECT
        c.customerNumber,
        c.customerName,
        SUM(od.quantityOrdered * od.priceEach) AS net_sales
    FROM classicmodels.customers c
    INNER JOIN classicmodels.orders o
        ON c.customerNumber = o.customerNumber
    INNER JOIN classicmodels.orderdetails od
        ON o.orderNumber = od.orderNumber
    GROUP BY c.customerNumber, c.customerName
),
customer_segments AS (
    SELECT
        customerNumber,
        customerName,
        net_sales,
        CASE
            WHEN net_sales > 100000 THEN 'HIGH VALUE'
            WHEN net_sales BETWEEN 80000 AND 100000 THEN 'MEDIUM VALUE'
            WHEN net_sales < 50000 THEN 'LOW VALUE'
            ELSE 'OTHERS'
        END AS segment
    FROM customer_totals
)
SELECT *
FROM customer_segments
ORDER BY net_sales DESC;


-- ------------------------------------------------------------
-- 5. TOP CUSTOMER PER SALES REPRESENTATIVE (ROW_NUMBER + CTE)
-- Uses ROW_NUMBER() to isolate the single highest-value
-- customer managed by each sales rep
-- ------------------------------------------------------------
WITH rep_customer_sales AS (
    SELECT
        e.employeeNumber,
        e.firstName,
        e.lastName,
        c.customerNumber,
        c.customerName,
        SUM(od.quantityOrdered * od.priceEach) AS customer_revenue
    FROM classicmodels.employees e
    INNER JOIN classicmodels.customers c
        ON e.employeeNumber = c.salesRepEmployeeNumber
    INNER JOIN classicmodels.orders o
        ON c.customerNumber = o.customerNumber
    INNER JOIN classicmodels.orderdetails od
        ON o.orderNumber = od.orderNumber
    GROUP BY e.employeeNumber, e.firstName, e.lastName, c.customerNumber, c.customerName
),
ranked_customers AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY employeeNumber
            ORDER BY customer_revenue DESC
        ) AS rn
    FROM rep_customer_sales
)
SELECT firstName, lastName, customerName, customer_revenue
FROM ranked_customers
WHERE rn = 1
ORDER BY customer_revenue DESC;
