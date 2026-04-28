--------------------------------------------------------------------------------
-- QUERY 1: Full Table Scan (Busca sem índice em coluna de texto)
--------------------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT * FROM events 
WHERE event_type = 'purchase' 
  AND status = 'failed';

--------------------------------------------------------------------------------
-- QUERY 2: Join Ineficiente (Filtro em tabela menor sem índice na FK)
--------------------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT u.name, e.event_type, e.created_at
FROM users u
JOIN events e ON u.id = e.user_id
WHERE u.email = 'user5000@example.com';

--------------------------------------------------------------------------------
-- QUERY 3: Agregação Pesada (Data Trunc sem índice funcional)
--------------------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT date_trunc('day', created_at) as dia, count(*)
FROM events
GROUP BY 1
ORDER BY 1 DESC
LIMIT 10;