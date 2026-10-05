# Customer churn and true revenue — Online Retail II

**Project 1 of 3** in my **Junior Data Analyst** portfolio.
Analysis of 1,067,371 invoice lines from a UK online retailer (Dec 2009 – Dec 2011) using **SQL, Excel and Power BI**.

**Status:** 🟡 In progress

---

## 1. Business problem

> *"We've had two years of feeling like we're growing, but I don't know if it's real. I see orders every week and I also see returns. I have customers who bought once and never came back, and customers who buy every month. I don't know who is keeping this business alive, or who I'm about to lose. And I need to know whether selling outside the UK is even worth it."*
> — Commercial Manager (simulated client)

**Core question:** what is the **net** revenue of the business, which customers sustain it, and how much of that revenue is **at risk of churn**?

**Business context:** this is a **wholesaler** of gifts and homeware. Most customers are small shops, not end consumers.

---

## 2. The data

| | |
|---|---|
| **Source** | [Online Retail II — UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii) |
| **License** | CC BY 4.0 |
| **Volume** | 1,067,371 invoice lines · 2 Excel sheets |
| **Period** | 2009-12-01 → 2011-12-09 |
| **Grain** | 1 row = **one product inside one invoice** |
| **Currency** | GBP |
| **Data dictionary** | [`docs/01-contexto-y-dataset.md`](docs/01-contexto-y-dataset.md) (Spanish) |

---

## 3. Key findings

<!-- Completed in Phase 5. Every finding: a number plus an action. -->

| # | Finding | Evidence |
|---|---|---|
| 1 | | |
| 2 | | |
| 3 | | |

---

## 4. Method decisions (the *why*, not the *what*)

| Decision | Alternative rejected | Why |
|---|---|---|
| | | |

---

## 5. Project phases

| Phase | Scope | Status |
|---|---|---|
| **0** | Repository structure, GitFlow, raw dataset | ✅ |
| **1** | Profiling, data dictionary, data quality rules | ⬜ |
| **2** | Cleaning and star schema (`stg` → `marts`) | ⬜ |
| **3** | Commercial KPIs, RFM segmentation, cohort retention | ⬜ |
| **4** | Power BI dashboard (3 pages) | ⬜ |
| **5** | Report, final README, release `v1.0.0` | ⬜ |

---

## 6. Repository structure

```
├── docs/         context, business questions, work log, findings
├── data/raw      original dataset (not versioned)
├── data/staging  cleaned data, no aggregations
├── data/marts    final model: dimensions and fact table
├── sql/          00_setup · 10_staging · 20_marts · 30_analisis
├── excel/        supporting Excel analysis (documented formulas)
├── powerbi/      .pbix dashboard and screenshots
├── scripts/      data loading and validation
└── reports/      figures and final report
```

---

## 7. How to reproduce

```bash
git clone <repo-url>
cd 01-retail-ecommerce
git checkout develop
python tools/descargar_datasets.py   # downloads the original dataset
# copy online_retail_II.xlsx into data/raw/
# run sql/00_setup/00_crear_esquema.sql, then 10_staging -> 20_marts -> 30_analisis
```

**Requirements:** SQL Server 2019+ (or PostgreSQL 14+), Power BI Desktop, Excel.

---

## 8. Assumptions and limitations

- The dataset has **no product cost**, so this analysis covers **revenue**, not profit or margin.
- Lines without `Customer ID` cannot be attributed to a customer; the decision taken is documented in `docs/`.
- The period ends on 9 December 2011: **December is incomplete** and not comparable to other Decembers.
- Single UK wholesaler: findings are **not generalisable** to other businesses.

---

**Author:** Arnaldo Reyes · License [MIT](LICENSE)
**Dataset citation:** Chen, D. (2012). *Online Retail II* [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5CG6D
