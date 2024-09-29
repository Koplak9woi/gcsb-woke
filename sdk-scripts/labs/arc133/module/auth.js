const { GoogleAuth } = require('google-auth-library');

const auth = new GoogleAuth({
    scopes: [
        'https://www.googleapis.com/auth/drive',
        'https://www.googleapis.com/auth/spreadsheets',
        'https://www.googleapis.com/auth/bigquery',
        'https://www.googleapis.com/auth/script.cpanel',
        'https://www.googleapis.com/auth/script.scriptapp',
        'https://www.googleapis.com/auth/script.storage',
    ],
});

exports.auth = auth;
