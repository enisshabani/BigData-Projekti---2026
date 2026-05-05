USE BigData_Group24;
GO

/*
14_ExportAllViewsToXML.sql
Purpose: Produce XML exports for all analytical views so you can save them
         as .xml files for Power BI or other tools.

How it works:
- The script builds XML variables for each view using `FOR XML PATH` and prints them.
- To save each XML to file non-interactively, use `sqlcmd` or `bcp` from the shell
  (examples below).

Notes:
- If your database is named `EnergyDW`, update the `USE` statement.
- Run ETL / ensure views are populated before running this script.
*/

-- Export v_ExecutiveSummary
DECLARE @XML_Executive XML;
SET @XML_Executive = (
    SELECT CountryName AS '@Country', Year AS '@Year', CO2PerCapita, EnergyPerPerson, TotalRenewable_Pct
    FROM v_ExecutiveSummary
    FOR XML PATH('Record'), ROOT('ExecutiveSummary')
);
PRINT '=== EXECUTIVE SUMMARY XML ===';
SELECT @XML_Executive;
GO

-- Export v_EnergyMixAnalysis
DECLARE @XML_EnergyMix XML;
SET @XML_EnergyMix = (
    SELECT CountryName AS '@Country', Year AS '@Year', Coal_Pct AS 'Coal', Gas_Pct AS 'Gas', Hydro_Pct AS 'Hydro', Solar_Pct AS 'Solar', Wind_Pct AS 'Wind'
    FROM v_EnergyMixAnalysis
    FOR XML PATH('MixRecord'), ROOT('EnergyMixAnalysis')
);
PRINT '=== ENERGY MIX ANALYSIS XML ===';
SELECT @XML_EnergyMix;
GO

-- Export v_CountryYearlyProfile
DECLARE @XML_CountryProfile XML;
SET @XML_CountryProfile = (
    SELECT CountryName AS '@Country', Year AS '@Year', CO2PerCapita, EnergyPerPerson, Coal_Pct, Solar_Pct, Wind_Pct, (Coal_Pct + Solar_Pct + Wind_Pct) AS TotalRenewable
    FROM v_CountryYearlyProfile
    FOR XML PATH('Profile'), ROOT('CountryYearlyProfiles')
);
PRINT '=== COUNTRY YEARLY PROFILE XML ===';
SELECT @XML_CountryProfile;
GO

-- Export v_GlobalYearlyTrends
DECLARE @XML_GlobalTrends XML;
SET @XML_GlobalTrends = (
    SELECT Year AS '@Year', AvgCO2 AS 'AvgCO2', AvgEnergyUsage AS 'AvgEnergy', AvgCoalUsage AS 'AvgCoal'
    FROM v_GlobalYearlyTrends
    FOR XML PATH('YearSummary'), ROOT('GlobalYearlyTrends')
);
PRINT '=== GLOBAL YEARLY TRENDS XML ===';
SELECT @XML_GlobalTrends;
GO

-- Export v_RenewableRankings
DECLARE @XML_RenewRank XML;
SET @XML_RenewRank = (
    SELECT CountryName AS '@Country', Year AS '@Year', RenewablePct, RankInYear
    FROM v_RenewableRankings
    FOR XML PATH('Ranking'), ROOT('RenewableRankings')
);
PRINT '=== RENEWABLE RANKINGS XML ===';
SELECT @XML_RenewRank;
GO

-- Export v_EconomicImpact
DECLARE @XML_EconImpact XML;
SET @XML_EconImpact = (
    SELECT CountryName AS '@Country', Year AS '@Year', CO2PerCapita, EmissionIntensity
    FROM v_EconomicImpact
    FOR XML PATH('Record'), ROOT('EconomicImpact')
);
PRINT '=== ECONOMIC IMPACT XML ===';
SELECT @XML_EconImpact;
GO

/*
Shell examples to save each XML to a file using `sqlcmd` (cross-platform) or `bcp`.

1) Using sqlcmd (outputs the FIRST result set to file). Replace <SERVER> and auth as needed.

-- Export v_ExecutiveSummary to executive_summary.xml
sqlcmd -S <SERVER> -d BigData_Group24 -U <user> -P <pass> -Q "SET NOCOUNT ON; SELECT CountryName AS '@Country', Year AS '@Year', CO2PerCapita, EnergyPerPerson, TotalRenewable_Pct FROM v_ExecutiveSummary FOR XML PATH('Record'), ROOT('ExecutiveSummary')" -o executive_summary.xml -s "" -W -w 7000

Notes about sqlcmd flags:
- `-s ""` removes column separators
- `-W` removes trailing spaces
- `-w 7000` increases output width to avoid line breaks

2) Using bcp (fast, good for large exports):

bcp "SET NOCOUNT ON; SELECT CountryName AS '@Country', Year AS '@Year', CO2PerCapita, EnergyPerPerson, TotalRenewable_Pct FROM v_ExecutiveSummary FOR XML PATH('Record'), ROOT('ExecutiveSummary')" queryout executive_summary.xml -S <SERVER> -d BigData_Group24 -U <user> -P <pass> -c

Replace auth with `-T` for integrated auth on Windows.

If you prefer to run everything interactively in SSMS, simply execute this script and right-click each XML result -> Save Results As -> XML file.
*/

PRINT '14_ExportAllViewsToXML script completed. Use sqlcmd/bcp examples to save files.';
GO
