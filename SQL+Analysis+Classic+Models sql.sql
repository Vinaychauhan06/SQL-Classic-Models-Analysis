-- Calculate the average order amount for each country
select country, AVG(quantityOrdered * priceEach) as average_order_amount from  classicmodels.customers c
inner join  classicmodels.orders o on c.customerNumber=o.customerNumber
inner join classicmodels.orderdetails od on od.orderNumber=o.orderNumber
group by country
order by average_order_amount DESC;




-- Calculate the total sales amount for each product line
 select productLine,sum(quantityOrdered * priceEach) as total_sales from classicmodels.products c
 inner join classicmodels.orderdetails o
 on c.productCode=o.productCode
group by productLine;
 
 


-- List the top 10 best-selling products based on total quantity sold
 select productname,sum(quantityOrdered)as total_quantity_sold from classicmodels.products c
 inner join classicmodels.orderdetails o
 on c.productCode=o.productCode
group by productname
order by total_quantity_sold desc
limit 10;
 



-- Evaluate the sales performance of each sales representative
SELECT e.firstName,e.lastName,sum(quantityOrdered * priceEach) as total_sales
FROM classicmodels.customers c
INNER JOIN classicmodels.employees e #Use INNER JOIN if you only want to include employees who have customers with orders and order details.
    ON c.salesRepEmployeeNumber = e.employeeNumber
left JOIN classicmodels.orders o 	#Use LEFT JOIN if you want to include all employees because many of customer who's order is null and they are assicated with employee so we also want to inculude
    ON c.customerNumber = o.customerNumber
left JOIN classicmodels.orderdetails od
    ON o.orderNumber = od.orderNumber
    group by e.firstName,e.lastName;
    
-- Calculate the average number of orders placed by each customer
select count(o.orderNumber)/count(distinct c.customerNumber) from  classicmodels.customers c
left  join classicmodels.orders o
on c.customerNumber=o.customerNumber;



-- Calculate the percentage of orders that were shipped on time
Select sum(case when shippedDate <= requiredDate then 1 else 0 end)/count(orderNumber) * 100  as on_time  from classicmodels.orders;





-- Calculate the profit margin for each product by subtracting the cost of goods sold (COGS) from the sales revenue

SELECT 
    p.productName,
    SUM((o.quantityOrdered * p.buyPrice) - (o.priceEach * o.quantityOrdered)) AS profit_margin
FROM 
    classicmodels.orderdetails o
INNER JOIN 
    classicmodels.products p
ON 
    o.productCode = p.productCode
GROUP BY 
    p.productName;


-- Segment Customers by Value

select * from  classicmodels.customers c
left join #because i want to include null value also
(SELECT *,
case when net_sale > 100000 THEN 'HIGH VALUE'
	when net_sale BETWEEN 80000 AND 100000 THEN 'MEDIUM VALUE'
	when net_sale <50000 THEN 'LOW VALUE'
  ELSE "OTHERS" END AS SEGMENT
FROM
(SELECT customerNumber,sum(quantityOrdered *  priceEach) as net_sale from  classicmodels.orders o
inner join classicmodels.orderdetails od
on  o.orderNumber=od.orderNumber
group by customerNumber) t1
) t2
on c.customerNumber=t2.customerNumber;

-- Identify frequently co-purchased products to understand cross-selling opportunities
select o.productCode,p.productName,o2.productCode,p2.productName,count(*) from classicmodels.orderdetails o
inner join classicmodels.orderdetails o2 
on o.ordernumber=o2.ordernumber and o.productCode<> o2.productCode
inner join classicmodels.products p
on o.productCode=p.productCode
inner join products p2
on  o2.productCode=p2.productCode
group by o.productCode,p.productName,o2.productCode,p2.productName;




