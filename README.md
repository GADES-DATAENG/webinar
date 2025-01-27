# PySQLshop Data Repository

This repository contains the code necessary to build the data pipeline for **PySQLshop**, a fictional store. The code is designed for educational purposes and demonstrates how to set up and manage a data pipeline using **Airflow** and **DBT (Data Build Tool)** for data transformations with **BigQuery** as the target.

In this project, we use Docker to containerize Airflow, DBT, and related services. The DBT process uses the `dbt-bigquery` adapter to connect to Google BigQuery for data transformation tasks.

## Prerequisites

Before running this project, you need to have the following prerequisites:

1. **Docker** installed on your machine to build and run the containers.
2. **Docker Compose** installed to manage multi-container Docker applications.
3. **Google Cloud Service Account** with access to BigQuery, and the corresponding **JSON key file**.

   - Create a service account in Google Cloud with access to BigQuery. 
   - Download the service account key JSON file and place it in the root of this repository as `bigquery-service-account.json`.

## Setup Instructions

### Step 1: Clone the Repository

If you haven't already cloned the repository, you can do so by running the following command:

```bash
git clone git@github.com:GADES-DATAENG/webinar.git
cd webinar
```

### Step 2: Create your .env file
Before starting the services, you need to build the .env file with some variables. Please check the .env.template file and use it as
a template for your .env file.
```bash
cp .env.template .env
```

### Step 3: Get your GCP service account JSON credentials file
After downloading your GCP service account JSON credentials file, just past it under the keys folder with the name `gcp-key.json`

### Step 4: Build the Docker Image for DBT
Before starting the services, you need to build the DBT Docker image. Run the following command inside the repository folder:
```bash
docker build -t dbt-core .
```

This will build the `dbt-core` image based on the `Dockerfile` in the repository.

### Step 5: Start the Services with Docker Compose
Once the image is built, you can start the services (Airflow, DBT, and other dependencies) using Docker Compose. Run the following command:
```bash
docker-compose up -d
```

This command will start all the containers defined in the `docker-compose.yml` file. It will set up Airflow, DBT, and any necessary services, including BigQuery integration.

### Step 6: Access the Services
- **Airflow Web UI**: You can access the Airflow web interface at http://localhost:8080
    - Default login credentials are
        - **Username**: `airflow`
        - **Password**: `airflow`
- **DBT**: The DBT transformation will run inside the DBT container, triggered by the Airflow DAG

## Environment Setup
- The DBT container uses `dbt-bigquery` to interact with Google BigQuery
- The service account key file (`gcp-key.json`) should be inside the `keys` folder. DBT will use this file to authenticate and interact with BigQuery

Ensure that the key file is placed correctly in the repository folder as:
```bash
/webinar/gcp-key.json
```
### Step 7: Running the DAG
Airflow will trigger the DBT transformations according to the defined DAGs. You can monitor the progress of your tasks in the Airflow UI and view the logs for any issues or success.

## Example Command to Run DBT Manually (if needed)
If you need to run DBT manually inside the container, you can use the following command:
```bash
docker exec -it dbt-container dbt run
```
This will execute the DBT transformations inside the running container.

## Directory Structure
- `/dags`: Contains the Airflow DAGs that control the data pipeline.
- `/dbt`: Contains DBT models and configuration.
- `docker-compose.yml`: The Docker Compose configuration to run the services.
- `Dockerfile`: The Dockerfile for building the DBT container.
- `/keys/gcp-key.json`: Your Google Cloud service account JSON key file (not included in the repo for security reasons).

## License
This project is for educational purposes. Please do not use for production without proper security and configuration updates.