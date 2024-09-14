const csv = require('csv-parse');
const fs = require('fs');
const { Firestore } = require('@google-cloud/firestore');
require('dotenv').config();

async function writeToFirestore(records) {
    const db = new Firestore({
        // projectId: projectId
    });
    const batch = db.batch();

    records.forEach((record) => {
        console.log(`Write: ${record.email}`);
        const docRef = db.collection('customers').doc(record.email);
        batch.set(docRef, record, { merge: true });
    });

    try {
        await batch.commit();
        console.log('Batch executed');
    } catch (err) {
        console.log(`Batch error: ${err}`);
    }
    return;
}

async function importCsv(csvFilename) {
    const parser = csv.parse({ columns: true, delimiter: ',' }, async function (err, records) {
        if (err) {
            console.error('Error parsing CSV:', err);
            return;
        }

        try {
            console.log('Call write to Firestore');
            await writeToFirestore(records);
            console.log(`Wrote ${records.length} records`);
        } catch (e) {
            console.error(e);
            process.exit(1);
        }
    });

    await fs.createReadStream(csvFilename).pipe(parser);
}

if (process.argv.length < 3) {
    console.error('Please include a path to a csv file');
    process.exit(1);
}

importCsv(process.argv[2]).catch((e) => console.error(e));
