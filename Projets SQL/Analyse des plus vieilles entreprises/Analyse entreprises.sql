--Nombre d'entreprise
SELECT 
    COUNT(business)
FROM businesses

-- Plus vieux et plus récent business
SELECT 
    MIN(year_founded), 
    MAX(year_founded)
FROM businesses;

-- Nombre de business ayant été créer avant l'an 1000
SELECT 
    COUNT(business)
FROM businesses
WHERE year_founded < 1000;

-- Information sur ces entreprises
SELECT *
FROM businesses
WHERE year_founded < 1000
ORDER BY year_founded;

-- Catégorie de ses entreprises ? 
SELECT 
    business, 
    year_founded, 
    b.country_code, 
    category
FROM businesses AS b
INNER JOIN categories AS c
ON b.category_code = c.category_code
WHERE year_founded <1000
ORDER BY year_founded;

-- Nombre d'entreprise de même catégorie
SELECT 
    c.category, 
    COUNT (c.category) AS n
FROM businesses AS b
INNER JOIN categories AS c
    ON b.category_code = c.category_code
GROUP BY c.category
ORDER BY n DESC
LIMIT 10;

-- Âge moyen des entreprises par catégorie (plus ancienne)
SELECT 
  c.category,
  ROUND(AVG(2025 - b.year_founded), 2) AS avg_age
FROM businesses b
JOIN categories c ON b.category_code = c.category_code
GROUP BY c.category
ORDER BY avg_age DESC
LIMIT 3;


-- Âge moyen des entreprises par catégorie (plus récente)
SELECT 
  c.category,
  ROUND(AVG(2025 - b.year_founded), 2) AS avg_age
FROM businesses b
JOIN categories c ON b.category_code = c.category_code
GROUP BY c.category
ORDER BY avg_age
LIMIT 3;
 
-- Plus vieille entreprise par continent (avec nom)
SELECT 
    b.business, 
    b.year_founded, 
    c2.continent
FROM businesses AS b
INNER JOIN countries AS c2 ON b.country_code = c2.country_code
WHERE (c2.continent, b.year_founded) IN (
    SELECT c.continent, MIN(b2.year_founded)
    FROM businesses AS b2
    INNER JOIN countries AS c ON b2.country_code = c.country_code
    GROUP BY c.continent
)
ORDER BY c2.continent;

-- Répartition des catégorie en Europe

SELECT 
    c2.continent, 
    c1.category, 
    COUNT(*) AS n
FROM businesses AS b
INNER JOIN categories AS c1
    ON b.category_code = c1.category_code
INNER JOIN countries AS c2
    ON b.country_code = c2.country_code
WHERE c2.continent = 'Europe'
GROUP BY c2.continent, c1.category
ORDER BY n DESC

-- Meilleur catégorie par continent
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

-- Pays qui n’ont aucune entreprise enregistrée
SELECT 
    c.country
FROM countries c
LEFT JOIN businesses b ON c.country_code = b.country_code
WHERE b.business IS NULL;

-- Nombre de pays qui n’ont aucune entreprise enregistrée par continent
SELECT 
  c.continent,
  COUNT(*) AS countries_without_businesses
FROM countries c
LEFT JOIN businesses b ON c.country_code = b.country_code
WHERE b.business IS NULL
GROUP BY c.continent
ORDER BY countries_without_businesses DESC;

-- Répartion des 'postal service' en Europe
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

--PLus vieille entreprise par catégorie en Asie
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

-- Nombre d'entreprises créées par siècle 
SELECT 
  FLOOR(year_founded / 100) * 100 AS century,
  COUNT(*) AS n
FROM businesses
GROUP BY century
ORDER BY century

-- Nombre d'entreprises créées par siècle (par plus grand nombre d'enteprise)
SELECT 
  FLOOR(year_founded / 100) * 100 AS century,
  COUNT(*) AS n
FROM businesses
GROUP BY century
ORDER BY n DESC;

-- Evolution de la diversité des catégorie
SELECT 
  FLOOR(year_founded / 100) * 100 AS century,
  COUNT(DISTINCT category_code) AS unique_categories
FROM businesses
GROUP BY century
ORDER BY century;

