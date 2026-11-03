# Getting Started with Pipeline Builder

Companion repo for the [Getting Started with Pipeline Builder](https://www.snowflake.com/en/developers/guides/getting-started-with-pipeline-builder/) Quickstart. You turn two Tasty Bytes notebooks into a scheduled task graph with Pipeline Builder in Snowflake Workspaces.

## What's in this repo

| File | Purpose |
| --- | --- |
| `setup.sql` | Creates the Quickstart role, warehouse, compute pool, database, schemas, sample orders, and the `RUN_LOG` table used by the Advanced modules. Run as ACCOUNTADMIN. |
| `01_clean_orders.ipynb` | Removes duplicate and invalid orders and writes `STAGING.ORDERS_CLEAN`. |
| `02_daily_sales.ipynb` | Aggregates clean orders into `ANALYTICS.DAILY_TRUCK_SALES`. |
| `cleanup.sql` | Purges the DCM projects and drops everything the Quickstart created. |

## How to use it

Follow the Quickstart. It walks you through creating a Git workspace from this repo in Snowsight, running `setup.sql`, and building the pipeline.

Pull the latest changes before you start. Once you move the notebooks into your Pipeline Builder project folder, your workspace has local changes, and later pulls can conflict with them.

## License

Apache 2.0. See [LICENSE](LICENSE).
