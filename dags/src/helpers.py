import pandas as pd
from io import StringIO
from pandas_gbq import to_gbq
from src.bigquery import bigquery
from datetime import datetime
from src.cloud_storage import cloud_storage


def load_csv_to_bigquery(bucket_name, file_name, bigquery_table_id, project_id, location):
    print('Starting!!!')
    bigquery.check_and_create_dataset(
        dataset_id=bigquery_table_id.split('.')[1],
        location=location
    )
    
    bigquery.check_and_create_table(
        project_id=project_id, 
        dataset_id=bigquery_table_id.split('.')[1],
        table_id=bigquery_table_id.split('.')[2], 
        sql_file_path=f'/opt/airflow/dags/src/ddl/{bigquery_table_id.split('.')[1]}/{bigquery_table_id.split('.')[2]}.sql'
    )
    
    object_blob = cloud_storage.get_gcs_object(
        bucket_name=bucket_name, 
        file_name=file_name
    )

    # Use StringIO to convert the string into a file-like object
    csv_file = StringIO(object_blob.download_as_text())

    # Download the content of the blob into memory and read it as a DataFrame
    df = pd.read_csv(csv_file)
    
    # Add the 'audit_load_at' column with the current timestamp
    df['audit_load_at'] = datetime.now()
    df['filename'] = file_name
   
    bigquery.load_data_into_table(
        df=df,
        dataset_id=bigquery_table_id.split('.')[1],
        table_id=bigquery_table_id.split('.')[2]
    )
    return