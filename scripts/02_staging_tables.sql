USE BigData_Group24;
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Staging_CO2Emissions') DROP TABLE Staging_CO2Emissions;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Staging_EnergyPerPerson') DROP TABLE Staging_EnergyPerPerson;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Staging_ElecBySource') DROP TABLE Staging_ElecBySource;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Staging_Kaggle') DROP TABLE Staging_Kaggle;
GO

CREATE TABLE Staging_CO2Emissions (
    Entity NVARCHAR(255),
    Code NVARCHAR(50),
    Year INT,
    CO2PerCapita FLOAT
);

CREATE TABLE Staging_EnergyPerPerson (
    Entity NVARCHAR(255),
    Code NVARCHAR(50),
    Year INT,
    EnergyPerPerson FLOAT
);

CREATE TABLE Staging_ElecBySource (
    Entity NVARCHAR(255),
    Code NVARCHAR(50),
    Year INT,
    Coal FLOAT, Gas FLOAT, Hydropower FLOAT, Solar FLOAT, Wind FLOAT, 
    Oil FLOAT, Nuclear FLOAT, OtherRenewables FLOAT, Bioenergy FLOAT
);

CREATE TABLE Staging_Kaggle (
    country NVARCHAR(255),
    year NVARCHAR(50),
    iso_code NVARCHAR(50),
    population NVARCHAR(255),
    gdp NVARCHAR(255),
    energy_per_capita NVARCHAR(255),
    energy_per_gdp NVARCHAR(255),
    electricity_demand NVARCHAR(255),
    electricity_generation NVARCHAR(255),
    fossil_fuel_consumption NVARCHAR(255),
    fossil_share_energy NVARCHAR(255),
    fossil_share_elec NVARCHAR(255),
    coal_consumption NVARCHAR(255),
    gas_consumption NVARCHAR(255),
    oil_consumption NVARCHAR(255),
    nuclear_consumption NVARCHAR(255),
    hydro_consumption NVARCHAR(255),
    renewables_consumption NVARCHAR(255),
    renewables_share_energy NVARCHAR(255),
    solar_consumption NVARCHAR(255),
    wind_consumption NVARCHAR(255),
    greenhouse_gas_emissions NVARCHAR(255),
    primary_energy_consumption NVARCHAR(255),
    per_capita_electricity NVARCHAR(255)
);
GO