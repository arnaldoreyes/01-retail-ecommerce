/* ============================================================================
   00_setup / 00_crear_esquema.sql
   Proyecto : 01 - Retail / Online Retail II
   Motor    : MySQL 8.0  (MySQL Workbench)
   Objetivo : crear la base de datos y las tablas de trabajo del proyecto.
   Regla    : el script se puede correr varias veces sin romperse.

   ATENCION A LOS NOMBRES DE COLUMNA
   El archivo original nombra los campos: Invoice, StockCode, Description,
   Quantity, InvoiceDate, Price, Customer ID, Country.
   Es decir: `Invoice` (NO InvoiceNo) y `Price` (NO UnitPrice).
   Muchos tutoriales usan la version antigua del dataset, de una sola hoja, donde
   esos dos campos SI se llaman InvoiceNo y UnitPrice. Si copias codigo de ahi,
   no te va a correr y vas a perder media hora averiguando por que.

   COMO USARLO
     1. Abre MySQL Workbench y conectate a tu servidor local.
     2. File > Open SQL Script... y abre este archivo.
     3. Ejecuta TODO el script (icono del rayo).
   ============================================================================ */

CREATE DATABASE IF NOT EXISTS portafolio_retail
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE portafolio_retail;

/* MySQL no maneja "esquemas" separados como SQL Server: se usa el prefijo en el
   nombre de la tabla (stg_ / mart_ / dq_). Es la convencion mas clara y legible
   cuando alguien entra a revisar tu modelo. */

-- ============================================================================
-- CAPA 1 · STAGING: copia fiel del archivo original, ya tipada.
-- ============================================================================
DROP TABLE IF EXISTS stg_ventas_2009_2010;
CREATE TABLE stg_ventas_2009_2010 (
  -- Carga todo como texto en la primera pasada: asi decides TU, y no el motor,
  -- que filas son validas. El tipado fino es la Fase 2.
  invoice       VARCHAR(20)   NULL,   -- ojo: los que empiezan con 'C' son cancelaciones
  stock_code    VARCHAR(20)   NULL,   -- ojo: POST, D, M, BANK CHARGES no son productos
  description   VARCHAR(120)  NULL,
  quantity      INT           NULL,   -- negativo = devolucion
  invoice_date  DATETIME      NULL,
  price         DECIMAL(18,4) NULL,   -- 0 = cortesia, puede ser negativo
  customer_id   INT           NULL,   -- ~23% vacio: decision clave del proyecto
  country       VARCHAR(60)   NULL,
  fila_origen   INT           NULL,   -- numero de fila del CSV: sirve para auditar
  cargado_en    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

DROP TABLE IF EXISTS stg_ventas_2010_2011;
CREATE TABLE stg_ventas_2010_2011 LIKE stg_ventas_2009_2010;

-- ============================================================================
-- CAPA 2 · BITACORA DE CALIDAD: cada regla de limpieza que aplicas.
-- Si no esta aqui, no existe. Es tu defensa en la entrevista.
-- ============================================================================
DROP TABLE IF EXISTS dq_reglas;
CREATE TABLE dq_reglas (
  id_regla        INT AUTO_INCREMENT PRIMARY KEY,
  nombre          VARCHAR(120) NOT NULL,
  descripcion     VARCHAR(400) NOT NULL,
  filas_afectadas INT          NULL,
  decision        VARCHAR(200) NULL,   -- que hice con esas filas y POR QUE
  fecha           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

/* ============================================================================
   NOTAS DE CARGA (Fase 1)
   ----------------------------------------------------------------------------
   El archivo original es un .xlsx de 43 MB con DOS hojas. Pasos:

   1) Abre online_retail_II.xlsx en Excel.
   2) Guarda la hoja "Year 2009-2010" como CSV UTF-8 en data/staging/.
      Guarda la hoja "Year 2010-2011" como CSV UTF-8 en data/staging/.
      (Son ~500.000 filas cada una: Excel lo hace, pero tarda.)

   3) Carga en MySQL. Dos caminos:

      A) Interfaz grafica (mas facil):
         En MySQL Workbench: clic derecho sobre la tabla > Table Data Import Wizard >
         selecciona el CSV > mapea las columnas (incluido "Customer ID" -> customer_id)
         > Next.

      B) LOAD DATA (mas rapido y repetible):
         SET GLOBAL local_infile = 1;   -- requiere tambien local_infile=1 en el cliente
         LOAD DATA LOCAL INFILE 'C:/ruta/data/staging/ventas_2009_2010.csv'
         INTO TABLE stg_ventas_2009_2010
         FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
         LINES TERMINATED BY '\r\n'
         IGNORE 1 LINES
         (invoice, stock_code, description, quantity, invoice_date, price,
          customer_id, country);

   4) VERIFICA EL CONTEO despues de cargar:
         SELECT COUNT(*) FROM stg_ventas_2009_2010;
         SELECT COUNT(*) FROM stg_ventas_2010_2011;
      Si no coincide con el origen, PARA y averigua por que antes de seguir.
      Esa es tu primera regla en dq_reglas.

   5) Comprueba el solape de diciembre de 2010 entre las dos hojas ANTES de unirlas.
   ============================================================================ */
