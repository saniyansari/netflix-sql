-- CREATING A NEW TABLE

DROP TABLE IF EXISTS NETFLIX;

CREATE TABLE NETFLIX(
	show_id VARCHAR(20),
	type VARCHAR(20),
	title VARCHAR(200),
	director VARCHAR (400),	
	casts VARCHAR(800),
	country	VARCHAR(200),
	date_added	VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),	
	duration VARCHAR(50),
	listed_in VARCHAR(150),
	description VARCHAR(300)
	);

SELECT * FROM NETFLIX;

--15 Business Questions

1. Finding the number of Tv Shows and Movies

SELECT type, count(type) from NETFLIX group by type;

2. Most Common Genres on Netflix

SELECT unnest(string_to_array(listed_in,', ')), count(show_id) as new_genre
from NETFLIX 
group by listed_in 
order by new_genre desc limit 10;

3. Top 5 Countries Producing Netflix Content

select unnest(STRING_TO_ARRAY(country,', ')) as new_country, count(*) 
from
	NETFLIX
group by
	new_country
order by
	count desc limit 5;


4. Top 5 Actors Featured in Netflix Content

select 
	unnest(string_to_array(casts,', ')) as new_cast, count(show_id)
from NETFLIX
group by 1
order by 2 desc limit 5;


5. Most Common Ratings in Netflix Content

select rating, count(show_id) as count_r 
from NETFLIX
group by rating
order by count_r desc limit 10;


6. TV shows released in the year 2021

select * from NETFLIX where type ='TV Show' AND release_year=2021;

7. Find the most bingeworthy series

select * from NETFLIX 
	where type ='TV Show'
	and
	duration > '2 Seasons';

8. Find the content added in the last 5 years

select *, TO_DATE(date_added ,'Month DD, YYYY') from NETFLIX 
	where TO_DATE(date_added ,'Month DD, YYYY') >= (current_date - interval '5 years');

9. Find all works by Director Steven Spielberg

select * from NETFLIX 
 where director like '%Steven Spielberg%'

10. Find the average release date by country

select unnest(string_to_array(country,', ')) as country, avg(release_year) 
from NETFLIX 
	group by 1
	order by 2 desc;

11. Find the longest series

--select max(split_part(duration, ' ',1)) from NETFLIX;

select *
from
	NETFLIX
where
	type='Movie'
and
	split_part(duration, ' ',1)=(select max(split_part(duration, ' ',1)) from NETFLIX)

12. Find the average content per year released by USA, get the top 5 years

select
extract (year from to_date(date_added,'Month DD, YYYY'))  as year, count(*), count(*)::numeric/(select count(*) from NETFLIX 
		where country like '%United States%' )::numeric*100 as avg_release
from
	NETFLIX
where
	country like '%United States%'
group by 1
order by 2 desc limit 5;

13. List all the movies that are documentaries

select * 
from
	NETFLIX
where 
	type='Movie'
and
	listed_in ilike '%docu%';

14. Find the movies that had actor 'Liam Hemsworth'

select show_id, title, director,casts 
from NETFLIX
where casts like '%Liam Hemsworth%';

15. Categorise the data based on description into 'Suitable for kids' , 'Mature Content' and 'Not suitable for kids'. 
Filter descriptions based on presence of words like kill, violence and murder and rating based on official ratings. Find the count of each respective group.

with new_table as
(
select *,
CASE
	when description ilike 'kill%' or 
	description ilike '%murder%' or
	description ilike '%violen%'or
	description ilike '%crime%' or listed_in ilike '%docu%' or
	description ilike '%drug%' 
	or description ilike '%dead%' or description ilike '%death%'  then 'Not Suitable for Kids'
	when rating ='R' or rating like '%MA' then 'Mature Content'
	else 'Suitable for Kids'
	END category 
from NETFLIX
) select category, count(*) from new_table group by 1;


16. Find country wise distribution of movies and tv shows

select unnest(string_to_array(country, ', ')) as country_, count(*) as total_count,
sum(case when type='Movie' then 1 else 0 END) as movie_counts,
sum(case when type='TV Show' then 1 else 0 END) as tv_show_counts
from netflix
group by country_
order by total_count desc;


17. Most Popular Content Durations(Movies)

select split_part(duration, ' ',1) as durations, count(*)
from
NETFLIX
where 
type='Movie'
group by 1
order by count desc limit 5;

18. Most Popular Content Durations(TV Shows)

select split_part(duration, ' ',1) as durations, count(*)
from
NETFLIX
where 
type='TV Show'
group by 1
order by count desc limit 5;

19. What is the latest content added per country?

with rank_t as(
select 
	title, UNNEST(string_to_array(country,', ')) as country_2, TO_DATE(date_added ,'Month DD, YYYY') as date_new, 
		rank() over(partition by UNNEST(string_to_array(country,', ')) order by TO_DATE(date_added ,'Month DD, YYYY') desc) 
as rank_m from NETFLIX
WHERE
	country is not null
) select * from rank_t where rank_m=1;


20. Rank directors by filmography

select unnest(string_to_array(director, ', ')) as director_new,
count(*) as titles_count,
dense_rank() over (order by count(*) desc) 
from netflix group by director_new;


21. Which genres have seen the most consistent growth over the years?

with genre_c as(
select unnest(string_to_array(listed_in, ', ')) as genre, release_year, count(*) as genre_count
from netflix group by 1,2 order by 2),

genre_lag as(
select genre, release_year, genre_count, lag(genre_count) over(partition by genre order by release_year) as prev_count
from genre_c group by 1,2,3 
)

select genre, release_year, genre_count, prev_count, (genre_count-prev_count)::numeric 
as change from genre_lag group by 1,2,3,4;


	