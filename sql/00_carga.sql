/* ============================================================================
   00_carga.sql  —  Crea la tabla y carga las dos hojas del dataset.
   ----------------------------------------------------------------------------
   Verificado en MySQL 8.0.46: carga 1.067.371 filas sin errores.

   ANTES DE EJECUTAR
     1. Descarga online_retail_II.xlsx desde el enlace de la fuente (ver el README)
        y guardalo en data/raw/.
     2. Abre el .xlsx en Excel y guarda cada hoja como CSV UTF-8 en data/limpio/:
          data/limpio/ventas_2009_2010.csv   (hoja "Year 2009-2010")
          data/limpio/ventas_2010_2011.csv   (hoja "Year 2010-2011")
     3. Reemplaza las rutas de abajo por las tuyas. Usa barras normales (/).
   ============================================================================ */

CREATE DATABASE IF NOT EXISTS portafolio_retail
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE portafolio_retail;

/* Una sola tabla para las dos hojas. La columna `hoja` guarda de donde viene
   cada fila: sin ella es imposible medir el solape de diciembre de 2010, porque
   los duplicados se ven igual que cualquier otro duplicado. */
DROP TABLE IF EXISTS ventas;
CREATE TABLE ventas (
  invoice       VARCHAR(20)   NULL,
  stock_code    VARCHAR(20)   NULL,
  description   VARCHAR(120)  NULL,
  quantity      INT           NULL,
  invoice_date  DATETIME      NULL,
  price         DECIMAL(18,4) NULL,
  customer_id   INT           NULL,
  country       VARCHAR(60)   NULL,
  hoja          VARCHAR(20)   NULL
) ENGINE=InnoDB;

SET GLOBAL local_infile = 1;

/* ---------------------------------------------------------------------------
   CARGA DE LA HOJA 1
   Las tres conversiones del SET no son opcionales; cada una evita un error
   silencioso distinto:

     invoice_date = STR_TO_DATE(...)   el CSV trae 'm/d/yy h:mm' y MySQL lo lee
                                       como año/mes/día ('12/1/09' -> 2012-01-09)
     customer_id  = NULLIF(...)        los vacíos se convertirían en 0 y crearían
                                       un cliente inexistente
     description  = NULLIF(...)        los vacíos quedan como '' en vez de NULL

   LINES TERMINATED BY '\r\n'  ->  los CSV de Windows usan CRLF. Con '\n' la
                                   carga se corrompe sin dar error.
   --------------------------------------------------------------------------- */
TRUNCATE TABLE ventas;
LOAD DATA LOCAL INFILE 'C:/ruta/a/tu/proyecto/data/limpio/ventas_2009_2010.csv'
INTO TABLE ventas
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(invoice, stock_code, description, quantity, @fecha, price, @customer_id, country)
SET invoice_date = STR_TO_DATE(TRIM(@fecha), '%m/%d/%Y %H:%i'),
    customer_id  = NULLIF(TRIM(@customer_id), ''),
    description  = NULLIF(TRIM(description), ''),
    hoja         = '2009-2010';

/* ---------------------------------------------------------------------------
   CARGA DE LA HOJA 2  (mismo comando, otro archivo y otro valor de `hoja`)

   OJO CON LA 'Y': el formato de fecha usa %Y (mayuscula) y no %y. La %y solo
   acepta años de dos digitos y devuelve NULL si el CSV trae '2009'. La %Y acepta
   las dos formas. Verificado en MySQL 8.0.46:
       STR_TO_DATE('12/1/09 7:45',   '%m/%d/%y %H:%i')  ->  2009-12-01 07:45:00
       STR_TO_DATE('12/1/2009 7:45', '%m/%d/%y %H:%i')  ->  NULL
       STR_TO_DATE('12/1/09 7:45',   '%m/%d/%Y %H:%i')  ->  2009-12-01 07:45:00
       STR_TO_DATE('12/1/2009 7:45', '%m/%d/%Y %H:%i')  ->  2009-12-01 07:45:00
   --------------------------------------------------------------------------- */
LOAD DATA LOCAL INFILE 'C:/ruta/a/tu/proyecto/data/limpio/ventas_2010_2011.csv'
INTO TABLE ventas
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(invoice, stock_code, description, quantity, @fecha, price, @customer_id, country)
SET invoice_date = STR_TO_DATE(TRIM(@fecha), '%m/%d/%Y %H:%i'),
    customer_id  = NULLIF(TRIM(@customer_id), ''),
    description  = NULLIF(TRIM(description), ''),
    hoja         = '2010-2011';

/* ---------------------------------------------------------------------------
   COMPROBACION MINIMA
   Si alguno de estos numeros no coincide, la carga fallo. No seguir.
   --------------------------------------------------------------------------- */
SELECT hoja,
       COUNT(*)                        AS filas,
       SUM(customer_id IS NULL)        AS clientes_vacios,
       SUM(customer_id = 0)            AS cliente_cero,   -- debe ser 0
       MIN(DATE(invoice_date))         AS fecha_min,
       MAX(DATE(invoice_date))         AS fecha_max
FROM ventas
GROUP BY hoja;
