USE EnergyDW;
GO
-- 1. HEQJA E CONSTRAINTS
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Env_Country')
    ALTER TABLE Fact_EnvironmentalImpact DROP CONSTRAINT FK_Env_Country;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Env_Time')
    ALTER TABLE Fact_EnvironmentalImpact DROP CONSTRAINT FK_Env_Time;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Elec_Country')
    ALTER TABLE Fact_ElectricitySources DROP CONSTRAINT FK_Elec_Country;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Elec_Time')
    ALTER TABLE Fact_ElectricitySources DROP CONSTRAINT FK_Elec_Time;
GO

-- 2. FSHIRJA E TABELAVE DHE PROCEDURËS

IF OBJECT_ID('sp_LoadDataWarehouse', 'P') IS NOT NULL DROP PROCEDURE sp_LoadDataWarehouse;
IF OBJECT_ID('Fact_EnvironmentalImpact', 'U') IS NOT NULL DROP TABLE Fact_EnvironmentalImpact;
IF OBJECT_ID('Fact_ElectricitySources', 'U') IS NOT NULL DROP TABLE Fact_ElectricitySources;
IF OBJECT_ID('DimCountry', 'U') IS NOT NULL DROP TABLE DimCountry;
IF OBJECT_ID('DimTime', 'U') IS NOT NULL DROP TABLE DimTime;
GO

-- 3. KRIJIMI I STRUKTURËS SË RE (Saktësisht sipas kërkesës)

CREATE TABLE DimCountry (
    CountryKey INT IDENTITY(1,1) PRIMARY KEY,
    CountryName NVARCHAR(255) NOT NULL,
    ISOCode NVARCHAR(50)
);

CREATE TABLE DimTime (
    TimeKey INT IDENTITY(1,1) PRIMARY KEY,
    Year INT NOT NULL
);
GO

CREATE TABLE Fact_EnvironmentalImpact (
    FactKey INT IDENTITY(1,1) PRIMARY KEY,
    CountryKey INT CONSTRAINT FK_Env_Country FOREIGN KEY REFERENCES DimCountry(CountryKey),
    TimeKey INT CONSTRAINT FK_Env_Time FOREIGN KEY REFERENCES DimTime(TimeKey),
    CO2PerCapita FLOAT,
    EnergyPerPerson FLOAT
);

CREATE TABLE Fact_ElectricitySources (
    FactKey INT IDENTITY(1,1) PRIMARY KEY,
    CountryKey INT CONSTRAINT FK_Elec_Country FOREIGN KEY REFERENCES DimCountry(CountryKey),
    TimeKey INT CONSTRAINT FK_Elec_Time FOREIGN KEY REFERENCES DimTime(TimeKey),
    Coal_Pct FLOAT,
    Gas_Pct FLOAT,
    Hydro_Pct FLOAT,
    Solar_Pct FLOAT,
    Wind_Pct FLOAT
);
GO
