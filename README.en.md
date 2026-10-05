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

1. Clone the repository.
2. Download the dataset from the source link above and save `online_retail_II.xlsx` into `data/raw/`.
3. Open the file in Excel and save each sheet as UTF-8 CSV into `data/limpio/`.
4. Run `sql/00_carga.sql` in MySQL Workbench (creates the table and loads both sheets).
5. Run `sql/01_perfilado.sql` to verify the load and profile the data.

**Requirements:** MySQL 8.0 + MySQL Workbench · Excel · Power BI Desktop

---

**Author:** Arnaldo Reyes · License [MIT](LICENSE)
