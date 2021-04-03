USE SCHRUDY
/*Business Rules*/
GO
--BUSINESS RULE 1: NO COVID RULE
--ALL NEW EMPLOYEES MUST HAVE THE COVID SHOT BEFORE ENROLLING
CREATE FUNCTION fn_covidCheckEmployees()
RETURNS INT
AS
BEGIN
DECLARE @RET int = 0
IF EXISTS (SELECT * FROM tblEMPLOYEE
WHERE if_covid_shot_id = 2)
SET @RET = 1
RETURN @RET
END
GO
-------------------------------------------------------------------
ALTER TABLE tblEMPLOYEE
ADD CONSTRAINT CK_covidCheck CHECK (dbo.fn_covidCheckEmployees()=0)
-------------------------------------------------------------------
--TEST: THIS SHOULD NOT WORK
EXEC sp_addRowEmployee
@position_name = 'juicer',
@if_covid = 'no',
@fname = 'David',
@lname = 'Wallace',
@hire_date = '2020-8-1',
@email = 'dsad',
@dob = '1695-4-5'
-------------------------------------------------------------------
--BUSINESS RULE NO 2: NO EMPLOYEE SHOLD BE YOUNGER THAN 18 OR ORDER THAN 75
GO
CREATE FUNCTION fn_employeeAgeLimit()
RETURNS INT
AS
BEGIN
DECLARE @RET int = 0
IF EXISTS (SELECT * FROM tblEMPLOYEE
WHERE emp_dob < DateAdd(Year, -75, GetDate())
OR emp_dob > DateAdd(Year, -18, GetDate()))
SET @RET = 1
RETURN @RET
END
GO
-------------------------------------------------------------------
ALTER TABLE tblEMPLOYEE
ADD CONSTRAINT CK_ageLimit CHECK (dbo.fn_employeeAgeLimit()=0)
-------------------------------------------------------------------
--TEST: This SHOULD NOT WORK
EXEC sp_addRowEmployee
@position_name = 'juicer',
@if_covid = 'yes',
@fname = 'David',
@lname = 'Wallace',
@hire_date = '2020-8-1',
@email = 'dsad',
@dob = '1900-4-5'
------------------------------------------------------------------
--BUSINESS RULE NO 3: NO LIVESTOCK OF OLDER THAN 20 YEATS OLD CAN BE ADDED.
GO
CREATE FUNCTION fn_livestockNoOlder20()
RETURNS INT
AS
BEGIN
DECLARE @RET int = 0
IF EXISTS (SELECT * FROM tblLIVESTOCK WHERE livestock_dob < DateAdd(Year,-20, GetDate()))
SET @RET = 1
RETURN @RET
END
GO
------------------------------------------------------------------
ALTER TABLE tblLIVESTOCK
ADD CONSTRAINT CK_livestockAgeLimit CHECK (dbo.fn_livestockNoOlder20()=0)
------------------------------------------------------------------
EXEC sp_addRowLIVESTOCK
@livestock_type_name = 'chicken',
@gender_name = 'female',
@dob = '1900-1-3',
@livestock_name = 'chloe the alpha chicken'
------------------------------------------------------------------
--BUSINESS RULE NO 4: A SINGLE CUSTOMER CAN NOT PLACE AN ORDER WITH OVER 50 QUANTITY.
GO
ALTER FUNCTION fn_quantityMax()
RETURNS INT
AS
BEGIN
DECLARE @RET int = 0
IF EXISTS (SELECT * FROM tblORDER WHERE quantity >= 50)
SET @RET = 1
RETURN @RET
END
GO
------------------------------------------------------------------
ALTER TABLE tblORDER
ADD CONSTRAINT CK_quantityMax CHECK (dbo.fn_quantityMax()=0)
------------------------------------------------------------------
EXEC sp_addRowOrder
@customerfname = 'kate',
@customerlname = 'riley',
@orderTypeName = 'delivery',
@empfname = 'Andy',
@emplname = 'bernard',
@productname = 'eggsA',
@quantity = 80
------------------------------------------------------------------
--BUSINESS RULES 5: NO CUSTOMERS FROM ALASKA(AK) CAN BE ADDED
GO
CREATE FUNCTION fn_noAlaskaCustomer()
RETURNS INT
AS
BEGIN
DECLARE @RET int = 0
IF EXISTS (SELECT * FROM tblSTATE S
JOIN tblCUSTOMER C ON S.state_id = C.state_id
WHERE state_abbreviation = 'AK')
SET @RET = 1
RETURN @RET
END
GO
ALTER TABLE tblCUSTOMER
ADD CONSTRAINT CK_noAlaskaCustomer CHECK (dbo.fn_noAlaskaCustomer()=0)
------------------------------------------------------------------
ALTER TABLE tblCUSTOMER
drop CONSTRAINT CK_noAlaskaCustomer
------------------------------------------------------------------
EXEC sp_addRowCustomer
@StateAbbre = 'WA', --existing
@OrganizationName = 'Portage Bay', --existing
@CustomerTypeName = 'Whole sale', --existing
@customerfname = 'Jack', --new
@customerlname = 'Jones', --new
@phone = '634495', --new
@email = 'jacjones@yahoo.com', --new
@customerdesc = 'short, dark and handsome' --new
------------------------------------------------------------------
--BUSINESS RULES 6: THE ORDER TOTAL FOR DELIVERY MUST NOT BE LESS THEN $4.
GO
CREATE FUNCTION fn_priceSpentMin()
RETURNS INT
AS
BEGIN
DECLARE @RET int = 0
IF EXISTS (SELECT * FROM tblORDER O
JOIN tblORDERTYPE OT ON O.order_type_id= OT.order_type_id
WHERE order_total_price <= 4 AND order_type_name = 'delivery')
SET @RET = 1
RETURN @RET
END
GO
------------------------------------------------------------------
ALTER TABLE tblORDER
ADD CONSTRAINT CK_priceSpentMin CHECK (dbo.fn_priceSpentMin()=0)
------------------------------------------------------------------
EXEC sp_addRowOrder
@customerfname = 'kate',
@customerlname = 'riley',
@orderTypeName = 'delivery',
@empfname = 'Andy',
@emplname = 'bernard',
@productname = 'beetroot',
@quantity = 1
------------------------------------------------------------------
--BUSINESS RULE 7: EVENT NAME AND MEASUREMENT NAME MUST MATCH FOR MILKING AND JUICING WITH GALLON.
GO
ALTER FUNCTION fn_noGallonNonMilkingJuicing()
RETURNS INT
AS
BEGIN
DECLARE @RET int = 0
IF EXISTS(
SELECT * FROM tblEVENT E JOIN tblEMP_EVENT EE
ON E.event_id = EE.event_id
JOIN tblMEASUREMENT M
ON M.measurement_id = EE.measurement_id
WHERE event_name IN ('goat milking','cow milking', 'beets juicing')
AND measurement_name != 'gallon'
)
SET @RET = 1
RETURN @RET
END
GO
-----------------------------------------------------------------------------------
ALTER TABLE tblEMP_EVENT
ADD CONSTRAINT CK_noGallonNonMilkingJuicing CHECK (dbo.fn_noGallonNonMilkingJuicing() = 0)
-----------------------------------------------------------------------------------
--THIS SHOULD NOT WORK BECAUSE COW MILKING CAN'T BE MEASURED IN GALLON
EXEC sp_addRowEmp_Event
@empfname = 'Mose',
@emplname = 'Schrute',
@measurementName = 'lbs',
@eventName = 'cow milking',
@date = '2021-3-4',
@quantity = '5'
-----------------------------------------------------------------------------------
--BUSINESS RULE 8: NO DELIVERY ORDER IS ALLOWED OUTSIDE OF WASHINGTON.
GO
ALTER FUNCTION fn_noDeliveryOtherThanWA()
RETURNS INT
AS
BEGIN
DECLARE @RET int = 0
IF EXISTS(
SELECT *
FROM tblSTATE S
JOIN tblCUSTOMER C ON C.state_id = S.state_id
JOIN tblORDER OD ON OD.customer_id = C.customer_id
JOIN tblORDERTYPE OT ON OT.order_type_id = OD.order_type_id
WHERE state_abbreviation NOT IN ('WA')
AND OT.order_type_name = 'delivery'
)
SET @RET = 1
RETURN @RET
END
GO
ALTER TABLE tblORDER WITH NOCHECK
ADD CONSTRAINT CK_noDeliveryOtherThanWA CHECK (dbo.fn_noDeliveryOtherThanWA() = 0)
------------------------------------------------------------------
alter table tblorder
drop constraint CK_noDeliveryOtherThanWA
---------------------------------------------------------
EXEC sp_addRowOrder
@customerfname = 'Ned',
@customerlname = 'Baker',
@orderTypeName = 'delivery',
@empfname = 'Andy',
@emplname = 'bernard',
@productname = 'eggsA',
@quantity = 2