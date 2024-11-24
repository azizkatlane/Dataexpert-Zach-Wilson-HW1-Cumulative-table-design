insert into actors_scd
with previous as (
	select 
		max(actor) as actor,
		actorid,
		films,
		current_year,
		lag(quality_class , 1) over(partition by actorid order by current_year) as previous_quality_class,
		quality_class,
		lag(is_active,1) over(partition by actorid order by current_year) as previous_is_active,
		is_active
	from actors
	group by actorid,current_year
),

indicator_change as (
	select 
		*,
		case 
			when quality_class <> previous_quality_class then 1 
			when is_active <> previous_is_active then 1 
			else 0
		end as change_indicator
	from previous

),

streaks as (
	select
		*,
		sum(change_indicator) over(partition by actorid order by current_year) as streak_identifier
	from indicator_change
),
aggregated as (
	select
		actor,
		actorid,
		quality_class,
		is_active,
		streak_identifier,
		min(current_year) as start_date,
		max(current_year) as end_date
	from streaks
	group by 1,2,3,4,5
	order by actor,start_date

)

select 
	actor,
	actorid,
	quality_class,
	start_date,
	end_date,
	is_active
from aggregated
