USE BigData_Group24; 
GO

-- 1. View për Dashboard-in Kryesor (Executive)
CREATE OR ALTER VIEW v_ExecutiveSummary AS
SELECT 
    c.CountryName,
    t.Year,
    f1.CO2PerCapita,
    f1.EnergyPerPerson,
    (f2.Solar_Pct + f2.Wind_Pct + f2.Hydro_Pct) AS TotalRenewable_Pct
FROM Fact_EnvironmentalImpact f1
JOIN Fact_ElectricitySources f2 ON f1.CountryKey = f2.CountryKey AND f1.TimeKey = f2.TimeKey
JOIN DimCountry c ON f1.CountryKey = c.CountryKey
JOIN DimTime t ON f1.TimeKey = t.TimeKey;
GO

-- 2. View për Shpërndarjen e Energjisë (Analytical)
CREATE OR ALTER VIEW v_EnergyMixAnalysis AS
SELECT 
    c.CountryName,
    t.Year,
    f2.Coal_Pct, f2.Gas_Pct, f2.Hydro_Pct, f2.Solar_Pct, f2.Wind_Pct
FROM Fact_ElectricitySources f2
JOIN DimCountry c ON f2.CountryKey = c.CountryKey
JOIN DimTime t ON f2.TimeKey = t.TimeKey;
GO

CREATE OR ALTER PROCEDURE sp_GetTopPolluters
    @TopN INT,
    @Year INT
AS
BEGIN
    SELECT TOP (@TopN) CountryName, Year, CO2PerCapita
    FROM v_ExecutiveSummary
    WHERE Year = @Year
    ORDER BY CO2PerCapita DESC;
END;
GO

SELECT TOP 10 * FROM v_ExecutiveSummary ORDER BY Year DESC;

EXEC sp_GetTopPolluters @TopN = 5, @Year = 2020;

CREATE OR ALTER VIEW v_EconomicImpact AS
SELECT 
    c.CountryName,
    t.Year,
    f1.CO2PerCapita,
    -- Supozojmë se kemi kolonën GDP në staging ose fact
    (f1.CO2PerCapita / NULLIF(f1.EnergyPerPerson, 0)) AS EmissionIntensity
FROM Fact_EnvironmentalImpact f1
JOIN DimCountry c ON f1.CountryKey = c.CountryKey
JOIN DimTime t ON f1.TimeKey = t.TimeKey;

SELECT TOP 10 * FROM v_ExecutiveSummary

CREATE OR ALTER PROCEDURE sp_CompareCountryEnergy
    @CountryName NVARCHAR(255),
    @Year1 INT,
    @Year2 INT
AS
BEGIN
    SELECT CountryName, Year, EnergyPerPerson, TotalRenewable_Pct
    FROM v_ExecutiveSummary
    WHERE CountryName = @CountryName AND Year IN (@Year1, @Year2)
    ORDER BY Year;
END;
GO

USE EnergyDW;
GO