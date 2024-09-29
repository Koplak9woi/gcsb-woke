const { google } = require('googleapis');
const { auth } = require('./auth');

const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT;

const createProject = async () => {
    try {
        const service = google.script({ version: 'v1', auth });
        const { data } = await service.projects.create({ fields: 'scriptId', requestBody: { title: 'Hublaa Script' } });
        const { scriptId } = data;
        return { service, scriptId };
    } catch (e) {
        console.log(
            'AppScript Creation Failed, please open https://script.google.com/home/usersettings and turn on the API Access'
        );
        return createProject();
    }
};

const createScript = async (service, scriptId) => {
    try {
        await service.projects.updateContent({
            scriptId,
            requestBody: {
                files: [
                    {
                        name: 'appsscript',
                        type: 'json',
                        source: '{\n  "timeZone": "Asia/Jakarta",\n  "dependencies": {\n    "enabledAdvancedServices": [\n      {\n        "userSymbol": "BigQuery",\n        "version": "v2",\n        "serviceId": "bigquery"\n      }\n    ]\n  },\n  "exceptionLogging": "STACKDRIVER",\n  "runtimeVersion": "V8"\n}',
                    },
                    {
                        name: 'code',
                        type: 'SERVER_JS',
                        source: `\n// Filename for data results\nvar QUERY_NAME = \"Most common words in all of Shakespeare's works\";\nvar PROJECT_ID = \"${PROJECT_ID}\";\nif (!PROJECT_ID) throw Error('Project ID is required in setup');\n\nfunction runQuery() {\n  // Replace sample with your own BigQuery query.\n  var request = {\n    query:\n        'SELECT ' +\n            'LOWER(word) AS word, ' +\n            'SUM(word_count) AS count ' +\n        'FROM [bigquery-public-data:samples.shakespeare] ' +\n        'GROUP BY word ' +\n        'ORDER BY count ' +\n        'DESC LIMIT 10'\n  };\n  var queryResults = BigQuery.Jobs.query(request, PROJECT_ID);\n  var jobId = queryResults.jobReference.jobId;\n\n  // Wait for BQ job completion (with exponential backoff).\n  var sleepTimeMs = 500;\n  while (!queryResults.jobComplete) {\n    Utilities.sleep(sleepTimeMs);\n    sleepTimeMs *= 2;\n    queryResults = BigQuery.Jobs.getQueryResults(PROJECT_ID, jobId);\n  }\n\n  // Get all results from BigQuery.\n  var rows = queryResults.rows;\n  while (queryResults.pageToken) {\n    queryResults = BigQuery.Jobs.getQueryResults(PROJECT_ID, jobId, {\n      pageToken: queryResults.pageToken\n    });\n    rows = rows.concat(queryResults.rows);\n  }\n\n  // Return null if no data returned.\n  if (!rows) {\n    return Logger.log('No rows returned.');\n  }\n\n  // Create the new results spreadsheet.\n  var spreadsheet = SpreadsheetApp.create(QUERY_NAME);\n  var sheet = spreadsheet.getActiveSheet();\n\n  // Add headers to Sheet.\n  var headers = queryResults.schema.fields.map(function(field) {\n    return field.name.toUpperCase();\n  });\n  sheet.appendRow(headers);\n\n  // Append the results.\n  var data = new Array(rows.length);\n  for (var i = 0; i < rows.length; i++) {\n    var cols = rows[i].f;\n    data[i] = new Array(cols.length);\n    for (var j = 0; j < cols.length; j++) {\n      data[i][j] = cols[j].v;\n    }\n  }\n\n  // Start storing data in row 2, col 1\n  var START_ROW = 2;      // skip header row\n  var START_COL = 1;\n  sheet.getRange(START_ROW, START_COL, rows.length, headers.length).setValues(data);\n\n  Logger.log('Results spreadsheet created: %s', spreadsheet.getUrl());\n}`,
                    },
                ],
            },
        });
    } catch (e) {
        console.log('Updating Appscript Failed, Retrying...');
        return createScript(service, scriptId);
    }
};

const appScript = async () => {
    const { scriptId, service } = await createProject();
    await createScript(service, scriptId);

    console.log('Appscript Creation Succeess, Open and run the script manualy!');
    console.log('https://script.google.com/home/projects/' + scriptId);
};
exports.appScript = appScript;
