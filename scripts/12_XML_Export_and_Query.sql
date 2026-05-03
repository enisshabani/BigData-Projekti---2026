USE BigData_Group24;
GO

-- =====================================================
-- FASE 2 PJESA 2: XML EXPORT AND QUERY
-- =====================================================
-- Qëllim: Eksportoj DWH data si XML, shkruaj XPath dhe XQuery
-- =====================================================

-- =====================================================
-- SEKSIONI 1: EKSPORTIMI I ENERGJISË SI XML
-- =====================================================

-- 1.1: Eksporti i Environmental Impact Data si XML
DECLARE @XMLEnvironmental XML;

SET @XMLEnvironmental = (
    SELECT 
        dc.CountryName AS '@Country',
        dt.Year AS '@Year',
        fei.CO2PerCapita AS 'CO2PerCapita',
        fei.EnergyPerPerson AS 'EnergyPerPerson'
    FROM Fact_EnvironmentalImpact fei
    INNER JOIN DimCountry dc ON fei.CountryKey = dc.CountryKey
    INNER JOIN DimTime dt ON fei.TimeKey = dt.TimeKey
    FOR XML PATH('EnergyRecord'), ROOT('EnvironmentalData')
);

-- Shfaq XML-in e Environmental Impact
PRINT '=== ENVIRONMENTAL IMPACT XML ===';
SELECT @XMLEnvironmental;
GO

-- 1.2: Eksporti i Electricity Sources Data si XML
DECLARE @XMLElectricity XML;

SET @XMLElectricity = (
    SELECT 
        dc.CountryName AS '@Country',
        dt.Year AS '@Year',
        fes.Coal_Pct AS 'Coal',
        fes.Gas_Pct AS 'Gas',
        fes.Hydro_Pct AS 'Hydro',
        fes.Solar_Pct AS 'Solar',
        fes.Wind_Pct AS 'Wind'
    FROM Fact_ElectricitySources fes
    INNER JOIN DimCountry dc ON fes.CountryKey = dc.CountryKey
    INNER JOIN DimTime dt ON fes.TimeKey = dt.TimeKey
    FOR XML PATH('ElectricityRecord'), ROOT('ElectricitySourcesData')
);

-- Shfaq XML-in e Electricity Sources
PRINT '=== ELECTRICITY SOURCES XML ===';
SELECT @XMLElectricity;
GO

-- =====================================================
-- SEKSIONI 2: XPath QUERIES (2 shembuj)
-- =====================================================

-- XPath Query 1: Të gjithë vendet në XML-in e Environmental Data
PRINT '=== XPath Query 1: EXTRACT ALL COUNTRIES (Environmental) ===';
SET QUOTED_IDENTIFIER ON;
DECLARE @XMLEnv XML = (
    SELECT 
        dc.CountryName AS '@Country',
        dt.Year AS '@Year',
        fei.CO2PerCapita AS 'CO2PerCapita',
        fei.EnergyPerPerson AS 'EnergyPerPerson'
    FROM Fact_EnvironmentalImpact fei
    INNER JOIN DimCountry dc ON fei.CountryKey = dc.CountryKey
    INNER JOIN DimTime dt ON fei.TimeKey = dt.TimeKey
    WHERE dt.Year >= 2020  -- Filtro për vitet e para-stara
    FOR XML PATH('EnergyRecord'), ROOT('EnvironmentalData')
);

-- XPath: Merr atributin @Country nga të gjitha ngarkesat
SELECT 
    T.C.value('@Country', 'NVARCHAR(255)') AS Country,
    T.C.value('@Year', 'INT') AS Year,
    T.C.value('(CO2PerCapita)[1]', 'FLOAT') AS CO2PerCapita
FROM @XMLEnv.nodes('/EnvironmentalData/EnergyRecord') T(C)
WHERE T.C.value('(CO2PerCapita)[1]', 'FLOAT') IS NOT NULL;
GO

-- XPath Query 2: Të gjithë pjesëmarrjet e burimeve të energjisë për vit specifik
PRINT '=== XPath Query 2: EXTRACT RENEWABLE SOURCES ===';
SET QUOTED_IDENTIFIER ON;
DECLARE @XMLElec XML = (
    SELECT 
        dc.CountryName AS '@Country',
        dt.Year AS '@Year',
        fes.Solar_Pct AS 'Solar',
        fes.Wind_Pct AS 'Wind',
        fes.Hydro_Pct AS 'Hydro'
    FROM Fact_ElectricitySources fes
    INNER JOIN DimCountry dc ON fes.CountryKey = dc.CountryKey
    INNER JOIN DimTime dt ON fes.TimeKey = dt.TimeKey
    WHERE dt.Year = (SELECT MAX(Year) FROM DimTime)  -- Merr vitin më të ri
    FOR XML PATH('SourceRecord'), ROOT('RenewableData')
);

-- XPath: Merr burimet e rinovueshme për vitin më të ri
SELECT 
    T.C.value('@Country', 'NVARCHAR(255)') AS Country,
    T.C.value('@Year', 'INT') AS Year,
    CAST(T.C.value('(Solar)[1]', 'NVARCHAR(20)') AS FLOAT) AS SolarPercent,
    CAST(T.C.value('(Wind)[1]', 'NVARCHAR(20)') AS FLOAT) AS WindPercent,
    CAST(T.C.value('(Hydro)[1]', 'NVARCHAR(20)') AS FLOAT) AS HydroPercent
FROM @XMLElec.nodes('/RenewableData/SourceRecord') T(C)
WHERE T.C.value('@Country', 'NVARCHAR(255)') IS NOT NULL;
GO

-- =====================================================
-- SEKSIONI 3: XQuery QUERIES (2 shembuj)
-- =====================================================

-- XQuery 1: Gjen vendet me CO2 më të lartë se 5
PRINT '=== XQuery 1: HIGH CO2 COUNTRIES ===';
SET QUOTED_IDENTIFIER ON;
DECLARE @XMLEnvData XML = (
    SELECT 
        dc.CountryName AS '@Country',
        dt.Year AS '@Year',
        fei.CO2PerCapita AS 'CO2PerCapita'
    FROM Fact_EnvironmentalImpact fei
    INNER JOIN DimCountry dc ON fei.CountryKey = dc.CountryKey
    INNER JOIN DimTime dt ON fei.TimeKey = dt.TimeKey
    FOR XML PATH('Record'), ROOT('EnvData')
);

-- XQuery: Filtrimi i të dhënave bazuar në CO2PerCapita
SELECT 
    T.C.value('@Country', 'NVARCHAR(255)') AS Country,
    T.C.value('@Year', 'INT') AS Year,
    CAST(T.C.value('CO2PerCapita[1]', 'NVARCHAR(20)') AS FLOAT) AS CO2Level
FROM @XMLEnvData.nodes('/EnvData/Record') T(C)
WHERE CAST(T.C.value('CO2PerCapita[1]', 'NVARCHAR(20)') AS FLOAT) > 5;
GO

-- XQuery 2: Burimet e energjisë sipas tipit
PRINT '=== XQuery 2: ENERGY SOURCE ANALYSIS ===';
SET QUOTED_IDENTIFIER ON;
DECLARE @XMLElecData XML = (
    SELECT 
        dc.CountryName AS '@Country',
        dt.Year AS '@Year',
        fes.Coal_Pct AS 'Coal',
        fes.Gas_Pct AS 'Gas',
        fes.Hydro_Pct AS 'Hydro',
        fes.Solar_Pct AS 'Solar',
        fes.Wind_Pct AS 'Wind'
    FROM Fact_ElectricitySources fes
    INNER JOIN DimCountry dc ON fes.CountryKey = dc.CountryKey
    INNER JOIN DimTime dt ON fes.TimeKey = dt.TimeKey
    FOR XML PATH('EnergySource'), ROOT('ElectricityData')
);

-- XQuery: Shfaq vendet me energji rinovueshme > 50%
SELECT 
    T.C.value('@Country', 'NVARCHAR(255)') AS Country,
    T.C.value('@Year', 'INT') AS Year,
    CAST(T.C.value('Coal[1]', 'NVARCHAR(20)') AS FLOAT) AS Coal_Pct,
    CAST(T.C.value('Gas[1]', 'NVARCHAR(20)') AS FLOAT) AS Gas_Pct,
    CAST(T.C.value('Hydro[1]', 'NVARCHAR(20)') AS FLOAT) AS Hydro_Pct,
    CAST(T.C.value('Solar[1]', 'NVARCHAR(20)') AS FLOAT) AS Solar_Pct,
    CAST(T.C.value('Wind[1]', 'NVARCHAR(20)') AS FLOAT) AS Wind_Pct,
    (CAST(T.C.value('Hydro[1]', 'NVARCHAR(20)') AS FLOAT) + 
     CAST(T.C.value('Solar[1]', 'NVARCHAR(20)') AS FLOAT) + 
     CAST(T.C.value('Wind[1]', 'NVARCHAR(20)') AS FLOAT)) AS Renewable_Pct
FROM @XMLElecData.nodes('/ElectricityData/EnergySource') T(C)
WHERE (CAST(T.C.value('Hydro[1]', 'NVARCHAR(20)') AS FLOAT) + 
       CAST(T.C.value('Solar[1]', 'NVARCHAR(20)') AS FLOAT) + 
       CAST(T.C.value('Wind[1]', 'NVARCHAR(20)') AS FLOAT)) > 50;
GO

-- =====================================================
-- SEKSIONI 4: EKSPORTI I TË DHËNAVE SI FICHIER
-- =====================================================

-- 4.1: Eksporti i plotë të DWH si XML (për ruajtje në fichier)
PRINT '=== FULL DWH EXPORT AS XML ===';
DECLARE @FullXML XML;

SET @FullXML = (
    SELECT 
        (SELECT 
            dc.CountryKey,
            dc.CountryName,
            dc.ISOCode
         FROM DimCountry dc
         FOR XML PATH('Country'), TYPE) AS Countries,
        (SELECT 
            dt.TimeKey,
            dt.Year
         FROM DimTime dt
         FOR XML PATH('Year'), TYPE) AS TimeData,
        (SELECT 
            dc.CountryName AS '@Country',
            dt.Year AS '@Year',
            fei.CO2PerCapita,
            fei.EnergyPerPerson
         FROM Fact_EnvironmentalImpact fei
         INNER JOIN DimCountry dc ON fei.CountryKey = dc.CountryKey
         INNER JOIN DimTime dt ON fei.TimeKey = dt.TimeKey
         FOR XML PATH('EnvironmentalRecord'), TYPE) AS EnvironmentalFacts,
        (SELECT 
            dc.CountryName AS '@Country',
            dt.Year AS '@Year',
            fes.Coal_Pct,
            fes.Gas_Pct,
            fes.Hydro_Pct,
            fes.Solar_Pct,
            fes.Wind_Pct
         FROM Fact_ElectricitySources fes
         INNER JOIN DimCountry dc ON fes.CountryKey = dc.CountryKey
         INNER JOIN DimTime dt ON fes.TimeKey = dt.TimeKey
         FOR XML PATH('ElectricityRecord'), TYPE) AS ElectricityFacts
    FOR XML PATH('DataWarehouse'), ROOT('EnergyDWH')
);

SELECT @FullXML;

-- Ruaje XML-in në fichier (i njohur si energy_data.xml)
-- Vini re: SQL Server nuk mund të shkruajë fichiere direkt nëse ajo është në Docker
-- Por mund ta eksportosh rezultatin përmes SSMS ose Power BI
PRINT '=== XML Export Complete ===';
PRINT 'Shënim: Energy_data.xml mund të eksportohet nga rezultatet e sipërm';
GO

-- =====================================================
-- SEKSIONI 5: VERIFIKIM DHE STATISTIKA
-- =====================================================

-- 5.1: Statistika të të dhënave XML
PRINT '=== DATA STATISTICS ===';
SELECT 
    'DimCountry' AS TableName, 
    COUNT(*) AS RecordCount 
FROM DimCountry
UNION ALL
SELECT 'DimTime', COUNT(*) FROM DimTime
UNION ALL
SELECT 'Fact_EnvironmentalImpact', COUNT(*) FROM Fact_EnvironmentalImpact
UNION ALL
SELECT 'Fact_ElectricitySources', COUNT(*) FROM Fact_ElectricitySources;
GO

PRINT '=== SCRIPT COMPLETED SUCCESSFULLY ===';
