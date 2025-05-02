-- Represents clients interacting with the business. Phone value is text because in some countries it can start with a zero.
CREATE TABLE
    "clients" (
        "id" INTEGER,
        "first_name" TEXT NOT NULL,
        "last_name" TEXT NOT NULL,
        "phone" TEXT NOT NULL,
        "email" TEXT NOT NULL,
        "address" TEXT NOT NULL,
        PRIMARY KEY ("id")
    );

-- Represents the inventory of products of the busineess. The price of an item must be higher than zero and its inventory cannot be negative.
CREATE TABLE
    "items" (
        "id" INTEGER,
        "name" TEXT NOT NULL,
        "code" TEXT NOT NULL UNIQUE,
        "inventory" INTEGER NOT NULL CHECK ("inventory" >= 0),
        "price" REAL NOT NULL CHECK ("price" > 0),
        PRIMARY KEY ("id")
    );

-- Represents a business transaction made with a client. A description may be optional. The total cost is calculated by triggers, and thus may be ignored when inserting, deleting or updating an item in an order.
CREATE TABLE
    "orders" (
        "id" INTEGER,
        "datetime" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
        "client_id" INTEGER,
        "total" REAL,
        "description" TEXT,
        PRIMARY KEY ("id"),
        FOREIGN KEY ("client_id") REFERENCES "clients" ("id")
    );

-- Represents a "fake" array to enable having more than one item in an order. The quantity of an must be higher than zero. The subtotal cost of each item is calculated by triggers, and thus may be ignored when inserting or updating an item in an order.
CREATE TABLE
    "order_items" (
        "id" INTEGER,
        "order_id" INTEGER,
        "item_id" INTEGER,
        "quantity" INTEGER NOT NULL CHECK ("quantity" > 0),
        "subtotal" REAL,
        PRIMARY KEY ("id"),
        FOREIGN KEY ("order_id") REFERENCES "orders" ("id"),
        FOREIGN KEY ("item_id") REFERENCES "items" ("id")
    );

-- Represents the employees working for the business.
CREATE TABLE
    "workers" (
        "id" INTEGER,
        "first_name" TEXT NOT NULL,
        "last_name" TEXT NOT NULL,
        PRIMARY KEY ("id")
    );

-- Represents the assignment of orders to one or more worker.
CREATE TABLE
    "work_orders" (
        "id" INTEGER,
        "order_id" INTEGER,
        "worker_id" INTEGER,
        "datetime_fulfilled" NUMERIC,
        PRIMARY KEY ("id"),
        FOREIGN KEY ("order_id") REFERENCES "orders" ("id"),
        FOREIGN KEY ("worker_id") REFERENCES "workers" ("ID")
    );

-- Represents the alerts to contact a client to inform them about an upcoming maintenance.
CREATE TABLE
    "future_maintenances" (
        "id" INTEGER,
        "client_id" INTEGER,
        "alert_date" NUMERIC NOT NULL,
        "description" TEXT NOT NULL,
        PRIMARY KEY ("id"),
        FOREIGN KEY ("client_id") REFERENCES "clients" ("id")
    );

-- Trigger that changes an item's subtotal based on price and quantity, the inventory for that particular item (it subtracts the new amount), and the total for every item in the affected order AFTER an item has been inserted in an order.
CREATE TRIGGER "item_sold_insert" AFTER INSERT ON "order_items" FOR EACH ROW BEGIN
-- Subtotal update
UPDATE "order_items"
SET
    "subtotal" = NEW."quantity" * (
        SELECT
            "price"
        FROM
            "items"
        WHERE
            NEW."item_id" = "items"."id"
    )
WHERE
    "order_items"."id" = new."id";

-- Inventory update
UPDATE "items"
SET
    "inventory" = "inventory" - NEW."quantity"
WHERE
    "items"."id" = NEW."item_id";

-- Total update
UPDATE "orders"
SET
    "total" = (
        SELECT
            SUM("subtotal")
        FROM
            "order_items"
        WHERE
            "orders"."id" = "order_items"."order_id"
        GROUP BY
            "order_items"."order_id"
    );

END;

-- Trigger that changes an item's subtotal based on price and quantity, the inventory for that particular item (it returns the old amount and subtracts the new amount), and the total for every item in the affected order AFTER an item in an order has been updated.
CREATE TRIGGER "item_sold_update" AFTER
UPDATE OF "quantity" ON "order_items" FOR EACH ROW BEGIN
-- Subtotal update
UPDATE "order_items"
SET
    "subtotal" = NEW."quantity" * (
        SELECT
            "price"
        FROM
            "items"
        WHERE
            NEW."item_id" = "items"."id"
    )
WHERE
    "order_items"."id" = new."id";

-- Inventory update
UPDATE "items"
SET
    "inventory" = "inventory" + OLD."quantity" - NEW."quantity"
WHERE
    "items"."id" = NEW."item_id";

-- Total update
UPDATE "orders"
SET
    "total" = (
        SELECT
            SUM("subtotal")
        FROM
            "order_items"
        WHERE
            "orders"."id" = "order_items"."order_id"
        GROUP BY
            "order_items"."order_id"
    );

END;

-- Trigger that changes the inventory for that particular item (it returns the old amount), and the total for every item in the affected order AFTER an item in an order has been deleted.
CREATE TRIGGER "item_sold_delete" AFTER DELETE ON "order_items" FOR EACH ROW BEGIN
-- Inventory update
UPDATE "items"
SET
    "inventory" = "inventory" + OLD."quantity"
WHERE
    "items"."id" = OLD."item_id";

-- Total update
UPDATE "orders"
SET
    "total" = (
        SELECT
            SUM("subtotal")
        FROM
            "order_items"
        WHERE
            "orders"."id" = "order_items"."order_id"
        GROUP BY
            "order_items"."order_id"
    );

END;

-- View to show upcoming maintenance alerts with the clients' info, ordered by closest to today.
CREATE VIEW
    "client_maintenances_alerts" AS
SELECT
    "alert_date",
    "first_name",
    "last_name",
    "email",
    "phone",
    "description"
FROM
    "future_maintenances"
    JOIN "clients" ON "future_maintenances"."client_id" = "clients"."id"
ORDER BY
    "alert_date",
    "last_name",
    "first_name",
    "clients"."id";

-- View to show workers' names and their assigned orders.
CREATE VIEW
    "workers_orders" AS
SELECT
    "work_orders"."id",
    "datetime" AS 'Date created',
    "datetime_fulfilled" AS 'Date fulfilled',
    "client_id",
    CONCAT (
        "clients"."first_name",
        ' ',
        "clients"."last_name"
    ) AS "Client",
    "address",
    CONCAT (
        "workers"."first_name",
        ' ',
        "workers"."last_name"
    ) AS "Worker"
FROM
    "workers"
    JOIN "work_orders" ON "workers"."id" = "work_orders"."worker_id"
    JOIN "orders" ON "orders"."id" = "work_orders"."order_id"
    JOIN "clients" ON "orders"."client_id" = "clients"."id"
ORDER BY
    "Date created" DESC;

-- View to show the summary of all orders, ordered by most recent.
CREATE VIEW
    "order_details" AS
SELECT
    "orders"."id",
    "datetime",
    "first_name",
    "last_name",
    "address",
    "description",
    ROUND("total", 2) AS "total"
FROM
    "orders"
    JOIN "clients" ON "orders"."client_id" = "clients"."id"
ORDER BY
    "datetime" DESC;

-- View to show the complete order details, including items' names, ordered by most recent.
CREATE VIEW
    "complete_orders" AS
SELECT
    "orders"."id",
    "orders"."datetime",
    "first_name",
    "last_name",
    "items"."name",
    ROUND("items"."price", 2) AS "price",
    "order_items"."quantity" AS "quantity",
    ROUND("order_items"."subtotal", 2) AS "subtotal",
    ROUND("orders"."total", 2) AS "total"
FROM
    "orders"
    JOIN "clients" ON "orders"."client_id" = "clients"."id"
    JOIN "order_items" ON "order_items"."order_id" = "orders"."id"
    JOIN "items" ON "order_items"."item_id" = "items"."id"
ORDER BY
    "datetime" DESC,
    "last_name",
    "first_name",
    "clients"."id",
    "items"."id";

-- View to show the details of the items in every order, ordered by the order id.
CREATE VIEW
    "order_items_details" AS
SELECT
    "order_id",
    "name",
    "code",
    "price",
    "quantity",
    "subtotal"
FROM
    "order_items"
    JOIN "items" ON "order_items"."item_id" = "items"."id"
ORDER BY
    "order_id" DESC,
    "order_items"."id" ASC;

-- Create indexes to speed common searches
CREATE INDEX "client_name_search" ON "clients" ("first_name", "last_name");

CREATE INDEX "worker_name_search" ON "workers" ("first_name", "last_name");

CREATE INDEX "item_name_search" ON "items" ("name", "code");

CREATE INDEX "order_date_search" ON "orders" ("datetime");

CREATE INDEX "maintenance_date_search" ON "future_maintenances" ("alert_date");