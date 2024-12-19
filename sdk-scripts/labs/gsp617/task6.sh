bq mk --project_id=$PROJECT_ID \
    --table \
    --schema=schema.json \
    --description "Table for race details" \
    $PROJECT_ID:bq_logs.cloudaudit_googleapis_com_data_access_20240910

# bq load --project_id=$PROJECT_ID \
#   --source_format=NEWLINE_DELIMITED_JSON \
#   --autodetect $PROJECT_ID:bq_logs.cloudaudit_googleapis_com_data_access_20240910 data.json

COMMAND='bq query --project_id=$PROJECT_ID --use_legacy_sql=false "CREATE OR REPLACE VIEW \`$PROJECT_ID.bq_logs.v_querylogs\` AS SELECT resource.labels.project_id, protopayload_auditlog.authenticationInfo.principalEmail, protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobConfiguration.query.query, protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobConfiguration.query.statementType, protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatus.error.message, protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.startTime, protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.endTime, TIMESTAMP_DIFF(protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.endTime, protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.startTime, MILLISECOND)/1000 AS run_seconds, protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalProcessedBytes, protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalSlotMs, ARRAY(SELECT as STRUCT datasetid, tableId FROM UNNEST(protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.referencedTables)) as tables_ref, protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalTablesProcessed, protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.queryOutputRowCount, severity FROM \`$PROJECT_ID.bq_logs.cloudaudit_googleapis_com_data_access_*\` ORDER BY startTime;"'

# Run the command until it succeeds
until eval "$COMMAND"
do
    echo "Command failed, retrying..."
done