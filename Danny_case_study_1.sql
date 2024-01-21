Create database FM;
use FM;


CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);


INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-- 1)What is the total amount each customer spent at the restaurant?
Select s.customer_id,sum(m.price) as total_price from
sales s join menu m on s.product_id = m.product_id
group by s.customer_id;

-- 2)How many days has each customer visited the restaurant?
Select customer_id, count(distinct order_date) as No_of_visits
from sales
group by customer_id;

-- 3)What was the first item from the menu purchased by each customer?
SELECT distinct customer_id, product_name
FROM (
    SELECT s.customer_id, m.product_name,
           dense_rank() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
    FROM sales s
    JOIN Menu m ON s.product_id = m.product_id
) X
WHERE rn = 1
;


-- 4)What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name as most_purchased_Product,count(*) as Product_Bought_Count from sales s
join Menu m on s.product_id = m.product_id
where m.product_id = (select max(m.product_id) from sales s
					join Menu m on s.product_id = m.product_id
					)
group by m.product_name;

-- 5)Which item was the most popular for each customer?
with cte as(select s.customer_id,m.product_name,COUNT(*) as total_Purchase,
rank() over(partition by s.customer_id order by COUNT(*) DESC) as rnk
from sales s
join Menu m on s.product_id = m.product_id
group by s.customer_id,m.product_name)
Select customer_id,product_name
from cte
where rnk = 1;

-- 6)Which item was purchased first by the customer after they became a member?
with cte as(Select s.customer_id,menu.product_name,rank() over(partition by s.customer_id order by s.order_date) as rn from sales s 
join members m on s.customer_id = m.customer_id and s.order_date > m.join_date
join menu  on s.product_id = menu.product_id)
select customer_id,product_name
from cte
where rn = 1;

-- 7)Which item was purchased just before the customer became a member?
	
with cte as(Select s.customer_id,menu.product_name,rank() over(partition by s.customer_id order by s.order_date desc) as rn from sales s 
join members m on s.customer_id = m.customer_id and s.order_date < m.join_date
join menu  on s.product_id = menu.product_id)
select customer_id,product_name
from cte
where rn = 1;

-- 8)What is the total items and amount spent for each member before they became a member?
Select s.customer_id,count(*) as Total_Items,sum(price) as total_price from sales s 
join members m on s.customer_id = m.customer_id and s.order_date < m.join_date
join menu  on s.product_id = menu.product_id
group by s.customer_id
order by  s.customer_id;

-- 9)If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

Select s.customer_id,sum(case when  m.product_name = 'sushi' then 20*m.price else 10*price end) as total_Points
from sales s
join Menu m on s.product_id = m.product_id
group by s.customer_id;

-- 10)In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT s.customer_id,
       SUM(IF(order_date BETWEEN join_date AND DATE_ADD(join_date, INTERVAL 6 DAY), price*10*2, IF(product_name = 'sushi', price*10*2, price*10))) AS customer_points
FROM menu AS m
INNER JOIN sales AS s ON m.product_id = s.product_id
INNER JOIN members AS mem USING (customer_id)
WHERE order_date <='2021-01-31'
  AND order_date >=join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

