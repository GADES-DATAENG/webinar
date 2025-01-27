import uuid
from datetime import datetime
from src.helpers import load_csv_to_bigquery
from airflow import DAG
from airflow.models import Variable
from airflow.utils.dates import days_ago
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.transfers.local_to_gcs import LocalFilesystemToGCSOperator
from airflow.datasets import Dataset


# Configuration
BUCKET_NAME = Variable.get("BRONZE_GCS_BUCKET_NAME")
LOCAL_CSV_PATH = f"{Variable.get("LOCAL_FILE_PATH")}/olist_order_items_dataset.csv"
PROJECT_ID = Variable.get("GCP_PROJECT_ID")
BRONZE_DATASET = Variable.get("BRONZE_BIGQUERY_DATASET")
BIGQUERY_TABLE = f"{PROJECT_ID}.{BRONZE_DATASET}.bronze_order_items"
BIGQUERY_LOCATION = Variable.get("GCP_LOCATION")


def generate_unique_file_name(**kwargs):
    """Generate a unique file name using UUID and push it to XCom."""
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    unique_id = uuid.uuid4().hex[:5]
    unique_file_name = f"order_items/data_{unique_id}_{timestamp}.csv"
    kwargs['ti'].xcom_push(key='uploaded_file', value=unique_file_name)


def load_csv_to_bigquery_task(**kwargs):
    load_csv_to_bigquery(
        bucket_name=BUCKET_NAME,
        file_name=kwargs['ti'].xcom_pull(task_ids='generate_unique_file_name', key='uploaded_file'),
        bigquery_table_id=BIGQUERY_TABLE,
        project_id=PROJECT_ID,
        location=BIGQUERY_LOCATION
    )


with DAG(
    dag_id="bronze_order_items",
    start_date=days_ago(1),
    schedule_interval=None,
    catchup=False,
    tags=["bigquery", "pysqlshop", "bronze_layer", "order_items"],
) as dag:

    generate_file_name_task = PythonOperator(
        task_id="generate_unique_file_name",
        python_callable=generate_unique_file_name,
        provide_context=True,
    )

    upload_to_gcs_task = LocalFilesystemToGCSOperator(
        task_id="upload_csv_to_gcs",
        src=LOCAL_CSV_PATH,
        dst="{{ ti.xcom_pull(task_ids='generate_unique_file_name', key='uploaded_file') }}",
        bucket=BUCKET_NAME,
    )

    load_to_bq = PythonOperator(
        task_id='load_to_bigquery',
        python_callable=load_csv_to_bigquery_task,
        dag=dag,
        outlets=[Dataset("bronze_order_items_dataset_ready")] # This indicates that this task writes to the dataset
    )

    generate_file_name_task.set_downstream(upload_to_gcs_task)
    upload_to_gcs_task.set_downstream(load_to_bq)
