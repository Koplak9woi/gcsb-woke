const fs = require('fs');
require('dotenv').config();
const { connectedSheet } = require('./connected-sheets');
const { driveUpload } = require('./drive-upload');
const { appScript } = require('./app-script');

const runner = async () => {
    appScript();
    connectedSheet();
    driveUpload(
        {
            mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            body: fs.createReadStream('./files/task4.xlsx'),
        },
        {
            name: 'task4',
            mimeType: 'application/vnd.google-apps.spreadsheet',
        }
    );
};

runner();
