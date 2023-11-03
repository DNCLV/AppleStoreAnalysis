Create table appleStore_description_total as 

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4

**Exploratory Analysis**

--Checking if the data has the same amount of unique apps

SELECT COUNT(DISTINCT id) as UniqueAppIDs
from AppleStore

SELECT COUNT(DISTINCT id) as UniqueAppIDs
from appleStore_description_total

--Checking for missing values
SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS NULL OR user_rating IS NULL OR prime_genre IS NULL

SELECT COUNT(*) AS MissingValues
FROM appleStore_description_total
WHERE app_desc IS NULL

--Using count with a group by to list the number of apps per genre
SELECT prime_genre, COUNT(*) as NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps desc

--Overview of app ratings
SELECT min(user_rating) as MinRating,
	   max(user_rating) as MaxRating,
       avg(user_rating) as AvgRating
FROM AppleStore

** Data Analysis**

--Determine if paid apps have higher rating than free apps 
SELECT CASE
			WHEN price > 0 then 'Paid'
            ELSE 'Free'
       END AS App_type,
       avg(user_rating) as Avg_Rating
FROM AppleStore
GROUP BY App_type

--Check if apps with more supported languages have higher raing 
SELECT CASE 
 			WHEN lang_num < 10 THEN 'Under 10 languages'
            WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
            ELSE 'Over 30 languages'
       END AS language_bucket,
       avg(user_rating) as AVG_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY AVG_Rating desc

--CHECK genres with low rating 
SELECT prime_genre,
	   avg(user_rating) as Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating

-- Check for correlation between length of app description and user rating 
SELECT CASE
			WHEN length(b.app_desc) < 500 THEN 'short'
            WHEN length(b.app_desc) BETWEEN 500 and 1000 THEN 'Medium'
            ELSE 'Long'
        End AS description_length_bucket,
        avg(user_rating) as Avg_Rating

FROM 
	AppleStore AS a
Join
	appleStore_description_total as b 
ON
	a.id = b.id
Group BY description_length_bucket
ORDER BY Avg_Rating DESC

--Check toprated apps for each genre with a window function and CTE
WITH RankedApps AS (
    SELECT
        prime_genre,
        track_name,
        user_rating,
        RANK() OVER (PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS ranking
    FROM AppleStore
)
-- Selecting the top performing apps in each genre
SELECT
    prime_genre,
    track_name,
    user_rating
FROM RankedApps
WHERE ranking = 1;
