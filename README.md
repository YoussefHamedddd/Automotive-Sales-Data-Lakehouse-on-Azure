# Automotive Sales Data Lakehouse — Medallion Architecture on Azure

![Architecture](https://github.com/YoussefHamedddd/Automotive-Sales-Data-Lakehouse-on-Azure/blob/main/docs/Project%20Architecture.png)

---

## Overview

This project implements a **production-grade end-to-end Data Engineering pipeline** that processes automotive sales data using Microsoft Azure services. The pipeline uses **Medallion Architecture (Bronze, Silver, Gold)** with **Incremental Loading via Watermark Pattern** to efficiently process only new data on each run.

---

## Setup Instructions

### Step 1 — Prepare the Azure SQL Database

1. Create an **Azure SQL Database** on Azure Portal
2. Open the **Query Editor** inside Azure Portal
3. Run the following SQL to create the required tables:

```sql
CREATE TABLE Source_cars_data (
    Branch_ID     NVARCHAR(50),
    Dealer_ID     NVARCHAR(50),
    Model_ID      NVARCHAR(50),
    Revenue       BIGINT,
    Units_Sold    INT,
    Date_ID       NVARCHAR(50),
    Day           INT,
    Month         INT,
    Year          INT
);

CREATE TABLE water_mark (
    last_load NVARCHAR(50)
);

INSERT INTO water_mark (last_load) VALUES ('DT00000');
```

4. Download the CSV file from the **data/** folder in this repository
5. Import the CSV data into **Source_cars_data** using the Query Editor

---

### Step 2 — Configure ADLS Gen2 Containers

Before running any pipeline, make sure the following **three containers exist** in your Azure Data Lake Storage Gen2 account:

| Container | Purpose |
|-----------|---------|
| **bronze** | Raw data copied from SQL Server |
| **silver** | Cleaned and transformed data |
| **gold** | Star Schema tables for analytics |

---

### Step 3 — Configure Azure Data Factory (Incremental Load)

The pipeline uses a **Watermark Pattern** to load only new records on each run instead of reloading all data.

![ADF Incremental Loading Pipeline](https://github.com/YoussefHamedddd/Automotive-Sales-Data-Lakehouse-on-Azure/blob/main/docs/ADF%20Pipline.png)

Build the following pipeline activities in ADF in this exact order:

| Activity | Type | Description |
|----------|------|-------------|
| **Get_Max_DateID** | Lookup | Gets MAX(Date_ID) from Source_cars_data |
| **Get_Last_Watermark** | Lookup | Gets last loaded Date_ID from water_mark |
| **Set_New_Watermark** | Set Variable | Stores the new max Date_ID |
| **Set_Last_Watermark** | Set Variable | Stores the last loaded Date_ID |
| **Incremental_Load_To_Bronze** | Copy Data | Copies only new records to Bronze container |
| **Update_WatermarkTable** | Stored Procedure | Updates water_mark table with the new value |

Add the following **Pipeline Variables** before running:

| Name | Type | Default Value |
|------|------|---------------|
| **source_date** | String | DT00000 |
| **last_load** | String | DT00000 |

The Copy Data query used in **Incremental_Load_To_Bronze**:

```sql
@concat(
  'SELECT * FROM Source_cars_data WHERE Date_ID > ''',
  variables('last_load'),
  ''''
)
```

The Stored Procedure used to update the watermark:

```sql
CREATE PROCEDURE [dbo].[UpdateWatermarkTable]
    @LastLoad NVARCHAR(50)
AS
BEGIN
    UPDATE water_mark
    SET last_load = @LastLoad
END
```

---

### Step 4 — Launch Azure Databricks and Configure Credentials

1. Launch your **Azure Databricks workspace**
2. Create a new **cluster** (Serverless compute recommended)
3. Configure your ADLS Gen2 credentials in the cluster or notebook:

```python
spark.conf.set(
    "fs.azure.account.key.<your_storage_account>.dfs.core.windows.net",
    "<your_storage_account_access_key>"
)
```

---

### Step 5 — Run the Silver Layer Notebook

1. Import **notebooks/Bronze_To_Silver.py** into your Databricks workspace
2. Update the config section with your storage account name:

```python
storage_account  = "your_storage_account_name"
container_bronze = "bronze"
container_silver = "silver"
```

3. Run all cells — the notebook will:
   - **Remove duplicate rows**
   - **Cast columns** to correct data types
   - **Fill missing string values** with "Unknown"
   - **Handle null Revenue** based on Units_Sold business logic
   - **Remove negative values**
   - **Filter outliers** using IQR method
   - **Save to ADLS Gen2** as Delta format using MERGE pattern

---

### Step 6 — Run the Gold Layer Notebook

1. Import **notebooks/Silver_To_Gold.py** into your Databricks workspace
2. Update the config section:

```python
storage_account  = "your_storage_account_name"
container_silver = "silver"
container_gold   = "gold"
CATALOG          = "cars_catalog"
SCHEMA           = "gold"
```

3. Run all cells — the notebook will create the following tables in **Unity Catalog**:

| Table | Type | Key |
|-------|------|-----|
| **dim_date** | Dimension | Date_ID |
| **dim_branch** | Dimension | Branch_ID |
| **dim_dealer** | Dimension | Dealer_ID |
| **dim_product** | Dimension | Model_ID |
| **fact_sales** | Fact | Sale_SK (Surrogate Key) |

**Star Schema Design:**

![Star Schema](https://github.com/YoussefHamedddd/Automotive-Sales-Data-Lakehouse-on-Azure/blob/main/docs/Star%20Schema.png)

---

### Step 7 — Connect Power BI

1. Open **Power BI Desktop**
2. Select **Get Data — Databricks**
3. Enter your connection details:
   - **Server Hostname:** your-workspace.azuredatabricks.net
   - **HTTP Path:** from SQL Warehouse settings in Databricks
4. Select all tables from **cars_catalog.gold**
5. Build your reports using the Star Schema

---

## Tech Stack

| Category | Technology |
|----------|------------|
| **Cloud Platform** | Microsoft Azure |
| **Data Source** | Azure SQL Database |
| **Orchestration** | Azure Data Factory |
| **Storage** | Azure Data Lake Storage Gen2 |
| **File Format** | Delta Lake |
| **Compute** | Azure Databricks |
| **Language** | PySpark |
| **Catalog** | Databricks Unity Catalog |
| **Visualization** | Power BI |
| **Architecture Pattern** | Medallion Architecture |
| **Load Pattern** | Incremental Load — Watermark Pattern |
