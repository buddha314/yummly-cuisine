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

