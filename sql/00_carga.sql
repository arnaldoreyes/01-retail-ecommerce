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
     3. Reemplaza las dos rutas de abajo por las tuyas. Usa barras normales (/).
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
   EL FORMATO DE LA FECHA DEPENDE DEL IDIOMA DE WINDOWS

   Excel NO exporta la fecha con el formato de la celda: la exporta con el
   formato corto de fecha del sistema. El mismo dia, dos Windows distintos:

       valor real en el .xlsx     Windows en español     Windows en ingles
          2009-12-01 07:45        01/12/2009 07:45       12/1/09 7:45

   Es el mismo dia en orden distinto (dia/mes vs mes/dia). Si usas el formato
   equivocado MySQL NO da error: te intercambia el mes y el dia en las 1.067.371
   filas y tu analisis temporal queda entero al reves.

   Este script usa '%d/%m/%Y %H:%i' (dia/mes) porque el CSV de este repositorio
   se exporto con Windows en español. Si el tuyo sale en formato mes/dia, cambia
   la `d` por la `m` en las dos lineas SET.

   Se usa %Y (mayuscula) y no %y: la minuscula solo acepta años de dos digitos y
   devuelve NULL si el CSV trae '2009'.

   COMO SABER SI ACERTASTE: mira la COMPROBACION del final del script. Si la
   fecha_min de la hoja 1 no es 2009-12-01, el orden esta invertido. No sigas.
   --------------------------------------------------------------------------- */
TRUNCATE TABLE ventas;
LOAD DATA LOCAL INFILE 'C:/ruta/a/tu/proyecto/data/limpio/ventas_2009_2010.csv'
INTO TABLE ventas
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(invoice, stock_code, description, quantity, @fecha, price, @customer_id, country)
SET invoice_date = STR_TO_DATE(TRIM(@fecha), '%d/%m/%Y %H:%i'),
    customer_id  = NULLIF(TRIM(@customer_id), ''),
    description  = NULLIF(TRIM(description), ''),
    hoja         = '2009-2010';

/* ---------------------------------------------------------------------------
   CARGA DE LA HOJA 2  (mismo comando, otro archivo y otro valor de `hoja`)

   LINES TERMINATED BY '\r\n': los CSV de Windows terminan las lineas con CRLF.
   Con '\n' la carga se corrompe sin dar error (te quedas con la mitad de las
   filas y la ultima columna con comillas y un caracter invisible pegados).
   --------------------------------------------------------------------------- */
LOAD DATA LOCAL INFILE 'C:/ruta/a/tu/proyecto/data/limpio/ventas_2010_2011.csv'
INTO TABLE ventas
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(invoice, stock_code, description, quantity, @fecha, price, @customer_id, country)
SET invoice_date = STR_TO_DATE(TRIM(@fecha), '%d/%m/%Y %H:%i'),
    customer_id  = NULLIF(TRIM(@customer_id), ''),
    description  = NULLIF(TRIM(description), ''),
    hoja         = '2010-2011';

/* ---------------------------------------------------------------------------
   COMPROBACION — esto es lo que tiene que salir

     hoja         filas     clientes_vacios   cliente_cero   fecha_min     fecha_max
     2009-2010    525.461   107.927           0              2009-12-01    2010-12-09
     2010-2011    541.910   135.080           0              2010-12-01    2011-12-09

   Si `cliente_cero` no es 0  -> los customer_id vacios se guardaron como 0, y
                                 tienes un cliente inexistente con 243.007 filas.
   Si `fecha_min`/`fecha_max` no coinciden -> el formato de fecha esta mal.
   Si `filas` no coincide     -> la carga se corto (terminador de linea).
   Cualquiera de las tres: PARA y corrige antes de analizar nada.
   --------------------------------------------------------------------------- */
SELECT hoja,
       COUNT(*)                        AS filas,
       SUM(customer_id IS NULL)        AS clientes_vacios,
       SUM(customer_id = 0)            AS cliente_cero,
       MIN(DATE(invoice_date))         AS fecha_min,
       MAX(DATE(invoice_date))         AS fecha_max
FROM ventas
GROUP BY hoja;
