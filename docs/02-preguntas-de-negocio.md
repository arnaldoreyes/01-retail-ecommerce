# 02 — Preguntas de negocio (el backlog del proyecto)

> Estas son las preguntas que el cliente pidió responder. Cada una es **una rama de Git**, un PR y un entregable.
> No se avanza a la siguiente sin cerrar la anterior: eso es lo que hace que el repo se vea como trabajo profesional y no como un volcado de archivos.

**Regla de oro:** si la respuesta a una pregunta no cambia ninguna decisión del negocio, la pregunta no vale la pena. No la incluyas.

> **Dos aclaraciones antes de empezar**
> 1. Los archivos que aparecen como *Entregable* (`sql/30_analisis/...`) **todavía no existen**: se crean en la Fase 3. Son el destino de cada pregunta, no un enlace roto.
> 2. Los nombres que verás escritos como en el archivo original — `Customer ID`, `StockCode`, `Description`, `InvoiceNo`, `UnitPrice` — se llaman en la base **`customer_id`, `stock_code`, `description`, `invoice`, `price`**. El mapeo completo está en [`docs/01-contexto-y-dataset.md`](01-contexto-y-dataset.md). **Cuando escribas SQL, usa siempre el nombre de la base.**

---

## Estructura de cada pregunta

| Campo | Qué significa |
|---|---|
| **Pregunta del cliente** | Cómo la dijo él, sin jerga técnica |
| **Decisión que cambia** | Si no hay decisión, no hay proyecto |
| **Entregable** | El archivo concreto que cierra la pregunta |
| **KPI / medida** | Con fórmula y grano |
| **Trampa** | Dónde se equivoca la mayoría |
| **Criterio de aceptación** | Cómo sé que está bien hecho |

---

## P1 — ¿Cuál es nuestra facturación neta real y cómo evoluciona?

- **Pregunta del cliente:** *"El sistema me dice que vendí X. Yo quiero saber cuánto me quedó de verdad, después de cancelaciones y devoluciones, y si estoy creciendo o solo me muevo."*
- **Decisión que cambia:** si fija el objetivo de venta del próximo trimestre sobre cifras brutas o netas.
- **Entregable:** `sql/30_analisis/10_kpis_comerciales.sql` + gráfico de evolución mensual en el dashboard.
- **KPI:** `Venta bruta = SUM(quantity * price)` sobre ventas · `Devoluciones = SUM(...)` sobre facturas `C` y cantidades negativas · `Venta neta = bruta - devoluciones` · `Tasa de devolución = devoluciones / bruta`.
- **Grano:** mes × país. Además, versión por semana para ver la tendencia fina.
- **Trampa:** no separar cancelaciones; comparar diciembre 2011 (incompleto) contra diciembre 2010; contar líneas de ajuste contable como ventas.
- **Criterio de aceptación:** la venta neta está validada contra un segundo cálculo (una tabla dinámica en Excel) y la diferencia es cero o está explicada.

---

## P2 — ¿Quiénes son mis clientes que sostienen el negocio? (Pareto)

- **Pregunta del cliente:** *"Sospecho que unos pocos clientes me pagan la nómina. Quiero saber cuántos son y con nombre y apellido."*
- **Decisión que cambia:** a quién le asigna el equipo comercial y a quién le da condiciones preferentes.
- **Entregable:** `sql/30_analisis/20_pareto_clientes.sql` + tabla de clientes ordenados por venta neta con % acumulado.
- **KPI:** `% del ingreso que aporta el top 10 / 20 / 50` · `Ingreso acumulado (running total)` · `Índice de concentración`.
- **Grano:** cliente.
- **Trampa:** calcular el Pareto sobre las líneas sin haber decidido antes qué es "venta neta"; ordenar por número de pedidos en lugar de por ingreso; no excluir los `customer_id` nulos (en el archivo original, `Customer ID`) y luego preguntarse por qué el total no cuadra.
- **Criterio de aceptación:** puedes decir en una frase *"N clientes = X% del ingreso"* y el acumulado cierra en 100%.

---

## P3 — ¿Qué clientes están en riesgo de fuga? (segmentación RFM)

- **Pregunta del cliente:** *"Quiero una lista de a quién llamar este mes. Los buenos que se están enfriando, no los que ya se fueron."*
- **Decisión que cambia:** la lista de llamadas del equipo comercial del próximo mes.
- **Entregable:** `sql/30_analisis/30_rfm.sql` + segmentos en el dashboard + CSV exportable de la lista.
- **KPI:** `Recencia` (días desde la última compra) · `Frecuencia` (nº de facturas distintas) · `Monetario` (venta neta total) · puntaje R/F/M de 1 a 5 · segmento.
- **Grano:** cliente, con **fecha de corte fija** (documentada en el script: no puede ser `MAX(fecha)` "flotante", o el análisis no es reproducible).
- **Trampa:** calcular RFM sin fijar la fecha de corte; no separar devoluciones (un cliente que devuelve todo aparece como "campeón"); usar cuantiles cuando hay demasiados clientes de una sola compra (la mayoría); olvidar que este es un **mayorista**: una frecuencia de 2 veces al año puede ser perfectamente normal y no "riesgo".
- **Criterio de aceptación:** cada segmento tiene una definición escrita, un número de clientes y su ingreso asociado. Y puedes defender por qué elegiste esos cortes.

---

## P4 — ¿Los clientes vuelven? (retención por cohortes)

- **Pregunta del cliente:** *"¿Estoy creciendo porque entran clientes nuevos o porque los que tengo repiten? Porque si es lo primero, estoy llenando un balde agujereado."*
- **Decisión que cambia:** repartir presupuesto entre captación y retención.
- **Entregable:** `sql/30_analisis/40_cohortes.sql` + heatmap de retención en Power BI.
- **KPI:** `Tasa de recompra` · `Retención por cohorte (mes de primera compra × mes N)`.
- **Grano:** cohorte (mes de primera compra del cliente) × mes de actividad.
- **Trampa:** confundir *retención* (sigue comprando) con *supervivencia* (no se ha ido); y en un mayorista con compras esporádicas, mirar meses en lugar de **trimestres** hace que todo parezca fuga.
- **Criterio de aceptación:** la diagonal de la cohorte más antigua es coherente con los datos crudos y sabes explicar el efecto de diciembre.

---

## P5 — ¿Qué productos son la puerta de entrada y cuáles se venden juntos?

- **Pregunta del cliente:** *"Quiero saber qué producto hace que un cliente nuevo me compre, y qué combino en las promociones."*
- **Decisión que cambia:** qué producto promocionar para captar y cómo armar los packs.
- **Entregable:** `sql/30_analisis/50_productos.sql` + top de productos por primera compra.
- **KPI:** `% de clientes cuya primera compra incluyó el producto` · `Pares de productos en la misma factura (co-ocurrencia)`.
- **Grano:** `stock_code` (en el archivo original: `StockCode`).
- **Trampa:** agrupar por `description` en lugar de `stock_code`; incluir los códigos que **no son productos** (`POST`, `BANK CHARGES`, etc.); interpretar co-ocurrencia como recomendación sin mirar el volumen (dos productos raros que coinciden una vez aparecen como "el par estrella").
- **Criterio de aceptación:** el ranking excluye los códigos administrativos y cada par reportado tiene un mínimo de facturas en común (define el umbral).

---

## P6 — ¿Vale la pena vender fuera del Reino Unido?

- **Pregunta del cliente:** *"Estoy pagando envíos a medio mundo. ¿Cuáles de esos mercados me dejan algo y cuáles debería cortar?"*
- **Decisión que cambia:** qué mercados internacionales se mantienen y cuáles se abandonan.
- **Entregable:** `sql/30_analisis/60_mercados.sql` + tabla país / ingreso / clientes / ticket / devoluciones.
- **KPI:** `Venta neta por país` · `Nº de clientes por país` · `Ticket promedio` · `Tasa de devolución por país`.
- **Grano:** país (con UK aparte, siempre).
- **Trampa:** **el dataset no tiene costos de envío ni de producto.** No puedes calcular rentabilidad real. Tienes que decirlo explícitamente y usar proxies declarados (volumen, ticket, devoluciones) en lugar de inventar un margen. *Este punto es el que demuestra madurez analítica y es exactamente lo que te van a preguntar en la entrevista.*
- **Criterio de aceptación:** en el README está escrito, en una línea, qué **no** se puede concluir con estos datos y por qué.

---

## Orden de ejecución y ramas

| # | Pregunta | Rama | Fase |
|---|---|---|---|
| 1 | Facturación neta | `feature/fase-3-venta-neta` | 3 |
| 2 | Pareto de clientes | `feature/fase-3-pareto` | 3 |
| 3 | RFM | `feature/fase-3-rfm` | 3 |
| 4 | Cohortes | `feature/fase-3-cohortes` | 3 |
| 5 | Productos | `feature/fase-3-productos` | 3 |
| 6 | Mercados | `feature/fase-3-mercados` | 3 |

> Si el tiempo aprieta, el orden de prioridad es: **1 → 3 → 2 → 4 → 6 → 5**.
> Un proyecto con 4 preguntas respondidas a fondo vale más que uno con 6 a medias.
