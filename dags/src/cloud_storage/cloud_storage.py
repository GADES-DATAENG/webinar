from google.cloud import storage

def get_gcs_object(bucket_name, file_name):
    # Initialize GCS client
    storage_client = storage.Client.from_service_account_json('/opt/airflow/keys/gcp-key.json')

    # Download CSV file from GCS to a Pandas DataFrame
    bucket = storage_client.get_bucket(bucket_name)
    return bucket.blob(file_name)