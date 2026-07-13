-- Detect Duplicates
SELECT
    t.relname AS table_name,
    i.relname AS index_name,
    pg_get_indexdef(i.oid) AS index_definition
FROM pg_class t
JOIN pg_index ix ON t.oid = ix.indrelid
JOIN pg_class i ON i.oid = ix.indexrelid
WHERE t.relkind = 'r' AND t.relname NOT LIKE 'pg_%'
ORDER BY t.relname;

-- This may be difficult on big datasets
-- since we have to review the indexes manually 

/*I created another index on the customer table on customer_id column
for demonstration purposes*/

CREATE INDEX duplicate_customer_id
ON customer (customer_id);

-- More advanced: This will return only duplicate indexes.

WITH indexes AS (
    SELECT
        indrelid,
        indexrelid,
        indkey
    FROM pg_index
)
SELECT *
FROM indexes i1
JOIN indexes i2
ON i1.indrelid = i2.indrelid
AND i1.indkey = i2.indkey
AND i1.indexrelid <> i2.indexrelid;

-- Drop duplicate, make sure not to delete the primary key.

DROP INDEX duplicate_customer_id;
