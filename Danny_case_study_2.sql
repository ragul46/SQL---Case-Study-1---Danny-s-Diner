use FM;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
------------------------ A - Pizza Metrics -------------------
-- Q1: How many pizzas were ordered?
Select count(order_id) from customer_orders;

-- Q2: How many unique customer orders were made?
Select count(distinct customer_id) as Total_customer from customer_orders;

-- Q3: How many successful orders were delivered by each runner?
Select runner_id,count(*) as runner_orders
from runner_orders
where distance != 0
group by runner_id;

-- Q4: How many of each type of pizza was delivered?
Select co.pizza_id,count(*) as Total_Pizzas from customer_orders co
join runner_orders rn
on co.order_id = rn.order_id
where rn.distance != 0
group by co.pizza_id;

-- Q5: How many Vegetarian and Meatlovers were ordered by each customer?
Select co.customer_id,pz.pizza_name,count(*) as Total_Pizzas from customer_orders co
join pizza_names pz on co.pizza_id = pz.pizza_id
group by co.customer_id,co.pizza_id
order by co.customer_id;

-- Q6: What was the maximum number of pizzas delivered in a single order?
Select co.order_id,count(*) as No_Of_Orders from customer_orders co
join runner_orders rn
on co.order_id = rn.order_id
where rn.distance != 0
group by co.order_id
order by No_Of_Orders desc limit 1;

-- Q7: For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- Here we need to take care of null values in customer_orders for that we're creating one temperory table to handle all nulls.

create table updated_customer_orders_1 as
select order_id, customer_id, pizza_id, nullif(ud_exclusions, 'null') as udp_exclusions , nullif(ud_extras, 'null') as udp_extras, order_time
from updated_customer_orders;

Select uco.customer_id, sum(case when uco.udp_exclusions is not null or uco.udp_extras is not null then 1 else 0 end) as With_changes,
sum(case when uco.udp_exclusions is null or uco.udp_extras is null then 1 else 0 end) as No_changes
from updated_customer_orders_1 uco
join runner_orders ro on uco.order_id = ro.order_id
where ro.distance != 0
group by uco.customer_id;

-- Q8: How many pizzas were delivered that had both exclusions and extras?
Select
sum(case when uco.udp_exclusions is not null or uco.udp_extras is not null then 1 else 0 end) as with_exclusion_and_extra
from updated_customer_orders_1 uco
join runner_orders ro on uco.order_id = ro.order_id
where ro.distance != 0;

-- Q9: What was the total volume of pizzas ordered for each hour of the day?
Select date_format(order_time,'%H') as hours,count(*) as Total_Orders from customer_orders
group by date_format(order_time,'%H')
order by Total_Orders desc;
-- Above one is for just reference how can we find out peak hours among all the days

select *, (Total_orders/24) as ord_pizza_each_hour from (select day(order_time) as day,count(*) as Total_orders from customer_orders
group by day(order_time)) X;

-- Q10: What was the volume of orders for each day of the week?

-- If you want days only according to the table you can use below
select dayname(order_time) as week_day,  COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders
group by week_day;

-- if you want missing days also then you can use the below one.
SELECT
  all_days.day_of_week,
  COUNT(order_time) AS occurrence_count
FROM
  (SELECT 'Monday' AS day_of_week UNION SELECT 'Tuesday' UNION SELECT 'Wednesday' UNION SELECT 'Thursday' UNION SELECT 'Friday' UNION SELECT 'Saturday' UNION SELECT 'Sunday') all_days
LEFT JOIN
  customer_orders ON DAYNAME(order_time) = all_days.day_of_week
GROUP BY
  all_days.day_of_week
ORDER BY
  all_days.day_of_week;
  
  --------------------- B.Runner and Customer Experience -------------------------------
  -- Q1: How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
  
Select *,ceil(datediff(registration_date,'2020-12-31')/7) from runners;
-- Ignore the above
  
select week(registration_date,5) ,count(runner_id)
from runners
group by week(registration_date,5);

-- Q2: What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select round(avg(second_diff)/60,2) as Avgtime_in_minutes from (Select timestampdiff(second,co.order_time,ro.pickup_time) as second_diff from customer_orders co
join runner_orders ro
on co.order_id = ro.order_id
where ro.distance !=0
group by co.order_id) X;

-- Q3: Is there any relationship between the number of pizzas and how long the order takes to prepare?

select total_pizza,avg(waiting_time) as avg_time_for_prepare from (Select co.order_id,count(co.order_id) as total_pizza,timestampdiff(minute,co.order_time,ro.pickup_time) as waiting_time from customer_orders co
join runner_orders ro on co.order_id = ro.order_id
where ro.distance !=0
group by co.order_id) x
group by total_pizza;

-- Q4: What was the average distance travelled for each customer?

select customer_id,avg(distance) from (Select co.order_id,co.customer_id,min(ro.distance) as distance from customer_orders co
join runner_orders ro on co.order_id = ro.order_id
where ro.distance !=0
group by co.order_id,co.customer_id) x
group by customer_id;

-- Q5: What was the difference between the longest and shortest delivery times for all orders?
select y.mx- y.mn as Max_min_time_diff from (select x.order_id, max(x.duration) as mx, min(x.duration) as mn
from (select order_id, duration
from runner_orders
where duration != 'null')x)y;

-- Q6: What was the average speed for each runner for each delivery and do you notice any trend for these values?
select runner_id, round(distance/(duration/60),2) as AVG_Speed
from runner_orders
where distance != 0;

-- Q7: What is the successful delivery percentage for each runner?

select runner_id,
sum(case when distance = 'null' then 0 else 1 end)/count(runner_id)*100 as delivery_Percentage
from runner_orders
group by runner_id;

--------------- C. Ingredient Optimisation ---------------
-- Q1: What are the standard ingredients for each pizza?

create table updated_pizza_recipes as
SELECT
    Pizza_Id,
    TRIM(BOTH ' ' FROM SUBSTRING_INDEX(SUBSTRING_INDEX(Toppings, ',', numbers.n), ',', -1)) AS topping
FROM
    pizza_recipes
JOIN
    numbers
ON
    numbers.n <= LENGTH(Toppings) - LENGTH(REPLACE(Toppings, ',', '')) + 1
    order by pizza_id;

Select up.Pizza_id,group_concat(pt.topping_name) from updated_pizza_recipes up
join pizza_toppings pt
on up.topping = pt.topping_id
group by up.Pizza_id;

-- Q2: What was the most commonly added extra?

SELECT
    order_id,
    TRIM(BOTH ' ' FROM SUBSTRING_INDEX(SUBSTRING_INDEX(udp_extras, ',', 2), ',', 2)) AS extras
FROM
    updated_customer_orders_1;


WITH RECURSIVE numbers1 AS (
  SELECT 1 AS n
  UNION
  SELECT n + 1
  FROM numbers
  WHERE n < (SELECT MAX(LENGTH(udp_extras) - LENGTH(REPLACE(udp_extras, ',', '')) + 1) FROM updated_customer_orders_1)
),
cte1 as (SELECT
    Pizza_Id,
    TRIM(BOTH ' ' FROM SUBSTRING_INDEX(SUBSTRING_INDEX(udp_extras, ',', numbers1.n), ',', -1)) AS `number1`
FROM
    updated_customer_orders_1
JOIN
    numbers1
ON
    numbers1.n <= LENGTH(udp_extras) - LENGTH(REPLACE(udp_extras, ',', '')) + 1)
select pz.topping_name,count(*) as cnt from cte1 c
join pizza_toppings pz
on c.number1 = pz.topping_id
group by pz.topping_id;

-- Q3: What was the most common exclusion?


WITH RECURSIVE numbers1 AS (
  SELECT 1 AS n
  UNION
  SELECT n + 1
  FROM numbers
  WHERE n < (SELECT MAX(LENGTH(udp_exclusions) - LENGTH(REPLACE(udp_exclusions, ',', '')) + 1) FROM updated_customer_orders_1)
),
cte1 as (SELECT
    Pizza_Id,
    TRIM(BOTH ' ' FROM SUBSTRING_INDEX(SUBSTRING_INDEX(udp_exclusions, ',', numbers1.n), ',', -1)) AS `number1`
FROM
    updated_customer_orders_1
JOIN
    numbers1
ON
    numbers1.n <= LENGTH(udp_exclusions) - LENGTH(REPLACE(udp_exclusions, ',', '')) + 1)
select pz.topping_name,count(*) as cnt from cte1 c
join pizza_toppings pz
on c.number1 = pz.topping_id
group by pz.topping_id;

-- Q4: Generate an order item for each record in the customers_orders table in the format of one of the following:

SELECT
	tco.order_id,
    tco.pizza_id,
    pn.pizza_name,
    tco.exclusions,
    tco.extras,
    CASE
		WHEN tco.pizza_id = 1 AND tco.exclusions = '' AND tco.extras = '' THEN 'Meat Lovers'
		WHEN tco.pizza_id = 1 AND tco.exclusions = 'null' AND tco.extras = 'null' THEN 'Meat Lovers'
        WHEN pn.pizza_name = 'Vegetarian' THEN 'Vegetarian'
        WHEN tco.pizza_id = 1 AND tco.exclusions = '4' AND tco.extras = '' THEN 'Meat Lovers - Exclude Cheese'
        WHEN tco.pizza_id = 2 AND tco.exclusions = '4' AND tco.extras = '' THEN 'Vegetarian - Exclude Cheese'
        WHEN tco.pizza_id = 1 AND tco.exclusions = '' AND tco.extras = '1' THEN 'Meat Lovers - Extra Bacon'
		WHEN tco.pizza_id = 1 AND tco.exclusions = 'null' AND tco.extras = '1' THEN 'Meat Lovers - Extra Bacon'
        WHEN tco.pizza_id = 2 AND tco.exclusions = '' AND tco.extras = '1' THEN 'Vegetarian - Extra Bacon'
        WHEN tco.pizza_id = 1 AND tco.exclusions = '4' AND tco.extras = '1, 5' THEN 'Meat Lovers - Exclude Cheese - Extra Bacon and Chicken'
        WHEN tco.pizza_id = 1 AND tco.exclusions = '2, 6' AND tco.extras = '1, 4' THEN 'Meat Lovers - Exclude BBQ Sauce and Mushroom - Extra Bacon and Cheese'
	END AS order_item
FROM customer_orders tco
JOIN pizza_names pn ON tco.pizza_id = pn.pizza_id;

-- Q6: What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
Select pt.topping_name,count(*) as Product_used_count from updated_pizza_recipes up
join customer_orders c on up.pizza_id = c.pizza_id
join pizza_toppings pt on up.topping = pt.topping_id
join runner_orders ro on c.order_id = ro.order_id
where ro.distance != 0
group by pt.topping_name
order by Product_used_count desc;

--------------- D. Pricing and Ratings ----------------------
-- Q1)If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

Select sum(case when c.pizza_id = 1 then 12 else 0 end) +
sum(case when c.pizza_id = 2 then 10 else 0 end) as total_sales
from customer_orders c
join runner_orders ro on c.order_id = ro.order_id
where ro.distance != 0;

-- 2. What if there was an additional $1 charge for any pizza extras?- Add cheese is $1 extra


WITH cte_price AS (
  SELECT
    c.order_id,
    SUM(CASE WHEN c.pizza_id = 1 THEN 12 ELSE 10 END) AS pizza_cost
  FROM
    customer_orders c
    JOIN runner_orders ro ON c.order_id = ro.order_id
  WHERE
    ro.distance != 0
),
cte1 AS (
  SELECT
    LENGTH(GROUP_CONCAT(c.extras))-(LENGTH(REPLACE(GROUP_CONCAT(c.extras), ',', '')) + 1) AS extra_cost
  FROM
    customer_orders c
    JOIN runner_orders ro ON c.order_id = ro.order_id
  WHERE
    ro.distance != 0
    AND c.extras IS NOT NULL
    AND c.extras != ''
)
SELECT
  cte_price.pizza_cost + extra_cost AS total_cost
FROM
  cte_price, cte1;
  
  
 -- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - 
 -- generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
 
 DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
order_id int,
rating int);

INSERT INTO ratings VALUES 
(1, 5), (2, 3), (3, 4), (4, 2), (5,3), (7, 3), (8, 4), (10, 5);

SELECT * FROM ratings;

-- 4)

Select co.customer_id,
co.order_id,
ro.runner_id,
r.rating,
co.order_time,
ro.pickup_time,
minute(timediff(co.order_time,ro.pickup_time)) as Time_between_order_and_pickup,left(ro.duration,2) as duration,
round(ro.distance/(ro.duration/60),1) as Average_speed,
count(*) as Total_number_of_pizzas
from customer_orders co
join runner_orders ro on co.order_id = ro.order_id
join ratings r on ro.order_id = r.order_id
group by co.order_id,ro.runner_id;

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per 
-- kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

Select sum(case when c.pizza_id = 1 then 12 else 0 end) +
sum(case when c.pizza_id = 2 then 10 else 0 end) as total_sales,
from customer_orders c
join runner_orders ro on c.order_id = ro.order_id
where ro.distance != 0;

select 138 - sum(distance)*0.3 from
(Select ro.order_id,ro.distance
from customer_orders c
join runner_orders ro on c.order_id = ro.order_id
where ro.distance != 0
group by order_id) x;