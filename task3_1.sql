-- Products priced above the average price in their category

SELECT
    product_data.id AS product_id,
    product_data.name AS product,
    category_data.name AS category,
    product_data.price,
    category_statistics.average_price,
    ROUND(product_data.price - category_statistics.average_price, 2) AS difference_from_average
FROM product AS product_data
JOIN category AS category_data
    ON category_data.id = product_data.category_id
JOIN (
    SELECT
        category_id,
        ROUND(AVG(price), 2) AS average_price
    FROM product
    GROUP BY category_id
) AS category_statistics
    ON category_statistics.category_id = product_data.category_id
WHERE product_data.price > category_statistics.average_price
ORDER BY category_data.name, difference_from_average DESC;
