CREATE TABLE actor (
    actor_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    last_update TIMESTAMP
);

CREATE TABLE category (
    category_id INTEGER PRIMARY KEY,
    name VARCHAR(50),
    last_update TIMESTAMP
);

CREATE TABLE film (
    film_id INTEGER PRIMARY KEY,
    title VARCHAR(255),
    description TEXT,
    release_year INTEGER,
    language_id INTEGER,
    original_language_id INTEGER,
    rental_duration INTEGER,
    rental_rate NUMERIC,
    length INTEGER,
    replacement_cost NUMERIC,
    rating VARCHAR(10),
    last_update TIMESTAMP,
    special_features TEXT,
    fulltext TEXT
);

CREATE TABLE film_actor (
    actor_id INTEGER,
    film_id INTEGER,
    last_update TIMESTAMP,
    PRIMARY KEY (actor_id, film_id)
);

CREATE TABLE film_category (
    film_id INTEGER,
    category_id INTEGER,
    last_update TIMESTAMP,
    PRIMARY KEY (film_id, category_id)
);

CREATE TABLE inventory (
    inventory_id INTEGER PRIMARY KEY,
    film_id INTEGER,
    store_id INTEGER,
    last_update TIMESTAMP
);

CREATE TABLE rental (
    rental_id INTEGER PRIMARY KEY,
    rental_date TIMESTAMP,
    inventory_id INTEGER,
    customer_id INTEGER,
    return_date TIMESTAMP,
    staff_id INTEGER,
    last_update TIMESTAMP
);


\copy actor FROM 'actor.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
\copy category FROM 'category.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
\copy film FROM 'film.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
\copy film_actor FROM 'film_actor.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
\copy film_category FROM 'film_category.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
\copy inventory FROM 'inventory.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
\copy rental FROM 'rental.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
