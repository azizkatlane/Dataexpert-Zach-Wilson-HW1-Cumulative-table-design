

create table actors(
    actor text,
    actor_id text,
    films films_stats[],
    quality_class quality,
    current_year int,
    year_since_last_film int,
    is_active boolean
);