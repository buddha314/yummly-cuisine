DROP TABLE IF EXISTS r.yummly_recipe;
CREATE TABLE r.yummly_recipe (
  cuisine text
, recipe_id int
, ingredient text
);

// \copy r.yummly_recipe from 'app/data/yummly.txt' with csv header delimiter E'\t'

DROP TABLE IF EXISTS r.yummly_crystal;
CREATE TABLE r.yummly_crystal (
  id int
, original_entropy real
, entropy real
, ingredient text
, status text
);
// \copy r.yummly_crystal from 'crystals_dev.txt' with csv header delimiter E'\t'


DROP TABLE IF EXISTS r.yummly_inflation;
CREATE TABLE r.yummly_inflation (
  recipe_id int
, crystal_id int
, entropy real
, inflation real
, intersection_size int
, symdiff_size int
);

// \copy r.yummly_inflation from 'results/inflation_20171114.txt' with csv header delimiter E'\t'

DROP TABLE IF EXISTS r.yummly_rank;
CREATE TABLE r.yummly_rank AS
SELECT
  crystal_id
, recipe_id
, (entropy-inflation) AS err
, intersection_size
, symdiff_size
, DENSE_RANK() OVER (PARTITION BY crystal_id ORDER BY entropy-inflation) AS r
FROM r.yummly_inflation
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
