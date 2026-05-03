IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Staging_Kaggle')
    PRINT 'Databaza ekziston'
ELSE
    PRINT 'Databaza nuk ekziston'
GO

SELECT name FROM sys.databases;