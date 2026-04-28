--------------------------------------------------------------------------------
-- SOLUÇÃO 1: Índice Parcial (Focado apenas no que importa)
--------------------------------------------------------------------------------
CREATE INDEX CONCURRENTLY idx_events_failed_purchases 
ON events (event_type, status) 
WHERE event_type = 'purchase' AND status = 'failed';

--------------------------------------------------------------------------------
-- SOLUÇÃO 2: Índice de Cobertura (Covering Index) para a FK
--------------------------------------------------------------------------------
CREATE INDEX CONCURRENTLY idx_events_user_id_covering 
ON events (user_id) 
INCLUDE (event_type, created_at);

--------------------------------------------------------------------------------
-- SOLUÇÃO 3: Índice Funcional (Para a query de data)
--------------------------------------------------------------------------------
CREATE INDEX CONCURRENTLY idx_events_created_at_day 
ON events (date_trunc('day', created_at) DESC);