DROP TABLE IF EXISTS r.yummly_recipe;
CREATE TABLE r.yummly_recipe (
  cuisine text
, recipe_id int
, ingredient text
);

// \copy r.yummly_recipe from 'app/data/yummly.txt' with csv header delimiter E'\t'

DROP TABLE IF EXISTS r.yummly_crystal;
CREATE TABLE r.yummly_crystal (
  crystal_id int
, original_entropy real
, entropy real
, ingredient text
, status text
);
// \copy r.yummly_crystal from 'crystals_dev.txt' with csv header delimiter E'\t'


DROP TABLE IF EXISTS r.yummly_inflation CASCADE;
CREATE TABLE r.yummly_inflation (
  recipe_id int
, crystal_id int
, symdiff_e real
, crystal_minus_e real
, recipe_minus_e real
, intersection_size int
, symdiff_size int
);

// \copy r.yummly_inflation from 'inflation_dev.txt' with csv header delimiter E'\t'


DROP TABLE IF EXISTS r.yummly_rank;
CREATE TABLE r.yummly_rank AS
SELECT
  crystal_id
, recipe_id
, symdiff_e
, crystal_minus_e
, recipe_minus_e
, intersection_size
, symdiff_size
, DENSE_RANK() OVER (PARTITION BY crystal_id ORDER BY symdiff_e) AS r_symdiff
, DENSE_RANK() OVER (PARTITION BY crystal_id ORDER BY crystal_minus_e) AS r_cdiff
, DENSE_RANK() OVER (PARTITION BY crystal_id ORDER BY recipe_minus_e) AS r_rdiff
FROM r.yummly_inflation
WHERE intersection_size > 0
;

DROP TABLE IF EXISTS r.yummly_rank_recipe;
CREATE TABLE r.yummly_rank_recipe AS
SELECT
  crystal_id
, recipe_id
, (entropy-inflation) AS err
, symdiff_size
, DENSE_RANK() OVER (PARTITION BY recipe_id ORDER BY entropy-inflation) AS r
FROM r.yummly_inflation
;
