/* Exploratory analysis of my_guitar_shop database */


/* This code returns customer's first and last name columns combined into one, sorted by the last_name column ascending */
SELECT CONCAT(first_name,',', ' ', last_name) AS customer_name,
email_address
FROM customers
ORDER BY last_name ASC
;


/* Returns orders that have not shipped yet */
SELECT order_id,
		order_date,
        ship_date
FROM orders
WHERE ship_date IS NULL
;

/* Joins the category table and product table to return a list of all product names, which category the products belong to and their list price */
SELECT c.category_name,
		p.product_name,
		p.list_price
FROM categories c
	JOIN products p
		ON c.category_id = p.category_id
ORDER BY category_name ASC,
		product_name ASC
;

/* Returns a list of orders and their shipped status */
	SELECT 'SHIPPED' AS shipped_status,
			order_id,
			order_date
	FROM orders
	WHERE ship_date IS NOT NULL
UNION
    SELECT 'NOT SHIPPED' AS shipped_status,
	order_id,
    order_date
    FROM orders
    WHERE ship_date IS NULL
ORDER BY order_date
;

/* Uses a joiner table to connect two tables that do not have a direct relationship in order to return the total amount biled to each customer as well as total discount received */
SELECT c.email_address,
		SUM(oi.item_price * oi.quantity) AS total_amount,
        SUM(oi.discount_amount * oi.quantity) AS total_discount
FROM customers c
	JOIN orders o
		ON c.customer_id = o.customer_id
	JOIN order_items oi
		ON o.order_id = oi.order_id
GROUP BY email_address
ORDER BY total_amount DESC
;

/* Uses aggregated and named windows to create a cumulating total for each order */
SELECT order_id,
		SUM((item_price - discount_amount) * quantity) OVER(product_id_window) AS order_item_total,
        SUM((item_price - discount_amount) * quantity) OVER(PARTITION BY order_id ORDER BY order_id ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_row,
        AVG((item_price - discount_amount) * quantity) OVER (product_id_window) AS average_item_amount
FROM order_items
WINDOW product_id_window AS (PARTITION BY product_id)
;

/* Uses a subquery to identify products that are priced higher than the average price of all products in the inventory */
SELECT product_name,
		list_price
FROM products
WHERE list_price > (
	SELECT AVG(list_price)
    FROM products)
ORDER BY list_price DESC
;

/* Uses a subquery to sum all orders per customer in order for the main query to return the largest order of each customer */
SELECT email_address,
		MAX(total_per_order) AS largest_order
FROM (
SELECT c.email_address,
		oi.order_id,
        (oi.item_price - oi.discount_amount) * oi.quantity AS total_per_order
	FROM customers c
	JOIN orders o
		ON c.customer_id = o.customer_id
	JOIN order_items oi
		ON o.order_id = oi.order_id
	GROUP BY c.email_address, oi.order_id) AS order_totals
GROUP BY email_address
ORDER BY largest_order DESC
;

/* Uses a subquery to return the products that do not share the sam discount amount as other products */
SELECT product_name,
		discount_percent
FROM products p
WHERE discount_percent NOT IN (
		SELECT DISTINCT discount_percent
        FROM products
        WHERE product_id != p.product_id)
ORDER BY product_name
;