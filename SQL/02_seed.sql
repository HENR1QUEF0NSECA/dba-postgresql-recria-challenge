-- Popular 10 mil usuários
INSERT INTO users (name, email, created_at)
SELECT 'User ' || i, 'user' || i || '@example.com', now() - (random() * interval '365 days')
FROM generate_series(1, 10000) s(i);

-- Popular 1 milhão de eventos
INSERT INTO events (user_id, event_type, status, value, created_at)
SELECT 
    floor(random() * 10000 + 1)::int,
    (ARRAY['login', 'purchase', 'logout', 'click'])[floor(random() * 4 + 1)],
    (ARRAY['pending', 'completed', 'failed'])[floor(random() * 3 + 1)],
    (random() * 500)::numeric(10,2),
    now() - (random() * interval '400 days')
FROM generate_series(1, 1000000) s(i);