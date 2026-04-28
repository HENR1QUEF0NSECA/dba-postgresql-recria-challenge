--------------------------------------------------------------------------------
-- 1. TOP 5 QUERIES MAIS LENTAS
--------------------------------------------------------------------------------
SELECT 
    query, 
    calls, 
    round(total_exec_time::numeric / 1000, 2) as total_sec,
    round(mean_exec_time::numeric, 2) as avg_ms
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 5;

--------------------------------------------------------------------------------
-- 2. ÍNDICES NÃO UTILIZADOS
--------------------------------------------------------------------------------
SELECT 
    relname AS table_name, 
    indexrelname AS index_name, 
    idx_scan 
FROM pg_stat_user_indexes 
WHERE idx_scan = 0 
  AND schemaname = 'public';

--------------------------------------------------------------------------------
-- 3. ESTIMATIVA DE BLOAT
--------------------------------------------------------------------------------
SELECT
    relname AS table_name,
    round(n_dead_tup * 100 / max(n_live_tup, 1), 2) AS dead_tuple_percent
FROM pg_stat_all_tables
WHERE schemaname = 'public'
GROUP BY relname, n_dead_tup;