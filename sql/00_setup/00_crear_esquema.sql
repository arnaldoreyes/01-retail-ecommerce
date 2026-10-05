/* ============================================================================
   00_setup / 00_crear_esquema.sql
   ----------------------------------------------------------------------------
   Objetivo : crear el esquema del proyecto y las tablas de trabajo.
   Dialecto : SQL Server (T-SQL). Al final esta la variante PostgreSQL.
   Regla    : el script debe poder correrse varias veces sin romperse (idempotente).

   TODO (Fase 1): reemplaza los nombres y tipos por los de TU dataset.
   Este archivo NO es la respuesta, es el molde. La primera vez que lo corras
   vas a tener que decidir el tipo de dato de cada columna: eso es parte del
   trabajo de perfilado y es exactamente lo que evaluan en una entrevista.
   ============================================================================ */

-- 1. Esquemas: separa cada capa para que se vea el flujo del dato.
IF SCHEMA_ID('stg') IS NULL EXEC('CREATE SCHEMA stg');   -- copia fiel del crudo, ya tipada
IF SCHEMA_ID('marts') IS NULL EXEC('CREATE SCHEMA marts'); -- modelo de negocio (dim / fact)
IF SCHEMA_ID('dq') IS NULL EXEC('CREATE SCHEMA dq');     -- chequeos de calidad de datos
GO

-- 2. Tabla de staging: una columna por cada columna del archivo origen.
--    Usa tipos generosos al inicio (NVARCHAR(255)); en la Fase 2 ajustas.
IF OBJECT_ID('stg.tabla_origen', 'U') IS NOT NULL DROP TABLE stg.tabla_origen;
GO
CREATE TABLE stg.tabla_origen (
    -- TODO: una linea por columna del origen, con el mismo nombre.
    -- Ejemplo:
    -- id_registro      NVARCHAR(50)  NULL,
    -- fecha_evento     DATETIME2(0)  NULL,
    -- cantidad         INT           NULL,
    -- precio_unitario  DECIMAL(18,4) NULL,
    -- cliente_id       NVARCHAR(50)  NULL,
    _fila_origen       INT           NULL,  -- numero de fila del archivo: sirve para auditar
    _cargado_en        DATETIME2(0)  NOT NULL DEFAULT SYSDATETIME()
);
GO

-- 3. Bitacora de calidad: cada regla de limpieza que aplicas queda registrada.
IF OBJECT_ID('dq.reglas', 'U') IS NOT NULL DROP TABLE dq.reglas;
GO
CREATE TABLE dq.reglas (
    id_regla        INT IDENTITY(1,1) PRIMARY KEY,
    nombre          NVARCHAR(120) NOT NULL,
    descripcion     NVARCHAR(400) NOT NULL,
    filas_afectadas INT           NULL,
    decision        NVARCHAR(200) NULL,  -- que hice con esas filas y por que
    fecha           DATETIME2(0)  NOT NULL DEFAULT SYSDATETIME()
);
GO

/* ---------------------------------------------------------------------------
   VARIANTE PostgreSQL (por si el proyecto se monta en Postgres)
   ---------------------------------------------------------------------------
   CREATE SCHEMA IF NOT EXISTS stg;
   CREATE SCHEMA IF NOT EXISTS marts;
   CREATE SCHEMA IF NOT EXISTS dq;

   CREATE TABLE IF NOT EXISTS stg.tabla_origen (
       id_registro     TEXT,
       fecha_evento    TIMESTAMP,
       cantidad        INTEGER,
       precio_unitario NUMERIC(18,4),
       cliente_id      TEXT,
       _fila_origen    INTEGER,
       _cargado_en     TIMESTAMP NOT NULL DEFAULT NOW()
   );
   --------------------------------------------------------------------------- */
