
CREATE TABLE pgcustomer (
    customer_id int primary key not enforced,
    store_id int,
    first_name string,
    last_name string,
    email string,
    address_id string,
    activebool boolean,
    create_date DATE,
    last_update TIMESTAMP(3),
    active int
) WITH (
    'connector' = 'postgres-cdc', -- postgres cdc connector
    'hostname' = 'postgres',
    'port' = '5432',
    'username' = 'postgres',
    'password' = 'postgres',
    'database-name' = 'dvdrental',
    'schema-name' = 'public',
    'table-name' = 'customer',
    'slot.name' = 'pgcustomers1',
    'scan.incremental.snapshot.enabled' = 'true',
    'decoding.plugin.name'='pgoutput'
);

CREATE TABLE pgrentals (
    rental_id  int  primary key not enforced,
    rental_date timestamp(3),
    inventory_id int,
    customer_id int,
    return_date timestamp(3),
    staff_id int,
    last_update timestamp(3)
) WITH (
    'connector' = 'postgres-cdc', -- postgres cdc connector
    'hostname' = 'postgres',
    'port' = '5432',
    'username' = 'postgres',
    'password' = 'postgres',
    'database-name' = 'dvdrental',
    'schema-name' = 'public',
    'table-name' = 'rental',
    'slot.name' = 'pgrentals1',
    'scan.incremental.snapshot.enabled' = 'true',
    'decoding.plugin.name'='pgoutput'
);

CREATE TABLE OBT (
    rental_id INT,
    rental_date TIMESTAMP(3),
    inventory_id INT,
    customer_id INT,
    return_date TIMESTAMP(3),
    staff_id INT,
    rental_last_update TIMESTAMP(3),
    store_id INT,
    first_name STRING,
    last_name STRING,
    email STRING,
    address_id STRING,
    activebool BOOLEAN,
    create_date DATE,
    customer_last_update TIMESTAMP(3),
    active int,
    PRIMARY KEY (rental_id) NOT ENFORCED
)
WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'obt',
    'properties.bootstrap.servers' = 'kafka:9092',
    'properties.group.id' = 'obt',
    'key.format' = 'json',
    'value.format' = 'json'
);

INSERT INTO OBT SELECT 
    rental_id,
    rental_date,
    inventory_id,
    r.customer_id,
    return_date,
    staff_id,
    r.last_update as rental_last_update,
    store_id,
    first_name,
    last_name,
    email,
    address_id,
    activebool,
    create_date,
    c.last_update as customer_last_update,
    active
FROM pgrentals r
LEFT JOIN pgcustomer c  ON r.customer_id=c.customer_id;
