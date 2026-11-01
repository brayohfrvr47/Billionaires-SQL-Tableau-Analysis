# Forbes Billionaires Analysis (SQL + Tableau)

## Goal
I analyzed a billionaires dataset in MySQL to answer business questions about
wealth, industry, age, gender and country, then visualized the results in
Tableau Public.

## Tools
MySQL (Workbench), Excel, Tableau Public.

All dashboards are on my [Tableau Public profile](https://public.tableau.com/app/profile/brian.lugunga).

Full queries: [Billionaire_Wealth_Analysis.sql](Billionaire_Wealth_Analysis.sql)

## Dataset
- Source: [billionaires dataset](https://www.kaggle.com/datasets/ahmedmohamedibrahim1/billionaires-dataset)
- Original file: `billionaires_dataset.csv`
- Working table in MySQL: `billionaires_portfolio`
- 475 rows, 19 columns, no duplicate rows or blank values

## Data notes
- `finalWorth` is in millions of USD, so I converted to billions where needed
  to make results easier to read.
- `category` and `industries` contain identical values, so I used `industries`.
- `selfMade` is stored as TRUE/FALSE (FALSE = inherited).
- About 80 entries are family fortunes (e.g. "X & family"), so counts mean
  entries on the list, not strictly individuals.
- Country-level columns (population, GDP, tax rate, etc.) repeat on every row,
  so I grouped by country first to avoid counting them multiple times.
- The source CSV is Latin-1 encoded; I checked that accented names (e.g. François,
  Saadé) imported correctly.
- Minor spelling inconsistency in source like "Francoise" vs "François" (I haven't corrected it,
  doesn't affect the analysis).

  ## Questions, queries and findings

### 1. Which industries hold the most wealth, and which have the most billionaires?

```sql
-- SELECT industries,COUNT(personName) AS billionaires_count, 
ROUND(SUM(finalWorth) /1000,1) AS total_wealth_billions,
ROUND(AVG(finalWorth) /1000,2) AS average_wealth_billions
FROM billionaires_portfolio
GROUP BY industries
ORDER BY total_wealth_billions DESC;
```

**Finding:** Technology holds the most total wealth (about $1.3 trillion), but
Finance & Investments has the most billionaires (77 vs 62). Fashion & Retail is a
close second in wealth with fewer people, so its billionaires are individually richer.

[View chart](https://public.tableau.com/views/BillionaireWealthbyIndustry/Sheet1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

### 2. Are self-made billionaires richer than those who inherited?

```sql
-- SELECT CASE WHEN Selfmade = 'TRUE' THEN 'SelfMade' ELSE 'Inherited' END AS wealth_origin,
COUNT(personName) AS billionaires_count,
ROUND(AVG(finalWorth) /1000,2) AS average_wealth_billions,
ROUND(AVG(Age),1) AS average_age
FROM billionaires_portfolio
GROUP BY SelfMade
ORDER BY average_wealth_billions DESC;
```

**Finding:** Average net worth is almost identical, about $14.8 billion for both
groups. There are nearly twice as many self-made billionaires (309) as inherited
(166), and inherited billionaires are slightly older on average. 

[View chart](https://public.tableau.com/views/Self-madevsInheritedBillionaires/Sheet1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

### 3. How are billionaires spread across age groups?

```sql
-- SELECT COUNT(*) AS no_of_billionaires,
ROUND (AVG(finalWorth)/1000,2) AS average_wealth,
		CASE WHEN Age < 50 THEN 'under 50'
             WHEN Age < 60 THEN '50-59'
             WHEN Age < 70 THEN '60-69'
             WHEN Age < 80 THEN '70-79'
             ELSE '80+' END as Age_band
FROM billionaires_portfolio
GROUP BY Age_band
ORDER BY MIN(age);
```

**Finding:** The 80+ group is the largest (134 of 475), and only 28 billionaires are
under 50. Average net worth doesn't rise steadily with age: it dips in the 60-69 band
(about $13.0 billion) and is highest in the 70-79 and 80+ bands (about $15.7 billion).
The results show that the age group with the most billionaires does not necessarily have
the highest average wealth. These are descriptive comparisons, not evidence that age causes 
differences in wealth.

[View chart](https://public.tableau.com/views/BillionairesByAgeGroup/Sheet1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

### 4. Which countries have the most billionaires per million people?

```sql
-- SELECT country, COUNT(*) AS billionaires,
       MAX(population_country) AS population,
       ROUND(COUNT(*) *1000000.0 / MAX(population_country),2) AS per_million
FROM billionaires_portfolio
GROUP BY country
ORDER BY per_million DESC;
```

**Finding:** Small, wealthy countries lead once population is taken into account:
Switzerland has about 2.1 billionaires per million people, ahead of Singapore (1.23)
and Denmark (1.03). The US (0.58) and China, which top the raw counts, rank much lower.

[View dashboard](https://public.tableau.com/views/BillionairesPerMillionPeople/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

### 5. How large is the share of women among billionaires in each industry?

```sql
-- SELECT industries, COUNT(*) AS billionaires,
SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS women,
ROUND(100.0*SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END)/COUNT(*),1)AS female_percentage
FROM billionaires_portfolio
GROUP BY industries
ORDER BY female_percentage DESC;
```

**Finding:** Food & Beverage has the most women billionaires (12) and the highest share
among larger industries (27.9%). Finance & Investments (7.8%) and Technology (8.1%)
are under 9% women. Gambling & Casinos tops the list at 40%, but that is only 2 of 5.

[View chart](https://public.tableau.com/views/WomenBillionairesbyIndustry/Sheet1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

### 6. Among industries with at least 10 billionaires, which have the highest average billionaire wealth, and how do their billionaire counts and total wealth compare?

```sql
-- SELECT industries,
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
```

**Finding:** Automotive ranked the highest with an average of ($24.8B) per billionaire among industries with 
at least 10 billionaires, Fashion & Retail ranked second with an average of ($21.5B), Technology followed
closely ranking third with an average of ($21.0B).Technology's total billionaire wealth was approximately ($1,299.8 B), compared with $397.2 B in Automotive. This demonstrates that an industry's total wealth and its average wealth per billionaire measure different things, the results show that industries with the greatest combined wealth do not necessarily have the highest average wealth per billionaire.

[view chart](https://public.tableau.com/views/AverageBillionaireWealthByIndustryUSDBillions/Sheet1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

### 7. Who are the 3 wealthiest billionaires in each industry whose individual wealth exceeds the average wealth of billionaires in that industry?

```sql
-- SELECT personName,industries,
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
```

**Finding:** The analysis identifies the 3 highest-ranked billionaires in each industry whose individual net worth exceeds their respective industry average. It highlights individuals who stand out in terms of wealth within their industries, while also showing that global billionaire rankings do not necessarily translate into the same ranking across individual industries.

[view chart](https://public.tableau.com/views/RankedBillionairesAboveIndustryAverage/Sheet1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)


## Dashboard links
- [Billionaire Wealth by Industry](https://public.tableau.com/views/BillionaireWealthbyIndustry/Sheet1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
- [Self-made vs Inherited Billionaires](https://public.tableau.com/views/Self-madevsInheritedBillionaires/Sheet1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
- [Billionaires by Age Group](https://public.tableau.com/views/BillionairesByAgeGroup/Sheet1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
- [Billionaires per Million People](https://public.tableau.com/views/BillionairesPerMillionPeople/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
- [Women Billionaires by Industry](https://public.tableau.com/views/WomenBillionairesbyIndustry/Sheet1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
- [Average Billonaire Wealth by Industry](https://public.tableau.com/views/AverageBillionaireWealthByIndustryUSDBillions/Sheet1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
- [Ranked Billionaires Above Industry Average](https://public.tableau.com/views/RankedBillionairesAboveIndustryAverage/Sheet1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

All dashboards are on my [Tableau Public profile](https://public.tableau.com/app/profile/brian.lugunga).

  ## Limitations
- The industry with the highest average wealth is not necessarily the one with the
  highest total wealth or the most billionaires, so I report all three.
- About 80 entries are family fortunes, so counts refer to entries, not individuals.
- The analysis is descriptive. It shows patterns (for example between country and number
  of billionaires, or wealth origin and net worth), not causes. Each factor was
  analyzed separately, without controlling for the others.
- Averages hide variation between individuals, and they are rounded, so two averages
  that look equal (such as self-made and inherited) are not necessarily identical.
- Gender results describe representation among the billionaires in this dataset, not
  the wider workforce of an industry. Percentages from industries with very few
  billionaires should be read cautiously.
- The data is a snapshot in time and does not show how fortunes change.
- The findings reflect the billionaires and industry classifications represented in this dataset.
  They should not beinterpreted as a complete representation of all wealthy individuals or the entire business sector.
- Wealth values are displayed in billions and rounded, so small differences between industries may be less precise than      the displayed figures suggest.
- The analysis is limited to the top 3 ranked billionaires per industry, excluding other billionaires who may also           exceed their industry's average wealth.
- Industry averages can be influenced by exceptionally wealthy individuals, potentially making comparisons less              representative of the typical billionaire in an industry.
  

  ## What I learned
- How `CASE WHEN` works, including why the order of conditions matters: SQL stops
  at the first condition that is true.
- The difference between `WHERE` (filters rows before grouping) and `HAVING`
  (filters groups after).
- To check results against a known total or a manual calculation, which caught an
  off-by-one error (`>` vs `>=`) in one of my queries.
- Using ROUND ','*'/' to calculate percentages, round of decimals & multiply.
- Exporting query results as CSV files from SQL and building a dashboard from them.
- How `RANK` works i was able to use rank to get billionaires wealth in their respective
  industries and get the top 3 billionaires in every industry.

