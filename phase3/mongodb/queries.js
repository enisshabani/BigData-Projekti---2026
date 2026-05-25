const { MongoClient } = require('mongodb');

// MongoDB Connection Configuration
const url = 'mongodb://127.0.0.1:27017';
const dbName = 'bigdata_phase3';
const collectionName = 'country_energy_profiles';

async function runQueries() {
    const client = new MongoClient(url);

    try {
        await client.connect();
        console.log('Connected to MongoDB.\n');
        const collection = client.db(dbName).collection(collectionName);

        // We use a specific year for consistent reporting
        const yearToQuery = 2022;

        // =====================================================================
        // Query 1: Top 10 CO2 emitting countries for a selected year
        // =====================================================================
        console.log(`--- Query 1: Top 10 CO2 Emitting Countries in ${yearToQuery} ---`);
        const topPolluters = await collection.find({ year: yearToQuery, co2_per_capita: { $gt: 0 } })
            .sort({ co2_per_capita: -1 }) // Sort descending
            .limit(10) // Take top 10
            .project({ _id: 0, country: 1, co2_per_capita: 1 }) // Only return specific fields
            .toArray();
            
        console.table(topPolluters);

        // =====================================================================
        // Query 2: Top 10 renewable energy leaders by renewable_share
        // =====================================================================
        console.log(`\n--- Query 2: Top 10 Renewable Energy Leaders in ${yearToQuery} ---`);
        const topRenewable = await collection.find({ year: yearToQuery })
            .sort({ renewable_share: -1 }) // Sort descending
            .limit(10) // Take top 10
            .project({ _id: 0, country: 1, renewable_share: 1 }) // Only return specific fields
            .toArray();
            
        console.table(topRenewable);

    } catch (err) {
        console.error('Error running queries:', err);
    } finally {
        await client.close();
    }
}

runQueries();