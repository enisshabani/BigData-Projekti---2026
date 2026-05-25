# SQL vs NoSQL Comparison

This document fulfills the **Phase 3 - Part A.2** requirements by comparing the analytical queries executed in the relational Data Warehouse (SQL) with equivalent NoSQL queries (MongoDB).

---

## Query 1: Top 10 CO2 Emitting Countries for a Selected Year

**Purpose:** Identify the top 10 countries with the highest CO2 emissions per capita for a specific year (e.g., 2022).

### Equivalent SQL Query (Phase 1)
```sql
SELECT TOP 10 c.CountryName, f.CO2PerCapita
FROM Fact_EnvironmentalImpact f
JOIN DimCountry c ON f.CountryKey = c.CountryKey
JOIN DimTime t ON f.TimeKey = t.TimeKey
WHERE t.Year = 2022
ORDER BY f.CO2PerCapita DESC;
```

### MongoDB Query (Phase 3)
```javascript
db.country_energy_profiles.find(
  { year: 2022 },
  { _id: 0, country: 1, co2_per_capita: 1 }
)
.sort({ co2_per_capita: -1 })
.limit(10);
```

### Syntax Difference & Interpretation
- **Syntax Difference:** In SQL, we must use `JOIN` on multiple tables (`Fact_EnvironmentalImpact`, `DimCountry`, `DimTime`) to gather the dimensions before filtering with a `WHERE` clause and sorting with `ORDER BY`. In MongoDB, because the data is denormalized and embedded into a single document per country/year, we query a single collection. We use the `.find()` filter object for the condition, `.project()` (the second argument) to select specific columns, and `.sort()` to order the results.
- **Interpretation:** Both approaches return the identical list of the top 10 emitting countries. The NoSQL approach, however, simplifies analytical reads because the required values are stored in one document and no joins are needed for these queries.

---

## Query 2: Top 10 Renewable Energy Leaders

**Purpose:** Identify the top 10 countries with the highest share of renewable energy sources in a specific year.

### Equivalent SQL Query (Phase 1)
```sql
SELECT TOP 10 c.CountryName, (f2.Solar_Pct + f2.Wind_Pct + f2.Hydro_Pct) AS RenewableShare
FROM Fact_ElectricitySources f2
JOIN DimCountry c ON f2.CountryKey = c.CountryKey
JOIN DimTime t ON f2.TimeKey = t.TimeKey
WHERE t.Year = 2022
ORDER BY RenewableShare DESC;
```

### MongoDB Query (Phase 3)
```javascript
db.country_energy_profiles.find(
  { year: 2022 },
  { _id: 0, country: 1, renewable_share: 1 }
)
.sort({ renewable_share: -1 })
.limit(10);
```

### Syntax Difference & Interpretation
- **Syntax Difference:** The SQL query requires joining three tables and calculating the `RenewableShare` on the fly mathematically during the query execution. In MongoDB, our pipeline during the data import step handles calculating the `renewable_share` and embeds it directly. The query acts purely as a filter (`.find`) and sort (`.sort`) pipeline. 
- **Interpretation:** The MongoDB syntax is much cleaner. By storing calculated properties or embedding the metrics (like `renewable_share`), NoSQL provides a clear performance advantage when serving dashboards or client applications that require instant data retrieval without needing on-the-fly math and aggregations.