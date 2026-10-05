# Online retailer — commercial analysis

**Project 1 of 3** in my Junior Data Analyst portfolio · **Status:** in progress
**Stack:** MySQL · Excel · Power BI

> This is a short English summary. The full documentation — problem statement, data dictionary,
> method decisions and findings — lives in the [Spanish README](README.md).

## The problem

A UK wholesale gift retailer turns over several million pounds a year and sells to 40+ countries.
The commercial manager does not know whether revenue growth comes from **new customers** or from
**the same customers buying more**, or how much revenue is at risk of churn.

**Core question:** what is the true **net** revenue, which customers sustain it, and how much of it
is at risk?

## The data

| | |
|---|---|
| **Source** | [Online Retail II — UCI ML Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii) (CC BY 4.0) |
| **Volume** | 1,067,371 invoice lines · 2 Excel sheets |
| **Period** | 2009-12-01 → 2011-12-09 |
| **Grain** | 1 row = one product inside one invoice |

## How to reproduce

```bash
git clone https://github.com/arnaldoreyes/01-retail-ecommerce.git
cd 01-retail-ecommerce
python scripts/descargar_datos.py      # downloads the dataset into data/raw/
# export each Excel sheet as UTF-8 CSV into data/limpio/
# run sql/00_carga.sql, then sql/01_perfilado.sql
```

**Requirements:** MySQL 8.0 + MySQL Workbench · Power BI Desktop · Excel

---

**Author:** Arnaldo Reyes · License [MIT](LICENSE)
