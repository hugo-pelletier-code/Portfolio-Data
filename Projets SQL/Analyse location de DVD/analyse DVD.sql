-- Nombre de film louable
SELECT COUNT(DISTINCT inventory_id)
FROM rental;

-- Nombre de film disponible dans l'inventaire
SELECT 
  COUNT(inventory_id)
FROM inventory;

-- Existe t'il un film qui n'a jamais été loué ? 
SELECT DISTINCT f.title AS nom_film
FROM inventory AS i
JOIN film AS f ON i.film_id = f.film_id
WHERE NOT EXISTS (
  SELECT 1
  FROM rental AS r
  WHERE r.inventory_id = i.inventory_id
);

-- Nombre de même film disponible

SELECT 
  f.title AS nom_film,
  COUNT(*) AS inventory_count
FROM inventory i
JOIN film f ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY f.title;


-- Lot de film du même nombre

WITH inventory_grouped AS (
SELECT 
  DISTINCT(film_id), 
  COUNT(*) AS inventory_records_count
FROM inventory
GROUP BY film_id)
SELECT 
  inventory_records_count, 
  COUNT(*)
FROM inventory_grouped
GROUP BY inventory_records_count
ORDER BY inventory_records_count;


-- Nombre de film unique
SELECT 
  COUNT(DISTINCT film_id)
FROM film

--Meilleurs films
SELECT 
  f.title AS nom_film,
  COUNT(*) AS nombre_locations
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY nombre_locations DESC;


-- Meilleures catégories
SELECT 
  c.name AS categorie,
  COUNT(*) AS nombre_locations
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY nombre_locations DESC;

-- Meilleurs clients
SELECT 
  r.customer_id,
  COUNT(*) AS total_locations
FROM rental r
GROUP BY r.customer_id
ORDER BY total_locations DESC
LIMIT 5;

-- Moyenne de film loué  par client 
SELECT 
  ROUND(1.0 * COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM rental), 2) AS moyenne_films_par_client
FROM rental;


-- Meilleurs clients par catégorie
WITH location_par_categorie AS (
  SELECT
    c.name AS categorie,
    r.customer_id,
    COUNT(*) AS nb_locations
  FROM rental r
  JOIN inventory i ON r.inventory_id = i.inventory_id
  JOIN film f ON i.film_id = f.film_id
  JOIN film_category fc ON f.film_id = fc.film_id
  JOIN category c ON fc.category_id = c.category_id
  GROUP BY c.name, r.customer_id
),
classement AS (
  SELECT *,
    RANK() OVER (PARTITION BY categorie ORDER BY nb_locations DESC) AS rang
  FROM location_par_categorie
)
SELECT categorie, customer_id, nb_locations
FROM classement
WHERE rang = 1
ORDER BY categorie;


-- Catégorie préféré du client qui à le plus emprunté
SELECT 
  c.name AS categorie,
  COUNT(*) AS nb_locations
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE r.customer_id = 128
GROUP BY c.name
ORDER BY nb_locations DESC;

-- 5 derniers films emprunté par le meileur client
SELECT
  r.customer_id,
  f.title, 
  c.name AS category_name,
  r.rental_date
FROM rental AS r
JOIN inventory AS i ON r.inventory_id = i.inventory_id
JOIN film AS f ON i.film_id = f.film_id
JOIN film_category AS fc ON f.film_id = fc.film_id
JOIN category AS c ON fc.category_id = c.category_id
WHERE r.customer_id = 128
ORDER BY r.rental_date DESC
LIMIT 5;

-- Acteur le plus present dans les films loués
SELECT 
  a.first_name || ' ' || a.last_name AS nom_acteur,
  COUNT(DISTINCT f.film_id) AS nb_films_loues
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id
GROUP BY nom_acteur
ORDER BY nb_films_loues DESC;

