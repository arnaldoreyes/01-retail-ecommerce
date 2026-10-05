/* ============================================================================
   00_setup / 01_validar_carga.sql
   Proyecto : 01 - Retail / Online Retail II
   ----------------------------------------------------------------------------
   QUE ES ESTO
   Un control de calidad de la carga. Lo corres INMEDIATAMENTE despues de cargar
   los CSV y antes de escribir una sola consulta de analisis.

   POR QUE EXISTE
   La peor falla de una carga no es la que da error: es la que deja la tabla
   llena, con datos creibles y equivocados. Este script convierte la regla
   "verifica el conteo" en algo que no depende de tu memoria ni de tu voluntad.

   COMO LEERLO
   La columna `resultado` tiene que decir OK en TODAS las filas.
   Si alguna dice FALLA: PARA. No limpies nada, no sigas. Corrige la carga
   (TRUNCATE TABLE y volver a cargar) y vuelve a correr este script.

   Resultado esperado: 10 filas, todas en OK.
   ============================================================================ */

USE portafolio_retail;

SELECT '01 Filas hoja 2009-2010' AS chequeo,
       (SELECT COUNT(*) FROM stg_ventas_2009_2010) AS obtenido,
       525461 AS esperado,
       IF((SELECT COUNT(*) FROM stg_ventas_2009_2010) = 525461, 'OK', 'FALLA') AS resultado
UNION ALL
SELECT '02 Filas hoja 2010-2011',
       (SELECT COUNT(*) FROM stg_ventas_2010_2011), 541910,
       IF((SELECT COUNT(*) FROM stg_ventas_2010_2011) = 541910, 'OK', 'FALLA')
UNION ALL
SELECT '03 Total de lineas',
       (SELECT (SELECT COUNT(*) FROM stg_ventas_2009_2010) + (SELECT COUNT(*) FROM stg_ventas_2010_2011)), 1067371,
       IF((SELECT (SELECT COUNT(*) FROM stg_ventas_2009_2010) + (SELECT COUNT(*) FROM stg_ventas_2010_2011)) = 1067371, 'OK', 'FALLA')
UNION ALL
SELECT '04 Invoice sin vacios',
       (SELECT COUNT(*) FROM (SELECT invoice FROM stg_ventas_2009_2010 UNION ALL SELECT invoice FROM stg_ventas_2010_2011) x WHERE invoice IS NULL OR invoice = ''), 0,
       IF((SELECT COUNT(*) FROM (SELECT invoice FROM stg_ventas_2009_2010 UNION ALL SELECT invoice FROM stg_ventas_2010_2011) x WHERE invoice IS NULL OR invoice = '') = 0, 'OK', 'FALLA')
UNION ALL
SELECT '05 Sin retorno de carro (\\r) en country',
       (SELECT COUNT(*) FROM (SELECT country FROM stg_ventas_2009_2010 UNION ALL SELECT country FROM stg_ventas_2010_2011) x WHERE country LIKE '%\r%' OR country LIKE '%"%'), 0,
       IF((SELECT COUNT(*) FROM (SELECT country FROM stg_ventas_2009_2010 UNION ALL SELECT country FROM stg_ventas_2010_2011) x WHERE country LIKE '%\r%' OR country LIKE '%"%') = 0, 'OK', 'FALLA')
UNION ALL
SELECT '06 Fechas interpretadas (no nulas)',
       (SELECT COUNT(*) FROM (SELECT invoice_date FROM stg_ventas_2009_2010 UNION ALL SELECT invoice_date FROM stg_ventas_2010_2011) x WHERE invoice_date IS NULL), 0,
       IF((SELECT COUNT(*) FROM (SELECT invoice_date FROM stg_ventas_2009_2010 UNION ALL SELECT invoice_date FROM stg_ventas_2010_2011) x WHERE invoice_date IS NULL) = 0, 'OK', 'FALLA')
UNION ALL
SELECT '07 Fecha minima correcta',
       (SELECT MIN(DATE(invoice_date)) FROM stg_ventas_2009_2010), '2009-12-01',
       IF((SELECT MIN(DATE(invoice_date)) FROM stg_ventas_2009_2010) = '2009-12-01', 'OK', 'FALLA')
UNION ALL
SELECT '08 Fecha maxima correcta',
       (SELECT MAX(DATE(invoice_date)) FROM stg_ventas_2010_2011), '2011-12-09',
       IF((SELECT MAX(DATE(invoice_date)) FROM stg_ventas_2010_2011) = '2011-12-09', 'OK', 'FALLA')
UNION ALL
SELECT '09 Clientes sin identificar: NULL, no 0',
       (SELECT COUNT(*) FROM (SELECT customer_id FROM stg_ventas_2009_2010 UNION ALL SELECT customer_id FROM stg_ventas_2010_2011) x WHERE customer_id IS NULL), 243007,
       IF((SELECT COUNT(*) FROM (SELECT customer_id FROM stg_ventas_2009_2010 UNION ALL SELECT customer_id FROM stg_ventas_2010_2011) x WHERE customer_id IS NULL) = 243007
          AND (SELECT COUNT(*) FROM (SELECT customer_id FROM stg_ventas_2009_2010 UNION ALL SELECT customer_id FROM stg_ventas_2010_2011) x WHERE customer_id = 0) = 0,
          'OK', 'FALLA')
UNION ALL
SELECT '10 Paises distintos',
       (SELECT COUNT(DISTINCT country) FROM (SELECT country FROM stg_ventas_2009_2010 UNION ALL SELECT country FROM stg_ventas_2010_2011) x), 43,
       IF((SELECT COUNT(DISTINCT country) FROM (SELECT country FROM stg_ventas_2009_2010 UNION ALL SELECT country FROM stg_ventas_2010_2011) x) = 43, 'OK', 'FALLA');

/* ----------------------------------------------------------------------------
   SI ALGO FALLA
   ----------------------------------------------------------------------------
   Chequeo 04/05 en FALLA  -> cargaste con el terminador de linea equivocado.
                              Usa LINES TERMINATED BY '\r\n' y recarga.
   Chequeo 01/02/03 en FALLA -> el separador, el IGNORE 1 LINES o las comillas.
   Chequeo 06/07 en FALLA  -> las fechas no se interpretaron. Formatea la columna
                              InvoiceDate como yyyy-mm-dd hh:mm:ss en Excel ANTES
                              de guardar el CSV, y recarga.
   Chequeo 09 en FALLA     -> los customer_id vacios se guardaron como 0 en lugar
                              de NULL (el cliente falso "0"). Recarga con el
                              patron NULLIF que esta en 00_crear_esquema.sql.
                              ESTE ES EL CHEQUEO MAS IMPORTANTE DEL PROYECTO:
                              con el cliente 0 dentro, tu analisis Pareto y tu RFM
                              apuntan a un cliente que no existe.

   Mientras algo este en FALLA, no se escribe analisis. Nunca.
   ---------------------------------------------------------------------------- */
