/**********************************Scénarion 1*********************************/
--analyse rapide et ciblée des pizzas disponibles dans une catégorie spécifique
---------------------------------- Requete SQL----------------------------------
SELECT category, COUNT(*) AS total_pizza_types
FROM pizza_types
WHERE category = 'Chicken'
GROUP BY category;
-----------------------------Plan Execution sans index -------------------------
EXPLAIN PLAN 
SET STATEMENT_ID= 'rq_chicken'
FOR SELECT category,COUNT(*) AS total_pizza_types
FROM pizza_types
WHERE category = 'Chicken'
GROUP BY category;

DELETE FROM PLAN_TABLE WHERE STATEMENT_ID = 'rq_chicken';
---------------------------Affichage Plan Execution ----------------------------
SELECT 
    'Sans Index' AS Index_Status,
    ID,
    OPERATION,
    OBJECT_NAME,
    OPTIONS,
    CPU_COST,
    IO_COST,
    ACCESS_PREDICATES,
    BYTES
FROM PLAN_TABLE
WHERE STATEMENT_ID = 'rq_chicken'

////////////////////////////////////////////////////////////////////////////////

---------------------------Creation Index Bitmap--------------------------------
CREATE BITMAP INDEX idx_chicken_bitmap ON pizza_types(category);

DROP INDEX idx_chicken_bitmap;
------------------------Plan Execution Avec Index-------------------------------
EXPLAIN PLAN 
SET STATEMENT_ID= 'rq_chicken_index'
For SELECT category,
       COUNT(*) AS total_pizza_types
FROM pizza_types
WHERE category = 'Chicken'
GROUP BY category;

DELETE FROM PLAN_TABLE WHERE STATEMENT_ID = 'rq_chicken_index';
---------------------Affichage Plan Execution Avec Index------------------------
SELECT 
    'Avec Index' AS Index_Status,
    ID,
    OPERATION,
    OBJECT_NAME,
    OPTIONS,
    CPU_COST,
    IO_COST,
    ACCESS_PREDICATES,
    BYTES
FROM PLAN_TABLE
WHERE STATEMENT_ID = 'rq_chicken_index'
////////////////////////////////////////////////////////////////////////////////

-----------------------Affichage des Plans Execution----------------------------
SELECT 
    'Sans Index' AS Index_Status,
    ID,
    OPERATION,
    OBJECT_NAME,
    OPTIONS,
    CPU_COST,
    IO_COST,
    ACCESS_PREDICATES,
    BYTES
FROM PLAN_TABLE
WHERE STATEMENT_ID = 'rq_chicken'
union all
SELECT 
    'Avec Index' AS Index_Status,
    ID,
    OPERATION,
    OBJECT_NAME,
    OPTIONS,
    CPU_COST,
    IO_COST,
    ACCESS_PREDICATES,
    BYTES
FROM PLAN_TABLE
WHERE STATEMENT_ID = 'rq_chicken_index'
--------------------------------------------------------------------------------
---------------------------------Scénarion 2------------------------------------
--------------------------------------------------------------------------------

---------------------------------- Requete SQL----------------------------------
-- les revenus générés par jour
SELECT o.date_order AS order_date,
       SUM(od.quantity * p.price) AS total_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.date_order
ORDER BY total_revenue DESC;

-----------------------------Plan Execution sans index -------------------------
EXPLAIN PLAN 
SET STATEMENT_ID= 'rq_revenu_date'
FOR SELECT o.date_order AS order_date,
       SUM(od.quantity * p.price) AS total_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.date_order
ORDER BY total_revenue DESC;
---------------------------Affichage Plan Execution ----------------------------
SELECT 
    'Sans Index' AS Index_Status,
    ID,
    OPERATION,
    OBJECT_NAME,
    OPTIONS,
    CPU_COST,
    IO_COST,
    ACCESS_PREDICATES,
    BYTES
FROM PLAN_TABLE
WHERE STATEMENT_ID = 'rq_revenu_date'
////////////////////////////////////////////////////////////////////////////////

--------------------------Creation Index composé-------------------------------
CREATE INDEX idx_order_details_order_pizza_quantity
ON order_details(order_id, pizza_id, quantity);

------------------------Plan Execution Avec Index-------------------------------
EXPLAIN PLAN 
SET STATEMENT_ID= 'rq_revenu_date_index'
FOR SELECT o.date_order AS order_date,
       SUM(od.quantity * p.price) AS total_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.date_order
ORDER BY total_revenue DESC;

DELETE FROM PLAN_TABLE WHERE STATEMENT_ID = 'rq_revenu_date_index';
---------------------Affichage Plan Execution Avec Index------------------------
SELECT 
    'Avec Index' AS Index_Status,
    ID,
    OPERATION,
    OBJECT_NAME,
    OPTIONS,
    CPU_COST,
    IO_COST,
    ACCESS_PREDICATES,
    BYTES
FROM PLAN_TABLE
WHERE STATEMENT_ID = 'rq_revenu_date_index'

DELETE FROM PLAN_TABLE WHERE STATEMENT_ID = 'rq_revenu_date_index';
////////////////////////////////////////////////////////////////////////////////

-----------------------Affichage des Plans Execution----------------------------
SELECT 
    'Sans Index' AS Index_Status,
    ID,
    OPERATION,
    OBJECT_NAME,
    OPTIONS,
    CPU_COST,
    IO_COST,
    ACCESS_PREDICATES,
    BYTES
FROM PLAN_TABLE
WHERE STATEMENT_ID = 'rq_revenu_date'

union all

SELECT 
    'Avec Index' AS Index_Status,
    ID,
    OPERATION,
    OBJECT_NAME,
    OPTIONS,
    CPU_COST,
    IO_COST,
    ACCESS_PREDICATES,
    BYTES
FROM PLAN_TABLE
WHERE STATEMENT_ID = 'rq_revenu_date_index'
--------------------------------------------------------------------------------
---------------------------------Scénario3 -------------------------------------
--------------------------------------------------------------------------------
-- Optimisation du 2 eme scénario

-- Index pour optimiser les jointures et l'accès aux tables volumineuses
-- 1. Index composé sur order_details pour réduire le scan complet
CREATE INDEX idx_order_details_order_pizza_quantity
ON order_details(order_id, pizza_id, quantity);

-- 2. Index composé sur orders pour optimiser le GROUP BY et ORDER BY
CREATE INDEX idx_orders_order_date
ON orders(order_id, date_order);





























--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
SELECT DISTINCT STATEMENT_ID 
FROM PLAN_TABLE;

DELETE FROM PLAN_TABLE WHERE STATEMENT_ID In ('rq_revenu_pizza');
COMMIT;
