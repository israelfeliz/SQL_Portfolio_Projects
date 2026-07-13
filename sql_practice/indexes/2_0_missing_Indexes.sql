-- Detect Sequential Scans

SELECT
    relname AS table_name,
    seq_scan,
    idx_scan
FROM pg_stat_user_tables
ORDER BY seq_scan DESC;

/*If:
seq_scan > idx_scan
investigate indexing opportunities.

I noticed I have to think about a good indexes strategy on the tables:
product, staff and sales_details*/