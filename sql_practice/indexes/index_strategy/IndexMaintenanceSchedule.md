## Index Maintenance Schedule:

# Daily
✓ Check slow queries
✓ Review EXPLAIN plans
✓ Check unused indexes
✓ Verify autovacuum

# Weekly
✓ Analyze largest tables
✓ Review sequential scans
✓ Check index growth

# Monthly
✓ Identify duplicate indexes
✓ Reindex bloated indexes
✓ Capacity planning

## DBA Index Management Checklist

# Monitor Usage
pg_stat_user_indexes

# Monitor Missing Indexes
EXPLAIN ANALYZE

# Monitor Duplicate Indexes
pg_index

# Update Statistics
ANALYZE
VACUUM ANALYZE

# Monitor Bloat
pg_relation_size()

# Rebuild Indexes
REINDEX CONCURRENTLY

# Review Query Plans
EXPLAIN (ANALYZE, BUFFERS)

# Track Slow Queries
pg_stat_statements

# Verify Autovacuum
pg_stat_user_tables

# Optimize Index Design
B-Tree
GIN
GiST
BRIN
Partial
Expression
Composite
Covering
