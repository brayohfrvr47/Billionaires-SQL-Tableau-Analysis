-- =====================================================
-- PROJECT: Exploring Global Billionaire Wealth
-- AUTHOR: BRIAN LUGUNGA
-- DATABASE: Billionaire Portfolio
-- =====================================================


-- ANALYSIS 1: BILLIONAIRE WEALTH BY INDUSTRY
-- Business question:
-- Which industries hold the most wealth, and which have the most billionaires?

SELECT industries,
       COUNT(personName) AS billionaires_count,
       ROUND(SUM(finalWorth) / 1000, 1) AS total_wealth_billions,
       ROUND(AVG(finalWorth) / 1000, 2) AS average_wealth_billions
FROM billionaires_portfolio
GROUP BY industries
ORDER BY total_wealth_billions DESC;


-- =====================================================


-- ANALYSIS 2: SELF-MADE VS INHERITED BILLIONAIRES
-- Business question:
-- Are self-made billionaires richer than those who inherited?

SELECT CASE WHEN Selfmade = 'TRUE' THEN 'SelfMade' ELSE 'Inherited' END AS wealth_origin,
            COUNT(personName) AS billionaires_count,
            ROUND(AVG(finalWorth) /1000,2) AS average_wealth_billions,
		    ROUND(AVG(Age),1) AS average_age
FROM billionaires_portfolio
GROUP BY SelfMade
ORDER BY average_wealth_billions DESC;


-- =====================================================


-- ANALYSIS 3: BILLIONAIRES BY AGE GROUP
-- Business question:
-- How are billionaires spread across age groups?

SELECT COUNT(*) AS no_of_billionaires,
ROUND (AVG(finalWorth)/1000,2) AS average_wealth,
		CASE WHEN Age < 50 THEN 'under 50'
             WHEN Age < 60 THEN '50-59'
             WHEN Age < 70 THEN '60-69'
             WHEN Age < 80 THEN '70-79'
             ELSE '80+' END as Age_band
FROM billionaires_portfolio
GROUP BY Age_band
ORDER BY MIN(age);


-- =====================================================


-- ANALYSIS 4: BILLIONAIRES PER MILLION PEOPLE
-- Business question:
-- Which countries have the most billionaires per million people?

SELECT country, COUNT(*) AS billionaires,
       MAX(population_country) AS population,
       ROUND(COUNT(*) *1000000.0 / MAX(population_country),2) AS per_million
FROM billionaires_portfolio
GROUP BY country
ORDER BY per_million DESC;


-- =====================================================


-- ANALYSIS 5: WOMEN BILLIONAIRES BY INDUSTRY
-- Business question:
-- How large is the share of women among billionaires in each industry?

SELECT industries,
                 COUNT(*) AS billionaires,
                 SUM(CASE WHEN gender= 'Female' THEN 1 ELSE 0 END) AS women,
                 ROUND(100.0 *SUM(CASE WHEN gender='Female'THEN 1 ELSE 0 END)/COUNT(*),1) AS women_percentage
FROM billionaires_portfolio
GROUP BY industries
ORDER BY women_percentage DESC;


-- =====================================================


-- ANALYSIS 6: AVERAGE BILLIONAIRE WEALTH BY INDUSTRY
-- Business question:
-- Among industries with at least 10 billionaires, which have the
-- highest average billionaire wealth, and how do their billionaire
-- counts and total wealth compare?

SELECT industries,
       number_of_billionaires,
       total_industry_wealth,
       average_billionaire_wealth
FROM   (SELECT industries,
           COUNT(*) AS number_of_billionaires,
			(SELECT ROUND(AVG(finalWorth) / 1000, 1)
               FROM billionaires_portfolio AS B
               WHERE Q.industries = B.industries) AS average_billionaire_wealth,
           ROUND(SUM(finalWorth) / 1000, 1) AS total_industry_wealth
    FROM billionaires_portfolio AS Q
    GROUP BY industries
) AS industries_total
WHERE number_of_billionaires >= 10
ORDER BY average_billionaire_wealth DESC;


-- =====================================================


-- ANALYSIS 7: RANKED BILLIONAIRES ABOVE INDUSTRY AVERAGE
-- Business question:
-- Who are the 3 wealthiest billionaires in each industry whose
-- individual wealth exceeds the average wealth of billionaires
-- in that industry?

SELECT personName,industries,
       ROUND(finalWorth/1000,2) AS billionaire_wealth,
       ROUND(average_industry_wealth,2) AS average_industry_wealth,industry_rank
FROM (SELECT personName,industries,finalWorth,
           (SELECT AVG(finalWorth)/1000
            FROM billionaires_portfolio AS B
            WHERE Q.industries = B.industries) AS average_industry_wealth,
           RANK() OVER (PARTITION BY industries
               ORDER BY finalWorth DESC) AS industry_rank
    FROM billionaires_portfolio AS Q) AS ranked_billionaires
WHERE industry_rank <= 3
AND finalWorth/1000 > average_industry_wealth;


-- =====================================================



