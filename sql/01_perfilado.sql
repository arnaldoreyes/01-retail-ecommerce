/* ============================================================================
   01_perfilado.sql  —  Verifica la carga y explora el dato.
   ----------------------------------------------------------------------------
   Se ejecuta despues de 00_carga.sql. El objetivo es conocer el dato antes de
   analizarlo: cuantos nulos hay, donde esta el solape entre hojas, que valores
   son imposibles y que codigos no son productos.
   ============================================================================ */

USE portafolio_retail;

/* ============================================================================
   1. INTEGRIDAD DE LA CARGA
   Si algo falla aqui, la carga esta mal y no tiene sentido seguir.
   ============================================================================ */

SELECT '01 Filas totales' AS chequeo,
       (SELECT COUNT(*) FROM ventas) AS obtenido, 1067371 AS esperado,
       IF((SELECT COUNT(*) FROM ventas) = 1067371, 'OK', 'FALLA') AS resultado
UNION ALL
SELECT '02 Filas por hoja',
       (SELECT COUNT(*) FROM ventas WHERE hoja = '2009-2010'), 525461,
       IF((SELECT COUNT(*) FROM ventas WHERE hoja = '2009-2010') = 525461, 'OK', 'FALLA')
UNION ALL
SELECT '03 Cliente falso 0 (debe ser 0)',
       (SELECT COUNT(*) FROM ventas WHERE customer_id = 0), 0,
       IF((SELECT COUNT(*) FROM ventas WHERE customer_id = 0) = 0, 'OK', 'FALLA')
UNION ALL
SELECT '04 Clientes sin identificar',
       (SELECT COUNT(*) FROM ventas WHERE customer_id IS NULL), 243007,
       IF((SELECT COUNT(*) FROM ventas WHERE customer_id IS NULL) = 243007, 'OK', 'FALLA')
UNION ALL
SELECT '05 Fechas dentro del rango real',
       (SELECT COUNT(*) FROM ventas
         WHERE invoice_date IS NULL OR invoice_date < '2009-12-01' OR invoice_date > '2011-12-10'), 0,
       IF((SELECT COUNT(*) FROM ventas
            WHERE invoice_date IS NULL OR invoice_date < '2009-12-01' OR invoice_date > '2011-12-10') = 0, 'OK', 'FALLA')
UNION ALL
SELECT '06 Fecha minima',
       (SELECT MIN(DATE(invoice_date)) FROM ventas), '2009-12-01',
       IF((SELECT MIN(DATE(invoice_date)) FROM ventas) = '2009-12-01', 'OK', 'FALLA')
UNION ALL
SELECT '07 Fecha maxima',
       (SELECT MAX(DATE(invoice_date)) FROM ventas), '2011-12-09',
       IF((SELECT MAX(DATE(invoice_date)) FROM ventas) = '2011-12-09', 'OK', 'FALLA')
UNION ALL
SELECT '08 Sin retorno de carro ni comillas en country',
       (SELECT COUNT(*) FROM ventas WHERE country LIKE '%\r%' OR country LIKE '%"%'), 0,
       IF((SELECT COUNT(*) FROM ventas WHERE country LIKE '%\r%' OR country LIKE '%"%') = 0, 'OK', 'FALLA')
UNION ALL
SELECT '09 Paises distintos',
       (SELECT COUNT(DISTINCT country) FROM ventas), 43,
       IF((SELECT COUNT(DISTINCT country) FROM ventas) = 43, 'OK', 'FALLA');

/* ============================================================================
   2. SOLAPE ENTRE LAS DOS HOJAS
   ============================================================================ */
-- Revisar el rango de fechas de la tabla ventas para cada periodo
SELECT MIN(invoice_date), MAX(invoice_date), hoja FROM ventas GROUP BY hoja;
-- Numero de filas que tienen filas repetidas por el rango de fecha presente en las 2 hojas
SELECT DATE(invoice_date) AS fecha, hoja, COUNT(*) FROM ventas WHERE DATE(invoice_date) BETWEEN '2010-12-01' AND '2010-12-09'  GROUP BY hoja, DATE(invoice_date);
-- Verificar si hay fechas unicas
SELECT DATE(invoice_date) AS fecha, hoja FROM ventas GROUP BY hoja, DATE(invoice_date) HAVING COUNT(*) = 1; 
-- Verificar si las facturas presentes en las fechas repetidas son las mismas
SELECT DATE(invoice_date), COUNT(DISTINCT invoice), ROUND(sum(quantity*price), 2), hoja FROM ventas WHERE DATE(invoice_date) BETWEEN '2010-12-01' AND '2010-12-09'  GROUP BY hoja, DATE(invoice_date);
-- Numero de filas repetidas en cada hoja correspondientes al numero de fechas
SELECT hoja, COUNT(*) FROM ventas WHERE DATE(invoice_date) BETWEEN '2010-12-01' AND '2010-12-09'  GROUP BY hoja;

-- Son 8 dias de cruce que tienen ambas hojas (IMPORTANTE: El dia 2010-12-04 no hay registro de facturacion/ventas)
-- 22.523 Filas duplicadas en total
-- Son las mismas facturas: mismo numero, mismo dinero.

CREATE VIEW ventas_sin_superposicion AS
SELECT * FROM ventas 
WHERE NOT (DATE(invoice_date) BETWEEN '2010-12-01' AND '2010-12-09' AND hoja = '2010-2011');

/* ============================================================================
   3. CALIDAD DE LAS COLUMNAS
   ============================================================================ */

-- TODO


/* ============================================================================
   4. CANCELACIONES Y DEVOLUCIONES
   ============================================================================ */

-- TODO


/* ============================================================================
   5. VALORES EXTREMOS
   ============================================================================ */

-- TODO


/* ============================================================================
   6. CODIGOS QUE NO SON PRODUCTOS
   ============================================================================ */

-- TODO


/* ============================================================================
   7. GEOGRAFIA
   ============================================================================ */

-- TODO


/* ============================================================================
   8. PATRON TEMPORAL
   ============================================================================ */

-- TODO


/* ============================================================================
   9. GRANO
   ============================================================================ */

-- TODO


/* ============================================================================
   10. REGLAS DE LIMPIEZA QUE DECIDI
   Cada decision que tome, con las filas que afecta y el motivo.
   ============================================================================ */

-- Regla: descartar la copia de la hoja 2010-2011 en los 8 días del cruce.
-- Afecta a 22.523 filas. Resultado: 1.044.848.


