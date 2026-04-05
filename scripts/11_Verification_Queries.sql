USE BigData_Group24;
GO


-- TESTIMI 1: Fact_EnvironmentalImpact (Range Partitioning)


-- A. ME PARTITIONING (Shfrytëzon TimeKey)
-- Rezultati: Scan count 1 (Partition Pruning)
SELECT AVG(CO2PerCapita) AS Mesatarja_CO2
FROM Fact_EnvironmentalImpact
WHERE TimeKey = 143; 
GO

-- B. PA PARTITIONING (Filtër në kolonë tjetër)
-- Rezultati: Scan count 4 (Full Table Scan)
SELECT * FROM Fact_EnvironmentalImpact
WHERE CO2PerCapita > 5.0;
GO



-- TESTIMI 2: Fact_ElectricitySources (List Partitioning)

-- A. ME PARTITIONING (Shfrytëzon CountryKey)
-- Rezultati: Scan count 1
SELECT CountryKey, AVG(Wind_Pct) AS Mesatarja_Wind
FROM Fact_ElectricitySources
WHERE CountryKey = 115 
GROUP BY CountryKey;
GO

-- B. PA PARTITIONING (Filtër në kolonë tjetër)
-- Rezultati: Scan count 4
SELECT * FROM Fact_ElectricitySources
WHERE Solar_Pct > 5.0;
GO

/* 
EXEC sp_help 'Fact_EnvironmentalImpact';
EXEC sp_help 'Fact_ElectricitySources';
*/