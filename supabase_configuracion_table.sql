CREATE TABLE IF NOT EXISTS configuracion (
  id integer PRIMARY KEY,
  reserva_ars numeric DEFAULT 0,
  reserva_usd numeric DEFAULT 0
);
ALTER TABLE configuracion DISABLE ROW LEVEL SECURITY;
