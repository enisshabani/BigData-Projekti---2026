USE BigData_Group24;
GO

-- 1. PREPARE THE COLUMNS
ALTER TABLE Fact_EnvironmentalImpact ALTER COLUMN CountryKey INT NOT NULL;
ALTER TABLE Fact_EnvironmentalImpact ALTER COLUMN TimeKey INT NOT NULL;
GO

-- 2. CREATE THE PARTITION FUNCTION
CREATE PARTITION FUNCTION pfTimeRange (INT)
AS RANGE LEFT FOR VALUES (123, 143, 163);
GO

-- 3. CREATE THE PARTITION SCHEME
CREATE PARTITION SCHEME psTimeScheme
AS PARTITION pfTimeRange
ALL TO ([PRIMARY]);
GO

-- 4. DYNAMIC PRIMARY KEY REMOVAL
DECLARE @PkName NVARCHAR(500);
SELECT @PkName = name FROM sys.key_constraints 
WHERE type = 'PK' AND parent_object_id = OBJECT_ID('Fact_EnvironmentalImpact');

IF @PkName IS NOT NULL
    EXEC('ALTER TABLE Fact_EnvironmentalImpact DROP CONSTRAINT ' + @PkName);
GO

-- 5. APPLY THE PARTITIONS
CREATE CLUSTERED INDEX IX_FactEnv_Partition 
ON Fact_EnvironmentalImpact (TimeKey)
ON psTimeScheme (TimeKey);
GO

-- 6. RESTORE THE PRIMARY KEY
ALTER TABLE Fact_EnvironmentalImpact
ADD CONSTRAINT PK_Fact_EnvironmentalImpact 
PRIMARY KEY NONCLUSTERED (CountryKey, TimeKey);
GO

-- 7. FINAL REPORT: THE YEAR MAP
SELECT 
    p.partition_number AS [Partition],
    p.rows AS [Row Count],
    dt.Year AS [Boundary Year],
    CASE 
        WHEN p.partition_number = 1 THEN 'Data up to Year 2000'
        WHEN p.partition_number = 2 THEN 'Between Year 2000 and 2020'
        WHEN p.partition_number = 3 THEN 'Between Year 2020 and 1980'
        WHEN p.partition_number = 4 THEN 'Data after Year 1980'
    END AS [Year Range Description]
FROM sys.partitions p
JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
LEFT JOIN sys.partition_range_values rv ON rv.boundary_id = p.partition_number
LEFT JOIN DimTime dt ON rv.value = dt.TimeKey
WHERE i.name = 'IX_FactEnv_Partition'
AND p.index_id <= 1;
GO