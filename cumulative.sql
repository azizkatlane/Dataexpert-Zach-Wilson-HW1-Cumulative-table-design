
with last_year as(
	select * from actors
	where current_year=1969
),

this_year as (
	select
		actor,
		actorid,
		ARRAY_AGG(
        	ROW(film, rating, votes, filmid)::films_stats
    	) AS films,
		year,
		avg(rating) as avg_rating
	from actor_films
	where year = 1970
	group by actor,actorid,year
)

select
	coalesce(ty.actor,ly.actor) as actor,
	coalesce(ty.actorid,ly.actorid) as actorid,
	COALESCE(
		ty.films, ARRAY[]::films_stats[]
	) || 
	COALESCE(
		ly.films, ARRAY[]::films_stats[]
	) AS films,
	(case
		WHEN ty.avg_rating > 8 THEN 'star'
    	WHEN ty.avg_rating > 7 THEN 'good'
    	WHEN ty.avg_rating > 6 THEN 'average'
    	ELSE 'bad'
	end)::quality as quality_class,	
	coalesce(ty.year,ly.current_year+1) as current_year,
	case when ty.year is not null then 0
		else ly.year_since_last_film +1
	end as year_since_last_film,
	ty.year is not null as is_active
from last_year ly full outer join this_year ty using (actor)