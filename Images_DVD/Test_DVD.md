
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
<img src="Images_DVD/Image1.png" alt="Mon image" width="500">

```sql
SELECT 
  COUNT(inventory_id)
FROM inventory;
```

![[Image 2.png|150]]


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

![[Image 3.png|200]]

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

![[Image 4.png|250]]

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

![[Image 5.png|250]]

En effet, tous les films sont disponibles entre 2 et 8 fois.

## 4. Quel est le film le plus loué ? 

```sql
SELECT 
  COUNT(DISTINCT film_id)
FROM film
```

![[Image 6.png|150]]

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

![[Image 7.png|250]]

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

![[Image 8.png|250]]

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

![[Image 9.png|250]]

C'est le client **128** qui a loué le plus de films (**46**).


```sql
SELECT 
  ROUND(1.0 * COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM rental), 2) AS moyenne_films_par_client
FROM rental;
```

![[Image 9 bis.png|250]]

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

![[Image 10.png|250]]

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

![[Image 11.png|250]]

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

![[Image 12.png|250]]

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

![[Image 13.png|250]]

**Susan Davis** est l'actrice présente dans le plus grand nombre de films loués (**53**).