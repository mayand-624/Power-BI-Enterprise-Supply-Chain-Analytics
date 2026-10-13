# Environment Migration & Database Transition Pipeline

### Dashboard Link : https://app.powerbi.com/groups/9c466814-698b-47ad-8aa4-a8c028940330/reports/80953900-17ef-488e-a8bf-4f5f889f7b63/2c0d75ac79adbb258475?experience=power-bi

## Problem Statement

This project simulates a strict real-world corporate data engineering scenario where reporting models must scale from restricted testing sandboxes into live production environments. The primary focus of this deployment was executing a seamless transition from a localized "Test" environment (containing 99 initial records) to a live "Production" environment (scaling to 1,043 records), followed by a complete architectural migration of the underlying database from Microsoft SQL Server (SSMS) to a MySQL Database.

A critical challenge in enterprise data management is altering backend storage architectures without corrupting downstream BI semantic models. By enforcing strict schema nomenclature and utilizing Advanced Query M-Code injection, this project successfully redirected the Power BI data pipeline to a completely new database engine dynamically, achieving zero downtime and requiring no frontend report reconstruction.

Furthermore, this pipeline demonstrates proactive anomaly resolution. By intercepting referential integrity failures (unmapped foreign keys) at the SQL source level, the data was cleansed upstream, ensuring that the Power BI engine ingested a perfectly optimized, flattened schema for highly performant financial analytics.

## Repository Assets

This repository contains the complete backend and frontend architecture required to reproduce this pipeline:

- `Datasets/`: `Products.csv`, `Test+Environment+Inventory+Dataset.csv`, `Prod+Env+Inventory+Dataset.csv` (Raw dimensional and transactional data).
- `SQL_Scripts/`: `1_SQLServer_Test_to_Prod.sql` (T-SQL environment setup, anomaly resolution, and schema flattening) and `2_MySQL_Database_Migration.sql` (MySQL replication logic).
- `PowerQuery/`: `Data_Source_Migration.m` (The M-code script executing the backend database switch).
- `Report/`: `Production_Inventory_Dashboard.pbix` (The final, interactive BI dashboard).

## Steps Followed

- Step 1 : Initialized a localized `test_env` database within Microsoft SQL Server Management Studio (SSMS) and loaded the initial 99-row `Test Environment Inventory Dataset` alongside the `Products` dimension table.
- Step 2 : Executed a `LEFT JOIN` to merge daily transactional data with static product metadata. To optimize reporting performance and minimize local compute footprint, this query was materialized directly into a flattened staging table (`new_table`) using a `SELECT INTO` statement.
- Step 3 : Connected Power BI Desktop to the `test_env` database and developed the baseline Operational Logistics DAX measures, utilizing `DISTINCTCOUNT` to establish a dynamic time-scaling denominator that adapts to date filters.
- Step 4 : **Advanced DAX (Iterators & Row-Level Context):** Developed robust financial metrics to evaluate profitability. Because aggregating raw unit discrepancies would incorrectly net out profits against losses, the `SUMX` iterator function was combined with `FILTER` to evaluate positive and negative margins row-by-row before aggregation: Code snippetCode snippet
    
    ```
      Total Profit =
      SUMX(
          FILTER('Demand/Availability Data','Demand/Availability Data'[Loss/Profit]>0),
          'Demand/Availability Data'[Loss/Profit] * 'Demand/Availability Data'[unit_price]
      )
    ```
    
    ```
      Total Loss =
      SUMX(
          FILTER('Demand/Availability Data','Demand/Availability Data'[Loss/Profit]<0),
          'Demand/Availability Data'[Loss/Profit] * 'Demand/Availability Data'[unit_price]
      ) * -1
    ```
    
- Step 5 : Transitioned to the live Production environment by creating a `PROD` database in SSMS and ingesting the scaled `Prod Env Inventory Dataset` (1,043 records).
- Step 6 : **Data Cleaning & Anomaly Resolution (SQL):** During the profiling phase of the Production migration, a referential integrity failure was intercepted. The transactional table contained two anomalous foreign keys (`21` and `22`) that did not exist in the master `Products` table. To prevent loading dirty data into Power BI, standard `UPDATE` statements were deployed upstream to correct these operational misspellings (remapping to valid IDs `7` and `11` respectively): SQL
    
    ```
      update [dbo].[Prod+Env+Inventory+Dataset]
      set product_id = 7 where product_id = 21
    
      update [dbo].[Prod+Env+Inventory+Dataset]
      set product_id = 11 where product_id = 22
    ```
    

<img width="727" height="283" alt="SS2" src="https://github.com/user-attachments/assets/23cce333-13f8-44cb-904b-cd320297d9c2" />


- Step 7 : Materialized the cleansed Production data into an identical `new_table` schema. Because strict nomenclature was maintained, the initial SSMS Test-to-Prod switch was executed seamlessly via Power BI's native "Data source settings" GUI.
- Step 8 : Initiated the final architectural transition: migrating the entire backend storage layer from Microsoft SQL Server to a MySQL Database. The exact `PROD` schema, anomaly corrections, and flattened `new_table` were replicated in MySQL to ensure structural parity[cite: 7].
- Step 9 : **Live Database Migration (Power Query / M-Code):** Because the native Power BI GUI cannot translate connection protocols across fundamentally different database engines, the semantic model's connection strings were manually rewritten at the foundational M-code level.

By opening the Advanced Query Editor, the legacy SSMS string was replaced with a direct MySQL database connector logic:

```
powerquery
  Source = MySQL.Database("localhost", "prod", [ReturnSingleDatabase=true, Query="select * from new_table;"])
```
This M-code injection dynamically remapped the data pipeline to the new MySQL server without breaking any frontend visuals, applied steps, or DAX measures.


<img width="1248" height="323" alt="SS1" src="https://github.com/user-attachments/assets/ea8530fa-d65c-4b71-9cfe-a128c1c372a2" />

- Step 10 : Validated absolute data parity between the legacy SQL Server model and the new MySQL model, and published the final optimized report to the Power BI Service cloud workspace.


# Dashboard Snapshots

### Page 1: Operational Logistics (Supply vs. Demand)

<img width="1295" height="722" alt="Page1" src="https://github.com/user-attachments/assets/bb3c6e0b-d008-44b8-a577-2435511ddfb7" />

### Page 2: Financial Risk & Profitability

<img width="1292" height="722" alt="Page2" src="https://github.com/user-attachments/assets/699566ab-3372-4e1d-8350-ffe6d853c7ad" />

# Insights

A dual-page executive report was created in Power BI Desktop and deployed via Power BI Service.

Following inferences can be drawn from the dashboard:

### [1] Operational Logistics

Average Demand per Day = 48.65 Units

Average Availability per Day = 24.70 Units

Total Supply Shortage = 61K Units

```
The production environment indicates a severe logistical bottleneck, with operational demand consistently outpacing available inventory by nearly 50% on a daily basis.
```

### [2] Financial Impact & Disruption Costs

Total Profit = $301K

Total Loss = $8M

Average Daily Loss = $2.97K[cite: 6]
