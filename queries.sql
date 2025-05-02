-- Registering product inventory.
INSERT INTO
    "items" ("name", "code", "price", "inventory")
VALUES
    ('Sediment filter', 'SED PP10 5M NSFr', 5.25, 100),
    ('Carbon filter', 'CTO 10 5M NSF', 12.50, 100),
    ('RO membrane', 'GAC NSF  2in1 A172', 112.50, 100),
    ('Post RO membrane', 'T33 NSF GAC', 22, 100),
    ('Big sediment filter', 'SED HF-17 5M', 45.90, 100);

-- Registering employees.
INSERT INTO
    "workers" ("first_name", "last_name")
VALUES
    ('Federico', 'Huerta'),
    ('Worker', 'Bee');

-- Adding client #1.
INSERT INTO
    "clients" (
        "first_name",
        "last_name",
        "phone",
        "email",
        "address"
    )
VALUES
    (
        'Alan',
        'Loopy',
        '12345',
        'alanloopy@gmail.com',
        '325 Some street, some city'
    );

-- Creating an order for client #1.
INSERT INTO
    "orders" ("client_id", "description")
VALUES
    (1, 'Our very first sale');

-- Adding items to order #1.
INSERT INTO
    "order_items" ("order_id", "item_id", "quantity")
VALUES
    (1, 1, 2),
    (1, 2, 1),
    (1, 3, 1),
    (1, 4, 1);

-- Assigning a worker to order #1.
INSERT INTO
    "work_orders" ("order_id", "worker_id")
VALUES
    (1, 1);

-- Creating an alert for a future maintenance for client #1.
INSERT INTO
    "future_maintenances" ("alert_date", "client_id", "description")
VALUES
    ('2025-10-01', 1, 'Change some filters');

-- Adding client #2.
INSERT INTO
    "clients" (
        "first_name",
        "last_name",
        "phone",
        "email",
        "address"
    )
VALUES
    (
        'The cooler Alan',
        'Loopier',
        '54321',
        'loopieralan@gmail.com',
        '123 that street, another city'
    );

-- Creating an order, for client #2.
INSERT INTO
    "orders" ("client_id", "description")
VALUES
    (2, 'Our 2nd sale');

-- Adding items to order #2.
INSERT INTO
    "order_items" ("order_id", "item_id", "quantity")
VALUES
    (2, 1, 1),
    (2, 5, 1);

-- Assigning a worker to order #2.
INSERT INTO
    "work_orders" ("order_id", "worker_id")
VALUES
    (2, 2);

-- Updating the order #2 to increase the quantity of an item.
UPDATE "order_items"
SET
    "quantity" = 5
WHERE
    "order_id" = 2
    AND "item_id" = 5;

-- Deleting an item from order #2 because the client didn't want it in the end.
DELETE FROM "order_items"
WHERE
    "order_id" = 1
    AND "item_id" = 1;

-- Creating an alert for future maintenance for client #2..
INSERT INTO
    "future_maintenances" ("alert_date", "client_id", "description")
VALUES
    ('2025-10-01', 2, 'Change those filters');

--  Find information about the client with the last name 'Loopy'.
SELECT
    *
from
    "clients"
WHERE
    "last_name" = 'Loopy';

-- Find all orders made by the client with the name 'Alan Loopy'.
SELECT
    *
FROM
    "order_details"
WHERE
    "first_name" = 'Alan'
    AND "last_name" = 'Loopy';

-- Find the complete order details from the client with the name 'Alan Loopy' made on March 2025.
SELECT
    *
FROM
    "complete_orders"
WHERE
    "first_name" = 'Alan'
    AND "last_name" = 'Loopy'
    AND "datetime" BETWEEN '2025-03-01' AND '2025-03-31';

-- Find the items details from the order associated with the client named 'Alan Loopy' on March 7th 2025. Ideally this ID selection would be achieved by the application when expanding the details of the order examined in the previous query.
SELECT
    *
FROM
    "order_items_details"
WHERE
    "order_id" = (
        SELECT
            "id"
        FROM
            "complete_orders"
        WHERE
            "first_name" = 'Alan'
            AND "last_name" = 'Loopy'
            AND "datetime" LIKE '2025-03-07%'
    );

-- View orders assigned to the worker with the last name 'Bee'.
SELECT
    *
FROM
    "workers_orders"
WHERE
    "Worker" LIKE '%Bee';

-- View maintenance alerts in 2025.
SELECT
    *
FROM
    "client_maintenances_alerts"
WHERE
    "alert_date" LIKE '2025%';

-- Adding client #3.
INSERT INTO
    "clients" (
        "first_name",
        "last_name",
        "phone",
        "email",
        "address"
    )
VALUES
    (
        'Gandalf',
        'the Gray',
        'Palantir #3',
        'therealmithrandir@secretfire.com',
        'Middle Earth'
    );

-- Creating an order, for client #3.
INSERT INTO
    "orders" ("client_id", "description")
VALUES
    (
        3,
        'Defeating dark lords and balrogs produces quite a thirst'
    );

-- Adding items to order #3.
INSERT INTO
    "order_items" ("order_id", "item_id", "quantity")
VALUES
    (3, 1, 2),
    (3, 2, 1),
    (3, 3, 1),
    (3, 4, 1),
    (3, 5, 1);

-- Assigning a worker to order #3.
INSERT INTO
    "work_orders" ("order_id", "worker_id")
VALUES
    (3, 2);