# Análisis comercial de un retailer online

**Proyecto 1 de 3** de mi portafolio como Analista de Datos Junior · **Estado:** en construcción
**Herramientas:** MySQL · Excel · Power BI

---

## El problema

Un retailer mayorista de regalos y artículos de hogar (Reino Unido) factura varios millones de libras al año y vende a más de 40 países. Su gerente comercial tiene una intuición incómoda: _"veo pedidos todas las semanas, pero también veo devoluciones y clientes que compraron una vez y nunca volvieron. No sé quién me sostiene el negocio ni a quién estoy a punto de perder"_.

**Pregunta central:** ¿cuál es la facturación **neta** real, qué clientes la sostienen y qué parte de esa facturación está en riesgo de fuga?

---

## Los datos

|              |                                                                                                                |
| ------------ | -------------------------------------------------------------------------------------------------------------- |
| **Fuente**   | [Online Retail II — UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii) |
| **Licencia** | CC BY 4.0                                                                                                      |
| **Volumen**  | 1.067.371 líneas de factura · 2 hojas de Excel                                                                 |
| **Periodo**  | 2009-12-01 → 2011-12-09                                                                                        |
| **Grano**    | 1 fila = un producto dentro de una factura                                                                     |
| **Moneda**   | Libra esterlina (GBP)                                                                                          |

Diccionario de columnas y notas de calidad del dato: [`docs/diccionario-de-datos.md`](docs/diccionario-de-datos.md)

**Cita:** Chen, D. (2012). _Online Retail II_ [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5CG6D

---

## Preguntas a responder

1. ¿Cuál es la facturación neta real y cómo evoluciona mes a mes?
2. ¿Cuántos clientes sostienen el negocio y cómo se concentra el ingreso?
3. ¿Qué clientes están en riesgo de fuga y cuánto ingreso representan?
4. ¿Los clientes vuelven, o el crecimiento depende de captar clientes nuevos?
5. ¿Qué productos atraen la primera compra y cuáles se venden juntos?
6. ¿Qué mercados fuera del Reino Unido vale la pena mantener?

---

## Método: decisiones tomadas

Cada decisión que cambia un número, con la alternativa que se descartó.

| Decisión | Alternativa descartada | Por qué |
|---|---|---|
| Las fechas se convierten durante la carga con `STR_TO_DATE` | Cargarlas directo a la columna `DATETIME` | El CSV exportado desde Excel trae el formato `m/d/yy h:mm` y MySQL lo interpreta mal **sin dar error**: `12/1/09` se guarda como `2012-01-09`. Verificado en MySQL 8.0.46 |
| Los `customer_id` vacíos se cargan como `NULL` con `NULLIF` | Dejarlos como vienen | Cargados directo a una columna numérica, MySQL los convierte en `0` e inventa un cliente con ~243.000 filas y 1,7 millones de libras |
| _pendiente_ | | |

---

## Hallazgos

 1. Son 8 dias de cruce que tienen ambas hojas (IMPORTANTE: El dia 2010-12-04 no hay registro de facturacion/ventas)
 2. 22.523 Filas duplicadas en total
 3. Son las mismas facturas: mismo numero, mismo dinero.
 4. Ambas copias son idénticas: mismo número de facturas y mismo importe. Conservo una sola, la de la hoja 2009-2010, porque en esa hoja esos días cierran su periodo. Si se mantuvieran las dos, toda cifra de 2010-2011 quedaría duplicada.

---

## Cómo reproducirlo

```bash
# 1. Clonar
git clone https://github.com/arnaldoreyes/01-retail-ecommerce.git
cd 01-retail-ecommerce

# 2. Descargar el dataset desde el enlace de la fuente (ver arriba) y guardar
#    online_retail_II.xlsx en data/raw/

# 3. Abrir el archivo en Excel y guardar cada hoja como CSV UTF-8 en data/limpio/
#      Year 2009-2010  ->  data/limpio/ventas_2009_2010.csv
#      Year 2010-2011  ->  data/limpio/ventas_2010_2011.csv
#    No hace falta formatear las fechas: el script de carga las convierte.

# 4. Crear la tabla y cargar las dos hojas
#    MySQL Workbench > File > Open SQL Script... > sql/00_carga.sql

# 5. Verificar la carga y perfilar
#    sql/01_perfilado.sql
```

**Requisitos:** MySQL 8.0 + MySQL Workbench · Excel · Power BI Desktop

---

## Estructura del repositorio

```
├── README.md                    este archivo: problema, datos, decisiones y hallazgos
├── CHANGELOG.md
├── docs/
│   └── diccionario-de-datos.md  qué significa cada columna y qué problemas tiene
├── data/
│   ├── raw/                     dataset original (no se versiona)
│   └── limpio/                  CSV exportados desde Excel para cargar
├── sql/
│   ├── 00_carga.sql             crea la tabla y carga las dos hojas
│   └── 01_perfilado.sql         verifica la carga y explora el dato
├── excel/                       análisis de apoyo
└── powerbi/                     dashboard
```

---

## Supuestos y limitaciones

- El dataset **no incluye costo de producto**: se analiza ingreso, no margen ni utilidad.
- Las líneas sin `customer_id` no se pueden atribuir a un cliente.
- El periodo termina el 9 de diciembre de 2011: **diciembre está incompleto**.
- Un único retailer mayorista del Reino Unido: los resultados **no son extrapolables**.

---

**Autor:** Arnaldo Reyes · Licencia [MIT](LICENSE)
