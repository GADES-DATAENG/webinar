import os
from google.cloud import bigquery


def check_and_create_dataset(dataset_id: str, location: str):
    """
    Check if a BigQuery dataset exists. If it doesn't, create it.

    Args:
    - dataset_id (str): The ID of the dataset to check or create.
    - project_id (str): The Google Cloud project ID.

    Returns:
    - str: A message indicating whether the dataset was created or already exists.
    """
    # Initialize the BigQuery client
    client = bigquery.Client.from_service_account_json('/opt/airflow/keys/gcp-key.json')
    
    # Create a reference to the dataset
    dataset_ref = client.dataset(dataset_id)
    
    try:
        # Try to fetch the dataset to check if it exists
        client.get_dataset(dataset_ref)
        return f"Dataset '{dataset_id}' already exists."
    
    except Exception as e:
        # If dataset doesn't exist, create it
        dataset = bigquery.Dataset(dataset_ref)
        dataset.location = location  # Set the location, change if necessary
        client.create_dataset(dataset)
        return f"Dataset '{dataset_id}' created successfully."


def check_and_create_table(project_id, dataset_id, table_id, sql_file_path):
    print('Getting Bigquery Client...')
    # Initialize the BigQuery client
    client = bigquery.Client.from_service_account_json('/opt/airflow/keys/gcp-key.json')
    
    # Define the table reference
    table_ref = client.dataset(dataset_id).table(table_id)

    # Check if the table exists
    try:
        # Try to fetch the table metadata
        client.get_table(table_ref)
        print(f"Table {table_id} already exists in dataset {dataset_id}.")
        return  # Table exists, exit the function
    except Exception as e:
        # If table does not exist, create it
        print(f"Table {table_id} does not exist. Creating it using the provided SQL.")
        
        # Read the SQL file to create the table
        with open(sql_file_path, 'r') as sql_file:
            sql_query = sql_file.read()

        sql_query = sql_query.replace(
            'GCP_PROJECT_ID',
            project_id
        ).replace(
            'DATASET_ID',
            dataset_id
        )
        
        # Run the SQL query to create the table
        query_job = client.query(sql_query)
        
        # Wait for the job to complete
        query_job.result()
        
        print(f"Table {table_id} has been successfully created.")


def load_data_into_table(df, dataset_id, table_id):
    # Initialize the BigQuery client
    client = bigquery.Client.from_service_account_json('/opt/airflow/keys/gcp-key.json')
    
    table_ref = client.dataset(dataset_id).table(table_id)
    
    job = client.load_table_from_dataframe(df, table_ref)
    
    # Wait for the job to complete
    job.result()
    
    return None