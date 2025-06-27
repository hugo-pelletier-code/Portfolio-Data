
-- 1. Combien de villes distinctes sont présentes dans les données ?
SELECT 
	COUNT(DISTINCT city) AS nb_villes 
FROM sales;

-- 2. Dans quelle ville se situe chaque succursale ?
SELECT 
	DISTINCT branch, 
	city 
FROM sales;


-- 3. Nombre de lignes de produits distinctes ?
SELECT 
	COUNT(DISTINCT product_line) AS nb_lignes_produits 
FROM sales;

-- 4. Méthode de paiement la plus fréquente
SELECT 
	payment, 
	COUNT(*) AS nb_utilisations
FROM sales
GROUP BY payment
ORDER BY nb_utilisations DESC;

-- 5. Ligne de produit la plus vendue
SELECT 
	product_line, 
	COUNT(*) AS nb_ventes
FROM sales
GROUP BY product_line
ORDER BY nb_ventes DESC
LIMIT 1;

-- 6. Revenu total par mois
SELECT 
	month_name, 
	SUM(total) AS revenu_total
FROM sales
GROUP BY month_name
ORDER BY revenu_total DESC;

-- 7. Mois avec le coût des marchandises vendues (COGS) le plus élevé
SELECT 
	month_name, 
	SUM(cogs) AS cogs_total
FROM sales
GROUP BY month_name
ORDER BY cogs_total DESC
LIMIT 1;

-- 8. Catégorie de produit avec le plus de chiffre d'affaires
SELECT 
	product_line, 
	SUM(total) AS revenu
FROM sales
GROUP BY product_line
ORDER BY revenu DESC;

-- 9. Ville avec le plus haut chiffre d'affaires
SELECT 
	city, 
	SUM(total) AS revenu
FROM sales
GROUP BY city
ORDER BY revenu DESC
LIMIT 1;

-- 10. Ligne de produit avec la TVA la plus élevée
SELECT 
	product_line, 
	AVG(vat) AS tva_moyenne
FROM sales
GROUP BY product_line
ORDER BY tva_moyenne DESC
LIMIT 1;

-- 11. Branche ayant vendu plus que la moyenne
SELECT 
	branch, 
	SUM(quantity) AS total_vendu
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (
    SELECT AVG(q) FROM (
        SELECT SUM(quantity) AS q FROM sales GROUP BY branch
    ) AS moyennes
)
ORDER BY total_vendu DESC;

-- 12. Catégorie de produit la plus populaire par genre
SELECT 
	DISTINCT ON (gender) gender, 
	product_line, 
	COUNT(*) AS nb_ventes
FROM sales
GROUP BY gender, product_line
ORDER BY gender, nb_ventes DESC;

-- 13. Note moyenne par catégorie de produit
SELECT 
	product_line, 
	ROUND(AVG(rating), 2) AS note_moyenne
FROM sales
GROUP BY product_line
ORDER BY note_moyenne DESC;


-- 14. Ventes par moment de la journée
SELECT 
	day_name, 
	time_of_day, 
	COUNT(*) AS nb_ventes
FROM sales
GROUP BY day_name, time_of_day
ORDER BY nb_ventes DESC;


-- 15. Revenu, Coûts, Profit par ligne de produit
SELECT 
	product_line, 
	SUM(total) AS revenu, 
	SUM(cogs) AS cout, 
	SUM(total - cogs) AS profit
FROM sales
GROUP BY product_line
ORDER BY profit DESC;

-- 16. Moment de la journée avec panier moyen le plus élevé
SELECT 
    time_of_day,
    COUNT(*) AS nb_ventes,
    SUM(quantity) AS qte_totale,
    ROUND(SUM(quantity)::decimal / COUNT(*), 2) AS panier_moyen_qte,
    ROUND(SUM(total)::decimal / COUNT(*), 2) AS panier_moyen_valeur
FROM sales
GROUP BY time_of_day
ORDER BY panier_moyen_valeur DESC;

-- 17. Type de client le plus fréquent
SELECT 
	customer_type, 
	COUNT(*) AS nb
FROM sales
GROUP BY customer_type
ORDER BY nb DESC
LIMIT 1;

-- 18. Type de client qui achète le plus (valeur)
SELECT 
    customer_type,
    ROUND(AVG(total), 2) AS achat_moyen
FROM sales
GROUP BY customer_type
ORDER BY achat_moyen DESC;


-- 19. Genre le plus présent parmi les clients
SELECT 
	gender, 
	COUNT(*) AS n
FROM sales
GROUP BY gender
ORDER BY n DESC;

-- 20. Moment de la journée avec la meilleure note moyenne
SELECT 
	time_of_day, 
	ROUND(AVG(rating), 2) AS note_moyenne
FROM sales
GROUP BY time_of_day
ORDER BY note_moyenne DESC;


-- 21. Jour avec la meilleure note moyenne
SELECT 
	day_name, 
	ROUND(AVG(rating), 2) AS note_moyenne
FROM sales
GROUP BY day_name
ORDER BY note_moyenne DESC;
