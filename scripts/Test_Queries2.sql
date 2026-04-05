USE EnergyDW;
GO

-- 1. Testimi i VIEWS
PRINT '--- 1. Duke testuar VIEWS ---';

PRINT 'Profilet e shteteve (Viti, CO2, Energjia):';
SELECT TOP 5 * FROM v_CountryYearlyProfile;

PRINT 'Trendet globale ndër vite:';
SELECT TOP 5 * FROM v_GlobalYearlyTrends;

PRINT 'Renditja e shteteve për energji të ripërtëritshme:';
SELECT TOP 5 * FROM v_RenewableRankings;


-- 2. Testimi i PROCEDURAVE 
PRINT '--- 2. Duke testuar PROCEDURAT ---';

PRINT 'Statistikat për një shtet specifik:';
EXEC sp_GetStatsByCountry @CountryName = 'United States';

PRINT 'Shtetet me ndotje të lartë (CO2 > 5) në një vit:';
EXEC sp_GetHighPolluters @Year = 2018, @MinCO2 = 5;

PRINT 'Krahasimi i burimeve të energjisë midis dy viteve:';
EXEC sp_CompareEnergyMixAcrossYears @Year1 = 2010, @Year2 = 2018;


-- 3. Testimi i QUERY-ve ANALITIKE 
PRINT '--- 3. Duke testuar QUERY-T ANALITIKE ---';

PRINT 'Shtetet me përdorimin më të lartë të qymyrit (Top 10):';
SELECT TOP 10 
    c.CountryName, 
    AVG(elec.Coal_Pct) as AvgCoal
FROM Fact_ElectricitySources elec
JOIN DimCountry c ON elec.CountryKey = c.CountryKey
JOIN DimTime t ON elec.TimeKey = t.TimeKey
WHERE t.Year = 2020
GROUP BY c.CountryName
ORDER BY AvgCoal DESC;

PRINT 'Shtetet me "Decoupling" (Rritje energjie, ulje CO2):';
SELECT TOP 5 
    c.CountryName,
    (MAX(env.EnergyPerPerson) - MIN(env.EnergyPerPerson)) as EnergyGrowth,
    (MAX(env.CO2PerCapita) - MIN(env.CO2PerCapita)) as CO2Change
FROM Fact_EnvironmentalImpact env
JOIN DimCountry c ON env.CountryKey = c.CountryKey
GROUP BY c.CountryName
HAVING (MAX(env.EnergyPerPerson) - MIN(env.EnergyPerPerson)) > 0 
   AND (MAX(env.CO2PerCapita) - MIN(env.CO2PerCapita)) < 0;

PRINT '--- TESTIMI MBAROI ME SUKSES ---';
GO
