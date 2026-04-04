-- 4. PROCEDURA ETL
CREATE PROCEDURE sp_LoadDataWarehouse
AS
BEGIN
    SET NOCOUNT ON;

    -- Pastrimi i të dhënave ekzistuese
    DELETE FROM Fact_EnvironmentalImpact;
    DELETE FROM Fact_ElectricitySources;
    DELETE FROM DimCountry;
    DELETE FROM DimTime;

    -- Popullimi i DimCountry nga Staging
    INSERT INTO DimCountry (CountryName, ISOCode)
    SELECT DISTINCT Entity, Code FROM Staging_CO2Emissions WHERE Entity IS NOT NULL;

    -- Popullimi i DimTime nga Staging
    INSERT INTO DimTime (Year)
    SELECT DISTINCT Year FROM Staging_CO2Emissions WHERE Year IS NOT NULL;

    -- Mbushja e Fact 1 (Lidh CO2 me Energjinë)
    INSERT INTO Fact_EnvironmentalImpact (CountryKey, TimeKey, CO2PerCapita, EnergyPerPerson)
    SELECT c.CountryKey, t.TimeKey, s1.CO2PerCapita, s2.EnergyPerPerson
    FROM Staging_CO2Emissions s1
    JOIN Staging_EnergyPerPerson s2 ON s1.Entity = s2.Entity AND s1.Year = s2.Year
    JOIN DimCountry c ON s1.Entity = c.CountryName
    JOIN DimTime t ON s1.Year = t.Year;

    -- Mbushja e Fact 2 (Burimet e Elektricitetit)
    INSERT INTO Fact_ElectricitySources (CountryKey, TimeKey, Coal_Pct, Gas_Pct, Hydro_Pct, Solar_Pct, Wind_Pct)
    SELECT c.CountryKey, t.TimeKey, s.Coal, s.Gas, s.Hydropower, s.Solar, s.Wind
    FROM Staging_ElecBySource s
    JOIN DimCountry c ON s.Entity = c.CountryName
    JOIN DimTime t ON s.Year = t.Year;

    PRINT 'Data Warehouse u mbush me sukses!';
END
GO