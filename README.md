# Automotive Sales Data Lakehouse on Azure

## Project Architecture

![Project Architecture](https://github.com/YoussefHamedddd/Automotive-Sales-Data-Lakehouse-on-Azure/blob/main/docs/Project%20Architecture.png?raw=true)

## Overview

This project demonstrates an **End-to-End Azure Data Engineering Pipeline** using the **Medallion Architecture** approach (**Bronze, Silver, Gold**) to process automotive sales data.

The pipeline starts from **Azure SQL Database**, performs **Incremental Loading** using **Azure Data Factory**, processes and transforms data inside **Databricks**, and finally delivers business-ready analytics to **Power BI**.

---

# Project Workflow

## 1. Upload Dataset to Azure SQL Database

First, upload the provided dataset into your local environment, then create an **Azure SQL Database Server** and import the dataset into SQL tables.

You can use:
- SQL Server Management Studio (SSMS)

After importing the data, make sure all tables are successfully created.

---

# 2. Configure Incremental Loading using Azure Data Factory

The project uses the **Watermark Pattern** for Incremental Loading inside **Azure Data Factory**.

You need to:
- Create an ADF Pipeline
- Configure Lookup activities
- Configure Watermark variables
- Copy only new records into the Bronze Layer
- Update the watermark table after each successful load

## Incremental Loading Pipeline

![ADF Incremental Loading](https://github.com/YoussefHamedddd/Automotive-Sales-Data-Lakehouse-on-Azure/blob/main/docs/ADF%20Pipline.png?raw=true)

---

# 3. Launch Azure Databricks

After configuring ADF:

- Launch **Azure Databricks**
- Create your workspace
- Create a cluster or SQL Warehouse
- Configure Storage Credentials
- Mount or connect to your storage account

---

# 4. Create Required Containers

Before running the notebooks, make sure the following containers are created inside your **Azure Storage Account**:

- bronze
- silver
- gold

These containers will store:
- Raw Data
- Cleaned Data
- Curated Business Data

---

# 5. Run Bronze Layer Pipeline

The Bronze Layer stores raw ingested data from Azure SQL Database into Azure Data Lake Storage Gen2 using **Parquet Format**.

---

# 6. Run Silver Layer Notebook

Run the **Silver Layer Notebook** to:
- Remove duplicates
- Handle missing values
- Cast columns to proper data types
- Apply business rules
- Clean and validate the data
- Filter invalid and outlier records

The cleaned data will be stored in:
- **Delta Lake Format**

---

# 7. Run Gold Layer Notebook

Run the **Gold Layer Notebook** to:
- Build business-ready aggregated tables
- Create analytical views
- Generate KPIs
- Prepare the data for reporting

The Gold Layer uses:
- **Delta Tables**
- **Unity Catalog**
- **Star Schema Modeling**

---

# Star Schema

![Star Schema](https://github.com/YoussefHamedddd/Automotive-Sales-Data-Lakehouse-on-Azure/blob/main/docs/Star%20Schema.png?raw=true)

The model contains:

## Fact Table
- fact_sales

## Dimension Tables
- dim_date
- dim_product
- dim_branch
- dim_dealer

---

# Power BI Integration

After building the Gold Layer:

- Connect **Power BI** to **Databricks SQL Warehouse**
- Import analytical views
- Build dashboards and business reports

Example business insights:
- Revenue by Branch
- Revenue by Dealer
- Revenue by Product
- Monthly Revenue Trends

---

# Tech Stack

- **Microsoft Azure**
- **Azure SQL Database**
- **Azure Data Factory**
- **Azure Data Lake Storage Gen2**
- **Azure Databricks**
- **PySpark**
- **Delta Lake**
- **Unity Catalog**
- **SQL**
- **Power BI**
- **GitHub**

---

# Architecture Pattern

This project follows:
- **Medallion Architecture**
- **Incremental Loading Pattern**
- **Star Schema Modeling**
- **Lakehouse Architecture**
