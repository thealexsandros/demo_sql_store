-- MSSQL2017
-- SCHEMA

CREATE TABLE Customer (
Id UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
FullName NVARCHAR(500) NOT NULL,
RegistrationDateTimeUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE [Order] (
Id UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
CustomerId UNIQUEIDENTIFIER NOT NULL FOREIGN KEY REFERENCES Customer(Id),
CreationDateTimeUtc DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE INDEX idx_Order_CustomerId
ON [Order](CustomerId);

CREATE VIEW v_OrdersDaysAfterRegistration
WITH SCHEMABINDING
AS
SELECT 
  O.Id,
  O.CustomerId,
  DATEDIFF(DAY, CU.RegistrationDateTimeUtc, O.CreationDateTimeUtc) AS DaysAfterCustomerRegistration
FROM dbo.[Order] O
INNER JOIN dbo.Customer CU
ON CU.Id = O.CustomerId;

CREATE UNIQUE CLUSTERED INDEX ucidx_v_OrdersDaysAfterRegistration_Id 
ON v_OrdersDaysAfterRegistration(Id);

CREATE INDEX idx_v_OrdersDaysAfterRegistration_DaysAfterCustomerRegistration
ON v_OrdersDaysAfterRegistration(DaysAfterCustomerRegistration);

-- QUERY

DECLARE @MaxDaysAfterRegistration INT = 5

SELECT COUNT(DISTINCT CustomerId)
FROM v_OrdersDaysAfterRegistration WITH (NOEXPAND)
WHERE DaysAfterCustomerRegistration <= @MaxDaysAfterRegistration;
