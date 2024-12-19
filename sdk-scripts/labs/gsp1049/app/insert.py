
from google.cloud import spanner
from google.cloud.spanner_v1 import param_types
INSTANCE_ID = "banking-instance"
DATABASE_ID = "banking-db"
spanner_client = spanner.Client()
instance = spanner_client.instance(INSTANCE_ID)
database = instance.database(DATABASE_ID)
def insert_customer(transaction):
    row_ct = transaction.execute_update(
        "INSERT INTO Customer (CustomerId, Name, Location)"
        "VALUES ('b2b4002d-7813-4551-b83b-366ef95f9273', 'Shana Underwood', 'Ely Iowa')"
    )
    print("{} record(s) inserted.".format(row_ct))
database.run_in_transaction(insert_customer)