# Diccionario de datos

**Fuente:** Online Retail II (UCI ML Repository) · **Grano:** 1 fila = un producto dentro de una factura
**Volumen cargado:** 1.067.371 filas (hoja 2009-2010: 525.461 · hoja 2010-2011: 541.910)

---

## Columnas

> El archivo original nombra los campos en CamelCase (`Invoice`, `Customer ID`). En la base de datos
> van en minúscula y con guion bajo. **Al escribir SQL se usa el nombre de la base.**

| Columna original | En la base | Tipo | Qué es | Problemas conocidos |
|---|---|---|---|---|
| `Invoice` | `invoice` | texto | Número de factura | Si empieza con **`C`** es una cancelación, no una venta |
| `StockCode` | `stock_code` | texto | Código de producto | Hay códigos que **no son productos**: `POST`, `D`, `M`, `BANK CHARGES`, `DOT`, `CRUK`, `PADS`, `AMAZONFEE`, `S`, `ADJUST`, `GIFT`, `DCGS*` |
| `Description` | `description` | texto | Nombre del producto | 4.382 vacíos. El mismo código aparece con descripciones distintas |
| `Quantity` | `quantity` | entero | Unidades de la línea | Negativo = devolución. Rango: −80.995 a 80.995 |
| `InvoiceDate` | `invoice_date` | fecha-hora | Fecha y hora de la factura | Formato de origen `m/d/yy h:mm`: **se corrompe si se carga sin convertir** |
| `Price` | `price` | decimal | Precio unitario (GBP) | 6.202 filas en 0 (cortesías). 5 filas negativas (ajustes contables) |
| `Customer ID` | `customer_id` | entero | Identificador del cliente | **243.007 vacíos (22,77%)**. Si se cargan directo se convierten en `0` |
| `Country` | `country` | texto | País del cliente | 43 países. Reino Unido concentra la mayor parte del ingreso |

---

## Notas de calidad del dato

Cuatro problemas verificados sobre el archivo original. Cada uno tiene su decisión documentada en el
[README](../README.md#método-decisiones-tomadas).

**1. Las dos hojas se solapan.** La hoja `Year 2009-2010` llega hasta el 2010-12-09 y `Year 2010-2011`
empieza el 2010-12-01. En esos nueve días hay **22.523 filas en cada hoja**: el mismo periodo contado
dos veces.

**2. Facturas canceladas.** 19.494 filas tienen un `invoice` que empieza con `C`, y 22.950 tienen
`quantity` negativa. Sumar sin separarlas mezcla venta con devolución.

**3. Duplicados exactos.** Hay decenas de miles de filas repetidas carácter por carácter dentro de una
misma hoja. Antes de eliminarlas hay que decidir qué significan en este negocio.

**4. `customer_id` vacío.** El campo llega vacío en el 22,77% de las filas. Al cargarlo directo a una
columna numérica, MySQL lo convierte en `0` y crea un cliente inexistente con ~243.000 filas y alrededor
de 1,7 millones de libras de facturación.

---

## Los tres estados de un campo

No son lo mismo, y en este dataset el detalle decide una de las decisiones de limpieza.

| Estado | Qué es | En esta tabla |
|---|---|---|
| `NULL` | **ausencia de valor**: se desconoce | los `customer_id` sin identificar y las `description` sin nombre |
| cadena vacía `''` | **un valor**: texto de longitud 0 | ninguno: se convirtieron a `NULL` durante la carga |
| `0` | **un valor numérico real** | ninguno: aparecerían si la carga no usara `NULLIF` |

- `NULL` no es igual a nada, ni siquiera a otro `NULL`. `COUNT(columna)` lo ignora; `COUNT(*)` no.
- La cadena vacía **sí es un valor**: `'' = ''` es verdadero y `COUNT(columna)` la cuenta.
- Una columna **numérica** no puede guardar una cadena vacía: el motor la convierte en `0` o en `NULL`. En `customer_id` solo puede haber `NULL`, `0` o un id real. En `description` (texto) puede haber `NULL` **y** `''`.
- Por eso, cuando en la documentación se lee "el campo llega vacío", significa **vacío en el CSV de origen**, no `NULL` en la base.

---

## Valores de referencia

Sirven para comprobar que la carga quedó bien.

| Métrica | Valor |
|---|---|
| Filas totales | 1.067.371 |
| `customer_id` vacíos | 243.007 |
| `description` vacíos | 4.382 |
| Países distintos | 43 |
| Facturas que empiezan con `C` | 19.494 |
| Fecha mínima / máxima | 2009-12-01 / 2011-12-09 |
