# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Set the working directory inside the container
WORKDIR /usr/app

# Install necessary system dependencies
RUN apt-get update && \
    apt-get install -y gcc g++ libsasl2-dev libssl-dev libffi-dev jq && \
    apt-get clean

# Install dbt-core and the BigQuery adapter
RUN pip install --upgrade pip
RUN pip install dbt-core dbt-bigquery

# Copy your DBT project (if needed)
# COPY ./dbt /usr/app/dbt

# Set the environment variable for DBT profiles
ENV DBT_PROFILES_DIR=/usr/app/dbt

# Command to keep the container alive (optional, depending on how you want it to run)
CMD ["tail", "-f", "/dev/null"]
