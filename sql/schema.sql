DROP TABLE IF EXISTS r.yummly_crystals_raw;
CREATE TABLE r.yummly_crystals_raw (
  id int
, original_entropy real
, entropy real
, original_crystals text
, crystals text
);

// \copy r.yummly_crystals_raw from 'output.txt' with csv header delimiter E'\t'

DROP TABLE IF EXISTS r.yummly_crystals_tall;
CREATE TABLE r.yummly_crystals_tall AS
SELECT
  id
, original_entropy
, entropy
, unnest(string_to_array(crystals, ':')) AS ingredient
, true as final
FROM r.yummly_crystals_raw
UNION ALL
SELECT
  id
, original_entropy
, entropy
, unnest(string_to_array(original_crystals, ':')) AS ingredient
, false as final
FROM r.yummly_crystals_raw
;

DROP TABLE IF EXISTS r.yummly_inflation;
CREATE TABLE r.yummly_inflation (
  recipe_id int
, crystal_id int
, entropy real
, inflation real
);

// \copy r.yummly_inflation from 'inflations_20171106.txt' with csv header delimiter E'\t'

DROP TABLE IF EXISTS r.yummly_crystal_fits;
CREATE TABLE r.yummly_crystal_fits AS
SELECT
  i.crystal_id
, i.recipe_id
, a.minflation
FROM (
    SELECT
      crystal_id, min(entropy-inflation) AS minflation
    FROM r.yummly_inflation
    GROUP BY crystal_id
    ) AS a
  INNER JOIN r.yummly_inflation AS i 
    ON  a.crystal_id = i.crystal_id
    AND a.minflation = i.entropy - i.inflation
;
