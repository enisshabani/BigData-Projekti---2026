# MongoDB Schema Explanation

## Collection Name
`country_energy_profiles`

## Document Structure
In Phase 1, our data was separated into multiple relational tables: `DimCountry`, `DimTime`, `Fact_EnvironmentalImpact`, and `Fact_ElectricitySources`. 

For Phase 3, we are migrating this into a single NoSQL document structure in MongoDB. Each document represents **one country in one specific year**.

Here is the document shape:
```json
{
  "country": "Germany",
  "iso_code": "DEU",
  "year": 2020,
  "co2_per_capita": 7.69,
  "energy_per_person": 42000,
  "electricity_sources": {
    "coal": 24.5,
    "gas": 15.2,
    "solar": 8.9,
    "wind": 23.1,
    "hydro": 3.4
  },
  "renewable_share": 35.4
}
```

## Relational to NoSQL Conversion
- **Dimensions (`DimCountry`, `DimTime`)**: Instead of storing foreign keys (`CountryKey`, `TimeKey`), we embed the actual dimension values (`country`, `iso_code`, `year`) directly inside the document. 
- **Facts (`Fact_EnvironmentalImpact`, `Fact_ElectricitySources`)**: The metrics like `co2_per_capita` and `energy_per_person` are stored as top-level fields.
- **Why Embedding?**: We grouped all the electricity sources (coal, gas, solar, etc.) into a single embedded sub-document called `electricity_sources`. This keeps related data together, making it easier to read and query without needing SQL `JOIN` operations.

## Why MongoDB Fits This Use Case
MongoDB is highly suited for this analytical use case because analytical queries (like finding top polluters in a specific year) often read data all at once. By embedding everything into a single document per country-year, MongoDB can retrieve the entire profile in a single read operation, offering great read performance compared to joining four tables in a relational database.