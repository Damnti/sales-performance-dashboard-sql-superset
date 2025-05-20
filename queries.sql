-- Проект Продажи (4)

SELECT COUNT(*) AS customers_count  -- считаем количество строк
FROM customers;

-- Проект Продажи (5)

-- top_10_total_income

SELECT
    -- объединяем имя и фамилию
    CONCAT(emp.first_name, ' ', emp.last_name) AS seller,
    -- считаем количество продаж
    COUNT(s.sales_id) AS operations,
    -- обрезаем сумму выручки
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
INNER JOIN employees AS emp ON s.sales_person_id = emp.employee_id
GROUP BY emp.first_name, emp.last_name  -- выполняем группировку
ORDER BY income DESC  -- сортируем по третьему столбцу в порядке убывания
limit 10;

-- lowest_average_income

SELECT
    -- объединяем имя и фамилию
    CONCAT(emp.first_name, ' ', emp.last_name) AS seller,
    -- обрезаем среднее значение выручки
    FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM sales AS s
INNER JOIN products AS p USING(product_id)  -- присоединяем таблицу
INNER JOIN employees AS emp ON s.sales_person_id = emp.employee_id  -- присоединяем таблицу
GROUP BY emp.first_name, emp.last_name  -- выполняем группировку
HAVING
AVG(s.quantity * p.price) < (
    SELECT AVG(s.quantity * p.price)
    FROM sales AS s
    INNER JOIN products AS p ON s.product_id = p.product_id
    )
ORDER BY average_income;  -- сортируем по третьему столбцу в порядке возрастания

-- day_of_the_week_income

SELECT
    -- объединяем имя и фамилию
    CONCAT(emp.first_name, ' ', emp.last_name) AS seller,
    -- преобразуем дату продажи в день недели
    LOWER(TRIM(TO_CHAR(s.sale_date, 'Day'))) AS day_of_week,
    -- вычисляем доход
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
INNER JOIN products AS p USING(product_id)  -- присоединяем таблицу
INNER JOIN employees AS emp ON s.sales_person_id = emp.employee_id  -- присоединяем таблицу
GROUP BY
    emp.first_name,
    emp.last_name,
    LOWER(TRIM(TO_CHAR(s.sale_date, 'Day'))),
    EXTRACT(ISODOW from s.sale_date)
ORDER BY EXTRACT(ISODOW from s.sale_date);  -- выполняем группировку

-- Проект Продажи (6)

-- age_groups

SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
	WHEN age BETWEEN 26 AND 40 THEN '26-40'
	WHEN age >= 41 THEN '40+'
	ELSE 'out of category'
    END AS age_category,
    COUNT(customer_id) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category;

-- customers_by_month

SELECT
    -- преобразуем формат даты
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    -- считаем уникальных покупателей
    COUNT(DISTINCT(s.customer_id)) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income  -- суммируем выручку
FROM sales AS s
INNER JOIN products AS p USING(product_id)  -- присоединяем таблицу
INNER JOIN customers USING (customer_id)  -- присоединяем таблицу
GROUP BY selling_month
ORDER BY selling_month;


-- special_offer

WITH tab AS (
    SELECT
	c.customer_id,
	s.sale_date,
	CONCAT(c.first_name, ' ', c.last_name) AS customer,
	CONCAT(emp.first_name, ' ', emp.last_name) AS seller,
	ROW_NUMBER() OVER (
		PARTITION BY CONCAT(c.first_name, ' ', c.last_name) 
		ORDER BY s.sale_date
	) AS rn
	FROM sales AS s
	INNER JOIN products AS p USING(product_id)
	INNER JOIN customers AS c USING(customer_id)
	INNER JOIN employees AS emp ON s.sales_person_id = emp.employee_id
        WHERE p.price = 0
)

SELECT
    customer,
    sale_date,
    seller
FROM tab
WHERE rn = 1
ORDER BY customer_id;





