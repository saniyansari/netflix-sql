# Netflix Movies and TV Shows Data Analysis using SQL

![netflix_card](https://github.com/user-attachments/assets/6bec4c18-4df2-4550-afc6-ca724864f1bc)


## Overview
This report presents an exploratory data analysis on Netflix titles using SQL, with a focus on business intelligence applications in the UAE's digital media industry. The project leverages SQL queries to derive meaningful insights for content strategy, genre trends, and regional preferences in streaming platforms.

## Why It Matters in the UAE
The UAE, with its high digital penetration, young population, and diverse expatriate community, is a key growth market for video-on-demand platforms. This project provides insight into international content trends that can inform local OTT players on what to acquire, produce, or promote. The analytical methods here align with skills sought by media-tech firms in Dubai, Abu Dhabi, and broader MENA.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Technical Stack & Skills Demonstrated
- PostgreSQL - For advanced querying and data aggregation
- Window Functions - ROW_NUMBER, RANK, LAG OVER for trend analysis
- Text Functions - unnest, string_to_array for parsing lists
- Date Handling - For time-based trend detection and filtering
- Data Cleaning - Filtering nulls, regex handling in season and duration fields

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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
```

## Business Problems and Solutions

### 1. Finding the number of Tv Shows and Movies

```sql
SELECT type, count(type) from NETFLIX group by type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the most common genres on Netflix

```sql
SELECT unnest(string_to_array(listed_in,', ')), count(show_id) as new_genre
from NETFLIX 
group by listed_in 
order by new_genre desc limit 10;
```


### 3. Top 5 countries producing Netflix content

```sql
select unnest(STRING_TO_ARRAY(country,', ')) as new_country, count(*) 
from
	NETFLIX
group by
	new_country
order by
	count desc limit 5;
```

**Objective:** Finding what countries produce the most content.

### 4. Finding the top 5 actors featured on Netflix

```sql
select 
	unnest(string_to_array(casts,', ')) as new_cast, count(show_id)
from NETFLIX
group by 1
order by 2 desc limit 5;
```

**Objective:** Identify the top 5 actors with the highest number of content items.

### 5. Finding the most common ratings on Netflix

```sql
select rating, count(show_id) as count_r 
from NETFLIX
group by rating
order by count_r desc limit 10;
```

**Objective:** Find the top ratings on the platform.

### 6. Finding content released in 2021

```sql
select * from NETFLIX where type ='TV Show' AND release_year=2021;
```

**Objective:** Retrieve content added to Netflix in the year 2021.

### 7. Finding the most-bingeworthy series

```sql
select * from NETFLIX 
	where type ='TV Show'
	and
	duration > '2 Seasons';
```

**Objective:** Listing all Tv Shows with multiple seasons.

### 8. Finding content released in last 5 years

```sql
select *, TO_DATE(date_added ,'Month DD, YYYY') from NETFLIX 
	where TO_DATE(date_added ,'Month DD, YYYY') >= (current_date - interval '5 years');
```

**Objective:** Identify content released in last 5 years.

### 9. Finding all works by the director 'Steven Spielberg'

```sql
select * from NETFLIX 
 where director like '%Steven Spielberg%'
```

**Objective:** List all works by Steven Spielberg.

### 10.Find each year and the average release date by country. 

```sql
select unnest(string_to_array(country,', ')) as country, avg(release_year) 
from NETFLIX 
	group by 1
	order by 2 desc;
```

**Objective:** Calculate average the release date per country.

### 11. List the longest movie

```sql
select *
from
	NETFLIX
where
	type='Movie'
and
	split_part(duration, ' ',1)=(select max(split_part(duration, ' ',1)) from NETFLIX)
```

**Objective:** Find the longest movies.

### 12. Find the average content per year released by USA, get the top 5 years

```sql
select
extract (year from to_date(date_added,'Month DD, YYYY'))  as year, count(*), count(*)::numeric/(select count(*) from NETFLIX 
		where country like '%United States%' )::numeric*100 as avg_release
from
	NETFLIX
where
	country like '%United States%'
group by 1
order by 2 desc limit 5;
```

**Objective:** Find the top 5 years with most content in USA. 

### 13. List all movies that are documentaries

```sql
select * 
from
	NETFLIX
where 
	type='Movie'
and
	listed_in ilike '%docu%';
```

**Objective:** List all movies that are Documentaries.

### 14. Find all movies with the actor Liam Hemsworth

```sql
select show_id, title, director,casts 
from NETFLIX
where casts like '%Liam Hemsworth%';
```

**Objective:** Find all movies featuring actor Liam Hemsworth.


### 15. Categorise the data based on description into 'Suitable for kids' , 'Mature Content' and 'Not suitable for kids'. Filter descriptions based on presence of words like kill, violence and murder and rating based on official ratings. Find the count of each respective group.

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

### 16. Find country wise distribution of movies and tv shows

```sql
select unnest(string_to_array(country, ', ')) as country_, count(*) as total_count,
sum(case when type='Movie' then 1 else 0 END) as movie_counts,
sum(case when type='TV Show' then 1 else 0 END) as tv_show_counts
from netflix
group by country_
order by total_count desc;
```

**Objective:** Find the number of TV Shows and Movies per country

### 17. Most Popular Content Durations(Movies)

```sql
select split_part(duration, ' ',1) as durations, count(*)
from
NETFLIX
where 
type='Movie'
group by 1
order by count desc limit 5;
```

**Objective:** Find the most common length for movies.

### 18. Most Popular Content Durations(Tv Shows)

```sql
select split_part(duration, ' ',1) as durations, count(*)
from
NETFLIX
where 
type='TV Show'
group by 1
order by count desc limit 5;
```

**Objective:** Find the most common length for Tv Shows.

### 19. What is the latest content added per country?

```sql
with rank_t as(
select 
	title, UNNEST(string_to_array(country,', ')) as country_2, TO_DATE(date_added ,'Month DD, YYYY') as date_new, 
		rank() over(partition by UNNEST(string_to_array(country,', ')) order by TO_DATE(date_added ,'Month DD, YYYY') desc) 
as rank_m from NETFLIX
WHERE
	country is not null
) select * from rank_t where rank_m=1;
```

**Objective:** Find the latest content additions across countries.

### 20. Rank directors by filmography

```sql
select unnest(string_to_array(director, ', ')) as director_new,
count(*) as titles_count,
dense_rank() over (order by count(*) desc) 
from netflix group by director_new;
```

**Objective:** Rank the directors by their works.

### 21. Genres with the most consistent growth over years

```sql
with genre_c as(
select unnest(string_to_array(listed_in, ', ')) as genre, release_year, count(*) as genre_count
from netflix group by 1,2 order by 2),

genre_lag as(
select genre, release_year, genre_count, lag(genre_count) over(partition by genre order by release_year) as prev_count
from genre_c group by 1,2,3 
)

select genre, release_year, genre_count, prev_count, (genre_count-prev_count)::numeric 
as change from genre_lag where (genre_count-prev_count)::numeric  > 0 group by 1,2,3,4;
```

**Objective:** Find the genres that consistently have new content per year.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

## Conclusion
This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
This project illustrates how SQL can uncover strategic business insights in media analytics. 
With the rise of streaming platforms in the UAE, such data-driven storytelling is essential for localized content curation, investment strategies, and product development. 
Future scope includes integrating user viewing behavior for personalized recommendations and revenue forecasting.

### Let's Connect!

- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/saniya-ansari-analyst)
- **Medium**: [View my articles](https://medium.com/@saniya.zubair.ansari)
  
Thank you for your support, and I look forward to connecting with you!
