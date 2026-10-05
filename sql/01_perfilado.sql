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

-- TODO


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

-- TODO
