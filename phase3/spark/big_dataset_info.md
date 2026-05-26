# Big Dataset Information

- Dataset name: World Energy Clean benchmark dataset
- Source: `data/WorldEnergy_Clean.csv`
- File format: CSV
- Size or row count: 550,301 rows after repeating the source file 25 times
- Why it is related to the project topic: it contains country-level energy, CO2, and renewable-energy data that matches the project theme and supports SparkSQL analysis
- Verification result: the Spark loader reads the CSV successfully, prints the schema, and reports the row count from `count()`