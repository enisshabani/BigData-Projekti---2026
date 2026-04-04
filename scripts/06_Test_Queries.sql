SELECT * FROM Fact_EnvironmentalImpact;

EXEC sp_LoadDataWarehouse;

-- A ka Fact 1 te dhena
SELECT TOP 10 * FROM Fact_EnvironmentalImpact;

-- A ka Fact 2 te dhena
SELECT TOP 10 * FROM Fact_ElectricitySources;

SELECT 
    c.CountryName, 
    t.Year, 
    f1.CO2PerCapita, 
    f2.Coal_Pct
FROM Fact_EnvironmentalImpact f1
JOIN Fact_ElectricitySources f2 ON f1.CountryKey = f2.CountryKey AND f1.TimeKey = f2.TimeKey
JOIN DimCountry c ON f1.CountryKey = c.CountryKey
JOIN DimTime t ON f1.TimeKey = t.TimeKey
WHERE c.CountryName = 'Germany'
ORDER BY t.Year DESC;

SELECT TOP 10 
    C.CountryName, 
    T.Year, 
    F1.CO2PerCapita, 
    F2.Solar_Pct
FROM Fact_EnvironmentalImpact F1
INNER JOIN Fact_ElectricitySources F2 ON F1.CountryKey = F2.CountryKey AND F1.TimeKey = F2.TimeKey
INNER JOIN DimCountry C ON F1.CountryKey = C.CountryKey
INNER JOIN DimTime T ON F1.TimeKey = T.TimeKey
WHERE F1.CO2PerCapita IS NOT NULL;

SELECT COUNT(*) AS Totali_Fact_Env FROM Fact_EnvironmentalImpact;
SELECT COUNT(*) AS Totali_Fact_Elec FROM Fact_ElectricitySources;

SELECT TOP 20 
    c.CountryName, 
    t.Year, 
    f.CO2PerCapita, 
    f.EnergyPerPerson
FROM Fact_EnvironmentalImpact f
JOIN DimCountry c ON f.CountryKey = c.CountryKey
JOIN DimTime t ON f.TimeKey = t.TimeKey;

EXEC sp_LoadDataWarehouse;
EXEC sp_LoadDataWarehouse;

-- Ky query tregon emetimet dhe burimin e energjisë (qymyrin) për të njëjtin shtet/vit
SELECT 
    c.CountryName, 
    t.Year, 
    env.CO2PerCapita, 
    elec.Coal_Pct
FROM Fact_EnvironmentalImpact env
JOIN Fact_ElectricitySources elec ON env.CountryKey = elec.CountryKey AND env.TimeKey = elec.TimeKey
JOIN DimCountry c ON env.CountryKey = c.CountryKey
JOIN DimTime t ON env.TimeKey = t.TimeKey
WHERE c.CountryName = 'Albania';