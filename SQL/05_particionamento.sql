-- 1. Criar a tabela "mãe" com a mesma estrutura, mas definida como particionada
CREATE TABLE events_partitioned (
    id SERIAL,
    user_id INTEGER,
    event_type VARCHAR(50),
    status VARCHAR(20),
    value NUMERIC(10, 2),
    created_at TIMESTAMP
) PARTITION BY RANGE (created_at);

-- 2. Criar as partições
CREATE TABLE events_y2025_m01 PARTITION OF events_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE events_y2025_m02 PARTITION OF events_partitioned
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE events_y2025_m03 PARTITION OF events_partitioned
    FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

-- Partição padrão para dados fora desse range
CREATE TABLE events_default PARTITION OF events_partitioned DEFAULT;

-- 3. Migrar os dados da tabela antiga para a nova
INSERT INTO events_partitioned SELECT * FROM events;

-- 4. Trocar as tabelas
BEGIN;
    ALTER TABLE events RENAME TO events_old;
    ALTER TABLE events_partitioned RENAME TO events;
COMMIT;