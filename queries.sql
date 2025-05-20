-- Проект Продажи (4)

SELECT
COUNT(*) AS customers_count -- считаем количество строк
FROM customers;

-- Проект Продажи (5)

-- top_10_total_income

SELECT concat(emp.first_name, ' ', emp.last_name) AS seller, -- объединяем имя и фамилию
COUNT(sales_id) AS operations, -- считаем количество продаж
FLOOR(SUM(s.quantity * p.price)) AS income -- обрезаем сумму выручки
FROM sales s
INNER JOIN products p -- присоединяем таблицу
USING(product_id)
INNER JOIN employees emp ON -- присоединяем таблицу
s.sales_person_id = emp.employee_id
GROUP BY emp.first_name, emp.last_name -- выполняем группировку
ORDER BY 3 DESC -- сортируем по третьему столбцу в порядке убывания
limit 10; 

-- lowest_average_income

SELECT CONCAT(emp.first_name, ' ', emp.last_name) AS seller, -- объединяем имя и фамилию
FLOOR(AVG(s.quantity * p.price)) as average_income -- обрезаем среднее значение выручки
FROM sales s
INNER JOIN products p -- присоединяем таблицу
USING(product_id)
INNER JOIN employees emp ON -- присоединяем таблицу
s.sales_person_id = emp.employee_id
GROUP BY emp.first_name, emp.last_name -- выполняем группировку
HAVING AVG(s.quantity * p.price) < (select AVG(s.quantity * p.price) 
				    FROM sales s
				    INNER JOIN products p ON
				    s.product_id = p.product_id)
ORDER BY 2; -- сортируем по третьему столбцу в порядке возрастания

-- day_of_the_week_income

SELECT CONCAT(emp.first_name, ' ', emp.last_name) AS seller, -- объединяем имя и фамилию
trim(to_char(s.sale_date, 'Day')) as day_of_week, -- преобразуем дату продажи в день недели
floor(sum(s.quantity * p.price)) as income -- вычисляем доход
FROM sales s
INNER JOIN products p -- присоединяем таблицу
USING(product_id)
INNER JOIN employees emp ON -- присоединяем таблицу
s.sales_person_id = emp.employee_id
GROUP BY emp.first_name, emp.last_name, to_char(s.sale_date, 'Day'), extract(isodow from s.sale_date)
ORDER BY extract(isodow from s.sale_date); -- выполняем группировку

-- Проект Продажи (6)

-- age_groups

SELECT 
	CASE WHEN age BETWEEN 16 and 25 THEN '16-25'
		 WHEN age BETWEEN 26 and 40 THEN '26-40'
	     WHEN age >= 41 THEN '40+'
	     ELSE 'out of category'
	END AS age_category,
COUNT(customer_id) AS age_count
FROM customers
GROUP BY 1
ORDER BY 1;

-- customers_by_month

SELECT to_char(s.sale_date, 'YYYY-MM') AS selling_month, -- преобразуем формат даты
COUNT(distinct(s.customer_id)) AS total_customers, -- считаем уникальных покупателей
FLOOR(SUM(s.quantity * p.price)) AS income -- суммируем выручку
FROM sales s
INNER JOIN products p -- присоединяем таблицу
USING(product_id)
INNER JOIN customers c -- присоединяем таблицу
USING (customer_id)
GROUP BY to_char(s.sale_date, 'YYYY-MM')
ORDER BY 1;

-- special_offer

WITH tab AS (
SELECT c.customer_id,
concat(c.first_name, ' ', c.last_name) AS customer,
s.sale_date,
concat(emp.first_name, ' ', emp.last_name) AS seller,
row_number() OVER (PARTITION BY concat(c.first_name, ' ', c.last_name) ORDER BY s.sale_date) AS rn
FROM sales s
INNER JOIN products p -- присоединяем таблицу
USING(product_id)
INNER JOIN customers c -- присоединяем таблицу
USING(customer_id)
INNER JOIN employees emp ON -- присоединяем таблицу
s.sales_person_id = emp.employee_id
where p.price = 0
)

SELECT customer,
sale_date,
seller
FROM tab 
WHERE rn = 1
order BY customer_id;





