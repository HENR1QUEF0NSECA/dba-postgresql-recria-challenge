# 🐘 DBA Challenge — PostgreSQL Performance Tuning

Projeto prático de otimização de banco de dados relacional com PostgreSQL 16, cobrindo diagnóstico de queries lentas, criação de índices, tuning de autovacuum e monitoramento de performance.

---

## 📁 Estrutura do Projeto

```
TESTE_TECNICO/
├── docker/
│   └── docker-compose.yml        # Ambiente PostgreSQL 16 isolado
├── SQL/
│   ├── 01_schema.sql             # Criação das tabelas (users, events, event_metadata)
│   ├── 02_seed.sql               # Carga de dados: 10k usuários e 1M de eventos
│   ├── 03_diagnostico.sql        # Queries de diagnóstico com EXPLAIN ANALYZE
│   ├── 04_indices.sql            # Criação de índices otimizados
│   ├── 05_particionamento.sql    # Particionamento da tabela de eventos por data
│   ├── 06_autovacuum.sql         # Tuning do autovacuum para tabelas de alta escrita
│   └── 07_monitoramento.sql      # Views e queries de monitoramento contínuo
├── README.md
└── RELATO_IA.md
```

---

## 🚀 Como Subir o Ambiente

### Pré-requisitos

- [Docker](https://www.docker.com/) e [Docker Compose](https://docs.docker.com/compose/) instalados
- `psql` disponível localmente (ou use o client dentro do container)

### 1. Subir o container PostgreSQL

```bash
docker compose -f docker/docker-compose.yml up -d
```

O banco estará disponível em `localhost:5432` com as seguintes credenciais:

| Parâmetro | Valor          |
|-----------|----------------|
| Host      | `localhost`    |
| Porta     | `5432`         |
| Banco     | `dev_db`       |
| Usuário   | `admin`        |
| Senha     | `dba_password` |

### 2. Verificar se o container está saudável

```bash
docker compose -f docker/docker-compose.yml ps
docker logs dba_challenge_pg
```

### 3. Conectar ao banco

```bash
psql -h localhost -U admin -d dev_db
```

Ou via o próprio container:

```bash
docker exec -it dba_challenge_pg psql -U admin -d dev_db
```

---

## ▶️ Como Rodar os Scripts

Execute os scripts **na ordem numérica**. Cada um depende do anterior.

### 01 — Schema

Cria as três tabelas principais e habilita a extensão `pg_stat_statements`.

```bash
psql -h localhost -U admin -d dev_db -f SQL/01_schema.sql
```

### 02 — Seed

Popula o banco com **10.000 usuários** e **1.000.000 de eventos** usando `generate_series`. Este script pode levar alguns minutos.

```bash
psql -h localhost -U admin -d dev_db -f SQL/02_seed.sql
```

### 03 — Diagnóstico

Roda três queries problemáticas com `EXPLAIN ANALYZE` para identificar gargalos: full table scan, join sem índice na FK e agregação sem índice funcional.

```bash
psql -h localhost -U admin -d dev_db -f SQL/03_diagnostico.sql
```

> 💡 Anote os tempos de execução aqui para comparar com os resultados após o `SQL/04_indices.sql`.

### 04 — Índices

Cria os três índices que resolvem os problemas identificados no diagnóstico.

```bash
psql -h localhost -U admin -d dev_db -f SQL/04_indices.sql
```

Após a criação, rode o `SQL/03_diagnostico.sql` novamente e compare os planos de execução.

### 05 — Particionamento

Implementa particionamento por intervalo de data (`RANGE`) na tabela `events`, criando partições mensais/anuais para melhorar a performance de queries temporais e facilitar a retenção de dados.

```bash
psql -h localhost -U admin -d dev_db -f SQL/05_particionamento.sql
```

### 06 — Autovacuum

Ajusta os parâmetros de autovacuum especificamente para a tabela `events`, que sofre alta taxa de escrita e atualização.

```bash
psql -h localhost -U admin -d dev_db -f SQL/06_autovacuum.sql
```

### 07 — Monitoramento

Cria views e queries utilitárias para acompanhar a saúde do banco de forma contínua (índices não utilizados, bloats, queries lentas via `pg_stat_statements`, etc.).

```bash
psql -h localhost -U admin -d dev_db -f SQL/07_monitoramento.sql
```

---

## 🧠 Decisões e Justificativas

### Índice Parcial (`04_indices.sql` — Solução 1)

```sql
CREATE INDEX idx_events_failed_purchases
ON events (event_type, status)
WHERE event_type = 'purchase' AND status = 'failed';
```

**Por quê?** A query filtra sempre pelo mesmo par de valores. Um índice parcial é menor, mais rápido de manter e mais eficiente para o planner do que um índice geral nas duas colunas. Descarta as demais combinações de `event_type` e `status` que nunca aparecem nesse filtro.

---

### Índice de Cobertura (`04_indices.sql` — Solução 2)

```sql
CREATE INDEX idx_events_user_id_covering
ON events (user_id)
INCLUDE (event_type, created_at);
```

**Por quê?** O join entre `users` e `events` via `user_id` causava um Seq Scan na tabela de eventos. Com o `INCLUDE`, o PostgreSQL consegue fazer um **Index-Only Scan** sem precisar acessar a heap, pois as colunas do `SELECT` (`event_type`, `created_at`) já estão embutidas no índice.

---

### Índice Funcional (`04_indices.sql` — Solução 3)

```sql
CREATE INDEX idx_events_created_at_day
ON events (date_trunc('day', created_at) DESC);
```

**Por quê?** A query de agregação aplicava `date_trunc('day', ...)` em 1 milhão de linhas em tempo real. Um índice funcional pré-computa o resultado da expressão, permitindo que o planner o use diretamente sem avaliar a função em cada linha.

---

### Tuning de Autovacuum (`06_autovacuum.sql`)

| Parâmetro | Padrão Global | Valor Aplicado | Justificativa |
|-----------|--------------|----------------|---------------|
| `autovacuum_vacuum_scale_factor` | 0.20 (20%) | **0.05 (5%)** | Com 1M de linhas, 20% significa 200k dead tuples antes do vacuum — alto demais |
| `autovacuum_analyze_scale_factor` | 0.10 (10%) | **0.02 (2%)** | Mantém as estatísticas frescas para o query planner após cargas frequentes |
| `autovacuum_vacuum_cost_limit` | 200 | **1000** | Permite que o autovacuum trabalhe mais agressivamente nesta tabela específica |

---

## ⚠️ O Que Ficou de Fora

| Item | Motivo |
|------|--------|
| `05_particionamento.sql` | Arquivo presente porém sem implementação final — migrar uma tabela existente com 1M de linhas para particionamento requer estratégia de zero-downtime (swap de tabelas, triggers ou `pg_partman`) que não foi concluída no prazo |
| `07_monitoramento.sql` | Arquivo presente porém sem implementação final — o conjunto de views de monitoramento (`pg_stat_user_tables`, `pg_stat_statements`, bloat queries) ficou planejado mas não foi entregue |
| Connection Pooling | PgBouncer não foi configurado; seria o próximo passo para ambientes com alta concorrência |
| Alertas automatizados | Não há integração com Prometheus/Grafana ou qualquer sistema de alertas |

---

## 🛑 Parar e Remover o Ambiente

```bash
# Parar o container (mantém os dados)
docker compose -f docker/docker-compose.yml down

# Parar e remover volume (apaga todos os dados)
docker compose -f docker/docker-compose.yml down -v
```

---

## 📋 Requisitos

- Docker >= 24.x
- Docker Compose >= 2.x
- PostgreSQL client (`psql`) >= 15 (opcional, pode usar o container)