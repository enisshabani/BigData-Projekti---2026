USE EnergyDW;
GO

-- 1. VIEWS

-- Bashkimi i të dhënave të CO2 dhe Energjisë për çdo shtet vjetor
IF OBJECT_ID('v_CountryYearlyProfile', 'V') IS NOT NULL DROP VIEW v_CountryYearlyProfile;
GO
CREATE VIEW v_CountryYearlyProfile AS
SELECT 
    c.CountryName,
    t.Year,
    env.CO2PerCapita,
    env.EnergyPerPerson,
    elec.Coal_Pct,
    elec.Solar_Pct,
    elec.Wind_Pct,
    (elec.Solar_Pct + elec.Wind_Pct + elec.Hydro_Pct) AS TotalRenewablePct
FROM Fact_EnvironmentalImpact env
JOIN DimCountry c ON env.CountryKey = c.CountryKey
JOIN DimTime t ON env.TimeKey = t.TimeKey
LEFT JOIN Fact_ElectricitySources elec ON env.CountryKey = elec.CountryKey AND env.TimeKey = elec.TimeKey;
GO

-- Mesataret globale vjetore për analizë të trendit
IF OBJECT_ID('v_GlobalYearlyTrends', 'V') IS NOT NULL DROP VIEW v_GlobalYearlyTrends;
GO
CREATE VIEW v_GlobalYearlyTrends AS
SELECT 
    t.Year,
    AVG(env.CO2PerCapita) AS AvgCO2,
    AVG(env.EnergyPerPerson) AS AvgEnergyUsage,
    AVG(elec.Coal_Pct) AS AvgCoalUsage
FROM Fact_EnvironmentalImpact env
JOIN DimTime t ON env.TimeKey = t.TimeKey
LEFT JOIN Fact_ElectricitySources elec ON env.TimeKey = elec.TimeKey
GROUP BY t.Year;
GO

-- Renditja e shteteve sipas performancës së energjisë së renovueshme
IF OBJECT_ID('v_RenewableRankings', 'V') IS NOT NULL DROP VIEW v_RenewableRankings;
GO
CREATE VIEW v_RenewableRankings AS
SELECT 
    c.CountryName,
    t.Year,
    (elec.Solar_Pct + elec.Wind_Pct + elec.Hydro_Pct) AS RenewablePct,
    RANK() OVER (PARTITION BY t.Year ORDER BY (elec.Solar_Pct + elec.Wind_Pct + elec.Hydro_Pct) DESC) as RankInYear
FROM Fact_ElectricitySources elec
JOIN DimCountry c ON elec.CountryKey = c.CountryKey
JOIN DimTime t ON elec.TimeKey = t.TimeKey;
GO


-- 2. STORED PROCEDURES

-- Historiku i plotë vjetor për një shtet specifik
IF OBJECT_ID('sp_GetStatsByCountry', 'P') IS NOT NULL DROP PROCEDURE sp_GetStatsByCountry;
GO
CREATE PROCEDURE sp_GetStatsByCountry
    @CountryName NVARCHAR(255)
AS
BEGIN
    SELECT * FROM v_CountryYearlyProfile
    WHERE CountryName = @CountryName
    ORDER BY Year;
END;
GO

-- Shtetet me emetime mbi një limit të caktuar në një vit specifik
IF OBJECT_ID('sp_GetHighPolluters', 'P') IS NOT NULL DROP PROCEDURE sp_GetHighPolluters;
GO
CREATE PROCEDURE sp_GetHighPolluters
    @Year INT,
    @MinCO2 FLOAT
AS
BEGIN
    SELECT CountryName, CO2PerCapita, EnergyPerPerson
    FROM v_CountryYearlyProfile
    WHERE Year = @Year AND CO2PerCapita > @MinCO2
    ORDER BY CO2PerCapita DESC;
END;
GO

-- Krahasimi i mix-it të energjisë mes dy viteve të zgjedhura
IF OBJECT_ID('sp_CompareEnergyMixAcrossYears', 'P') IS NOT NULL DROP PROCEDURE sp_CompareEnergyMixAcrossYears;
GO
CREATE PROCEDURE sp_CompareEnergyMixAcrossYears
    @Year1 INT,
    @Year2 INT
AS
BEGIN
    SELECT 
        Year,
        AVG(Coal_Pct) as AvgCoal,
        AVG(Solar_Pct) as AvgSolar,
        AVG(Wind_Pct) as AvgWind
    FROM v_CountryYearlyProfile
    WHERE Year IN (@Year1, @Year2)
    GROUP BY Year;
END;
GO


-- 3. ANALYTICAL QUERIES

-- Q1: Top 10 shtetet me përdorimin më të lartë të qymyrit në vitin 2020
SELECT TOP 10 
    c.CountryName, 
    AVG(elec.Coal_Pct) as AvgCoal
FROM Fact_ElectricitySources elec
JOIN DimCountry c ON elec.CountryKey = c.CountryKey
JOIN DimTime t ON elec.TimeKey = t.TimeKey
WHERE t.Year = 2020
GROUP BY c.CountryName
ORDER BY AvgCoal DESC;

-- Q2: Lidhja mes nivelit të konsumit të energjisë dhe emetimeve të CO2
SELECT 
    CASE 
        WHEN EnergyPerPerson < 2000 THEN 'Low Consumer'
        WHEN EnergyPerPerson BETWEEN 2000 AND 10000 THEN 'Medium Consumer'
        ELSE 'High Consumer'
    END AS ConsumptionCategory,
    AVG(CO2PerCapita) as AverageCO2
FROM Fact_EnvironmentalImpact
GROUP BY 
    CASE 
        WHEN EnergyPerPerson < 2000 THEN 'Low Consumer'
        WHEN EnergyPerPerson BETWEEN 2000 AND 10000 THEN 'Medium Consumer'
        ELSE 'High Consumer'
    END;

-- Q3: Shtetet efikase që kanë rritur energjinë por kanë ulur CO2 (Decoupling)
SELECT 
    c.CountryName,
    (MAX(env.EnergyPerPerson) - MIN(env.EnergyPerPerson)) as EnergyGrowth,
    (MAX(env.CO2PerCapita) - MIN(env.CO2PerCapita)) as CO2Change
FROM Fact_EnvironmentalImpact env
JOIN DimCountry c ON env.CountryKey = env.CountryKey
GROUP BY c.CountryName
HAVING (MAX(env.EnergyPerPerson) - MIN(env.EnergyPerPerson)) > 0 
   AND (MAX(env.CO2PerCapita) - MIN(env.CO2PerCapita)) < 0;

-- Q4: Trendi mesatar i energjisë së renovueshme vjetore
SELECT 
    Year, 
    AVG(TotalRenewablePct) as AvgRenewables
FROM v_CountryYearlyProfile
GROUP BY Year
ORDER BY Year;

-- Q5: Analiza e emetimeve mesatare sipas kodeve të rajoneve
SELECT 
    LEFT(ISOCode, 1) as RegionCode,
    AVG(CO2PerCapita) as AvgCO2
FROM DimCountry c
JOIN Fact_EnvironmentalImpact env ON c.CountryKey = env.CountryKey
WHERE ISOCode IS NOT NULL
GROUP BY LEFT(ISOCode, 1);