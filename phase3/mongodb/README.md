# Phase 3 - Part A: MongoDB Migration

This folder contains the Phase 3 implementation for migrating our dataset from a Relational Data Warehouse (SQL Server - Phase 1) into a Document-Oriented NoSQL database (MongoDB).

## Connection to Phase 1
In Phase 1, our data was scattered across a Star Schema inside SQL Server (`DimCountry`, `DimTime`, `Fact_EnvironmentalImpact`, `Fact_ElectricitySources`). 
For Phase 3, we extract that data, denormalize it, and load it into MongoDB as embedded documents. This drastically improves read performance for our analytical queries because all data for a specific country in a specific year is stored in exactly one document—meaning no computationally expensive `JOIN` operations are needed!

## Setup Requirements
1. **Node.js** must be installed on your machine.
2. **MongoDB** must be running locally on the default port `27017` (either installed locally or running via Docker).

## Installation
Navigate to this folder (`phase3/mongodb/`) from your terminal and install the Node dependencies:
```bash
npm install
```

## Running the Scripts

### 1. Import Data
To read the CSV from `shared-data` and insert the documents into the `bigdata_phase3` MongoDB database, run:
```bash
node import_data.js
```
**Expected Output:**
- A connection success message.
- "Parsed [number] rows from CSV".
- Number of new documents created / updated.
- A printed JSON sample of a created document.

### 2. Run Analytical Queries
To execute the two equivalent analytical queries adapted from Phase 1, run:
```bash
node queries.js
```
**Expected Output:**
- A neatly formatted table displaying the Top 10 CO2 Emitting Countries for the year 2022.
- A neatly formatted table displaying the Top 10 Renewable Energy Leaders for the year 2022.