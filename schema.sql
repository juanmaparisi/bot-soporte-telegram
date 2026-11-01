-- Bot de soporte de Tienda Demo (Telegram). Todos los datos son ficticios.

-- Pedidos de ejemplo. Las fechas son relativas a hoy para que la demo siempre esté al día.
CREATE TABLE IF NOT EXISTS tienda_pedidos (
  numero            TEXT PRIMARY KEY,           -- formato TD-1234
  email             TEXT NOT NULL,
  cliente           TEXT,
  estado            TEXT NOT NULL,              -- preparando, despachado, en_camino, entregado, demorado, cancelado
  fecha_compra      DATE NOT NULL,
  entrega_estimada  DATE,
  transportista     TEXT,
  seguimiento       TEXT,
  productos         TEXT
);

INSERT INTO tienda_pedidos VALUES
  ('TD-1001', 'lucia@example.com',  'Lucía',  'en_camino',  CURRENT_DATE - 3, CURRENT_DATE + 2, 'Correo Demo',  'CD123456789AR', 'Remera básica blanca (M)'),
  ('TD-1002', 'martin@example.com', 'Martín', 'preparando', CURRENT_DATE - 1, CURRENT_DATE + 6, NULL,           NULL,            'Jean recto azul (42)'),
  ('TD-1003', 'sofia@example.com',  'Sofía',  'entregado',  CURRENT_DATE - 12, CURRENT_DATE - 6, 'Correo Demo', 'CD987654321AR', 'Buzo canguro gris (S)'),
  ('TD-1004', 'diego@example.com',  'Diego',  'demorado',   CURRENT_DATE - 10, CURRENT_DATE - 2, 'Envíos Demo', 'ED555000111',   'Campera rompevientos (L)'),
  ('TD-1005', 'ana@example.com',    'Ana',    'cancelado',  CURRENT_DATE - 5, NULL,             NULL,           NULL,            'Vestido midi negro (M)'),
  ('TD-1006', 'lucia@example.com',  'Lucía',  'despachado', CURRENT_DATE - 2, CURRENT_DATE + 4, 'Envíos Demo',  'ED555000222',   'Medias pack x3')
ON CONFLICT (numero) DO NOTHING;

-- Historial de mensajes: memoria del bot, límite de uso y registro de la conversación.
CREATE TABLE IF NOT EXISTS tienda_bot_mensajes (
  id      SERIAL PRIMARY KEY,
  chat_id TEXT NOT NULL,
  rol     TEXT NOT NULL,                        -- cliente, bot, operador
  texto   TEXT NOT NULL,
  agente  TEXT,                                 -- pedidos, consultas, reglas, derivacion, operador, error
  creado  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_tienda_bot_mensajes_chat ON tienda_bot_mensajes (chat_id, id);
CREATE INDEX IF NOT EXISTS idx_tienda_bot_mensajes_creado ON tienda_bot_mensajes (creado);

-- Casos derivados a una persona. Un solo caso abierto por chat.
CREATE TABLE IF NOT EXISTS tienda_derivaciones (
  id          SERIAL PRIMARY KEY,
  chat_id     TEXT NOT NULL,
  nombre      TEXT,
  motivo      TEXT,
  estado      TEXT NOT NULL DEFAULT 'abierta',  -- abierta, cerrada
  creado      TIMESTAMPTZ NOT NULL DEFAULT now(),
  cerrada_en  TIMESTAMPTZ
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_tienda_derivacion_abierta ON tienda_derivaciones (chat_id) WHERE estado = 'abierta';

-- Permisos mínimos para el usuario con el que se conecta n8n (reemplazar usuario_de_n8n):
-- GRANT SELECT ON tienda_pedidos TO usuario_de_n8n;
-- GRANT SELECT, INSERT ON tienda_bot_mensajes TO usuario_de_n8n;
-- GRANT SELECT, INSERT, UPDATE ON tienda_derivaciones TO usuario_de_n8n;
-- GRANT USAGE ON SEQUENCE tienda_bot_mensajes_id_seq, tienda_derivaciones_id_seq TO usuario_de_n8n;
