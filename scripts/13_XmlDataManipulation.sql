USE BigData_Group24;
GO

/*
13_XmlDataManipulation.sql
Purpose: Generate XML from analytic views, demonstrate XPath and XQuery examples,
         and document each operation (Goal / Input / Output).

Assumption: Database name is `BigData_Group24`. If you prefer `EnergyDW`,
update the `USE` statement at the top of this file.
*/

-- =====================================================
-- SECTION 1: EXPORT XML FROM VIEWS
-- =====================================================
-- Operation 1.1 - Export `v_ExecutiveSummary` as XML
-- Goal  : Produce XML of executive summary (one record per country/year).
-- Input : View `v_ExecutiveSummary` (CountryName, Year, CO2PerCapita, EnergyPerPerson, TotalRenewable_Pct)
-- Output: XML variable `@XMLExec` with root `ExecutiveData` and child `Record` elements.
DECLARE @XMLExec XML;

SET @XMLExec = (
    SELECT
        CountryName AS '@Country',
        Year AS '@Year',
        CO2PerCapita,
        EnergyPerPerson,
        TotalRenewable_Pct
    FROM v_ExecutiveSummary
    FOR XML PATH('Record'), ROOT('ExecutiveData')
);

PRINT '=== EXECUTIVE SUMMARY XML ===';
SELECT @XMLExec;
GO

-- Operation 1.2 - Export `v_EnergyMixAnalysis` as XML
-- Goal  : Produce XML containing energy mix by country/year.
-- Input : View `v_EnergyMixAnalysis` (Coal_Pct, Gas_Pct, Hydro_Pct, Solar_Pct, Wind_Pct)
-- Output: XML variable `@XMLEnergyMix` with root `EnergyMixData` and child `MixRecord` elements.
DECLARE @XMLEnergyMix XML;

SET @XMLEnergyMix = (
    SELECT
        CountryName AS '@Country',
        Year AS '@Year',
        Coal_Pct AS 'Coal',
        Gas_Pct  AS 'Gas',
        Hydro_Pct AS 'Hydro',
        Solar_Pct AS 'Solar',
        Wind_Pct AS 'Wind'
    FROM v_EnergyMixAnalysis
    FOR XML PATH('MixRecord'), ROOT('EnergyMixData')
);

PRINT '=== ENERGY MIX XML ===';
SELECT @XMLEnergyMix;
GO


-- =====================================================
-- SECTION 2: XPATH EXAMPLES (2 examples)
-- =====================================================
-- XPath Example 1: Extract Country, Year and CO2 from `@XMLExec`
-- Goal  : List all countries with their CO2 values from the executive XML.
-- Input : `@XMLExec` (ExecutiveData/Record)
-- Output: Rows with Country, Year, CO2PerCapita
PRINT '=== XPath Example 1: Countries and CO2 ===';
SELECT
    R.C.value('@Country', 'NVARCHAR(255)') AS Country,
    R.C.value('@Year', 'INT') AS Year,
    R.C.value('(CO2PerCapita)[1]', 'FLOAT') AS CO2PerCapita
FROM @XMLExec.nodes('/ExecutiveData/Record') R(C)
WHERE R.C.value('(CO2PerCapita)[1]', 'FLOAT') IS NOT NULL;
GO

-- XPath Example 2: Extract renewable parts from `@XMLEnergyMix` for latest year
-- Goal  : Get Solar/Wind/Hydro percentages for the most recent year in the XML.
-- Input : `@XMLEnergyMix` (EnergyMixData/MixRecord)
-- Output: Rows with Country, Year, Solar, Wind, Hydro
PRINT '=== XPath Example 2: Renewables (latest year) ===';
DECLARE @LatestYear INT = (
    SELECT MAX(CAST(X.M.value('@Year','INT') AS INT))
    FROM @XMLEnergyMix.nodes('/EnergyMixData/MixRecord') X(M)
);

SELECT
    M.C.value('@Country', 'NVARCHAR(255)') AS Country,
    M.C.value('@Year', 'INT') AS Year,
    CAST(M.C.value('(Solar)[1]', 'NVARCHAR(20)') AS FLOAT) AS SolarPercent,
    CAST(M.C.value('(Wind)[1]', 'NVARCHAR(20)') AS FLOAT) AS WindPercent,
    CAST(M.C.value('(Hydro)[1]', 'NVARCHAR(20)') AS FLOAT) AS HydroPercent
FROM @XMLEnergyMix.nodes('/EnergyMixData/MixRecord') M(C)
WHERE M.C.value('@Year', 'INT') = @LatestYear;
GO


-- =====================================================
-- SECTION 3: XQUERY EXAMPLES (2 examples)
-- =====================================================
-- XQuery Example 1: Return XML of records where CO2PerCapita > threshold
-- Goal  : Produce a filtered XML fragment containing high-CO2 countries.
-- Input : `@XMLExec` and a numeric threshold @CO2Thresh
-- Output: XML fragment from `@XMLExec` with matching `Record` nodes
PRINT '=== XQuery Example 1: High CO2 Countries (XML fragment) ===';
DECLARE @CO2Thresh FLOAT = 5.0;
SELECT @XMLExec.query('/ExecutiveData/Record[CO2PerCapita > sql:variable("@CO2Thresh")]') AS HighCO2_XML;
GO

-- XQuery Example 2: Use .nodes() + value() to list countries with TotalRenewable_Pct > 50
-- Goal  : Find countries with high renewable share using XQuery-aware extraction
-- Input : `@XMLExec`
-- Output: Rows with Country, Year, TotalRenewable_Pct
PRINT '=== XQuery Example 2: High Renewables Countries ===';
SELECT
    X.C.value('@Country', 'NVARCHAR(255)') AS Country,
    X.C.value('@Year', 'INT') AS Year,
    CAST(X.C.value('(TotalRenewable_Pct)[1]', 'NVARCHAR(20)') AS FLOAT) AS TotalRenewable_Pct
FROM @XMLExec.nodes('/ExecutiveData/Record') X(C)
WHERE CAST(X.C.value('(TotalRenewable_Pct)[1]', 'NVARCHAR(20)') AS FLOAT) > 50;
GO


-- =====================================================
-- SECTION 4: DOCUMENTATION SUMMARY
-- =====================================================
/*
Summary of operations in this file:

- Export from `v_ExecutiveSummary` into `@XMLExec`
  Goal: Provide a single XML snapshot of executive metrics per country/year.
  Input: `v_ExecutiveSummary` view
  Output: `@XMLExec` (XML) printed to results and usable for XPath/XQuery operations.

- Export from `v_EnergyMixAnalysis` into `@XMLEnergyMix`
  Goal: Provide energy-mix XML snapshot for analytical queries.
  Input: `v_EnergyMixAnalysis` view
  Output: `@XMLEnergyMix` (XML) printed to results.

- XPath & XQuery examples demonstrate extraction and filtering of XML data
  produced above. You can adapt thresholds and predicates for BI requirements.

How to use:
1) Run this script in SSMS or sqlcmd against the target database.
2) Save the XML result from the SELECT of `@FullXML` or the individual XML variables
   (right-click result grid -> Save Results As -> XML file) to produce the `.xml` file
   used by Power BI or other tools.

Notes:
- If your deployed DB is named `EnergyDW`, change the `USE` statement accordingly.
- This script assumes the views (`v_ExecutiveSummary`, `v_EnergyMixAnalysis`) exist
  and are populated. Run ETL/setup scripts before executing this file.
*/

PRINT '13_XmlDataManipulation script completed.';
GO
