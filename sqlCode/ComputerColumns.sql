/*Computed Columns*/
--Create a column that returns the
--age of the employees in tblEMPLOYEE
CREATE FUNCTION fn_computeAgeEmployees(@PK int)
RETURNS int
AS
BEGIN
DECLARE @RET int = (SELECT DateDiff(Year, emp_dob, GetDate())
FROM tblEMPLOYEE
WHERE @PK = employee_id)
RETURN @RET
END
GO
----------------------------------------------------------------
--add a new column called employee_age to tblEMPLOYEE
ALTER TABLE tblEMPLOYEE
ADD employee_age AS (dbo.fn_computeAgeEmployees(employee_id))
----------------------------------------------------------------
--Create a column that returns the total sale of an order
--Note total sale is calculated using current_price from
--tblPRODUCT and quantity from tblORDER. The pricing should
--always reflect the current pricing, rather than the old ones.
GO
CREATE FUNCTION fn_computeAgeEmployees(@PK int)
RETURNS int
AS
BEGIN
DECLARE @RET int = (SELECT DateDiff(Year, emp_dob, GetDate())
FROM tblEMPLOYEE
WHERE @PK = employee_id)
RETURN @RET
END
----------------------------------------------------------------
--We will then call this function within the stored procedure
--named sp_addRowOrder. When the stored procedures is called,
--it should automatically generate a total price for the order
--eg. SET @totalPrice = dbo.fn_getCurrentPrice(@productID) * @quantity
--SEE stored procedure sp_addRowOrder
---------------------------------------------------------------
--Create a column that returns the
--age of the livestock
GO
CREATE FUNCTION fn_computeAgeLivestock(@PK int)
RETURNS int
AS
BEGIN
DECLARE @RET int = (SELECT DateDiff(Year, livestock_dob, GetDate())
FROM tblLIVESTOCK
WHERE @PK = livestock_id)
RETURN @RET
END
GO
----------------------------------------------------------------
--add a new column called livestock_age to tblLIVESTOCK
ALTER TABLE tblLIVESTOCK
ADD livestock_age AS (dbo.fn_computeAgelivestock(livestock_id))
----------------------------------------------------------------
--create a column that returns the amount of money customers
--spend in the past 3 years
GO
ALTER FUNCTION fn_computeTotalSpendinPast3Years(@PK int)
RETURNS money
AS
BEGIN
DECLARE @RET money = (SELECT subq1.total_money_spent FROM
(SELECT O.customer_id, sum(order_total_price) AS total_money_spent
FROM tblORDER O
WHERE O.order_date > DateAdd(Year, -3, GetDate())
GROUP BY O.customer_id) as subq1 WHERE @PK = customer_id)
RETURN @RET
END
GO
----------------------------------------------------------------
--Alternatively, the code can be written as the following
CREATE FUNCTION fn_alt_computeTotalSpendinPast3Years(@PK int)
RETURNS money
AS
BEGIN
DECLARE @RET money = (SELECT sum(order_total_price) AS total_money_spent
FROM tblORDER O
WHERE O.order_date > DateAdd(Year, -3, GetDate())
AND customer_id = @PK)
RETURN @RET
END
----------------------------------------------------------------
--add this computed column to tblCustomer
ALTER TABLE tblCUSTOMER
ADD totalSpentLast3Years AS (dbo.fn_computeTotalSpendinPast3Years(customer_id))
--NULL means a customer never placed an order in the past 3 years.
----------------------------------------------------------------
--returned a column that counts the number of livestock
GO
CREATE FUNCTION fn_computeCountLivestock(@PK int)
RETURNS int
AS
BEGIN
DECLARE @RET int = (SELECT subq1.livestockCount FROM
(SELECT livestock_type_id, count(livestock_id) livestockCount
FROM tblLIVESTOCK
GROUP BY livestock_type_id) AS subq1 WHERE @PK = livestock_type_id)
RETURN @RET
END
GO
----------------------------------------------------------------
--returned the column in tblLIVESTOCKCOUNT
ALTER TABLE tblLIVESTOCKTYPE
ADD livestock_type_count AS (dbo.fn_computeCountLivestock(livestock_type_id))
----------------------------------------------------------------
--return a computed column that finds the amount of money spent associated
--with each organization
GO
CREATE FUNCTION fn_computeTotalSpendbyOrg(@PK int)
RETURNS money
AS
BEGIN
DECLARE @RET money = (SELECT subq1.total_money_spent FROM
(SELECT O.organization_id, sum(order_total_price) AS total_money_spent
FROM tblORGANIZATION O JOIN tblCUSTOMER C ON C.organization_id = O.organization_id
JOIN tblORDER OD ON OD.customer_id = C.customer_id
GROUP BY O.organization_id) AS subq1 WHERE @PK = organization_id)
RETURN @RET
END
GO
----------------------------------------------------------------
ALTER TABLE tblORGANIZATION
ADD total_spend_by_org AS (dbo.fn_computeTotalSpendbyOrg(organization_id))
----------------------------------------------------------------
--calcualate a returned column that counts the number of male and female
--livestock respectively.
GO
CREATE FUNCTION fn_computeCountLivestockByGender(@PK int)
RETURNS int
AS
BEGIN
DECLARE @RET int = (SELECT subq1.genderCount FROM
(SELECT gender_id, count(livestock_id) genderCount
FROM tblLIVESTOCK
GROUP BY gender_id) AS subq1 WHERE @PK = gender_id)
RETURN @RET
END
GO
----------------------------------------------------------------
ALTER TABLE tblGENDER
ADD countLivestockByGender AS (dbo.fn_computeCountLivestockByGender(gender_id))
----------------------------------------------------------------
--a calculated column that calcuates the average price of the products
--based on tblPRICEHISTORY
GO
CREATE FUNCTION fn_computeAveragePrice(@PK int)
RETURNS money
AS
BEGIN
DECLARE @RET money = (SELECT subq1.averagePrice FROM
(SELECT product_id, AVG(price_amount) averagePrice
FROM tblPRICEHISTORY
GROUP BY product_id) AS subq1 WHERE @PK = product_id)
RETURN @RET
END
GO
----------------------------------------------------------------
ALTER TABLE tblproduct
ADD average_price AS (dbo.fn_computeAveragePrice(product_id))
----------------------------------------------------------------