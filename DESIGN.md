# Design Document

A Smart SQLite Database for Water Filtration Business Operations

By Federico Huerta

Video overview: <URL HERE>

## Scope

The database for this project allows for a business dedicated to the sale, installation and maintenance of water filtration systems that produce safe drinking water to track customers, items sold, workers, their work orders (installing sold items) and future maintenances. This project expands upon a personal spreadsheet I used to track something similar but on a smaller scale.

Included in this database are:

* Customers: Basic information such as first name, last name, address, etc.
* Items: Product information like product name, price, internal code, and current inventory.
* Orders: A purchase transaction that a client made with the business.
* Workers: Very basic information on employees that fulfill orders (installation or maintenance).
* Work orders: The link between a worker and its assigned orders.
* Items in an order: A "fake" array structure to include more than one item in an order since SQLite3 doesn't support them.

Outside the scope are more varied order items like services, more than one address per customer, business organizational structure, and payment transactions and receipts.

## Functional Requirements

In this section you should answer the following questions:
This database will support:

* CRUD operations for employees in all/most tables.
* Creating more than one order for a particular client.
* Including more than one item in any amount on one order.
* Assigning one or multiple (if the job requires it) workers to one or more orders.
* Creating maintenance alerts for a client to let them know about upcoming maintenances.

This database won't support:

* Generating order documents (like a bill) using json or xml files.
* Inserting, updating or deleting rows from views to avoid writing a lot of additional triggers.
* Managing returns.
* Logic and automation operations better reserved to be done at the application level.
* Compliance with data protection laws like GDPR when deleting a client's data that might break foreign keys in their past orders.

## Representation

All entities and their relations are created using SQLite3 with the following schema.

### Entities

#### Clients

The `clients` table includes:

* `id`: specifies the unique ID for the client as `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `first_name`: specifies the client's first name as `TEXT`. `TEXT` is used because a first name is a string.
* `last_name`: specifies the client's last name as `TEXT`. `TEXT` is used for the same reason as `first_name`.
* `phone`: specifies the client's contact phone number. `TEXT` is used to accomodate leading zeros, plus signs and hyphens.
* `email`: specifies the client's contact email address as `TEXT`. `TEXT` is used because an email is a complex string.
* `address`: specifies the client's home address as `TEXT`. `TEXT` is used because an address is a complex string.

All columns are required and have the `NOT NULL` constraint. `UNIQUE` constraints may be applied to most columns but it's not necessary at this level of complexity.

#### Items

The `items` table includes:

* `id`: specifies the unique ID for the item as `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `name`: specifies the item's descriptive name as `TEXT`. `TEXT` is used because the descriptive name is a string.
* `code`: specifies the item's internal code identifier as `TEXT`. `TEXT` is used because the code can be alphanumeric. It must be unique and has the `UNIQUE` constraint applied.
* `inventory`: specifies the item's current inventory as `INTEGER`. `INTEGER` is used because quantities must be whole numbers. It has a `CHECK` constraint to make sure the inventory cannot go into the negatives and avoid selling more items that current exist in the warehouse.
* `price`: specifies the item's price per unit as `REAL`. `REAL` is used to visually differentiate from `NUMERIC` and allow decimals coming from cents. It has a `CHECK` constraint to make sure the price is above zero.

All columns have the `NOT NULL` constraint applied unless it's a `PRIMARY KEY`.

#### Orders

The `orders` table includes:

* `id`: specifies the unique ID for the order as `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `datetime`: specifies the order's date as `NUMERIC` and has the default value of the current system time specified by `DEFAULT CURRENT_TIMESTAMP`. `NUMERIC` is used because that's how SQLite manages dates.
* `client_id`: specifies the ID of the client associated with the order as `INTEGER`. This column thus has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `clients` table.
* `total`: specifies the total cost of the order as `REAL`. `REAL` is used because a price must be decimal to specify cents. It's calculated through triggers and thus, doesn't really need any constraints.
* `description`: specifies the order's descriptive or comment as `TEXT`. `TEXT` is used because a description is a string. It's an optional field.

Only the column `datetime` requires an explicit `NOT NULL` constraint.

#### Order items

The `order_items` table fakes an array structure in SQLite to allow including more than one item in the same order. SQLite doesn't really support arrays, and for this project I deemed this solution sufficient as opposed to using semi-structured data structures like json or xml files. This table includes:

* `id`: specifies the unique ID for the entry in the array as `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `order_id`: specifies the ID of the order associated with the included item as `INTEGER`. This ID groups the items in an order together and delimits the "array" from others. This column thus has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `orders` table.
* `item_id`: specifies the ID of the item included in the order `INTEGER`. This column has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `items` table.
* `quantity`: specifies the amount of the item being sold in the order as `INTEGER`. `INTEGER` is used because quantities must be whole numbers. This column has a `CHECK` constraint to make sure the quantity is above zero.
* `subtotal`: specifies the subtotal cost of the item based on the price per unit and its quantity as `REAL`. `REAL` is used because a price should be decimal to specify cents. It's calculated through triggers and thus doesn't really need any constraints.

Only the column `quantity` requires an explicit `NOT NULL` constraint.

#### Workers

The `workers` table includes:

* `id`: specifies the unique ID for the worker as `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `first_name`: specifies the worker's first name as `TEXT`. `TEXT` is used because a first name is a string.
* `last_name`: specifies the worker's last name as `TEXT`. `TEXT` is used for the same reason as `first_name`.

Both name columns are required and have the `NOT NULL` constraint.

#### Work orders

The `work_orders` table includes:

* `id`: specifies the unique ID for the work order as `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `order_id`: specifies the ID of the order associated with the generated work order as `INTEGER`. This column thus has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `orders` table.
* `order_id`: specifies the ID of the worker assigned to the generated work order as `INTEGER`. This column thus has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `workers` table.
* `datetime_fulfilled`: specifies the order's date when it was fulfilled or completed as `NUMERIC`. `NUMERIC` is used because that's how SQLite manages dates.

No constraints are necessary beyond the ones defined by `PRIMARY KEY` and `FOREIGN KEY`. The `datetime_fulfilled` can be empty until the order is fulfilled.

#### Future maintenances

The `future_maintenances` table includes:

* `id`: specifies the unique ID for the future maintenance alert as `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `client_id`: specifies the ID of the client associated with future maintenance alert as `INTEGER`. This column thus has the `FOREIGN KEY` constraint applied, referencing the `id` column in the `clients` table.
* `alert_date`: specifies the date when the client should be contacted to inform them about a future maintenance as `NUMERIC`. `NUMERIC` is used because that's how SQLite manages dates.
* `description`: describes what the alert should be about like filters to change, or procedures to execute as `TEXT`. `TEXT` is used because a description is a string.

All the columns that aren't `PRIMARY KEY` or `FOREIGN KEY` should have the `NOT NULL` constraint.

### Relationships

The following entity relationship diagram describes the relationships among the entities in the database. It was made with the program "Enterprise Architect" and includes additional information like columns and constraints.

![ER Diagram](diagram.bmp)

The diagram can be mostly read from top to bottom and left to right. However, that doesn't really make sense chronologically. Thus, the diagram goes as follows:

* A client may request zero or many orders. Zero if they haven't bought anything in the business yet, and many if they are repeating customers. One order can only be associated with one customer.
* An order must, in practical terms, have one or many items in it. One because if an order has no items, it would be an empty order and thus shouldn't exist, and many if the client is buying more than one item. These items are stored in a simulated array in the `order_items` table. Any item in this array structure must be associated with just one order.
* The array structure `order_items` can pull information from the `items` table. Because of its simulated nature, this table has unconventional relations. Every item inside an array must be associated with one item entry from the `items` inventory registry. Multiple arrays can be associated with the same item entry from the `items` inventory registry, when clients are buying the same item on different occasions. An item entry from the `items` inventory registry can be in zero or many items in the array structure, zero if a particular item in inventory hasn't been sold yet, or many when the same item is being sold in multiple orders. Within the scope and limitations of this project, I've yet to find a better solution and welcome any suggestions in this regard.
* A client's order generates one and only one work order. A work order can be associated with one and only one client's order.
* A work order must be worked on by one or more workers, one if the job is simple and many if the job is complex. One worker may work on zero or many work orders, zero if the worker is a recent hire and hasn't started working yet, and many if the worker has been assigned multiple work orders throughout the day.

## Optimizations

### Indexes

In an initial optimization pass, and per the typical queries in `queries.sql` one might do, to improve search times based on people's first or last names, items' names or codes, dates of orders and maintenance alerts, the following indexes were created:

* `client_name_search`: On the columns `first_name` and `last_name`.
* `worker_name_search`: On the columns `first_name` and `last_name`.
* `item_name_search`: On the columns `name` and `code`.
* `order_date_search`: On the column `datetime`.
* `maintenance_date_search`: On the column `alert_date`.

### Views

Additionaly, the following views were created to speed up the process of finding information in joined tables:

* `client_maintenances_alerts`: Joins the `future_maintenances` and `clients` tables to show clients' name and their assigned alerts.
* `workers_orders`: Joins the `work_orders`, `orders`, `clients` and `workers` tables to show every work order, including the client's name, the workers' name, the date the order was created and the date the work order was fulfilled, if it was.
* `order_details`: Joins the `orders` and `clients` tables to show every order with its respective client name.
* `complete_order_details`: Joins the `orders`, `clients`, `order_items` and `items` to show every order including the client's name, the order's date, every item's name, its quantity, price per unit, subtotal for every item and the total for each whole order. Some values repeat themselves throughout the rows, like the `total` in every row corresponding to the same order.
* `order_items_details`: Joins the `order_items` and `items` tables to show the name, code, price per unit and subtotal for every item included in every order.

### Triggers

Finally, the following triggers were created to introduce some limited automation when calculating the subtotal for items and total for orders and updating the business' inventory according to sales made:

* `item_sold_insert`: After an item is inserted (added) to an order's items array, it will update its subtotal multiplying the amount by the unitary price, update the order's total summing up every subtotal linked to it, and update the inventory subtracting the sold amount from the particular item's inventory value. This would happen when a cashier adds an item to the bill.
* `item_sold_update`: After an item's amount is updated in an order's items array, it will update its subtotal multiplying the new amount by the unitary price, update the order's total summing up every subtotal linked to it, and update the inventory adding the old amount back and substracting the new sold amount from the particular's item inventory value. This would happen when a cashier corrects an item's amount based on the client's wishes but should not occur after the transaction has been finalized and the client has left the premises or received their items.
* `item_sold_delete`: After an item is deleted from an order's items array, update the order's total summing up every remaining subtotal linked to it, and update the inventory adding the old amount back. This would happen when a cashier removes an item from the "purchase basket" based on the client's wishes but should not occur after the transaction has been finalized and the client has left the premises or received their items.

## Limitations

Some limitations in this current design are:

* An array structure cannot be correctly represented in SQLite3 due to DBMS limitations. I'm avoiding using other methods like json or xml files for simplicity.
* A neat and non-repetitive view of a full order, including a client's name, order's date, and items in it cannot be properly shown with the current schema and queries.
* I'm assuming that a client only has one address, otherwise, it would require a many-to-many relationship which complicates matters when it comes to specifying where a work order is gonna be worked at, creating circular foreign key relationships. This was skipped for convenience and simplicity in the schema and ER diagram.
* Ideally, a future maintenance order should be generated automatically, but this could be better achieved at an application level.
