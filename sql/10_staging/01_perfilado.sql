/* ============================================================================
   FASE 1 · PERFILADO  —  Proyecto 01 (Online Retail II)
   Archivo : sql/10_staging/01_perfilado.sql
   Motor   : MySQL 8.0
   ----------------------------------------------------------------------------
   COLUMNAS REALES DEL ARCHIVO (no las que usan los tutoriales):
     invoice, stock_code, description, quantity, invoice_date, price,
     customer_id, country
   Ojo: es `invoice` y `price`, NO `InvoiceNo` ni `UnitPrice`.

   OBJETIVO DE ESTA FASE
   Conocer el dato ANTES de limpiarlo. No se limpia lo que no se entiende, y no
   se puede defender un numero que no se sabe de donde sale.

   COMO TRABAJAR ESTE ARCHIVO
   - Cada bloque tiene: la pregunta, el espacio para tu consulta y una linea
     `HALLAZGO:` que TIENES que escribir tu.
   - No copies de internet sin entender: en la entrevista te van a pedir que la
     expliques.
   - Cada decision que tomes se registra en la tabla `dq_reglas`.
   ============================================================================ */

USE portafolio_retail;

/* ============================================================================
   1. VOLUMEN
   Pregunta: cuantas filas tiene cada hoja y cuanto suman entre las dos?
   ============================================================================ */

-- TODO: cuenta las filas de stg_ventas_2009_2010
-- TODO: cuenta las filas de stg_ventas_2010_2011
-- TODO: suma total y comparala con el origen (el Excel lo dice en la hoja)

-- HALLAZGO:
-- Que esperaba:
-- Que encontre:


/* ============================================================================
   2. RANGO TEMPORAL Y SOLAPE  <<< LA PREGUNTA MAS IMPORTANTE DE ESTA FASE
   Pregunta: que periodo cubre cada hoja y se pisan entre ellas?
   Pista   : MIN() y MAX() sobre invoice_date. Para el solape, filtra por el rango
             comun en las dos tablas y compara los conteos.
   ============================================================================ */

-- TODO: MIN(invoice_date) y MAX(invoice_date) por hoja
-- TODO: cuantas facturas de la hoja 1 caen dentro del rango de la hoja 2
-- TODO: cuantas facturas de la hoja 2 caen dentro del rango de la hoja 1
-- TODO: son las MISMAS facturas duplicadas o son facturas distintas?
--       (compara COUNT(DISTINCT invoice) en el rango comun de cada hoja)

-- HALLAZGO:
-- Decision que tomo (que filas elimino y por que):


/* ============================================================================
   3. CALIDAD DE COLUMNAS
   Pregunta: cuantos vacios hay por columna y que representan?
   ============================================================================ */

-- TODO: conteo de nulos de customer_id y su porcentaje sobre el total de filas
-- TODO: conteo de nulos de description
-- TODO: suma de quantity * price de las filas SIN customer_id
--       y que porcentaje representa del ingreso total

-- HALLAZGO:
-- Decision (los excluyo de los analisis de cliente si / no, y por que):


/* ============================================================================
   4. CANCELACIONES Y DEVOLUCIONES
   Pregunta: cuanto de lo que parece venta no es venta?
   Pista   : las facturas canceladas empiezan con 'C'; ademas hay quantity negativa.
   ============================================================================ */

-- TODO: cuantas filas tienen invoice que empieza con 'C' (LIKE 'C%')
-- TODO: cuantas filas tienen quantity < 0 y NO empiezan con 'C'
-- TODO: suma de dinero de cada grupo (quantity * price)

-- HALLAZGO:
-- Definicion que adopto:
--   venta bruta   =
--   devoluciones  =
--   venta neta    =


/* ============================================================================
   5. VALORES IMPOSIBLES O SOSPECHOSOS
   Pregunta: hay cantidades o precios que no pueden ser reales?
   ============================================================================ */

-- TODO: MIN y MAX de quantity y de price
-- TODO: filas con price = 0 y filas con price < 0
-- TODO: la fila (o filas) con quantity mas alta: mirala completa antes de decidir
-- TODO: busca las filas con description tipo 'Adjust bad debt' o 'damaged'/'found'

-- HALLAZGO:
-- Que hago con los valores extremos (los borro / los trato aparte / los dejo) y por que:


/* ============================================================================
   6. CODIGOS QUE NO SON PRODUCTOS
   Pregunta: que valores de stock_code no representan mercancia?
   Pista   : agrupa por stock_code, ordena por numero de facturas y MIRA la lista
             completa. Los codigos administrativos suelen ser cortos o de texto.
   ============================================================================ */

-- TODO: SELECT stock_code, COUNT(DISTINCT invoice) ... GROUP BY ... ORDER BY ...
-- TODO: lista los codigos que no son productos y su impacto en el ingreso

-- HALLAZGO:
-- Lista de codigos excluidos del analisis de producto:


/* ============================================================================
   7. GEOGRAFIA
   Pregunta: cuantos paises hay y como se concentra el ingreso?
   ============================================================================ */

-- TODO: numero de paises distintos
-- TODO: ingreso (neto) por pais, ordenado de mayor a menor, con porcentaje
-- TODO: verifica si un solo pais concentra la gran mayoria del ingreso

-- HALLAZGO:
-- Como voy a agrupar los paises en los graficos y por que:


/* ============================================================================
   8. PATRON TEMPORAL
   Pregunta: que dias y a que horas se factura?
   Pista   : DAYOFWEEK() y HOUR() sobre invoice_date.
   ============================================================================ */

-- TODO: facturacion por dia de la semana
-- TODO: facturacion por hora del dia

-- HALLAZGO:
-- Implicacion para calcular promedios diarios:


/* ============================================================================
   9. GRANO
   Pregunta: cuantas facturas distintas hay y cuantas lineas por factura?
   Pista   : COUNT(DISTINCT invoice) frente a COUNT(*).
   ============================================================================ */

-- TODO: numero de facturas distintas
-- TODO: distribucion de lineas por factura (min, max, promedio)
-- TODO: ticket promedio por factura (agrupa primero por factura y despues promedia)

-- HALLAZGO:
-- Por que NO se puede promediar la columna quantity para hablar de ticket:


/* ============================================================================
   10. CIERRE DE LA FASE 1
   Registra aqui las reglas que decidiste, para pasarlas a la tabla dq_reglas.
   ============================================================================ */

-- TODO: INSERT INTO dq_reglas (nombre, descripcion, filas_afectadas, decision) VALUES
--   ('Solape diciembre 2010', '...', ..., '...'),
--   ('customer_id vacio',     '...', ..., '...'),
--   ('Facturas canceladas',   '...', ..., '...'),
--   ('stock_code no producto','...', ..., '...');
