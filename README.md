# SQL Analysis - Classic Models

## Overview

This project provides an in-depth analysis of the Classic Models database using SQL. The analysis focuses on various business metrics such as average order amounts, total sales, best-selling products, sales performance of sales representatives, customer segmentation, and more. This repository demonstrates my ability to write and execute SQL queries to derive meaningful insights from data.

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Key SQL Queries](#key-sql-queries)
- [Technologies Used](#technologies-used)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Contact](#contact)

## Project Structure

- **SQL Queries**: Contains all the SQL queries used for the analysis.
- **Results**: Includes any output files or screenshots demonstrating the results of the analysis.

## Key SQL Queries

### 1. Calculate the Average Order Amount for Each Country
```sql
SELECT country, AVG(quantityOrdered * priceEach) AS average_order_amount 
FROM classicmodels.customers c
INNER JOIN classicmodels.orders o ON c.customerNumber = o.customerNumber
INNER JOIN classicmodels.orderdetails od ON od.orderNumber = o.orderNumber
GROUP BY country
ORDER BY average_order_amount DESC;
```
**Explanation**: This query calculates the average order amount for each country by joining the customers, orders, and order details tables.

### 2. Calculate the Total Sales Amount for Each Product Line
```sql
SELECT productLine, SUM(quantityOrdered * priceEach) AS total_sales 
FROM classicmodels.products c
INNER JOIN classicmodels.orderdetails o ON c.productCode = o.productCode
GROUP BY productLine;
```
**Explanation**: This query sums the total sales amount for each product line, providing insights into which product lines generate the most revenue.

### 3. List the Top 10 Best-Selling Products Based on Total Quantity Sold
```sql
SELECT productName, SUM(quantityOrdered) AS total_quantity_sold 
FROM classicmodels.products c
INNER JOIN classicmodels.orderdetails o ON c.productCode = o.productCode
GROUP BY productName
ORDER BY total_quantity_sold DESC
LIMIT 10;
```
**Explanation**: This query identifies the top 10 best-selling products by summing the total quantities sold.

### 4. Evaluate the Sales Performance of Each Sales Representative
```sql
SELECT e.firstName, e.lastName, SUM(quantityOrdered * priceEach) AS total_sales
FROM classicmodels.customers c
INNER JOIN classicmodels.employees e ON c.salesRepEmployeeNumber = e.employeeNumber
LEFT JOIN classicmodels.orders o ON c.customerNumber = o.customerNumber
LEFT JOIN classicmodels.orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY e.firstName, e.lastName;
```
**Explanation**: This query evaluates the sales performance of each sales representative by calculating the total sales associated with each.

### 5. Calculate the Average Number of Orders Placed by Each Customer
```sql
SELECT COUNT(o.orderNumber)/COUNT(DISTINCT c.customerNumber) 
FROM classicmodels.customers c
LEFT JOIN classicmodels.orders o ON c.customerNumber = o.customerNumber;
```
**Explanation**: This query calculates the average number of orders placed by each customer, providing insights into customer engagement.

### 6. Calculate the Percentage of Orders That Were Shipped on Time
```sql
SELECT SUM(CASE WHEN shippedDate <= requiredDate THEN 1 ELSE 0 END)/COUNT(orderNumber) * 100 AS on_time  
FROM classicmodels.orders;
```
**Explanation**: This query calculates the percentage of orders that were shipped on time by comparing the shipped date with the required date.

### 7. Calculate the Profit Margin for Each Product
```sql
SELECT p.productName, 
       SUM((o.quantityOrdered * p.buyPrice) - (o.priceEach * o.quantityOrdered)) AS profit_margin
FROM classicmodels.orderdetails o
INNER JOIN classicmodels.products p ON o.productCode = p.productCode
GROUP BY p.productName;
```
**Explanation**: This query calculates the profit margin for each product by subtracting the cost of goods sold (COGS) from the sales revenue.

### 8. Segment Customers by Value
```sql
SELECT * 
FROM classicmodels.customers c
LEFT JOIN (
    SELECT *,
    CASE 
        WHEN net_sale > 100000 THEN 'HIGH VALUE'
        WHEN net_sale BETWEEN 80000 AND 100000 THEN 'MEDIUM VALUE'
        WHEN net_sale < 50000 THEN 'LOW VALUE'
        ELSE 'OTHERS' 
    END AS SEGMENT
    FROM (
        SELECT customerNumber, SUM(quantityOrdered * priceEach) AS net_sale 
        FROM classicmodels.orders o
        INNER JOIN classicmodels.orderdetails od ON o.orderNumber = od.orderNumber
        GROUP BY customerNumber
    ) t1
) t2 ON c.customerNumber = t2.customerNumber;
```
**Explanation**: This query segments customers into different value categories based on their total sales.

### 9. Identify Frequently Co-Purchased Products
```sql
SELECT o.productCode, p.productName, o2.productCode, p2.productName, COUNT(*) 
FROM classicmodels.orderdetails o
INNER JOIN classicmodels.orderdetails o2 ON o.orderNumber = o2.orderNumber AND o.productCode <> o2.productCode
INNER JOIN classicmodels.products p ON o.productCode = p.productCode
INNER JOIN classicmodels.products p2 ON o2.productCode = p2.productCode
GROUP BY o.productCode, p.productName, o2.productCode, p2.productName;
```
**Explanation**: This query identifies products that are frequently co-purchased to understand cross-selling opportunities.

## Technologies Used

- SQL
- MySQL or any SQL-compatible database system

## Getting Started

1. Clone this repository:
    ```
    git clone https://github.com/yourusername/SQL-Classic-Models-Analysis.git
    ```
2. Import the Classic Models database into your SQL environment.
3. Execute the SQL scripts provided in the repository.

## Usage

Execute the queries provided in the `SQL Queries` section to perform the analysis and gain insights from the Classic Models database.

## Contact

For any questions or feedback, feel free to reach out:

- **Name**: Vinay Chauhan
- **Email**: vc203132@gmail.com


