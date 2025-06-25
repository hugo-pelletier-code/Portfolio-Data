# Analyse des comportements de location de films dans une base de données DVD

## Objectif

Ce document présente une série d’analyses SQL réalisées à partir d’une base de données de locations de DVD.  
L’objectif est de répondre à différentes questions métiers à l’aide de requêtes SQL : nombre de films disponibles et loués, identification des films les plus populaires, catégories préférées des clients, comportements de location des meilleurs clients, ainsi que l’influence des acteurs.

Chaque section est illustrée avec des extraits SQL et des observations claires, permettant une meilleure compréhension des données et un appui à la prise de décision marketing.
## 1. Combien de films sont disponibles à la location et dans l'inventaire ?

```sql
SELECT 
  COUNT(inventory_id)
FROM rental;
```
<img src="https://github.com/user-attachments/assets/5d558027-0310-4bd0-8819-e94471f6afec)" alt="Image" width="150">


```sql
SELECT 
  COUNT(inventory_id)
FROM inventory;
```

<img src="https://github.com/user-attachments/assets/7432fd05-d3f4-4af2-a7d6-ed1a119261c2" alt="Image" width="150">


Il semble qu'il y ait 4 580 films louable et 4 581 films disponibles dans l'inventaire.
Il y a donc un film supplémentaire dans l'inventaire.

## 2. Explication de cette différence


```sql
SELECT DISTINCT f.title AS nom_film
FROM inventory AS i
JOIN film AS f ON i.film_id = f.film_id
WHERE NOT EXISTS (
  SELECT 1
  FROM rental AS r
  WHERE r.inventory_id = i.inventory_id
);
```
<img src="https://github.com/user-attachments/assets/39ebeeaa-ffaa-4419-9660-fae81cfeb991" alt="Image" width="200">

Il y a en effet un film, **"ACADEMY DINOSAUR"**, qui n'a jamais été emprunté. On peut supposer que ce film spécifique n’a jamais été loué par aucun client, c’est pourquoi il n’apparaît pas dans la table `rental`.

## 3. Est-ce que les films sont disponibles en plusieurs exemplaires ?

```sql
SELECT 
  f.title AS nom_film,
  COUNT(*) AS inventory_count
FROM inventory i
JOIN film f ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY f.title;
```
<img src="https://github.com/user-attachments/assets/57e19126-95e4-4bab-9f6f-e098d3c2ce11" alt="Image" width="250">

Il y a plusieurs fois le même film de disponible. Par exemple, le film **"ACADEMY DINOSAUR"** est disponible 8 fois dans l'inventaire c'est sûrement pour ça qu'un de ses exemplaires n'a jamais été loué.

```sql
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
```

<img src="https://github.com/user-attachments/assets/ff6d9757-d802-405d-8f0b-78890df5bf0b" alt="Image" width="250">

En effet, tous les films sont disponibles entre 2 et 8 fois.

## 4. Quel est le film le plus loué ? 

```sql
SELECT 
  COUNT(DISTINCT film_id)
FROM film
```
<img src="https://github.com/user-attachments/assets/a795354c-421e-4120-b7e7-544a6d6153c7" alt="Image" width="150">

Il y a 1000 films différents à louer.

```sql
SELECT 
  f.title AS nom_film,
  COUNT(*) AS nombre_locations
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY nombre_locations DESC;
```

<img src="https://github.com/user-attachments/assets/b7684e95-ea55-4b44-9cf7-814378284a1f" alt="Image" width="250">

Le film le plus loué est **"BUCKET BROTHERHOOD"**.

## 5. Quel est la catégorie de film préférée des clients ? 

```sql
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
```

<img src="https://github.com/user-attachments/assets/248c8319-54a5-4475-aa1f-be1ba3018686" alt="Image" width="250">

La catégorie préférée est **Sports**, suivie de **Animation**.

## 6. Qui est le client qui a loué le plus de films ? 

```sql
SELECT 
  r.customer_id,
  COUNT(*) AS total_locations
FROM rental r
GROUP BY r.customer_id
ORDER BY total_locations DESC
LIMIT 5;
```

<img src="https://github.com/user-attachments/assets/bb24092b-37e8-4c69-bdd6-369672fbd99a" alt="Image" width="250">

C'est le client **128** qui a loué le plus de films (**46**).

```sql
SELECT 
  ROUND(1.0 * COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM rental), 2) AS moyenne_films_par_client
FROM rental;
```
<img src="https://github.com/user-attachments/assets/1687338b-96d4-43d3-b537-f7af6c672c93" alt="Image" width="250">

En moyenne, un client loue entre **26 et 27 films**. Cela signifie que le client **128** a loué **presque deux fois plus de films** qu’un client moyen.

## 7. Quel client a loué le plus de films de meme catégorie

```sql
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
```

<img src="https://github.com/user-attachments/assets/348bb435-75c5-4603-affc-75d9c026867c" alt="Image" width="250">

On peut voir, par exemple, que pour la catégorie **Action**, ce sont les clients **323** et **506** qui ont loué le plus de films de ce genre avec **7 chacun**.

## 8. Quel est la catégorie préféré du meilleu client
```sql
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
```

<img src="https://github.com/user-attachments/assets/22d7c04e-301c-4804-bd3c-f857efa37490" alt="Image" width="250">

On peut voir que le client qui emprunte le plus préfère les films de **Musique**, **Sport** et **Animation**.
## 9. Quels sont les 5 derniers films qu'il a emprunté et de quel catégorie il s'agit ? 

```sql
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
```

<img src="https://github.com/user-attachments/assets/6de01e2e-7ced-441c-b4b2-e1f39d6c808b" alt="Image" width="250">

Dans ce tableau, on peut voir que le dernier film qu'il a emprunté est un film d’**Animation** nommé **"Falcon Volume"**, le **23 août 2005**.

## 10. Quels sont les acteurs présent dans le plus de films loués ?

```sql
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
```

<img src="https://github.com/user-attachments/assets/b563e7cc-7b55-4bbb-8cc8-e17c8d5a46ca)" alt="Image" width="250">

**Susan Davis** est l'actrice présente dans le plus grand nombre de films loués (**53**).
