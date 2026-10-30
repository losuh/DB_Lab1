/*
 orders + order_item + product + category
                ↓
order_lines: одна строка на позицию заказа,
             месяц, статус, категория, количество, стоимость
                ↓
month_category_agregation: доли успешных,
                            отменённых, обрабатываемых и доставленных заказов
month_category_revenue: выручка, число успешных заказов,
                        число товаров, средняя сумма по категории в заказе
                ↓
итоговый SELECT: соединение по месяцу и категории,
                 место категории по выручке в каждом месяце
 */
--complex analytics query

WITH order_lines AS (SELECT oi.order_id,
                            date_trunc('month', o.date) as order_month,
                            o.status                    as order_status,
                            c.id                        as category_id,
                            c.name                      as category_name,
                            oi.amount,
                            oi.price * oi.amount        as line_total
                     FROM order_item oi
                              JOIN orders o ON oi.order_id = o.id
                              JOIN product p ON oi.product_id = p.id
                              JOIN category c ON p.category_id = c.id),
     month_category_agregation AS (SELECT order_month,
                                          category_name,
                                          category_id,
                                          ROUND(COUNT(DISTINCT order_id)
                                                FILTER (WHERE order_status IN ('Paid', 'Shipped', 'Delivered')) *
                                                100.0 /
                                                NULLIF(COUNT(DISTINCT order_id), 0), 2) as buyout_rate,
                                          ROUND(COUNT(DISTINCT order_id)
                                                FILTER (WHERE order_status = 'Cancelled') * 100.0 /
                                                NULLIF(COUNT(DISTINCT order_id), 0), 2) as cancel_rate,
                                          ROUND(COUNT(DISTINCT order_id)
                                                FILTER (WHERE order_status = 'Pending') * 100.0 /
                                                NULLIF(COUNT(DISTINCT order_id), 0), 2) as pending_rate,
                                          ROUND(COUNT(DISTINCT order_id)
                                                FILTER (WHERE order_status = 'Delivered') * 100.0 /
                                                NULLIF(COUNT(DISTINCT order_id), 0), 2) as delivery_rate

                                   FROM order_lines
                                   GROUP BY order_month,
                                            category_name,
                                            category_id),
     month_category_revenue AS (SELECT order_month,
                                       category_name,
                                       category_id,
                                       SUM(line_total)                                      as revenue,
                                       COUNT(DISTINCT order_id)                             AS amount_of_successful_orders,
                                       SUM(amount)                                          as amount_of_sold_items,
                                       ROUND(SUM(line_total) / COUNT(DISTINCT order_id), 2) as avg_category_sale
                                FROM order_lines

                                WHERE order_status IN ('Paid', 'Shipped', 'Delivered')
                                GROUP BY order_month,
                                         category_name,
                                         category_id)
SELECT mca.order_month,
       DENSE_RANK() OVER (PARTITION BY mca.order_month ORDER BY COALESCE(mcr.revenue, 0) DESC) as category_rating,
       mca.category_name,
       COALESCE(mcr.revenue, 0)                                                                AS revenue,
       avg_category_sale,
       COALESCE(mcr.amount_of_successful_orders, 0)                                            AS amount_of_successful_orders,
       COALESCE(mcr.amount_of_sold_items, 0)                                                   AS amount_of_sold_items,
       buyout_rate,
       cancel_rate,
       pending_rate,
       delivery_rate
FROM month_category_agregation mca
         LEFT JOIN month_category_revenue mcr
                   ON mca.category_id = mcr.category_id
                       AND mca.order_month = mcr.order_month
ORDER BY order_month, revenue DESC;
