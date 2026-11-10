# MartForge · Snowflake + dbt ELT with Data Contracts & Slim CI/CD

[![dbt Slim CI](https://github.com/shivamdubey2310/Martforge/actions/workflows/dbt_slim_ci.yml/badge.svg)](https://github.com/shivamdubey2310/Martforge/actions/workflows/dbt_slim_ci.yml)
[![dbt Docs](https://img.shields.io/badge/dbt%20Docs-GitHub%20Pages-orange)](https://shivamdubey2310.github.io/Martforge/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An enterprise-grade ELT platform transforming **7.5M+ rows** of raw TPC-H transactional data in **Snowflake** using **dbt Core**, dimensional star-schema modeling, **enforced model contracts**, automated data testing, and **GitHub Actions Slim CI/CD** with state deferral.

---

## Architecture Overview

```text
 ┌──────────────────────┐  EL / CTAS  ┌──────────────────────────────────────────┐
 │ Snowflake Samples    │────────────▶│ MARTFORGE_RAW.TPCH                       │
 │ (TPC-H SF1 Bench)    │             │  • customers, orders, lineitem, etc.     │
 └──────────────────────┘             └────────────────────┬─────────────────────┘
                                                           │ dbt build
                                      ┌────────────────────▼─────────────────────┐
                                      │ MARTFORGE_ANALYTICS (dbt Layer)          │
                                      │  • Staging (Views, surrogate keys)       │
                                      │  • Intermediate (Denormalized views)     │
                                      │  • Snapshots (SCD Type 2 tracking)       │
                                      │  • Marts (Fact/Dim tables, Incremental)  │
                                      └────────────────────┬─────────────────────┘
                                                           │
                                ┌──────────────────────────┼──────────────────────────┐
                                ▼                          ▼                          ▼
                     ┌──────────────────────┐   ┌──────────────────────┐   ┌──────────────────────┐
                     │ Data Governance      │   │ CI/CD Pipeline       │   │ Interactive Docs     │
                     │  • Enforced Contracts│   │  • GitHub Actions    │   │  • GitHub Pages      │
                     │  • Schema validation │   │  • State deferral    │   │  • Full DAG lineage  │
                     │  • Generic + Exp tests│  │  • Slim CI build     │   │    graph preview     │
                     └──────────────────────┘   └──────────────────────┘   └──────────────────────┘

```

---

## Key Measured Results

| Metric | Measured Result | Source of Truth |
| --- | --- | --- |
| **Pipeline Scale** | 7,661,240 rows (SF1) | `MARTFORGE_RAW.INFORMATION_SCHEMA` |
| **Pipeline Scope** | 12 models · 1 snapshot · 15 tests · 5 sources | `run_results.json` / dbt CLI |
| **Slim CI Runtime Speedup** | Ran **1 of 12** models (`dim_suppliers`) in **4.79s** | GitHub Actions PR #2 Workflow Run |
| **Incremental Load Speedup** | **11.29s** (Full Refresh) → **7.23s** (Incremental) · **36.0% faster** | dbt run results / execution logs |
| **Contract Drift Violations** | Blocked breaking schema rename (`client_name`) before run | dbt compiler assertion |
| **Compute Warehouse** | `XSMALL` with 60-second auto-suspend | Snowflake `WAREHOUSE_METERING_HISTORY` |

---

## Technical Highlights

### 1. Snowflake RBAC & Compute Isolation

* **Least-Privilege Security:** Pipeline runs under a dedicated `MARTFORGE_ROLE` and `MARTFORGE_USER`, eliminating the need for `ACCOUNTADMIN` execution.
* **Storage Separation:** Physical isolation between immutable raw ingestion (`MARTFORGE_RAW`) and modeled analytical transformations (`MARTFORGE_ANALYTICS`).
* **Auto-Suspend Governance:** Compute managed via `XSMALL` warehouse with `AUTO_SUSPEND = 60` to eliminate idle credit leakage.

### 2. Multi-Layer Dimensional Modeling

* **Staging Layer (Bronze):** Materialized as views. Standardizes cryptic source naming (`c_custkey` → `customer_id`), casts explicit datatypes, and computes MD5 surrogate keys using `dbt_utils.generate_surrogate_key`.
* **Snapshots (SCD Type 2):** Tracks customer balance, address, and tier drifts over time using `check` strategies with validity windows (`dbt_valid_from`, `dbt_valid_to`).
* **Intermediate Layer (Silver):** Denormalizes geopolitical hierarchies (customer/supplier → nation → region) and pre-aggregates order metrics to avoid multi-table joins downstream.
* **Marts Layer (Gold):** Production-ready star schema with conformed dimensions (`dim_customers`, `dim_suppliers`) and incremental facts (`fct_orders`, `fct_order_items`) utilizing Snowflake's native `merge` strategy.

### 3. Data Contracts & Automated Testing

* **Enforced Model Contracts (`contract: {enforced: true}`):** Guarantees zero silent schema drift on public consumption models (`dim_customers`). Explicit data types and column names are enforced at compile time.
* **Test Suite:** Generic assertions (`unique`, `not_null`, `accepted_values`, `relationships`) combined with statistical distribution checks from `dbt-expectations` (`expect_column_values_to_be_between`).

### 4. Slim CI/CD with State Deferral

* **GitHub Actions Workflow:** Automatically triggers on every PR targeting `main`.
* **State Deferral (`state:modified+`):** Compares the PR branch against the committed baseline manifest artifact (`manifest.json`), building and testing only modified models and their downstream dependencies.
* **Ephemeral PR Isolation:** Dynamic target schema isolation (`CI_PR_<PR_NUMBER>`) prevents schema contamination across concurrent PR runs.
* **Automated Lineage Deployments:** Continuous deployment of single-page dbt documentation directly to GitHub Pages on every merge to `main`.

---

## Project Structure

```text
Martforge/
├── .github/
│   └── workflows/
│       ├── dbt_slim_ci.yml         # Slim CI workflow on PRs with state deferral
│       └── deploy_docs.yml         # GitHub Actions deployment of dbt docs to Pages
├── dbt_state/
│   └── manifest.json               # Baseline production manifest for Slim CI state comparison
├── extract/                        # Source EL scripts and utilities
├── martforge_dbt/
│   ├── analyses/
│   ├── macros/
│   ├── models/
│   │   ├── staging/tpch/           # Bronze staging views & source definitions
│   │   ├── intermediate/           # Silver denormalizations and rollups
│   │   └── marts/core/             # Gold star schema facts & dimension tables
│   ├── snapshots/                  # SCD2 snapshot models (snp_tpch_customers.sql)
│   ├── tests/                      # Custom singular tests
│   ├── dbt_project.yml
│   ├── packages.yml                # Dependencies: dbt-utils, dbt-expectations
│   └── profiles_ci.yml             # Environment-variable driven CI profile
├── .gitignore
├── README.md
└── requirements.txt

```

---

## Quickstart & Local Setup

### 1. Prerequisites

* Python 3.10+
* Snowflake Account with `ACCOUNTADMIN` access for initial DDL

### 2. Environment Setup

```bash
# Clone the repository
git clone [https://github.com/shivamdubey2310/Martforge.git](https://github.com/shivamdubey2310/Martforge.git)
cd Martforge

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

```

### 3. Local dbt Profile

Create or edit `~/.dbt/profiles.yml`:

```yaml
martforge_dbt:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "<YOUR_ACCOUNT_IDENTIFIER>"
      user: "MARTFORGE_USER"
      password: "<YOUR_PASSWORD>"
      role: "MARTFORGE_ROLE"
      database: "MARTFORGE_ANALYTICS"
      warehouse: "MARTFORGE_WH"
      schema: "DEV_<YOUR_NAME>"
      threads: 4
      client_session_keep_alive: False

```

### 4. Build and Test

```bash
cd martforge_dbt

# Install packages
dbt deps

# Verify connection
dbt debug

# Execute snapshot tracking
dbt snapshot

# Full build and test
dbt build

# Preview interactive documentation
dbt docs generate
dbt docs serve --port 8080

```

---

## Data Lineage Graph

The complete dependency DAG flows from raw sources to cleansed staging views, intermediate join rollups, and final marts:

```text
tpch.orders ──────▶ stg_tpch_orders ────────┬────────────▶ fct_orders
                                            │                   ▲
tpch.lineitem ────▶ stg_tpch_line_items ────┼──▶ int_summary ───┘
                                            │                   ▲
tpch.customers ───▶ stg_tpch_customers ─────┼──▶ dim_customers  │
                                            │                   │
tpch.supplier ────▶ stg_tpch_suppliers ─────┼──▶ dim_suppliers  │
                                            │                   │
tpch.nation ──────▶ stg_tpch_nations ───────┴───────────────────┴─▶ fct_order_items

```

---

## License

This project is licensed under the MIT License — see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.
