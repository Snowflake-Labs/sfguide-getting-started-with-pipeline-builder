-- Setup for Getting Started with Pipeline Builder
-- https://www.snowflake.com/en/developers/guides/getting-started-with-pipeline-builder/
--
-- Run this file as ACCOUNTADMIN, after you create the TASTY_PIPELINE_QS_GIT_INT
-- API integration from the guide. Replace <your_username> with your Snowflake
-- user name before you run it.

USE ROLE ACCOUNTADMIN;

-- 1. Create the role for this Quickstart
CREATE ROLE IF NOT EXISTS TASTY_PIPELINE_QS_ROLE;

-- 2. Grant the role to the user who will run the Quickstart, and to SYSADMIN
-- so the role sits in the role hierarchy and admins can manage its objects
GRANT ROLE TASTY_PIPELINE_QS_ROLE TO USER <your_username>;
GRANT ROLE TASTY_PIPELINE_QS_ROLE TO ROLE SYSADMIN;

-- 3. Warehouse privileges
CREATE WAREHOUSE IF NOT EXISTS TASTY_PIPELINE_QS_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;
GRANT USAGE, OPERATE ON WAREHOUSE TASTY_PIPELINE_QS_WH TO ROLE TASTY_PIPELINE_QS_ROLE;

-- 4. Database & schema privileges
-- The role owns the database, which covers CREATE SCHEMA, CREATE TABLE,
-- CREATE TASK, CREATE CODE BUNDLE, and CREATE DCM PROJECT.
CREATE DATABASE IF NOT EXISTS TASTY_PIPELINE_QS_DB;
GRANT OWNERSHIP ON DATABASE TASTY_PIPELINE_QS_DB TO ROLE TASTY_PIPELINE_QS_ROLE COPY CURRENT GRANTS;

-- 5. Integration privileges
-- Lets the guide role use the Git API integration to pull the companion repo
GRANT USAGE ON INTEGRATION TASTY_PIPELINE_QS_GIT_INT TO ROLE TASTY_PIPELINE_QS_ROLE;

-- 6. Future grants
-- N/A for this guide

-- 7. Stage privileges
-- N/A for this guide

-- 8. Guide-specific grants
-- Compute pool for notebook tasks
CREATE COMPUTE POOL IF NOT EXISTS TASTY_PIPELINE_QS_POOL
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = CPU_X64_XS
  AUTO_RESUME = TRUE
  AUTO_SUSPEND_SECS = 300
  INITIALLY_SUSPENDED = TRUE;
GRANT USAGE, MONITOR ON COMPUTE POOL TASTY_PIPELINE_QS_POOL TO ROLE TASTY_PIPELINE_QS_ROLE;

-- Run tasks and task graphs
GRANT EXECUTE TASK ON ACCOUNT TO ROLE TASTY_PIPELINE_QS_ROLE;

-- 9. Switch into the role to create the schemas and sample data
USE ROLE TASTY_PIPELINE_QS_ROLE;
USE WAREHOUSE TASTY_PIPELINE_QS_WH;

CREATE SCHEMA IF NOT EXISTS TASTY_PIPELINE_QS_DB.RAW;
CREATE SCHEMA IF NOT EXISTS TASTY_PIPELINE_QS_DB.STAGING;
CREATE SCHEMA IF NOT EXISTS TASTY_PIPELINE_QS_DB.ANALYTICS;
CREATE SCHEMA IF NOT EXISTS TASTY_PIPELINE_QS_DB.PIPELINE;

-- About 5,000 orders across 20 trucks in 5 cities over the last 30 days
CREATE OR REPLACE TABLE TASTY_PIPELINE_QS_DB.RAW.ORDERS AS
SELECT
  SEQ4() + 1 AS order_id,
  UNIFORM(1, 20, RANDOM()) AS truck_id,
  DECODE(UNIFORM(1, 5, RANDOM()),
    1, 'Seattle', 2, 'Boston', 3, 'Denver', 4, 'Austin', 'San Mateo') AS city,
  DATEADD('minute', -UNIFORM(0, 43200, RANDOM()), CURRENT_TIMESTAMP()) AS order_ts,
  ROUND(UNIFORM(500, 6000, RANDOM()) / 100, 2) AS order_total
FROM TABLE(GENERATOR(ROWCOUNT => 5000));

-- Duplicate 200 orders
INSERT INTO TASTY_PIPELINE_QS_DB.RAW.ORDERS
SELECT * FROM TASTY_PIPELINE_QS_DB.RAW.ORDERS SAMPLE (200 ROWS);

-- Add 50 invalid orders with no timestamp and a negative total
INSERT INTO TASTY_PIPELINE_QS_DB.RAW.ORDERS
SELECT 900000 + SEQ4(), 1, 'Seattle', NULL, -1
FROM TABLE(GENERATOR(ROWCOUNT => 50));

-- Log table for the optional Advanced modules
CREATE TABLE IF NOT EXISTS TASTY_PIPELINE_QS_DB.ANALYTICS.RUN_LOG (
  logged_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP(),
  source    STRING,
  message   STRING
);

-- Expect raw_rows = 5250
SELECT COUNT(*) AS raw_rows FROM TASTY_PIPELINE_QS_DB.RAW.ORDERS;
