const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const { MongoClient } = require('mongodb');

// MongoDB Connection Configuration
// Make sure MongoDB is running locally on default port 27017.
const url = 'mongodb://127.0.0.1:27017';
const dbName = 'bigdata_phase3';

const sharedDataPath = path.join(__dirname, '..', 'shared_data');

function toNumber(value) {
    const parsed = parseFloat(value);
    return Number.isNaN(parsed) ? 0 : parsed;
}

async function readCsv(fileName, transformRow) {
    const filePath = path.join(sharedDataPath, fileName);
    const results = [];

    console.log(`Reading CSV from: ${filePath}`);

    await new Promise((resolve, reject) => {
        fs.createReadStream(filePath)
            .pipe(csv())
            .on('data', (data) => results.push(transformRow(data)))
            .on('end', () => resolve())
            .on('error', (err) => reject(err));
    });

    return results;
}

async function replaceCollection(db, collectionName, documents) {
    const collection = db.collection(collectionName);

    await collection.deleteMany({});

    if (documents.length > 0) {
        await collection.insertMany(documents);
    }

    await collection.createIndex({ country: 1, year: 1 });

    console.log(`- ${collectionName}: inserted ${documents.length} documents`);
}

async function importData() {
    const client = new MongoClient(url);

    try {
        console.log('Connecting to MongoDB...');
        await client.connect();
        console.log('Connected correctly to MongoDB server.');

        const db = client.db(dbName);

        const countryProfiles = await readCsv('country_yearly_profile.csv', (data) => ({
            country: data.CountryName,
            iso_code: data.ISOCode,
            year: parseInt(data.Year, 10),
            co2_per_capita: toNumber(data.CO2PerCapita),
            energy_per_person: toNumber(data.EnergyPerPerson),
            electricity_sources: {
                coal: toNumber(data.Coal),
                gas: toNumber(data.Gas),
                solar: toNumber(data.Solar),
                wind: toNumber(data.Wind),
                hydro: toNumber(data.Hydro),
            },
            renewable_share: toNumber(data.RenewableShare),
        }));

        const executiveSummary = await readCsv('executive_summary.csv', (data) => ({
            country: data.CountryName,
            year: parseInt(data.Year, 10),
            co2_per_capita: toNumber(data.CO2PerCapita),
            energy_per_person: toNumber(data.EnergyPerPerson),
            total_renewable_pct: toNumber(data.TotalRenewable_Pct),
        }));

        const energyMixAnalysis = await readCsv('energy_mix_analysis.csv', (data) => ({
            country: data.CountryName,
            year: parseInt(data.Year, 10),
            coal_pct: toNumber(data.Coal_Pct),
            gas_pct: toNumber(data.Gas_Pct),
            hydro_pct: toNumber(data.Hydro_Pct),
            solar_pct: toNumber(data.Solar_Pct),
            wind_pct: toNumber(data.Wind_Pct),
        }));

        console.log('\nReplacing MongoDB collections...');
        await replaceCollection(db, 'country_energy_profiles', countryProfiles);
        await replaceCollection(db, 'executive_summary', executiveSummary);
        await replaceCollection(db, 'energy_mix_analysis', energyMixAnalysis);

        const sampleDoc = await db.collection('country_energy_profiles').findOne({});
        console.log('\n--- Sample Document in MongoDB ---');
        console.log(JSON.stringify(sampleDoc, null, 2));

        console.log('\nData Migration Completed!');
    } catch (err) {
        console.error('Error during data import:', err);
    } finally {
        await client.close();
    }
}

importData();
