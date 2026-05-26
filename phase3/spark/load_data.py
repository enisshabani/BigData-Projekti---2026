from __future__ import annotations

import csv
from pathlib import Path

from pyspark.sql import SparkSession


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parents[1]
SHARED_DATA_CANDIDATES = [
    REPO_ROOT / "phase3" / "shared_data",
    REPO_ROOT / "phase3" / "shared-data",
]
BENCHMARK_SOURCE = REPO_ROOT / "data" / "WorldEnergy_Clean.csv"
BENCHMARK_OUTPUT = SCRIPT_DIR / "generated_data" / "world_energy_benchmark.csv"
SQL_FILE = SCRIPT_DIR / "spark_queries.sql"


def first_existing_path(paths: list[Path]) -> Path:
    for path in paths:
        if path.exists():
            return path
    raise FileNotFoundError(
        "Could not find the shared data folder. Expected phase3/shared_data or phase3/shared-data."
    )


def build_spark_session() -> SparkSession:
    return (
        SparkSession.builder.appName("BigData-Phase3-SparkSQL")
        .master("local[*]")
        .config("spark.sql.shuffle.partitions", "8")
        .getOrCreate()
    )


def load_executive_summary(spark: SparkSession, csv_path: Path):
    return (
        spark.read.option("header", "true")
        .option("inferSchema", "true")
        .csv(str(csv_path))
        .selectExpr(
            "CountryName as country_name",
            "cast(Year as int) as year",
            "cast(CO2PerCapita as double) as co2_per_capita",
            "cast(EnergyPerPerson as double) as energy_per_person",
            "cast(TotalRenewable_Pct as double) as renewable_share",
        )
    )


def load_energy_mix_analysis(spark: SparkSession, csv_path: Path):
    return (
        spark.read.option("header", "true")
        .option("inferSchema", "true")
        .csv(str(csv_path))
        .selectExpr(
            "CountryName as country_name",
            "cast(Year as int) as year",
            "cast(Coal_Pct as double) as coal_pct",
            "cast(Gas_Pct as double) as gas_pct",
            "cast(Hydro_Pct as double) as hydro_pct",
            "cast(Solar_Pct as double) as solar_pct",
            "cast(Wind_Pct as double) as wind_pct",
        )
    )


def generate_big_dataset() -> Path:
    BENCHMARK_OUTPUT.parent.mkdir(parents=True, exist_ok=True)

    if BENCHMARK_OUTPUT.exists():
        return BENCHMARK_OUTPUT

    if not BENCHMARK_SOURCE.exists():
        raise FileNotFoundError(
            f"Benchmark source file not found: {BENCHMARK_SOURCE}"
        )

    with BENCHMARK_SOURCE.open("r", encoding="utf-8-sig", newline="") as source_file:
        reader = csv.reader(source_file)
        header = next(reader)
        rows = list(reader)

    with BENCHMARK_OUTPUT.open("w", encoding="utf-8", newline="") as output_file:
        writer = csv.writer(output_file)
        writer.writerow(header)
        for _ in range(25):
            writer.writerows(rows)

    return BENCHMARK_OUTPUT


def load_big_dataset(spark: SparkSession, csv_path: Path):
    return (
        spark.read.option("header", "true")
        .option("inferSchema", "true")
        .csv(str(csv_path))
    )


def run_sql_queries(spark: SparkSession) -> None:
    queries = [
        statement.strip()
        for statement in SQL_FILE.read_text(encoding="utf-8").split(";")
        if statement.strip()
    ]

    for index, query in enumerate(queries, start=1):
        print(f"\n=== SparkSQL Query {index} ===")
        result = spark.sql(query)
        if not result.take(1):
            print("No rows returned.")
            continue
        result.show(truncate=False)


def main() -> None:
    shared_data_dir = first_existing_path(SHARED_DATA_CANDIDATES)
    executive_summary_path = shared_data_dir / "executive_summary.csv"
    energy_mix_path = shared_data_dir / "energy_mix_analysis.csv"

    if not executive_summary_path.exists():
        raise FileNotFoundError(f"Missing CSV: {executive_summary_path}")
    if not energy_mix_path.exists():
        raise FileNotFoundError(f"Missing CSV: {energy_mix_path}")

    spark = build_spark_session()

    try:
        executive_summary_df = load_executive_summary(spark, executive_summary_path)
        energy_mix_df = load_energy_mix_analysis(spark, energy_mix_path)

        executive_summary_df.createOrReplaceTempView("executive_summary")
        energy_mix_df.createOrReplaceTempView("energy_mix_analysis")

        print("Loaded executive_summary rows:", executive_summary_df.count())
        executive_summary_df.printSchema()

        print("\nLoaded energy_mix_analysis rows:", energy_mix_df.count())
        energy_mix_df.printSchema()

        benchmark_path = generate_big_dataset()
        benchmark_df = load_big_dataset(spark, benchmark_path)
        benchmark_count = benchmark_df.count()

        print("\nLoaded benchmark dataset rows:", benchmark_count)
        benchmark_df.printSchema()

        run_sql_queries(spark)
    finally:
        spark.stop()


if __name__ == "__main__":
    main()