-- create_partitioned table
CREATE OR REPLACE TABLE diabetes_bq.diabetes_merged_partitioned
PARTITION BY
  date AS
SELECT * FROM diabetes_bq.diabetes_merged;