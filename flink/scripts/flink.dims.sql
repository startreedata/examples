
CREATE TABLE pgcustomer2 (
    customer_id int primary key not enforced,
    store_id int,
    first_name string,
    last_name string,
    email string,
    address_id string,
    activebool boolean,
    last_update TIMESTAMP(3)
) WITH (
    'connector' = 'postgres-cdc', -- postgres cdc connector
    'hostname' = 'postgres',
    'port' = '5432',
    'username' = 'postgres',
    'password' = 'postgres',
    'database-name' = 'dvdrental',
    'schema-name' = 'public',
    'table-name' = 'customer',
    'slot.name' = 'pgcustomers2',
    'scan.incremental.snapshot.enabled' = 'true',
    'decoding.plugin.name'='pgoutput'
);

CREATE TABLE pgrentals2 (
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
    'slot.name' = 'pgrentals2',
    'scan.incremental.snapshot.enabled' = 'true',
    'decoding.plugin.name'='pgoutput'
);

CREATE OR REPLACE TABLE customers_sink(
    customer_id int primary key not enforced,
    store_id int,
    first_name string,
    last_name string,
    email string,
    address_id string,
    activebool boolean,
    last_updated TIMESTAMP(3)
)
WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'customer_sink',
    'properties.bootstrap.servers' = 'kafka:9092',
    'key.format' = 'json',
    'value.format' = 'json'
);

create view customersv as SELECT *
FROM pgcustomer2;

INSERT INTO customers_sink SELECT *
FROM customersv;

CREATE OR REPLACE TABLE rental_sink(
    rental_id  int,
    rental_date timestamp(3),
    inventory_id int,
    customer_id int,
    return_date timestamp(3),
    staff_id int,
    last_update timestamp(3),
    PRIMARY KEY (rental_id) NOT ENFORCED
)
WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'rental_sink',
    'properties.bootstrap.servers' = 'kafka:9092',
    'key.format' = 'json',
    'value.format' = 'json'
);

create view rentalsv as SELECT *
FROM pgrentals2;

insert into rental_sink select * from rentalsv;
