const { google } = require('googleapis');
const { auth } = require('./auth');
const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT;

const connectedSheet = async () => {
    const service = google.sheets({ version: 'v4', auth });

    const { data } = await service.spreadsheets.create({
        fields: 'spreadsheetId',
        requestBody: {
            dataSources: [
                {
                    dataSourceId: PROJECT_ID + '-data',
                    spec: {
                        bigQuery: {
                            projectId: PROJECT_ID,
                            tableSpec: {
                                tableProjectId: 'bigquery-public-data',
                                datasetId: 'chicago_taxi_trips',
                                tableId: 'taxi_trips',
                            },
                        },
                    },
                },
            ],
        },
    });

    const { spreadsheetId } = data;

    await service.spreadsheets.batchUpdate({
        spreadsheetId,
        requestBody: {
            requests: [
                { addSheet: { properties: { sheetId: 2 } } },
                {
                    addChart: {
                        chart: {
                            chartId: 1001,
                            position: { newSheet: true },
                            spec: {
                                pieChart: {
                                    domain: { columnReference: { name: 'payment_type' } },
                                    series: { columnReference: { name: 'fare' }, aggregateType: 'COUNT' },
                                },
                                dataSourceChartProperties: {
                                    dataSourceId: PROJECT_ID + '-data',
                                },
                            },
                        },
                    },
                },
                {
                    addChart: {
                        chart: {
                            chartId: 1002,
                            position: { newSheet: true },
                            spec: {
                                filterSpecs: [
                                    {
                                        filterCriteria: {
                                            condition: {
                                                type: 'TEXT_CONTAINS',
                                                values: { userEnteredValue: 'mobile' },
                                            },
                                        },
                                        dataSourceColumnReference: { name: 'payment_type' },
                                    },
                                ],
                                basicChart: {
                                    chartType: 'LINE',
                                    threeDimensional: false,
                                    domains: [
                                        {
                                            domain: {
                                                columnReference: { name: 'trip_start_timestamp' },
                                                groupRule: { dateTimeRule: { type: 'YEAR_MONTH' } },
                                            },
                                        },
                                    ],
                                    series: [{ series: { columnReference: { name: 'fare' }, aggregateType: 'SUM' } }],
                                },
                                dataSourceChartProperties: {
                                    dataSourceId: PROJECT_ID + '-data',
                                },
                            },
                        },
                    },
                },
                {
                    updateCells: {
                        range: { sheetId: 2 },
                        fields: 'userEnteredValue',
                        rows: [
                            {
                                values: [
                                    {
                                        userEnteredValue: {
                                            formulaValue: '=COUNTUNIQUE(taxi_trips!company)',
                                        },
                                    },
                                    {
                                        userEnteredValue: {
                                            formulaValue: '=COUNTIF(taxi_trips!tips,">0")',
                                        },
                                    },
                                    {
                                        userEnteredValue: {
                                            formulaValue: '=COUNTIF(taxi_trips!fare,">0")',
                                        },
                                    },
                                ],
                            },
                        ],
                    },
                },
                {
                    refreshDataSource: {
                        references: {
                            references: [
                                { dataSourceFormulaCell: { sheetId: 2, rowIndex: 0, columnIndex: 0 } },
                                { dataSourceFormulaCell: { sheetId: 2, rowIndex: 0, columnIndex: 1 } },
                                { dataSourceFormulaCell: { sheetId: 2, rowIndex: 0, columnIndex: 2 } },
                                { chartId: 1001 },
                                { chartId: 1002 },
                            ],
                        },
                    },
                },
            ],
        },
    });
};

exports.connectedSheet = connectedSheet;
