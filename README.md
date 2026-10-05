# Fuga de clientes y rentabilidad real — Online Retail II

**Proyecto 1 de 3** de mi portafolio como **Analista de Datos Junior**.
Análisis de 1.067.371 líneas de factura de un retailer online del Reino Unido (diciembre 2009 – diciembre 2011) con **SQL, Excel y Power BI**.

**Estado:** 🟡 En construcción — ver [avance por fases](#avance-por-fases)

---

## 1. El problema de negocio

> *"Llevamos dos años con la sensación de que crecemos, pero no sé si eso es real. Veo pedidos cada semana y también veo devoluciones. Tengo clientes que compraron una vez y nunca volvieron, y clientes que me compran todos los meses. No sé quién me está sosteniendo el negocio, ni a quién estoy a punto de perder. Y necesito saber si vale la pena seguir vendiendo fuera del Reino Unido."*
> — Gerente Comercial (cliente simulado)

**Pregunta central:** ¿cuál es la facturación **neta** real del negocio, qué clientes la sostienen, y qué parte de esa facturación está **en riesgo de fuga**?

**Contexto del negocio:** es un **mayorista** de regalos y artículos de hogar. La mayoría de sus clientes son pequeñas tiendas, no consumidores finales. Vende en 40+ países, pero el Reino Unido concentra la mayor parte del ingreso.

---

## 2. Los datos

| | |
|---|---|
| **Fuente** | [Online Retail II — UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii) |
| **Licencia** | CC BY 4.0 (uso libre citando la fuente) |
| **Volumen** | 1.067.371 líneas de factura · 2 hojas de Excel |
| **Periodo** | 2009-12-01 → 2011-12-09 |
| **Grano** | 1 fila = **un producto dentro de una factura** |
| **Moneda** | Libra esterlina (GBP) |
| **Diccionario completo** | [`docs/01-contexto-y-dataset.md`](docs/01-contexto-y-dataset.md) |

> 🇬🇧 *English summary at [`README.en.md`](README.en.md).*

---

## 3. Qué encontré

<!-- Se completa en la Fase 5. Cada hallazgo: numero + accion. -->

| # | Hallazgo | Evidencia |
|---|---|---|
| 1 | | |
| 2 | | |
| 3 | | |

---

## 4. Decisiones de método (el *por qué*, no el *qué*)

Documentar el criterio vale más que el resultado: es lo que separa un análisis propio de un tutorial copiado.

| Decisión | Alternativa que descarté | Por qué |
|---|---|---|
| | | |

---

## 5. Avance por fases

| Fase | Qué incluye | Estado | Rama / PR |
|---|---|---|---|
| **0** | Estructura, GitFlow, carga del dataset original | ✅ | `main` / `develop` |
| **1** | Perfilado, diccionario de datos, reglas de calidad | ⬜ | `feature/fase-1-perfilado` |
| **2** | Limpieza y modelo estrella (`stg` → `marts`) | ⬜ | `feature/fase-2-modelo` |
| **3** | KPIs comerciales, RFM y cohortes | ⬜ | `feature/fase-3-analisis` |
| **4** | Dashboard Power BI (3 páginas) | ⬜ | `feature/fase-4-dashboard` |
| **5** | Informe, README final y release `v1.0.0` | ⬜ | `release/v1.0.0` |

---

## 6. Estructura del repositorio

```
├── docs/         contexto, preguntas de negocio, bitacora, hallazgos
├── data/raw      dataset original (no se versiona)
├── data/staging  datos limpios, sin agregaciones
├── data/marts    modelo final: dimensiones y tabla de hechos
├── sql/          00_setup · 10_staging · 20_marts · 30_analisis
├── excel/        analisis de apoyo en Excel (formulas documentadas)
├── powerbi/      dashboard .pbix y capturas
├── scripts/      carga y validacion de datos
└── reports/      figuras e informe final
```

---

## 7. Cómo reproducirlo

```bash
# 1. Clona el repositorio
git clone <url-del-repo>
cd 01-retail-ecommerce
git checkout develop

# 2. Descarga el dataset original (desde la raiz del portafolio)
python tools/descargar_datasets.py
# Copia online_retail_II.xlsx a data/raw/

# 3. Crea el esquema en SQL Server
#    Ejecuta sql/00_setup/00_crear_esquema.sql
#    Carga las dos hojas en stg.ventas_2009_2010 y stg.ventas_2010_2011

# 4. Corre las consultas en orden
#    sql/10_staging -> sql/20_marts -> sql/30_analisis
```

**Requisitos:** SQL Server 2019+ (o PostgreSQL 14+), Power BI Desktop, Excel.

---

## 8. Herramientas

![SQL Server](https://img.shields.io/badge/SQL_Server-T--SQL-CC2927?style=flat-square)
![Power BI](https://img.shields.io/badge/Power_BI-DAX-F2C811?style=flat-square)
![Excel](https://img.shields.io/badge/Excel-217346?style=flat-square)
![Git](https://img.shields.io/badge/Git-GitFlow-F05032?style=flat-square)

---

## 9. Supuestos y limitaciones

<!-- Honestidad tecnica. Se completa durante el proyecto. -->

- El dataset **no incluye costo de los productos**, por lo que se analiza **ingreso**, no margen ni utilidad.
- Las líneas sin `Customer ID` no se pueden atribuir a un cliente: la decisión que se tome con ellas está documentada en `docs/`.
- El periodo termina el 9 de diciembre de 2011: **diciembre está incompleto** y no es comparable con otros diciembres.
- Los datos provienen de un único retailer mayorista del Reino Unido: **no son extrapolables** a otros negocios.

---

## 10. Sobre este proyecto

Portafolio de Analista de Datos Junior — 3 proyectos de negocio real, desarrollados por fases con GitFlow, del dato crudo a la recomendación.

**Autor:** Arnaldo Reyes · [LinkedIn](https://www.linkedin.com/in/) · Licencia [MIT](LICENSE)
**Fuente de datos citada:** Chen, D. (2012). *Online Retail II* [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5CG6D
