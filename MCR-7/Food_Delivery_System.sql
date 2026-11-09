CREATE SCHEMA food_delivery_variant7;
SET search_path TO food_delivery_variant7;

-- ============================================================
-- 1. СХЕМА БАЗИ ДАНИХ
-- ============================================================

-- Ресторани: назва, кухня, адреса, рейтинг
CREATE TABLE Restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    cuisine VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    rating NUMERIC(2, 1) NOT NULL CHECK (rating BETWEEN 0 AND 5)
);

-- Клієнти: контакти, адреса доставки, спосіб оплати
CREATE TABLE Clients (
    client_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    delivery_address VARCHAR(255) NOT NULL,
    payment_info VARCHAR(100) NOT NULL
);

-- Кур'єри: транспорт, доступність, район роботи
CREATE TABLE Couriers (
    courier_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    vehicle VARCHAR(50) NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    district VARCHAR(100) NOT NULL
);

-- Страви: кожна позиція меню належить певному ресторану
CREATE TABLE Menu_Items (
    item_id SERIAL PRIMARY KEY,
    restaurant_id INT NOT NULL REFERENCES Restaurants(restaurant_id),
    name VARCHAR(150) NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    UNIQUE (item_id, restaurant_id)
);

-- Замовлення: одне замовлення оформлюється в одному ресторані
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES Clients(client_id),
    restaurant_id INT NOT NULL REFERENCES Restaurants(restaurant_id),
    courier_id INT REFERENCES Couriers(courier_id),
    order_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    delivery_time TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'Нове'
        CHECK (status IN ('Нове', 'Готується', 'Доставляється', 'Доставлено', 'Скасовано')),
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0),
    delivery_address VARCHAR(255) NOT NULL,
    CHECK (delivery_time IS NULL OR delivery_time >= order_time),
    CHECK ((status = 'Доставлено') = (delivery_time IS NOT NULL)),
    CHECK (status NOT IN ('Доставляється', 'Доставлено') OR courier_id IS NOT NULL),
    UNIQUE (order_id, restaurant_id)
);

-- Позиції замовлення: кількість і ціна на момент оформлення
CREATE TABLE Order_Items (
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id, restaurant_id)
        REFERENCES Orders(order_id, restaurant_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id, restaurant_id)
        REFERENCES Menu_Items(item_id, restaurant_id)
);

-- ============================================================
-- 2. ТЕСТОВІ ДАНІ
-- ============================================================

INSERT INTO Restaurants (name, cuisine, address, rating) VALUES
('Піца Хаус', 'Італійська', 'Київ, вул. Хрещатик, 10', 4.9),
('Суші Тайм', 'Японська', 'Київ, вул. Сагайдачного, 12', 4.8),
('Бургер Клуб', 'Американська', 'Київ, вул. Велика Васильківська, 20', 4.7),
('Українська хата', 'Українська', 'Київ, вул. Ярославів Вал, 15', 4.9),
('Паста Бар', 'Італійська', 'Київ, вул. Антоновича, 30', 4.6),
('Вок Експрес', 'Азійська', 'Київ, вул. Басейна, 5', 4.5),
('Грузинський двір', 'Грузинська', 'Київ, вул. Нижній Вал, 18', 4.8),
('Грін Боул', 'Вегетаріанська', 'Київ, вул. Ділова, 8', 4.6),
('Тако Мікс', 'Мексиканська', 'Київ, вул. Прорізна, 7', 4.4),
('Індія Спайс', 'Індійська', 'Київ, вул. Рейтарська, 9', 4.7),
('Французька пекарня', 'Французька', 'Київ, вул. Золотоворітська, 6', 4.5),
('Морський смак', 'Середземноморська', 'Київ, вул. Набережно-Хрещатицька, 14', 4.3);

INSERT INTO Clients (name, phone, delivery_address, payment_info) VALUES
('Маріян', '+380670000001', 'Київ, вул. Ділова, 13', 'Картка **** 1234'),
('Олена Кравченко', '+380670000002', 'Київ, вул. Сагайдачного, 25', 'Готівка'),
('Андрій Бондар', '+380670000003', 'Київ, вул. Антоновича, 40', 'Картка **** 5678'),
('Юлія Сорока', '+380670000004', 'Київ, вул. Ярославів Вал, 22', 'Готівка'),
('Ігор Петренко', '+380670000005', 'Київ, вул. Рейтарська, 17', 'Картка **** 9012');

INSERT INTO Couriers (name, phone, vehicle, is_available, district) VALUES
('Олександр Коваль', '+380680000001', 'Велосипед', TRUE, 'Шевченківський'),
('Дмитро Мельник', '+380680000002', 'Скутер', FALSE, 'Подільський'),
('Ірина Шевченко', '+380680000003', 'Автомобіль', TRUE, 'Шевченківський'),
('Максим Бондаренко', '+380680000004', 'Велосипед', FALSE, 'Печерський'),
('Анна Ткаченко', '+380680000005', 'Скутер', TRUE, 'Подільський');

INSERT INTO Menu_Items (restaurant_id, name, price) VALUES
(1, 'Піца Маргарита', 220.00),
(2, 'Рол Філадельфія', 320.00),
(3, 'Чізбургер', 180.00),
(4, 'Борщ', 140.00),
(5, 'Паста Карбонара', 260.00),
(6, 'Локшина з куркою', 210.00),
(7, 'Хачапурі', 240.00),
(8, 'Овочевий боул', 190.00),
(9, 'Тако з яловичиною', 170.00),
(10, 'Курка карі', 280.00),
(11, 'Круасан', 90.00),
(12, 'Риба на грилі', 360.00),
(1, 'Лимонад', 80.00);

-- Перші 10 замовлень доставлені, 5 скасовані, 2 ще виконуються.
-- Дати відносні: запити за сьогодні та поточний місяць мають дані.
INSERT INTO Orders (
    client_id, restaurant_id, courier_id, order_time,
    delivery_time, status, total_amount, delivery_address
) VALUES
(1, 1, 1, CURRENT_DATE, CURRENT_DATE + INTERVAL '30 minutes', 'Доставлено', 520.00, 'Київ, вул. Ділова, 13'),
(2, 2, 2, CURRENT_DATE, CURRENT_DATE + INTERVAL '45 minutes', 'Доставлено', 320.00, 'Київ, вул. Сагайдачного, 25'),
(3, 3, 3, CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE - INTERVAL '1 day' + INTERVAL '35 minutes', 'Доставлено', 360.00, 'Київ, вул. Антоновича, 40'),
(4, 4, 1, CURRENT_DATE, CURRENT_DATE + INTERVAL '25 minutes', 'Доставлено', 280.00, 'Київ, вул. Ярославів Вал, 22'),
(5, 5, 4, CURRENT_DATE - INTERVAL '2 days', CURRENT_DATE - INTERVAL '2 days' + INTERVAL '40 minutes', 'Доставлено', 260.00, 'Київ, вул. Рейтарська, 17'),
(1, 6, 2, CURRENT_DATE - INTERVAL '3 days', CURRENT_DATE - INTERVAL '3 days' + INTERVAL '50 minutes', 'Доставлено', 210.00, 'Київ, вул. Ділова, 13'),
(2, 7, 3, CURRENT_DATE - INTERVAL '4 days', CURRENT_DATE - INTERVAL '4 days' + INTERVAL '30 minutes', 'Доставлено', 240.00, 'Київ, вул. Сагайдачного, 25'),
(3, 8, 4, CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE - INTERVAL '5 days' + INTERVAL '55 minutes', 'Доставлено', 190.00, 'Київ, вул. Антоновича, 40'),
(4, 9, 1, CURRENT_DATE - INTERVAL '6 days', CURRENT_DATE - INTERVAL '6 days' + INTERVAL '35 minutes', 'Доставлено', 170.00, 'Київ, вул. Ярославів Вал, 22'),
(5, 10, 2, CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE - INTERVAL '7 days' + INTERVAL '40 minutes', 'Доставлено', 280.00, 'Київ, вул. Рейтарська, 17'),
(1, 1, 1, CURRENT_DATE - INTERVAL '1 day', NULL, 'Скасовано', 220.00, 'Київ, вул. Ділова, 13'),
(2, 2, 2, CURRENT_DATE - INTERVAL '1 day', NULL, 'Скасовано', 320.00, 'Київ, вул. Сагайдачного, 25'),
(3, 3, 2, CURRENT_DATE - INTERVAL '2 days', NULL, 'Скасовано', 180.00, 'Київ, вул. Антоновича, 40'),
(4, 4, 3, CURRENT_DATE - INTERVAL '2 days', NULL, 'Скасовано', 140.00, 'Київ, вул. Ярославів Вал, 22'),
(5, 5, 3, CURRENT_DATE - INTERVAL '3 days', NULL, 'Скасовано', 260.00, 'Київ, вул. Рейтарська, 17'),
(1, 1, 4, CURRENT_TIMESTAMP, NULL, 'Доставляється', 220.00, 'Київ, вул. Ділова, 13'),
(2, 2, 2, CURRENT_TIMESTAMP, NULL, 'Доставляється', 320.00, 'Київ, вул. Сагайдачного, 25');

INSERT INTO Order_Items (order_id, item_id, restaurant_id, quantity, unit_price) VALUES
(1, 1, 1, 2, 220.00), (1, 13, 1, 1, 80.00),
(2, 2, 2, 1, 320.00), (3, 3, 3, 2, 180.00),
(4, 4, 4, 2, 140.00), (5, 5, 5, 1, 260.00),
(6, 6, 6, 1, 210.00), (7, 7, 7, 1, 240.00),
(8, 8, 8, 1, 190.00), (9, 9, 9, 1, 170.00),
(10, 10, 10, 1, 280.00), (11, 1, 1, 1, 220.00),
(12, 2, 2, 1, 320.00), (13, 3, 3, 1, 180.00),
(14, 4, 4, 1, 140.00), (15, 5, 5, 1, 260.00),
(16, 1, 1, 1, 220.00), (17, 2, 2, 1, 320.00);

-- ============================================================
-- 3. OLTP ЗАПИТИ
-- ============================================================

-- INSERT 1: Додати нового клієнта
INSERT INTO Clients (name, phone, delivery_address, payment_info)
VALUES ('Тарас Савченко', '+380990000001', 'Київ, вул. Прорізна, 11', 'Готівка');

-- INSERT 2: Додати нову страву до меню ресторану №1
INSERT INTO Menu_Items (restaurant_id, name, price)
VALUES (1, 'Тестова піца', 250.00);

-- UPDATE 1: Змінити адресу доставки клієнта
UPDATE Clients
SET delivery_address = 'Київ, вул. Ділова, 15'
WHERE client_id = 1;

-- UPDATE 2: Змінити транспортний засіб кур'єра
UPDATE Couriers
SET vehicle = 'Автомобіль'
WHERE courier_id = 5;

-- DELETE 1: Видалити нову страву, яку ще не замовляли
DELETE FROM Menu_Items
WHERE restaurant_id = 1 AND name = 'Тестова піца';

-- DELETE 2: Видалити щойно доданого клієнта без замовлень
DELETE FROM Clients
WHERE phone = '+380990000001';

-- SELECT 1: Знайти доступних кур'єрів у Шевченківському районі
SELECT courier_id, name, phone, vehicle, district
FROM Couriers
WHERE is_available = TRUE
    AND district = 'Шевченківський';

-- SELECT 2: Усі замовлення ресторану №1 за сьогодні
SELECT order_id, client_id, courier_id, order_time, status, total_amount
FROM Orders
WHERE restaurant_id = 1
    AND order_time >= CURRENT_DATE
    AND order_time < CURRENT_DATE + INTERVAL '1 day'
ORDER BY order_time, order_id;

-- ============================================================
-- 4. OLAP ЗАПИТИ
-- ============================================================

-- OLAP 1: Дохід кожного ресторану за поточний календарний місяць
-- Враховуємо тільки доставлені замовлення, відбір за датою оформлення.
SELECT
    r.name AS "Ресторан",
    COALESCE(SUM(o.total_amount), 0) AS "Дохід за місяць"
FROM Restaurants r
LEFT JOIN Orders o ON o.restaurant_id = r.restaurant_id
    AND o.status = 'Доставлено'
    AND o.order_time >= DATE_TRUNC('month', CURRENT_DATE)
    AND o.order_time < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
GROUP BY r.restaurant_id, r.name
ORDER BY "Дохід за місяць" DESC, r.restaurant_id;

-- OLAP 2: Топ-10 ресторанів: спочатку рейтинг, потім кількість замовлень
-- Кількість замовлень рахуємо за весь час, включно зі скасованими.
SELECT
    r.name AS "Ресторан",
    r.rating AS "Рейтинг",
    COUNT(o.order_id) AS "Кількість замовлень"
FROM Restaurants r
LEFT JOIN Orders o ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id, r.name, r.rating
ORDER BY r.rating DESC, "Кількість замовлень" DESC, r.restaurant_id
LIMIT 10;

-- OLAP 3: Середній час від оформлення до доставки для кожного кур'єра
-- Для кур'єра без завершених доставок результат буде NULL.
SELECT
    c.name AS "Кур'єр",
    ROUND(AVG(EXTRACT(EPOCH FROM (o.delivery_time - o.order_time)) / 60), 2)
        AS "Середній час доставки, хв"
FROM Couriers c
LEFT JOIN Orders o ON o.courier_id = c.courier_id
    AND o.status = 'Доставлено'
GROUP BY c.courier_id, c.name
ORDER BY "Середній час доставки, хв" ASC NULLS LAST, c.courier_id;

-- OLAP 4: Кур'єри з максимальною кількістю скасованих доставок (CTE)
-- Якщо максимум однаковий, показуємо всіх таких кур'єрів.
WITH CancelledDeliveries AS (
    SELECT
        c.courier_id,
        c.name,
        COUNT(o.order_id) AS cancelled_count
    FROM Couriers c
    JOIN Orders o ON o.courier_id = c.courier_id
    WHERE o.status = 'Скасовано'
    GROUP BY c.courier_id, c.name
)
SELECT name AS "Кур'єр", cancelled_count AS "Скасованих доставок"
FROM CancelledDeliveries
WHERE cancelled_count = (SELECT MAX(cancelled_count) FROM CancelledDeliveries)
ORDER BY courier_id;
