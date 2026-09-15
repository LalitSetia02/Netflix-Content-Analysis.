use netflix;
select * from netflix;
-- Q1. Count the number of Movies vs TV Shows
select type,count(*) as number_of from netflix
group by type;

-- Q2. Find the most common rating for movies and TV shows
WITH RatingCounts AS (
    SELECT type,rating,COUNT(*) AS total_count
    FROM netflix 
    GROUP BY type, rating
),
RankedRatings AS (
	SELECT type,rating,total_count,
	RANK() OVER(PARTITION BY type ORDER BY total_count DESC) as rnk
    FROM RatingCounts
)
SELECT type,rating,total_count
FROM RankedRatings
WHERE rnk = 1;

-- Q3. List all movies released in a specific year (e.g., 2020)
select title,release_year from netflix 
where release_year=2020;

-- Q4. Find the top 5 countries with the most content on Netflix
SELECT country,COUNT(show_id) AS total_uploaded
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_uploaded DESC
LIMIT 5;

-- Q5. Identify the longest movie
SELECT title,
       cast(substring_index(duration, ' ', 1) AS unsigned) AS duration_minutes
from netflix
where type = 'movie'
order by duration_minutes desc limit 1;

-- Q6. Find content added in the last 5 years
select title,release_year from netflix
WHERE release_year between (SELECT MAX(release_year) - 4 FROM netflix) 
                       AND (SELECT MAX(release_year) FROM netflix)
order by release_year desc;

-- Q7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select type,title,director from netflix
where director="Rajiv Chilaka";

-- Q8. List all TV shows with more than 5 seasons
select type, title, duration from netflix
where type = 'TV Show' and duration > 5;

-- Q9. Count the number of content items in each genre
SELECT listed_in AS genre,COUNT(show_id) AS total_content
FROM netflix
GROUP BY listed_in
ORDER BY total_content DESC;

-- Q10.Find each year and the average numbers of content release in India on netflix.return top 5 year with highest avg content release!
SELECT release_year,AVG(show_id) AS avg_content_release
FROM netflix
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY avg_content_release DESC
LIMIT 5;

-- Q11. List all movies that are documentaries
select type,title,listed_in from netflix
where listed_in like "%documentaries%";

-- Q12. Find all content without a director
select type,title,director from netflix
where director is null;

-- Q13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select title,cast,release_year from netflix
where cast like '%Salman Khan%' and release_year between (select max(release_year) - 9 from netflix) 
                       and (select max(release_year) from netflix)
order by release_year desc;

-- Q14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
WITH RECURSIVE actor_split AS (
    SELECT show_id,
        TRIM(SUBSTRING_INDEX(cast, ',', 1)) AS actor,
        SUBSTRING(cast,
                  LENGTH(SUBSTRING_INDEX(cast, ',', 1)) + 2) AS remaining
    FROM netflix
    WHERE type = 'Movie'
      AND country LIKE '%India%'
      AND cast IS NOT NULL

    UNION ALL

    SELECT
        show_id,
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)),
        SUBSTRING(remaining,
                  LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM actor_split
    WHERE remaining <> ''
)

SELECT
    actor,
    COUNT(*) AS movie_count
FROM actor_split
WHERE actor <> ''
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;
   
/*
Q15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
SELECT 
    CASE
        WHEN description LIKE '%kill%' 
          OR description LIKE '%violence%'
        THEN 'Bad'
        ELSE 'Good'
    END AS category, 
    COUNT(*) AS total_content FROM netflix
GROUP BY category;
