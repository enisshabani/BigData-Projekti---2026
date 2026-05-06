#  Analiza e të Dhënave të Energjisë 

Ky projekt implementon një pipeline të plotë të përpunimit dhe analizës së të dhënave në fushën e energjisë dhe ndikimit mjedisor. Qëllimi është transformimi i të dhënave nga Data Warehouse në insight-e të kuptueshme përmes vizualizimeve interaktive.

---

##  Objektivat Kryesore

* Analiza e emetimeve të CO2 dhe konsumit të energjisë për person
* Krahasimi i burimeve të energjisë (fossile vs. renewable)
* Identifikimi i trendeve ndër vite dhe dallimeve mes vendeve
* Transformimi i të dhënave në forma të ndryshme (relational → XML → visualization)

---

##  Arkitektura e Projektit (Data Pipeline)

Data → ETL → Data Warehouse → Analysis → Visualization → Insight

---

##  Fazat e Projektit

### 1. Data Exposure (SQL Server)

Në këtë fazë, të dhënat nga Data Warehouse janë transformuar në forma analitike për përdorim në BI tools.

* Views:

  * `v_ExecutiveSummary` – përmbledhje e indikatorëve kryesorë
  * `v_EnergyMixAnalysis` – shpërndarja e burimeve të energjisë
  * `v_EconomicImpact` – analiza e intensitetit të emetimeve

* Stored Procedures:

  * `sp_GetTopPolluters` – identifikimi i vendeve me ndotjen më të lartë
  * `sp_CompareCountryEnergy` – krahasim ndër vite për një vend

---

### 2. XML Data Manipulation

Të dhënat janë transformuar nga format relacional në XML për analizë të mëtejshme.

* Gjenerimi i XML nga SQL Server
* Përdorimi i XPath dhe XQuery për filtrim dhe analizë
* Demonstrimi i kalimit nga structured → semi-structured data

---

### 3. Data Visualization (Power BI)

Në këtë fazë janë ndërtuar dashboard-e interaktive për analizë dhe eksplorim të të dhënave.

* Integrimi i burimeve:

  * SQL Views
  * XML files

* Dashboard-e:

  * Executive Dashboard (KPI kryesore)
  * Analytical Dashboard (trende dhe krahasime)
  * Drill-down Dashboard (analizë e detajuar)

---

## Teknologjitë e Përdorura

* SQL Server (T-SQL)
* XML (XPath, XQuery)
* Power BI
* GitHub

---

## Rezultatet

Ky projekt demonstron një rrjedhë të plotë të përpunimit të të dhënave, duke mundësuar:

* identifikimin e trendeve të emetimeve të CO2
* analizën e përdorimit të energjisë së rinovueshme
* krahasime të qarta ndërmjet vendeve dhe viteve

Rezultati final është një sistem i strukturuar që transformon të dhënat komplekse në informacion të përdorshëm për vendimmarrje.

---

## Si të ekzekutohet projekti

1. Ekzekutoni skriptat SQL në databazën tuaj (SQL Server)
2. Gjeneroni dhe analizoni të dhënat XML
3. Hapni skedarin `.pbix` në Power BI
4. Eksploroni dashboard-et interaktive
