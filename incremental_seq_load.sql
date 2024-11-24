with last_year_scd as (
	select
		*
	from actors_scd
	where current_year=2020
	and end_date=2020
),

historical as (
	select
		actor,
		actorid,
		quality_class,
		is_active,
		start_date,
		end_date
	from actors_scd
	where current_year=2020
	and end_date <2020
),

this_year_data as (
	select
		*
	from actors
	where current_year=2021
),

unchanged as (
	select 
		ty.actor,
		ty.actorid,
		ty.quality_class,
		ty.is_active,
		ly.start_date,
		ty.current_year as end_date
	from last_year_scd ly
	join this_year_data ty
	on ly.actorid=ty.actorid
	where ty.quality_class  = ly.quality_class
	and ty.is_active=ly.is_active
),

changed as (
	select
		ty.actor,
		ty.actorid,
		unnest(array[row(
			ly.quality_class,
			ly.is_active,
			ly.start_date,
			ly.end_date
		)::scd_type_actor,
		row(
			ty.quality_class,
			ty.is_active,
			ty.current_year,
			ty.current_year
		)::scd_type_actor]) as records 
	from last_year_scd ly
	join this_year_data ty
	on ly.actorid=ty.actorid
	where ty.quality_class  <> ly.quality_class
	and ty.is_active<>ly.is_active
),

unnested_changed as (
	select 
		actor,
		actorid,
		(records::scd_type_actor).quality_class,
		(records::scd_type_actor).is_active,
		(records::scd_type_actor).start_date,
		(records::scd_type_actor).end_date
	from changed
),

new_records as (
	select
		ty.actor,
		ty.actorid,
		ty.quality_class,
		ty.is_active,
		ty.current_year,
		ty.current_year
	from this_year_data ty
	left join last_year_scd ly
	on ty.actor = ly.actor
	where ly.actor is null
)

select * , 2021 as current_year from ( select * from historical

union all

select * from unchanged

union all 

select * from unnested_changed

union all

select * from new_records) a