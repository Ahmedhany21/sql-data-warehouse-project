/*
==============================================================
Create Database and Schemas
==============================================================
Script Purpose:
    This Script creates a new database named 'DataWareHouse' after checking if it already exists.
    If the database exists, it's dropped and recreated. Additionally, The script sets up three schemas
    within the database: 'bronze', 'silver', 'gold'.

WARNING:
    Running this script will drop the entire 'DataWareHouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this scripts.
*/

USE master;
GO

USE DataWareHouse;

-- CHECK if the database already exists of not
-- DROP and recreate the 'DataWareHouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWareHouse')
BEGIN
    ALTER DATABASE DataWareHouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWareHouse;
END;
GO

-- CREATE THE DATABASE 
CREATE DATABASE DataWareHouse;

USE DataWareHouse;

-- CREATE SCHEMAS 
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
