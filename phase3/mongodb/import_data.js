const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const { MongoClient } = require('mongodb');

// MongoDB Connection Configuration
// Make sure MongoDB is running locally on default port 27017
const url = 'mongodb://127.0.0.1:27017';
const dbName = 'bigdata_phase3';
const collectionName = 'country_energy_profiles';

// Path to our CSV file generated from the DWH in Phase 1
const csvFilePath = path.join(__dirname, '..', 'shared_data', 'country_yearly_profile.csv');

async function importData() {
    const client = new MongoClient(url);
    
    try {
        console.log('Connecting to MongoDB...');
        await client.connect();
        console.log('Connected correctly to MongoDB server.');
        
        const db = client.db(dbName);
        const collection = db.collection(collectionName);
        
        const results = [];
        
        // 1. Read and parse the CSV file
        console.log(`Reading CSV from: ${csvFilePath}`);
        await new Promise((resolve, reject) => {
            fs.createReadStream(csvFilePath)
                .pipe(csv())
                .on('data', (data) => {
                    // 2. Transform the flat relational row into the NoSQL document structure
                    // Using the exact CSV columns: CountryName,ISOCode,Year,CO2PerCapita,EnergyPerPerson,Coal,Gas,Solar,Wind,Hydro,RenewableShare
                    
                    const doc = {
                        country: data.CountryName,
                        iso_code: data.ISOCode,
                        year: parseInt(data.Year, 10),
                        co2_per_capita: parseFloat(data.CO2PerCapita) || 0,
                        energy_per_person: parseFloat(data.EnergyPerPerson) || 0,
                        
                        // Embedding related attributes in a sub-document
                        electricity_sources: {
                            coal: parseFloat(data.Coal) || 0,
                            gas: parseFloat(data.Gas) || 0,
                            solar: parseFloat(data.Solar) || 0,
                            wind: parseFloat(data.Wind) || 0,
                            hydro: parseFloat(data.Hydro) || 0
                        },
                        
                        renewable_share: parseFloat(data.RenewableShare) || 0
                    };
                    results.push(doc);
                })
                .on('end', () => resolve())
                .on('error', (err) => reject(err));
        });

        console.log(`Parsed ${results.length} rows from CSV.`);

        // 3. Insert or Update documents in MongoDB safely
        let upsertedCount = 0;
        let modifiedCount = 0;

        for (const doc of results) {
            // Using country and year as the unique identifier to prevent duplicates
            const query = { country: doc.country, year: doc.year };
            const update = { $set: doc };
            const options = { upsert: true }; // upsert: insert if it doesn't exist, update if it does

            const result = await collection.updateOne(query, update, options);
            if (result.upsertedCount > 0) upsertedCount++;
            if (result.modifiedCount > 0) modifiedCount++;
        }

        console.log(`\nData Migration Completed!`);
        console.log(`- New documents created: ${upsertedCount}`);
        console.log(`- Existing documents updated: ${modifiedCount}`);

        // 4. Print one sample document for verification
        const sampleDoc = await collection.findOne({});
        console.log('\n--- Sample Document in MongoDB ---');
        console.log(JSON.stringify(sampleDoc, null, 2));

    } catch (err) {
        console.error('Error during data import:', err);
    } finally {
        // Ensure connection is closed
        await client.close();
    }
}

importData();