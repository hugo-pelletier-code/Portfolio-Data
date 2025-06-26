### Analyse des plus vieilles entreprises du monde

## Source des données  
Le site [BusinessFinancing.co.uk](https://www.businessfinancing.co.uk/) a recherché les entreprises les plus anciennes encore en activité dans presque chaque pays du monde. Leurs résultats ont été compilés dans un ensemble de données structuré, contenant pour chaque entreprise :  
- son nom,  
- son pays,  
- son année de création,  
- son secteur d’activité.

## Description des données  
Le jeu de données est structuré en trois tables relationnelles :
- `businesses` : informations sur les entreprises (nom, année de fondation, code pays, code catégorie)  
- `countries` : liste des pays avec leurs codes et leur continent  
- `categories` : secteurs d'activité associés aux entreprises  

## Objectif
Ce projet a pour but de réaliser une exploration analytique approfondie de ces données via des requêtes SQL.  
Les objectifs principaux sont :
- Identifier les entreprises les plus anciennes au niveau mondial, par continent, pays ou secteur  
- Comprendre la répartition géographique et sectorielle des entreprises historiques  
- Repérer les pays ou catégories sous-représentés ou sans entreprise connue  
- Révéler des tendances historiques de fondation d’entreprises à travers le monde  

## 1. Combien d'entreprises sont présentes dans le dataset ? 

```sql
SELECT Count(business)
FROM businesses
```

Le jeu de données contient **163 entreprises** différentes.

## 2. Quelle est l’entreprise la plus ancienne et la plus récente ?

```sql
SELECT MIN(year_founded), MAX(year_founded)
FROM businesses;
```
L’entreprise la plus ancienne date de **578** et la plus récente de **1999**.

## 3. Combien d’entreprises ont été créées avant l’an 1000 ?

```sql
SELECT COUNT(business)
FROM businesses
WHERE year_founded < 1000;
```
Nous avons 6 entreprises datant d'avant l'an 1000.

```sql
SELECT *
FROM businesses
WHERE year_founded < 1000
ORDER BY year_founded;
```
La plus ancienne entreprise du jeu de données est **Kongō Gumi**, fondée en **578 au Japon**. On retrouve également une entreprise française : **la Monnaie de Paris**, créée en **864**.

## 4. Quelles sont les catégories de ces entreprises ?

```sql
SELECT business, year_founded, b.country_code, category
FROM businesses AS b
INNER JOIN categories AS c
ON b.category_code = c.category_code
WHERE year_founded <1000
ORDER BY year_founded;
```
Ces 6 entreprises se répartissent dans **4 catégories** :
- **"Construction"**
- **"Cafés, Restaurants & Bars"**
- **"Distillers, Vintners, & Breweries"**
- **"Manufacturing & Production"**

## 5. Quelles sont les catégories les plus représentées ?

```sql
SELECT c.category, COUNT (c.category) AS n
FROM businesses AS b
INNER JOIN categories AS c
    ON b.category_code = c.category_code
GROUP BY c.category
ORDER BY n DESC
LIMIT 10;
```

Les secteurs comptant le plus d’entreprises anciennes sont :
- **"Banking & Finance"** avec 37 entreprises
- **"Distillers, Vintners, & Breweries"** avec 22 entreprises
- **"Aviation & Transport"** avec 19 entreprises

## 6. Quel est l’âge moyen des entreprises par catégorie ?

```sql
SELECT 
  c.category,
  ROUND(AVG(2025 - b.year_founded), 2) AS avg_age
FROM businesses b
JOIN categories c ON b.category_code = c.category_code
GROUP BY c.category
ORDER BY avg_age DESC
LIMIT 3;
```

```sql
SELECT 
  c.category,
  ROUND(AVG(2025 - b.year_founded), 2) AS avg_age
FROM businesses b
JOIN categories c ON b.category_code = c.category_code
GROUP BY c.category
ORDER BY avg_age
LIMIT 3;
```

La catégorie avec les entreprises **les plus anciennes** est **"Construction"**, avec une moyenne de **803,5 ans**. À l’inverse, le secteur **"Media"** affiche la moyenne d’âge la plus faible : **73,14 ans**.

## 7. Quelle est la plus ancienne entreprise par continent ? 

```sql
SELECT b.business, b.year_founded, c2.continent
FROM businesses AS b
INNER JOIN countries AS c2 ON b.country_code = c2.country_code
WHERE (c2.continent, b.year_founded) IN (
    SELECT c.continent, MIN(b2.year_founded)
    FROM businesses AS b2
    INNER JOIN countries AS c ON b2.country_code = c.country_code
    GROUP BY c.continent
)
ORDER BY c2.continent;
```

Sans surprise, l'entreprise la plus ancienne d’**Asie** est **Kongō Gumi**. En **Europe**, il s’agit de **St. Peter Stifts Kulinarium**, fondée avant l’an 1000. Pour l’**Océanie**, l'entreprise la plus ancienne est **Australia Post**, créée en **1809**, soit **1331 ans après** celle d’Asie.

## 8. Quelle est la répartition des catégories d’entreprises en Europe ?

```sql
SELECT c2.continent, c1.category, COUNT(*) AS n
FROM businesses AS b
INNER JOIN categories AS c1
    ON b.category_code = c1.category_code
INNER JOIN countries AS c2
    ON b.country_code = c2.country_code
WHERE c2.continent = 'Europe'
GROUP BY c2.continent, c1.category
ORDER BY n DESC
```

En Europe, les catégories les plus représentées sont :
- **"Distillers, Vintners, & Breweries"** (12 entreprises)
- **"Manufacturing & Production"** (8)
- **"Banking & Finance"** (5)

## 9.  Quelle est la catégorie dominante par continent ?

```sql
WITH category_counts AS (
    SELECT 
        c2.continent,
        c1.category,
        COUNT(*) AS n,
        ROW_NUMBER() OVER (PARTITION BY c2.continent ORDER BY COUNT(*) DESC) AS rn
    FROM businesses AS b
    INNER JOIN categories AS c1 ON b.category_code = c1.category_code
    INNER JOIN countries AS c2 ON b.country_code = c2.country_code
    GROUP BY c2.continent, c1.category
)
SELECT continent, category, n
FROM category_counts
WHERE rn = 1
ORDER BY continent;
```

- En **Afrique** : "Banking & Finance" (17 entreprises)
- En **Océanie** : "Banking & Finance" (2)
- En **Amérique du Sud** : "Banking & Finance" (3)
- En **Amérique du Nord** : "Distillers, Vintners, & Breweries" (5)
- En **Asie** : "Aviation & Transport" (7)
- 
## 10. Y a-t-il des pays pour lesquels aucune entreprise ancienne n’a été recensée ?

```sql
SELECT c.country
FROM countries c
LEFT JOIN businesses b ON c.country_code = b.country_code
WHERE b.business IS NULL;
```

```sql
SELECT 
  c.continent,
  COUNT(*) AS countries_without_businesses
FROM countries c
LEFT JOIN businesses b ON c.country_code = b.country_code
WHERE b.business IS NULL
GROUP BY c.continent
ORDER BY countries_without_businesses DESC;
```

Il y a **32 pays** pour lesquels aucune entreprise ancienne n’a été identifiée. On en recense **11 en Océanie**, dont **les Fidji** ou encore **les Samoa**.

## 11. Quelle est la répartition des entreprises de type "Postal Service" en Europe ?

```sql
SELECT 
    b.business, 
    c.category, 
    b.year_founded,
    co.country
FROM businesses b
JOIN categories c ON b.category_code = c.category_code
JOIN countries co ON b.country_code = co.country_code
WHERE co.continent = 'Europe'
  AND c.category = 'Postal Service'
ORDER BY b.year_founded;
```

Il existe **4 entreprises postales anciennes** en Europe.  
La plus ancienne est celle du **Portugal** (1520), la plus récente celle du **Monténégro** (1841).

## 12. Quelle est la plus vieille entreprise par catégorie en Asie ?

```sql
SELECT 
    co.continent,
    ca.category,
    b.year_founded AS oldest_year,
    co.country
FROM businesses b
JOIN categories ca ON b.category_code = ca.category_code
JOIN countries co ON b.country_code = co.country_code
WHERE co.continent = 'Asia'
  AND b.year_founded = (
      SELECT MIN(b2.year_founded)
      FROM businesses b2
      JOIN countries co2 ON b2.country_code = co2.country_code
      JOIN categories ca2 ON b2.category_code = ca2.category_code
      WHERE co2.continent = 'Asia'
        AND ca2.category = ca.category
  )
ORDER BY b.year_founded;
```

Les 3 secteurs comptant les plus anciennes entreprises en Asie sont :
- **"Construction"** (Japon)
- **"Cafés, Restaurants & Bars"** (Chine)
- **"Tourism & Hotels"** (Turquie)
- 
Le secteur le plus récent est **"Media"**, avec une entreprise fondée en **1931 en Mongolie**.

## 13. Combien d’entreprises ont été créées par siècle ?

```sql
SELECT 
  FLOOR(year_founded / 100) * 100 AS century,
  COUNT(*) AS n
FROM businesses
GROUP BY century
ORDER BY century
```

```sql
SELECT 
  FLOOR(year_founded / 100) * 100 AS century,
  COUNT(*) AS n
FROM businesses
GROUP BY century
ORDER BY n DESC;
```

Avant **1300**, seules **18 entreprises** encore en activité aujourd’hui avaient été fondées.  Les **XIXe et XXe siècles** ont connu un essor avec **52 et 67 entreprises** respectivement.
## 14. Quelle est l’évolution du nombre de catégories par siècle ?

```sql
SELECT 
  FLOOR(year_founded / 100) * 100 AS century,
  COUNT(DISTINCT category_code) AS unique_categories
FROM businesses
GROUP BY century
ORDER BY century;
```

Avant le **XVIe siècle**, on ne comptait jamais plus de **5 catégories** différentes d'entreprises créées par siècle.  
Ce nombre grimpe à **14** au **XXe siècle** et **13** au **XIXe**, illustrant une diversification progressive des secteurs d’activité.
