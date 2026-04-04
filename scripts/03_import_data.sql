USE BigData_Group24;
GO

-- Importi i CO2 Emissions
BULK INSERT Staging_CO2Emissions
FROM '/var/opt/mssql/data/co-emissions-per-capita.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    FORMAT = 'CSV',
    TABLOCK
);

-- Importi i Energy Per Person
BULK INSERT Staging_EnergyPerPerson
FROM '/var/opt/mssql/data/per-capita-energy-use.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    FORMAT = 'CSV',
    TABLOCK
);

-- Importi i Electricity By Source
BULK INSERT Staging_ElecBySource
FROM '/var/opt/mssql/data/share-elec-by-source.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    FORMAT = 'CSV',
    TABLOCK
);

-- Importi i Kaggle World Energy
BULK INSERT Staging_Kaggle
FROM '/var/opt/mssql/data/WorldEnergy_Clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    FORMAT = 'CSV',
    TABLOCK
);
GO