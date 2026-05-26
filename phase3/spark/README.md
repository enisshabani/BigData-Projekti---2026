# Phase 3 - Part B: Apache Spark and SparkSQL

This folder contains the local SparkSQL implementation for Phase 3 Part B.

## What it does

- Loads the exported CSV files from `phase3/shared_data`.
- Registers temporary Spark SQL views named `executive_summary` and `energy_mix_analysis`.
- Runs two SparkSQL queries adapted from the Phase 2 XML/XPath/XQuery logic.
- Generates and loads a large benchmark dataset for the Big Data requirement.
- Prints row counts, schemas, and query results to the console.

## Prerequisites

- Python 3.10+.
- Java installed and available in `PATH`.
- PySpark installed in a virtual environment.

On this macOS setup, use a virtual environment because the system Python is PEP 668 managed.

Example setup from the repository root:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install pyspark
```

## Run

From the repository root:

```bash
python phase3/spark/load_data.py
```

## Data paths

- `phase3/shared_data/executive_summary.csv`
- `phase3/shared_data/energy_mix_analysis.csv`
- `phase3/spark/generated_data/world_energy_benchmark.csv`

If your local copy uses `phase3/shared-data` instead of `phase3/shared_data`, the script accepts both folder names.

## Query notes

- Query 1 keeps the requested `year = 2024` filter.
- The current shared CSV export ends at 2022, so Query 1 may return no rows until a 2024 export is available.
- Query 2 returns countries with renewable share greater than or equal to 50.

## Screenshot instructions

Capture screenshots of the terminal output showing:

1. Successful loading of `executive_summary` and `energy_mix_analysis`.
2. The printed schema for each DataFrame.
3. The benchmark dataset row count and schema.
4. The SparkSQL query results.

## Verification

The benchmark dataset is generated from `data/WorldEnergy_Clean.csv` and repeated 25 times to exceed 500,000 rows. The script verifies the dataset by loading it into Spark, printing the schema, and calling `count()`.