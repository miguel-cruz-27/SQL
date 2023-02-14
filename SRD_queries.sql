USE FlyHigh;				# We will use the FlyHigh database

#In every query, the select_type is always simple, which means this is not UNION or subquery.
#As well as that, we do not have partitions.

############################################################################################################################
## Query 1 -> List all the customer’s names, dates, and products or services used/booked/rented/bought by these customers ##
##			  in a range of two dates.																					  ##
############################################################################################################################
#Here, we considered as the date of buying a ticket, the time at which the order was made.
EXPLAIN
SELECT c.full_name AS 'Full Name',DATE(o.date_time) AS Date,f.flight_number AS 'Flight Number',
i.seat_code AS 'Seat Code'
FROM order_item i
JOIN `order` o ON o.order_id=i.order_id
JOIN customer c ON c.cust_id=o.cust_id
JOIN flight f ON f.flight_id=i.flight_id
JOIN payment p ON p.order_id=o.order_id
WHERE (o.date_time BETWEEN '2021-02-10 00:00:00' AND '2022-02-10 00:00:00') AND (p.`status`=1);
#We are using five tables: payment (p), flight (f), order_item (i), order (o) and customer (c).
#The query accesses the payment table, going through all the lines (31), with one possible
#key (order_id) but none are effectively used (which is a possible issue).
#The rest only go through one row, which is very good for the optimization of the query.
#Therefore, the query seems to have a good performance. Finding a way to improve the type of
#the first access (ALL) could be useful to improve the performance, as well as a meaningful index.

###################################################################################################################################
## Query 2 -> List the best three customers/products/services/places (you are free to define the criteria for what means “best”) ##
###################################################################################################################################
-- NOTE: For the company the best clients are those who spend the most money
EXPLAIN
SELECT c.full_name AS 'Full Name', sum(p.total_price) AS Sales
FROM payment p
JOIN `order` o ON o.order_id=p.order_id
JOIN customer c ON c.cust_id=o.cust_id
WHERE p.`status`=1
GROUP BY c.cust_id
ORDER BY sales DESC
LIMIT 3;
#We are using three tables: payment (p), order (o) and customer (c).
#The query accesses the payment table, going through all the lines (31), with one possible
#keys (order_id) but none are effectively used (which is a possible issue).
#The rest only go through one row, which is very good for the optimization of the query.
#The LIMIT clause was used, which also helps in faster querying.
#Therefore, the query seems to have a good performance. Finding a way to improve type of
#the first access (ALL) could be useful to improve the performance, as well as a meaningful index.

#####################################################################################################################
## Query 3 -> Get the average amount of sales/bookings/rents/deliveries for a period that involves 2 or more years ##
#####################################################################################################################
#Here, we considered as the date of buying a ticket, the time at which the order was made.
EXPLAIN
SELECT CONCAT(DATE_FORMAT('2020-02-01','%m/%Y'),'-',DATE_FORMAT('2022-02-01','%m/%Y')) 
 AS 'PeriodOfSales', sum(p.total_price) AS 'TotalSales (euros)',
ROUND(sum(p.total_price)/TIMESTAMPDIFF(month,'2020-02-01','2022-02-01'),2) AS 'MonthlyAverage (of the given period)',
ROUND(sum(p.total_price)/TIMESTAMPDIFF(year,'2020-02-01','2022-02-01'),2) AS 'YearlyAverage (of the given period)'
FROM payment p
JOIN `order` o ON o.order_id=p.order_id
WHERE (o.date_time BETWEEN '2020-02-01 00:00:00' AND '2022-02-01 00:00:00') AND (p.`status`=1);
#We are using two tables: payment (p) and order (o).
#The query accesses the payment table, going through all the lines (31), with one possible
#key (order_id), but none are effectively used (which indicates a possible issue).
#The other only goes through one row, which is very good for the optimization of the query.
#The query seems to be good but it could have better performance by finding a way to improve type of
#the first access (ALL), as well as a meaningful index.

#######################################################################################################
## Query 4 -> Get the total sales/bookings/rents/deliveries by geographical location (city/country). ##
#######################################################################################################
#We considered as location the airport from where the flight departs.
EXPLAIN
SELECT a.airport_name AS 'Airport Name (of departure)',sum(p.total_price) AS 'Total Sales'
FROM order_item i
JOIN `order` o ON o.order_id=i.order_id
JOIN payment p ON p.order_id=o.order_id  
JOIN flight f ON f.flight_id=i.flight_id
JOIN route r ON r.route_id=f.route_id
JOIN airport a ON a.airport_id=r.origin_id
WHERE p.`status`=1
GROUP BY origin_id;
#We are using six tables: payment (p), route (r), flight (f), order_item (i), order (o) and airport (a).
#The query accesses the payment table, going through all the lines (31), with one possible
#key (order_id) but none are effectively used (which is a possible issue).
#The rest only go through one row, which is very good for the optimization of the query.
#Therefore, the query seems to have a good performance. Finding a way to improve type of
#the first access (ALL) could be useful to improve the performance, as well as a meaningful index.

#################################################################################################################
## Query 5 -> List all the locations where products/services were sold, and the product has customer’s ratings ##
#################################################################################################################
#We considered as location the airport from where the flight departs.
EXPLAIN
SELECT a.airport_name AS 'Airport Name (of departure)'
FROM rating ra
JOIN flight f ON f.flight_id=ra.flight_id
JOIN route r ON r.route_id=f.route_id
JOIN airport a ON a.airport_id=r.origin_id
GROUP BY a.airport_name;
#We are using four tables: flight (f), rating (ra), route (r) and airport (a).
#The query accesses the route table, going through all the lines (10), with two possible
#keys (the primary key and fk_route_1) and using fk_route_1 as the key.
#The rest only go through one or two rows, which is very good for the optimization of the query.
#Instead of using SELECT DISTINCT we used group by for faster querying.
#Therefore, the query seems to have a good performance. Moreover, here, the first access has a type of index
#which did not happen in the other queries and is a good sign in terms of optimization.