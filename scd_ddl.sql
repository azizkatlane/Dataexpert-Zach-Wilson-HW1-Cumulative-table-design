create TABLE actors_scd(
    actor text,
    actorid text,
    quality_class quality,
    current_year int,
    start_date integer,
	end_date integer,
    is_active boolean,
    primary key (actorid, start_date)
)