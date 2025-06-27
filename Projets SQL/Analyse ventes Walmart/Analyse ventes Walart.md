## Objectif

Ce projet vise à analyser les performances commerciales d’un magasin Walmart à partir d’un dataset de ventes comprenant les informations sur les clients, les produits, les villes, les horaires, les modes de paiement et les évaluations clients.  

L’objectif est de répondre à des questions clés sur les ventes, la rentabilité, le comportement d’achat, les préférences des clients et la satisfaction globale, à travers une série de requêtes SQL commentées et interprétées.

## 1. Combien de villes sont présentes dans les données ?

```sql
SELECT 
	COUNT(DISTINCT city) AS nb_villes 
FROM sales;
```

Le jeu de données recense des ventes dans 3 villes distinctes.
## 2. Où se situe chaque branche ?

```sql
SELECT 
	DISTINCT branch, 
	city
 FROM sales;
```

La branche A est à **Yangon**, la B à **Mandalay** et la C à **Naypyitaw**.
## 3. Combien de catégorie de produits sont disponibles ? 

```sql
SELECT 
	COUNT(DISTINCT product_line) AS nb_lignes_produits 
FROM sales;
```

Il y a 6 gammes de produits différentes.
## 4. Quelle est la méthode de paiement la plus fréquente ?

```sql
SELECT 
	payment, 
	COUNT(*) AS nb_utilisations
FROM sales
GROUP BY payment
ORDER BY nb_utilisations DESC;
```

Les paiements par **e-wallet** (345 transactions) et en **espèces** (344) sont les plus courants.
## 5. Quelle est la catégorie de produit la plus vendue ?

```sql
SELECT 
	product_line, 
	COUNT(*) AS nb_ventes
FROM sales
GROUP BY product_line
ORDER BY nb_ventes DESC
LIMIT 1;
```

La catégorie **Fashion accessories** arrive en tête avec 178 ventes.
## 6. Quel est le revenu total par mois ?

```sql
SELECT 
	month_name, SUM(total) AS revenu_total
FROM sales
GROUP BY month_name
ORDER BY revenu_total DESC;
```

Les données couvrent le premier trimestre 2019. **Janvier** est le mois le plus rentable avec 116 292 $, suivi par une baisse en février (97 219 $).
## 7. Quel mois a enregistré le COGS (coût des marchandises vendues) le plus élevé ?

```sql
SELECT 
	month_name, 
	SUM(cogs) AS cogs_total
FROM sales
GROUP BY month_name
ORDER BY cogs_total DESC
LIMIT 1;
```

**Janvier** présente les coûts les plus élevés avec 110 754,16 $.
## 8. Quelle catégorie de produit génère le plus de chiffre d'affaires ?

```sql
SELECT 
	product_line, 
	SUM(total) AS revenu
FROM sales
GROUP BY product_line
ORDER BY revenu DESC;
```

**Food and beverages** est la plus rentable (56 145 $), suivie par **Sports and travel** (55 123 $).
## 9. Quelle ville génère le plus de chiffre d'affaires ?

```sql
SELECT 
	city, 
	SUM(total) AS revenu
FROM sales
GROUP BY city
ORDER BY revenu DESC
LIMIT 1;
```

**Naypyitaw** arrive en tête avec 110 569 $.
## 10. Quelle catégorie de produit a la TVA la plus élevée ?

```sql
SELECT 
	product_line, 
	AVG(vat) AS tva_moyenne
FROM sales
GROUP BY product_line
ORDER BY tva_moyenne DESC
LIMIT 1;
```

La TVA moyenne la plus élevée revient à **Home and lifestyle**, avec 16 $.
## 11. Quelle branche vend plus que la moyenne ?

```sql
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
```

La branche **A** est la plus performante, avec 1 859 articles vendus.
## 12. Quelle est la catégorie de produit préférée par genre ?

```sql
SELECT 
	DISTINCT ON (gender) gender,
	product_line, 
	COUNT(*) AS nb_ventes
FROM sales
GROUP BY gender, product_line
ORDER BY gender, nb_ventes DESC;
```

Les femmes préfèrent la catégorie **Fashion accessories**, les hommes **Health and beauty**.
## 13. Quelle est la note moyenne par catégorie de produit ?

```sql
SELECT 
	product_line, 
	ROUND(AVG(rating), 2) AS note_moyenne
FROM sales
GROUP BY product_line
ORDER BY note_moyenne DESC;
```

**Food and beverages** obtient la meilleure note (7,11). La plus faible revient à **Home and lifestyle** (6,84).
## 14. À quel moment de la semaine les ventes sont-elles les plus nombreuses ? 

```sql
SELECT 
	day_name, 
	time_of_day, COUNT(*) AS nb_ventes
FROM sales
GROUP BY day_name, time_of_day
ORDER BY nb_ventes DESC;
```

Les pics de ventes ont lieu le **samedi soir**, **mardi soir** et **mercredi après-midi**.
## 15.  Quels sont le revenu, les coûts et les bénéfices par catégorie ?

```sql
SELECT 
	product_line, 
	SUM(total) AS revenu, 
	SUM(cogs) AS cout, 
	SUM(total - cogs) AS profit
FROM sales
GROUP BY product_line
ORDER BY profit DESC;
```

**Food and beverages** et **Sports and travel** sont les plus rentables avec respectivement 2 673 $ et 2 625 $ de bénéfices.
## 16. Quel est le oment de la journée avec le panier moyen le plus élevé ?

```sql
SELECT 
    time_of_day,
    COUNT(*) AS nb_ventes,
    SUM(quantity) AS qte_totale,
    ROUND(SUM(quantity)::decimal / COUNT(*), 2) AS panier_moyen_qte,
    ROUND(SUM(total)::decimal / COUNT(*), 2) AS panier_moyen_valeur
FROM sales
GROUP BY time_of_day
ORDER BY panier_moyen_valeur DESC;
```

L’après-midi enregistre le panier moyen le plus élevé : **325,72 $** pour **5,6 articles**.
## 17. Quel type de client est le plus fréquent ?

```sql
SELECT 
	customer_type, 
	COUNT(*) AS nb
FROM sales
GROUP BY customer_type
ORDER BY nb DESC
LIMIT 1;
```

Les **membres** sont les plus représentés parmi les clients.
## 18. Quel type de client dépense le plus en moyenne ?

```sql
SELECT 
    customer_type,
    ROUND(AVG(total), 2) AS achat_moyen
FROM sales
GROUP BY customer_type
ORDER BY achat_moyen DESC;
```

Les **membres** sont aussi ceux qui dépensent le plus, avec **327 $** par achat en moyenne.
## 19. Quel est le genre majoritaire ?

```sql
SELECT 
	gender, 
	COUNT(*) AS n
FROM sales
GROUP BY gender
ORDER BY n DESC;
```

La clientèle est quasiment équilibrée entre hommes et femmes. Seulement 2 achats de plus ont été effectué par des femmes.
## 20.  À quel moment de la journée la satisfaction client est-elle la plus élevée ?

```sql
SELECT 
	time_of_day, 
	ROUND(AVG(rating), 2) AS note_moyenne
FROM sales
GROUP BY time_of_day
ORDER BY note_moyenne DESC;
```

L’après-midi obtient la meilleure note moyenne : **7,03**.
## 26. Quel jour de la semaine obtient la meilleure note moyenne ?

```sql
SELECT 
	day_name, 
	ROUND(AVG(rating), 2) AS note_moyenne
FROM sales
GROUP BY day_name
ORDER BY note_moyenne DESC;
```

C’est le **lundi** qui enregistre la meilleure note moyenne : **7,15**.
