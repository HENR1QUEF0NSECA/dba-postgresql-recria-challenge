-- Limpar tabelas se existirem
DROP TABLE IF EXISTS event_metadata;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS users;

-- Criar extensão
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Criar tabela de usuários
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(150) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criar tabela de eventos
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    event_type VARCHAR(50),
    status VARCHAR(20),
    value NUMERIC(10, 2),
    created_at TIMESTAMP
);

-- Criar tabela de metadados
CREATE TABLE event_metadata (
    id SERIAL PRIMARY KEY,
    event_id INTEGER REFERENCES events(id),
    key VARCHAR(50),
    value TEXT
);