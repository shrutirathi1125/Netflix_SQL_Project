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
SELECT * FROM netflix;
SELECT COUNT(*) AS total_content FROM netflix;
SELECT DISTINCT type FROM netflix;


-- 1. Count the Number of Movies vs TV Shows
SELECT type, COUNT(show_id) As Total_content 
from netflix
group by type;


-- 2. Find the Most Common Rating for Movies and TV Shows
select * from netflix;

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


-- 3. List all movies released in a specific year(e.g., 2020)

SELECT * FROM netflix;

SELECT * FROM netflix
WHERE type = 'Movie' AND release_year = 2020;


-- 4. Find the top 5 Countries with the most content on Netflix

SELECT * FROM netflix;

SELECT 
	unnest(string_to_array(country, ', ')) as new_country,
	count(show_id) AS Total_content 
from netflix
group by new_country
order by count(show_id) desc
limit 5;


-- 5. Identify the longest movie

select * from netflix;


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


-- 6. Find content added in the last 5 years 

SELECT * FROM netflix;

select current_date - interval '5 years';

SELECT *, TO_DATE(date_added, 'Month DD, YYYY') FROM netflix 
where TO_DATE(date_added, 'Month DD, YYYY') >= current_date - interval '5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT * FROM netflix 
WHERE director ILIKE '%Rajiv Chilaka%';


-- 8. List all TV Shows with more than 5 seasons 

SELECT * FROM netflix
WHERE type = 'TV Show' AND 
SPLIT_PART(duration, ' ', 1)::numeric > 5; 


-- 9. Count the number of content items in each genre 

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ', ')) as genre,
	COUNT(show_id) AS number_of_content
FROM netflix 
GROUP BY genre;


-- 10. Find each year and the average numbers of content release by India on netflix, 
--     return top 5 year with highest avg content release.
   

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



-- 11. List all movies that are documentries 


SELECT * FROM netflix;

SELECT * FROM netflix 
WHERE 
	listed_in ILIKE '%Documentaries%' 
	AND
	type = 'Movie';


-- 12. Find all content without a director 

SELECT * FROM netflix 
WHERE director IS NULL;



-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years

SELECT 
	*
FROM netflix
WHERE 
	type = 'Movie' 
	AND
	casts ILIKE '%Salman Khan%'
	AND 
	release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the Top 10 Actors who have appeared in the highest number of movies produced in India.
	
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ', ')) AS actors,
	COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%' AND type = 'Movie'
GROUP BY 1
ORDER BY 2 desc
LIMIT 10; 


-- 15. Categorize the content based on the presence of the keywords 'kill', and 'violence' in
--     the description field. Label content containing these keywords as 'Bad' and all other
--     content as 'Good'. Count how many items fall into each category.


SELECT * FROM netflix;

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