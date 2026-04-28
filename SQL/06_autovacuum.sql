--------------------------------------------------------------------------------
-- TUNING DE AUTOVACUUM PARA TABELA DE ALTA ESCRITA
-- Justificativa: O padrão global de 20% é muito alto para tabelas de milhões de linhas.
-- Aqui reduzimos para 5% para manter a tabela sempre limpa e as estatísticas atualizadas.
--------------------------------------------------------------------------------

ALTER TABLE events SET (
  -- Dispara o VACUUM quando 5% das linhas forem alteradas/deletadas (antes era 20%)
  autovacuum_vacuum_scale_factor = 0.05,
  
  -- Dispara o ANALYZE quando 2% das linhas mudarem (mantém o Planner esperto)
  autovacuum_analyze_scale_factor = 0.02,
  
  -- Aumenta o custo limite para que o autovacuum trabalhe mais rápido nesta tabela
  autovacuum_vacuum_cost_limit = 1000
);

-- Nota: Como recriamos a tabela no particionamento, precisamos recriar os índices nela
-- para que o diagnóstico continue rápido.
CREATE INDEX idx_events_user_id_new ON events (user_id);
CREATE INDEX idx_events_created_at_new ON events (created_at);