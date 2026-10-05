# 01 — Contexto de negocio y dataset

> Documento de referencia. Se lee **antes** de escribir una sola línea de SQL.
> Si no entiendes el negocio, tus queries pueden ser técnicamente perfectas y comercialmente inútiles.

---

## 1. El cliente y su dolor

**Quién es:** Gerente Comercial de un retailer online mayorista de regalos y artículos de hogar, con sede en el Reino Unido y facturación de varios millones de libras al año.

**Qué le quita el sueño:**
- Sospecha que la "facturación" que ve en su sistema está inflada: incluye pedidos que luego se cancelan y devoluciones.
- No sabe si su crecimiento es **más clientes** o **los mismos clientes comprando más**. Son dos negocios distintos y requieren estrategias opuestas.
- Tiene la intuición de que un puñado de clientes sostiene la operación, pero no lo puede demostrar.
- Cree que está perdiendo clientes buenos sin darse cuenta, y que se enterará cuando ya sea tarde.
- Está pagando envíos internacionales a 40 países sin saber cuáles dejan dinero.

**Qué decisión tiene que tomar** (esto es lo que define si tu análisis sirve o no):
1. ¿Dónde poner el esfuerzo del equipo comercial: **retener** o **captar**?
2. ¿A qué lista de clientes llamar este mes?
3. ¿Qué mercados internacionales mantener y cuáles abandonar?

**Cómo se mide el éxito del análisis:** que el gerente pueda decir *"llama a estos 300 clientes, no a estos otros"* con una razón en la mano.

---

## 2. La fuente de datos

| | |
|---|---|
| **Nombre** | Online Retail II |
| **Origen** | UCI Machine Learning Repository, dataset id 502 |
| **URL** | https://archive.ics.uci.edu/dataset/502/online+retail+ii |
| **Licencia** | CC BY 4.0 — se puede usar y compartir citando la fuente |
| **Archivo** | `online_retail_II.xlsx` (43,5 MB) |
| **Hojas** | `Year 2009-2010` (525.461 filas) y `Year 2010-2011` (541.910 filas) |
| **Periodo** | 2009-12-01 → 2011-12-09 |
| **Filas totales** | 1.067.371 líneas de factura |
| **País** | Reino Unido (ventas a más de 40 países) |
| **Moneda** | Libra esterlina (GBP) |

**Cita obligatoria (va en el README):**
> Chen, D. (2012). *Online Retail II* [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5CG6D

---

## 3. Grano de la tabla (lo primero que debes saber)

**1 fila = 1 producto dentro de 1 factura.**

Esto significa que:
- Una factura con 5 productos distintos ocupa **5 filas**.
- `COUNT(*)` **no** es el número de pedidos. Es el número de líneas.
- `COUNT(DISTINCT invoice)` sí es el número de facturas.
- Si quieres "ticket promedio", tienes que **agregar primero por factura** y recién después promediar. Si promedias la columna `quantity`, estás calculando otra cosa.

Este solo concepto es el error más común de los juniors y el que más preguntas genera en una entrevista técnica.

---

## 4. Diccionario de columnas

> ⚠️ **Los nombres reales de los campos son `invoice` y `price`.** La mayoría de los tutoriales de internet usan `InvoiceNo` y `UnitPrice`, porque trabajan con la versión **antigua** de este dataset (una sola hoja, año 2010-2011). Si copias código de ahí sin cambiar los nombres, no te va a correr. Es la primera trampa del proyecto y la vas a encontrar en los primeros 10 minutos.

| Columna original | Nombre en la base | Tipo | Qué es | Ojo con |
|---|---|---|---|---|
| `Invoice` | `invoice` | texto | Número de factura, 6 dígitos | Si empieza con **`C`** es una **cancelación**, no una venta |
| `StockCode` | `stock_code` | texto | Código del producto | También hay códigos que **no son productos**: `POST`, `D`, `M`, `BANK CHARGES`, `DOT`, `CRUK`, `PADS`, `AMAZONFEE`, `S`, `gift_0001_*` |
| `Description` | `description` | texto | Nombre del producto | Tiene nulos y variantes del mismo producto (mayúsculas, espacios) |
| `Quantity` | `quantity` | entero | Unidades en la línea | **Negativo** = devolución o cancelación. No es un error de carga |
| `InvoiceDate` | `invoice_date` | fecha-hora | Fecha y hora de la factura | Hora incluida: sirve para analizar patrones horarios |
| `Price` | `price` | decimal | Precio unitario en GBP | `0` = muestra o cortesía (no es ingreso). Hay negativos (ajustes contables) |
| `Customer ID` | `customer_id` | entero | Identificador del cliente | **22,8% de las filas están vacías** (243.007). Es la decisión más importante del proyecto |
| `Country` | `country` | texto | País de residencia del cliente | Reino Unido concentra la gran mayoría del ingreso |

**Referencia de volumen ya verificada** (te sirve para saber si cargaste bien):

| Métrica | Valor real |
|---|---|
| Filas hoja 2009-2010 | 525.461 |
| Filas hoja 2010-2011 | 541.910 |
| Total | **1.067.371** |
| Nulos en `customer_id` | 243.007 (22,77%) |
| Nulos en `description` | 4.382 (0,41%) |

**Campos que NO existen y te van a hacer falta:** costo del producto, margen, método de pago, canal de adquisición, fecha de entrega, motivo de devolución. Cuando el cliente pida "rentabilidad" o "costo", tendrás que **declarar el supuesto** y ser explícito en que es un proxy.

---

## 5. Trampas conocidas (esto es lo que separa tu análisis de un tutorial)

Cada punto es una decisión que **debes** tomar, documentar en `docs/03-bitacora.md` y reflejar en `dq_reglas`.

1. **Los nombres de las columnas no son los que verás en los tutoriales.** Aquí son `invoice` y `price`; en la versión antigua del dataset son `InvoiceNo` y `UnitPrice`. Verifica los nombres **antes** de escribir consultas, en cualquier dataset que recibas. Es un hábito profesional, no un detalle.

2. **Las dos hojas se solapan.** La hoja `Year 2009-2010` llega hasta el **9 de diciembre de 2010** y la hoja `Year 2010-2011` empieza el **1 de diciembre de 2010**. Si concatenas las dos sin filtrar, **duplicas** esos días e inflas la facturación. → Verifícalo tú, cuantifica cuántas filas son y decide con qué criterio eliminas el solape.

3. **`invoice` con `C` = cancelación.** Son facturas que se anularon. Si sumas `quantity` sin separarlas, mezclas venta con devolución. Lo correcto es calcular **venta bruta** y **devoluciones** por separado, y de ahí la **venta neta**.

4. **`customer_id` vacío (22,8% de las líneas).** No son "clientes invitados": en un mayorista son, casi siempre, ventas de mostrador o pedidos sin cuenta. Si los eliminas, pierdes ingresos reales; si los dejas, arruinas cualquier análisis por cliente. → **Decisión obligatoria:** justifica si los excluyes de los análisis de cliente (no de los de facturación) y cuánto ingreso representan.

5. **`description` nulo o inconsistente.** Un mismo `stock_code` puede aparecer con descripciones distintas. Agrupa siempre por `stock_code`, nunca por `description`.

6. **`price` = 0** en facturas de cortesía/regalo o en cargos manuales. Si multiplicas sin filtrar, esos productos "no valen nada" pero sí tienen costo.

7. **`stock_code` que no son productos:** cargos postales, descuentos manuales, comisiones de Amazon, ajustes. Si no los separas, aparecen como "los productos más vendidos" y contaminas el ranking.

8. **Ajustes contables con valores extremos:** existe al menos una línea con `quantity` enorme y un ajuste negativo de miles de libras ("bad debt adjustment"). **No la borres por ser rara**: identifícala y trátala aparte, documentando el motivo.

9. **Diciembre de 2011 está incompleto** (corta el día 9) y además el negocio tiene estacionalidad navideña. Nunca compares diciembre 2011 contra diciembre 2010 sin advertirlo.

10. **Fines de semana casi sin facturas.** Es un negocio B2B: opera de lunes a viernes. Un "promedio diario" calculado sobre 7 días está mal; debe ser sobre días hábiles.

11. **Reino Unido domina.** Cualquier gráfico de "ventas por país" sin separar UK se ve plano e ilegible. UK va aparte; el resto del mundo, en su propio gráfico.

12. **Hay decenas de miles de líneas duplicadas exactas dentro de una misma hoja.** Antes de borrarlas, decide **qué significa** un duplicado en este negocio: ¿es un error del sistema o son dos líneas reales del mismo producto en la misma factura? Tu respuesta cambia el total de facturación y tienes que poder defenderla. Lo que **no** puedes hacer es borrarlas en silencio: eso es maquillar los datos.

13. **Las líneas administrativas tienen importes enormes y negativos.** Existen cargos como el ajuste por deuda incobrable (*bad debt adjustment*) con importes de decenas de miles de libras, y líneas con `quantity` de ±80.995. No son datos corruptos: son apuntes contables. Si los mezclas con las ventas, tu ticket promedio y tu ranking de productos quedan contaminados. Identifícalos y trátalos en una consulta aparte.

14. **Los códigos que no son productos son más de los que parecen.** No basta con filtrar los obvios (`POST`, `M`, `D`): hay **al menos una docena** de códigos distintos que no representan mercancía, y varios no son evidentes a simple vista. Si tu filtro se queda corto, se cuelan en el top de productos más vendidos. Encontrarlos todos es parte de la Fase 1.

---

## 6. Cómo cargar los datos

**Motor del proyecto: MySQL 8.0 con MySQL Workbench** (ya está instalado y el servicio está corriendo).

1. Copia `online_retail_II.xlsx` desde `_datasets/online-retail-ii/` a `data/raw/`.
2. Abre el archivo en Excel y guarda **cada hoja** como CSV UTF-8 en `data/staging/`. Son ~500.000 filas por hoja: guarda en `.csv`, nunca en `.xlsx`.
3. En MySQL Workbench, abre y ejecuta `sql/00_setup/00_crear_esquema.sql`. Eso crea la base `portafolio_retail` y las tablas `stg_ventas_2009_2010`, `stg_ventas_2010_2011` y `dq_reglas`.
4. Carga cada CSV con el **Table Data Import Wizard** (clic derecho sobre la tabla → Table Data Import Wizard) o con `LOAD DATA LOCAL INFILE` (el script trae el ejemplo exacto). Acuérdate de mapear `Customer ID` al campo `customer_id`. Carga **todo como texto** en esta primera pasada: no quieres que el motor decida los tipos por ti.
5. **Verifica el conteo de filas** después de cada carga y anótalo en `dq_reglas`. Los números correctos están en la tabla de la sección 4.
6. En la Fase 2 conviertes los tipos definitivos y registras cuántas filas fallaron.

**Por qué no cargar los datos desde Power BI:** sirve para el dashboard, pero **no** para aprender SQL. El objetivo del proyecto es demostrar que modelas en base de datos; usa MySQL y deja Power BI para la Fase 4.

---

## 7. Las preguntas que yo (como tu revisor técnico) te voy a hacer

Tenlas presentes desde la Fase 1; las vas a responder en el README y en la entrevista:

1. ¿Cuál es el grano de tu tabla de hechos y por qué?
2. ¿Qué hiciste con los `customer_id` nulos y cuánto ingreso representan?
3. ¿Por qué tu "total de ventas" es distinto al que sale de sumar `quantity * price` sin filtros? ¿Cuál es el correcto y por qué?
4. ¿Cómo detectaste el solape de diciembre de 2010? ¿Qué evidencia tienes y cuántas filas eran?
5. ¿Cómo validaste tus totales? ¿Contra qué segundo número los comparaste?
6. Tu segmento "clientes en riesgo": ¿qué definición usaste y por qué esa y no otra?
7. Si el gerente te dice "estos números no me cuadran con mi sistema", ¿qué le respondes?
8. ¿Cómo supiste que las columnas se llamaban `invoice` y `price` y no lo que dice internet? *(Pregunta real de entrevista: evalúa si verificas o si asumes.)*
