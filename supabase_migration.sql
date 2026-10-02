-- 1. Agregar caja_id a liquidaciones
ALTER TABLE liquidaciones ADD COLUMN IF NOT EXISTS caja_id BIGINT;

-- 2. Crear tabla de configuracion para guardar las reservas
CREATE TABLE IF NOT EXISTS configuracion (
  id INT PRIMARY KEY,
  reserva_ars NUMERIC DEFAULT 0,
  reserva_usd NUMERIC DEFAULT 0
);

-- Insertar la fila inicial por defecto si no existe
INSERT INTO configuracion (id, reserva_ars, reserva_usd) 
VALUES (1, 0, 0) 
ON CONFLICT (id) DO NOTHING;
