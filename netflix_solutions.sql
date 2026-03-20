-- netflix project

CREATE TABLE NETFLIX
(
 	show_id	varchar(6),
	type	varchar(10),
	title	varchar(150),	
	director	varchar(208),	
	casts	varchar(1000),
	country	varchar(150),
	date_added	varchar(50),  	
	release_year	int,
	rating	varchar(10),
	duration	varchar(10),
	listed_in	varchar(100),	
	description	varchar(300)
);
-- reviewing dateset.
select * from netflix;

-- checking the type of contents we have.
select Distinct type from netflix;

-- counting the number of movies vs tv show.
select type,count(*) as Number_of_contents
from netflix
group by type;

--most common rating for movies and tv shows.
select type,rating
from(
	select type,rating,count(*),rank() over(partition by type order by count(*) desc) as ranking 
	from netflix 
	group by type,rating
	) as t
where ranking = 1

--listing movies that are releaased in a specific year (e.g 2019)
select * from netflix
where 
	type = 'Movie'
	and 
	release_year = 2019

--finding the top 10 countries with the most content on netflix.
select 
	unnest(STRING_TO_ARRAY(country,',')) as new_country,
	count(show_id) as total_content_by_country
from netflix
group by 1
order by 2 desc
limit 10;

--Identify the longest movie.
select * from netflix
where 
	type = 'Movie'
	and
	duration = (select max(duration) from netflix) 

--finding content added in the last 6 years
select * from netflix
where 
	to_date(date_added, 'month dd,year') >= current_date - INTERVAL '6 years'

--find all the Movies/tv shows by director Rajiv Chilaka.
select * from netflix
where director like '%Rajiv Chilaka%'

-- Listing all tv shows which have more than 5 seasons.
select * from netflix
where 
	type = 'TV Show'
	and
	split_part(duration,' ',1):: numeric>5

--counting the number of content items in each genre.
--finding the top 10 genres with the most contents.
select unnest(string_to_array(listed_in,',')) as different_genre,
	count(show_id) as total_contents
from netflix	
group by 1
order by 2 desc
limit 10;

--find each year and the percentage of content released in india on netflix.
--return top 6 years with highest percent content release. 
select extract(year from to_date(date_added,'month dd,yyyy')) as year,
	count(*) as number_of_contents,
	round(count(*)::numeric/(select count(*) from netflix where country like '%India%')::numeric *100,3) as percentage
from netflix
where country like '%India%'
group by 1
order by 3 desc
limit 6;

--list all that are Docuseries.
select * from netflix
where listed_in like '%Docuseries%'

--finding all content with no director
select * from netflix
where director is null

--finding in how many movies actor 'Anupam Kher' appeared in last 15 years.
select * from netflix
where casts Ilike '%Anupam Kher%'
	and release_year >= extract(year from current_date) - 15

--top 10 actors who have appeared in highest number of movies produced in 'India'
select 
	unnest(string_to_array(casts,',')) as actors,
	count(*) as movies_casted
from netflix
where country ilike '%India%'
group by 1
order by 2 desc
limit 10;

-- categorizing the content based on the presence of the words 'kills' and 'violence' in the description field.
-- split them into 'bad' and 'good' category,also count how many fall under each category.
with temp as
(
select *,
	CASE
		when description ilike '%kill%' or description ilike '%violence%' then 'bad_content'
		else 'good_content'
	end category
from netflix
)
select category,count(*) as total_counts
from temp
group by 1;
	