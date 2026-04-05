USE BigData_Group24;
GO

-- 1. TURN ON PERFORMANCE METRICS
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- ANALYSIS 1: Range Partitioning (Fact_EnvironmentalImpact)
-- Partitioned by: TimeKey

PRINT '--- [TABLE 1] QUERY ME RANGE PARTITIONING (Fast) ---';
SELECT * FROM Fact_EnvironmentalImpact WHERE TimeKey = 123;
GO

PRINT '--- [TABLE 1] QUERY PA PARTITIONING (Slower Scan) ---';
SELECT * FROM Fact_EnvironmentalImpact WHERE CountryKey = 10;
GO


-- ANALYSIS 2: List Partitioning (Fact_ElectricitySources)
-- Partitioned by: CountryKey

PRINT '--- [TABLE 2] QUERY ME LIST PARTITIONING (Fast) ---';
SELECT * FROM Fact_ElectricitySources WHERE CountryKey = 115;
GO

PRINT '--- [TABLE 2] QUERY PA PARTITIONING (Slower Scan) ---';
SELECT * FROM Fact_ElectricitySources WHERE TimeKey = 123;
GO

-- 2. TURN OFF PERFORMANCE METRICS
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

