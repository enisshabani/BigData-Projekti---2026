USE BigData_Group24;
GO

-- 1. PREPARE COLUMNS
-- Primary Keys and Partition Keys cannot be NULL.
ALTER TABLE Fact_ElectricitySources ALTER COLUMN CountryKey INT NOT NULL;
ALTER TABLE Fact_ElectricitySources ALTER COLUMN TimeKey INT NOT NULL;
GO

-- 2. CREATE LIST FUNCTION
-- We use your top 3 CountryKeys: 115, 161, 169.
-- This groups data based on specific country IDs.
CREATE PARTITION FUNCTION pfCountryList (INT)
AS RANGE LEFT FOR VALUES (115, 161, 169);
GO

-- 3. CREATE SCHEME
CREATE PARTITION SCHEME psCountryScheme
AS PARTITION pfCountryList
ALL TO ([PRIMARY]);
GO

-- 4. DYNAMIC PRIMARY KEY REMOVAL
-- This gaurantees the script runs on any computer by finding the PK name.
DECLARE @PkName NVARCHAR(500);
SELECT @PkName = name FROM sys.key_constraints 
WHERE type = 'PK' AND parent_object_id = OBJECT_ID('Fact_ElectricitySources');

IF @PkName IS NOT NULL
    EXEC('ALTER TABLE Fact_ElectricitySources DROP CONSTRAINT ' + @PkName);
GO

-- 5. APPLY LIST PARTITIONING
-- We physically divide the table using CountryKey.
CREATE CLUSTERED INDEX IX_FactElect_Partition 
ON Fact_ElectricitySources (CountryKey)
ON psCountryScheme (CountryKey);
GO

-- 6. RESTORE PRIMARY KEY
-- Keeps the table unique and valid for the relationship diagram.
ALTER TABLE Fact_ElectricitySources
ADD CONSTRAINT PK_Fact_ElectricitySources 
PRIMARY KEY NONCLUSTERED (CountryKey, TimeKey);
GO

-- 7. VERIFICATION 
SELECT 
    p.partition_number AS [Partition],
    p.rows AS [Row Count]
FROM sys.partitions p
WHERE p.object_id = OBJECT_ID('Fact_ElectricitySources')
AND p.index_id <= 1;
GO

USE BigData_Group24;
GO
