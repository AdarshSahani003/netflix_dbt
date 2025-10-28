WITH raw_genome_score AS (
    SELECT * FROM MOVIELENS.RAW.RAW_GENOME_SCORES
)
SELECT
    movieId AS movie_id,
    relevance,
    tagId AS tag_id
FROM raw_genome_score