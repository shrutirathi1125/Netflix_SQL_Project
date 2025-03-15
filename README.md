# Netflix Content Analysis using SQL

![Netflix_Logo](logo.png)

## Overview

This project contains SQL scripts for analyzing a Netflix dataset. The dataset includes information about movies and TV shows, such as their title, director, cast, country, release year, rating, and more. The SQL script provides insights into the data through various queries.

## Objective

The objective of this project is to analyze the Netflix dataset using SQL queries. The script helps in understanding content distribution, trends, and key insights such as the number of movies vs. TV shows, common ratings, and content production by country. It provides a foundation for further data exploration and visualization.

## Dataset

The data for this project is sourced from the Kaggle dataset:

-**Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema 

```sql
CREATE TABLE netflix(
	show_id	VARCHAR(6),
	type VARCHAR(10),	
	title VARCHAR(150),
	director VARCHAR(210),
	casts VARCHAR(800),
	country	VARCHAR(125),
	date_added VARCHAR(50),	
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(11),
	listed_in VARCHAR(80),
	description VARCHAR(250)
);
```
```sql
SELECT * FROM netflix;
SELECT COUNT(*) AS total_content FROM netflix;
SELECT DISTINCT type FROM netflix;
```

**Objective:**  Fetch all available data from the Netflix dataset. Determine the total number of movies and TV shows in the dataset. Identify the different types of content available on Netflix.

## Business Problems And Solutions 


### Q.1) Count the Number of Movies vs TV Shows


```sql
SELECT 
  type, 
  COUNT(show_id) As Total_content 
from netflix
group by type;
```
**Objective:** Compare the distribution of movies and TV shows.

### Q.2) Find the Most Common Rating for Movies and TV Shows


```sql
select type, rating from
(select 
	 type, 
	 rating, 
	 count(show_id),
	 RANK() OVER(PARTITION BY type ORDER BY COUNT(show_id) desc) as ranking 
from netflix 
group by type, rating
) AS T1
where ranking = 1;
```

**Objective:**  Identify the most frequently assigned content rating.

### Q.3) List all movies released in a specific year(e.g., 2020)


```sql
SELECT * FROM netflix;

SELECT * FROM netflix
WHERE type = 'Movie' AND release_year = 2020;
```

**Objective:** Retrieve all movies from a given release year. 

### Q.4) Find the top 5 Countries with the most content on Netflix


```sql
SELECT 
	unnest(string_to_array(country, ', ')) as new_country,
	count(show_id) AS Total_content 
from netflix
group by new_country
order by count(show_id) desc
limit 5;
```

**Objective:** Determine which countries contribute the most content to Netflix.


-- 5. Identify the longest movie


```sql
with cte as 
(
select 
	title,
	cast(split_part(duration, ' ', 1) as INT) as Duration
from netflix
where type = 'Movie'
)
select 
	title, 
	Duration
from cte 
where Duration = (select max(Duration) from cte);
```

**Objective:** Identify the Movies with the longest duration.


### Q.6) Find content added in the last 5 years 


```sql
SELECT *, TO_DATE(date_added, 'Month DD, YYYY') FROM netflix 
where TO_DATE(date_added, 'Month DD, YYYY') >= current_date - interval '5 years';
```

**Objective:** Find the most recently added Movies and TV shows.


### Q.7) Find all the movies/TV shows by director 'Rajiv Chilaka'


```sql
SELECT * FROM netflix 
WHERE director ILIKE '%Rajiv Chilaka%';
```

**Objective:** Extract all content directed by specific director (e.g., Rajiv Chilaka).


### Q.8) List all TV Shows with more than 5 seasons 


```sql
SELECT * FROM netflix
WHERE type = 'TV Show' AND 
SPLIT_PART(duration, ' ', 1)::numeric > 5; 
```

**Objective:**  Find the longest-running TV shows on Netflix.


### Q.9) Count the number of content items in each genre 


```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ', ')) as genre,
	COUNT(show_id) AS number_of_content
FROM netflix 
GROUP BY genre;
```

**Objective:** Identify the most frequent genre in Netflix's library.


### Q.10) Find each year and the average numbers of content release by India on netflix,      return top 5 year with highest avg content release.
   

```sql
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
	COUNT(*) AS yearly_content,
	ROUND(
		COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country ILIKE '%India%')::numeric * 100, 2) as avg_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
order by 3 desc
limit 5;
```

**Objective:** Analyze content addition trends over time.


### Q.11) List all movies that are documentaries 


```sql
SELECT * FROM netflix 
WHERE 
	listed_in ILIKE '%Documentaries%' 
	AND
	type = 'Movie';
```

**Objective:** Retrive all Movies with specific genre (e.g., Documentaries).


### Q.12) Find all content without a director 


```sql
SELECT * FROM netflix 
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.


### Q.13) Find how many movies actor 'Salman Khan' appeared in last 10 years


```sql
SELECT 	* FROM netflix
WHERE 
	type = 'Movie' 
	AND
	casts ILIKE '%Salman Khan%'
	AND 
	release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring specific actor in the last 10 years (e.g., Salman Khan).


### Q.14) Find the Top 10 Actors who have appeared in the highest number of movies produced in India.


```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ', ')) AS actors,
	COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%' AND type = 'Movie'
GROUP BY 1
ORDER BY 2 desc
LIMIT 10;
```

**Objective:** Identify actors featured in multiple Movies.


### Q.15) Categorize the content based on the presence of the keywords 'kill', and 'violence'  in the description field. Label content containing these keywords as 'Bad' and all othercontent as 'Good'. Count how many items fall into each category.


```sql
WITH cte AS 
(
SELECT *, 
CASE 
	WHEN description ILIKE '%kill%'
	OR description ILIKE '%violence%' THEN 'Bad'
	ELSE 'Good'
END AS category 
FROM netflix
)
SELECT 
	category,
	COUNT(*)
FROM cte
GROUP BY category;
```

**Objective:** Categorize content if it contains specified words in the description and count the number of items in each category.


## Insights

- Netflix's content library is dominated by movies, suggesting a preference for shorter-form content over multi-season TV shows.

- The majority of Netflix content is rated TV-MA, indicating a focus on mature audiences.

- Content production has increased significantly in recent years, reflecting Netflix's expansion and investment in original programming.

- The U.S., India, and other major film industries contribute the most to Netflix's content library.

- Certain genres, such as drama and comedy, are more prevalent, reflecting audience preferences and market demand.


## Conclusion

This project provides a structured approach to analyzing Netflix content using SQL. The findings highlight content trends, production patterns, and audience preferences. The insights gained can help understand Netflix's content strategy and its adaptation to viewer demands.
