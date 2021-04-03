/**Stored Procedures**/
USE SCHRUDY
GO
-----------------------------------------------------------
/*Creating the stored procedure for tblCUSTOMER. tblCUSTOMER
has 3 FKs, they are organization_id, state_id and
customer_type_id. We first write the procedures for each to
get the name based on its id before we created the nested
stored procedure for tblCUSTOMER*/
CREATE PROCEDURE sp_getOrganizationID
@this_organization_name varchar (50),
@this_organization_ID int OUTPUT
AS
SET @this_organization_ID =
(SELECT organization_id FROM tblORGANIZATION
WHERE organization_name = @this_organization_name)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_getStateID
@this_State_abbreviation varchar (50),
@this_State_ID int OUTPUT
AS
SET @this_State_ID =
(SELECT state_id FROM tblSTATE
WHERE state_abbreviation = @this_State_abbreviation)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_getCustomerTypeID
@this_cus_type_name varchar (50),
@this_cus_type_ID int OUTPUT
AS
SET @this_cus_type_ID =
(SELECT customer_Type_id FROM tblCUSTOMERTYPE
WHERE customer_type_name = @this_cus_type_name)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_addRowCustomer
@StateAbbre varchar (50),
@OrganizationName varchar (50),
@CustomerTypeName varchar(50),
@customerfname varchar(50),
@customerlname varchar(50),
@customerdesc varchar(255),
@phone varchar(50),
@email varchar(50)
AS
DECLARE @customerType_ID int, @state_ID int, @organization_ID int
EXEC sp_getCustomerTypeID
@this_cus_type_name = @CustomerTypeName,
@this_cus_type_ID = @customerType_ID OUTPUT
---stop the problem here if there is an error
IF @customerType_ID IS NULL
BEGIN
PRINT 'the thing you entered doesnt exist. check spelling plz';
THROW 54321, 'the thing you entered is null and that is a problem',1;
END
EXEC sp_getStateID
@this_State_abbreviation = @StateAbbre,
@this_State_ID = @State_ID OUTPUT
IF @State_ID IS NULL
BEGIN
PRINT 'the thing you entered doesnt exist. check spelling plz';
THROW 54321, 'the thing you entered is null and that is a problem',1;
END
EXEC sp_getOrganizationID
@this_Organization_name = @OrganizationName,
@this_organization_ID = @Organization_ID OUTPUT
IF @Organization_ID IS NULL
BEGIN
PRINT 'the thing you entered doesnt exist. check spelling plz';
THROW 54321, 'the thing you entered is null and that is a problem',1;
END
BEGIN TRAN T1
INSERT INTO tblCUSTOMER(customer_type_id, state_id,
organization_id, customer_first_name,
customer_last_name, phone, email)
VALUES (@customerType_ID, @State_ID, @Organization_ID,
@customerfname, @customerlname, @phone, @email )
-- error-handling goes here
IF @@ERROR <> 0
BEGIN
PRINT 'Hello, an error has occurred in the final bits of the transaction; we are rolling back'
ROLLBACK TRAN T1
END
ELSE
COMMIT TRANSACTION T1
-----------------------------------------------------------
EXEC sp_addRowCustomer
@StateAbbre = 'WA', --existing
@OrganizationName = 'Portage Bay', --existing
@CustomerTypeName = 'Whole sale', --existing
@customerfname = 'Jimmy', --new
@customerlname = 'Jones', --new
@phone = '6951357895', --new
@email = 'jjones@yahoo.com', --new
@customerdesc = 'tall, dark and handsome' --new
-----------------------------------------------------------
/*Creating the stored procedure for tblLIVESTOCK. tblLIVESTOCK
has 2 FKs, they are gender_id and livestock_type_id.
We first write the procedures for each to
get the name based on its id before we created the nested
stored procedure for tblLIVESTOCK*/
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_getGender_id
@this_gender_name varchar(20),
@this_gender_id int OUTPUT
AS
SET @this_gender_id =
(SELECT gender_id FROM tblgender
WHERE gender_name = @this_gender_name)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_getLivestock_type_id
@this_livestock_type_name varchar(20),
@this_livestock_type_id int OUTPUT
AS
SET @this_livestock_type_id =
(SELECT livestock_type_id FROM tblLIVESTOCKTYPE
WHERE livestock_type_name = @this_livestock_type_name)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_addRowLIVESTOCK
@livestock_type_name varchar(20),
@gender_name varchar(20),
@dob date,
@livestock_name varchar(50)
AS
DECLARE @livestock_type_id int, @gender_id int
exec sp_getLivestock_type_id
@this_livestock_type_name = @livestock_type_name,
@this_livestock_type_id = @livestock_type_id OUTPUT
exec sp_getGender_id
@this_gender_name = @gender_name,
@this_gender_id = @gender_id OUTPUT
BEGIN TRAN t1
INSERT INTO tblLIVESTOCK(livestock_type_id,
gender_id, livestock_dob, livestock_name)
VALUES (@livestock_type_id, @gender_id,
@dob, @livestock_name)
COMMIT TRAN t1
-----------------------------------------------------------
EXEC sp_addRowLIVESTOCK
@livestock_type_name = 'chicken', --existing
@gender_name = 'female', --existing
@dob = '2021-1-3', --new
@livestock_name = 'jimmy the alpha chicken'--new
-----------------------------------------------------------
/*Creating the stored procedure for tblEMPLOYEE. tblEMPLOYEE
has 2 FKs, they are if_covid_shot_id and position_id.
We first write the procedures for each to
get the name based on its id before we created the nested
stored procedure for tblEMPLOYEE*/
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_getIfCovid
@this_ifCovid varchar(20),
@this_ifCovid_id int OUTPUT
AS
SET @this_ifCovid_id =
(SELECT if_covid_shot_id FROM tblIFCOVIDSHOT
WHERE if_covid_shot_name = @this_ifCovid)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_positionID
@this_positionName varchar(20),
@this_position_id int OUTPUT
AS
SET @this_position_id =
(SELECT position_id FROM tblPOSITION
WHERE position_name = @this_positionName)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_newRowEmployee
@position_name varchar(20),
@if_covid varchar(20),
@fname varchar (20),
@lname varchar (20),
@hire_date date,
@email varchar(20),
@dob date
AS
DECLARE @position_id int, @if_covid_id int
--
EXEC sp_getIfCovid
@this_ifCovid = @if_covid,
@this_ifCovid_id = @if_covid_id OUTPUT
--
EXEC sp_positionID
@this_positionName = @position_name,
@this_position_id = @position_id OUTPUT
--
BEGIN TRAN t1
INSERT INTO tblEMPLOYEE(position_id, if_covid_shot_id,
employee_first_name, employee_last_name, hire_date,
employee_email, emp_dob)
VALUES (@position_id, @if_covid_id, @fname,
@lname, @hire_date, @email, @dob)
-- error-handling goes here
IF @@ERROR <> 0
BEGIN
PRINT 'Hello, an error has occurred in the final bits of the transaction; we are rolling back'
ROLLBACK TRAN T1
END
ELSE
COMMIT TRANSACTION T1
-----------------------------------------------------------
EXEC sp_newRowEmployee
@position_name = 'juicer',--existing
@if_covid = 'yes', --existing
@fname = 'David', --new
@lname = 'Wallace', --new
@hire_date = '2020-6-8', --new
@email = 'dwallace@mit.edu', --new
@dob = '1950-6-29' --new
-----------------------------------------------------------
/*Creating the stored procedure for tblPRODUCT. tblPRODUCT
has 2 FKs, they are farm_id and producttype_id.
We first write the procedures for each to
get the name based on its id before we created the nested
stored procedure for tblPRODUCT*/
GO
CREATE PROCEDURE sp_getFarmID
@this_farmName varchar(50),
@this_farmid int OUTPUT
AS
SET @this_farmid = (SELECT farm_id FROM tblFARM
WHERE farm_name = @this_farmName)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_getProducttypeID
@this_producttypeName varchar(20),
@this_producttypeID int OUTPUT
AS
SET @this_producttypeID = (SELECT product_type_id
FROM tblPRODUCTTYPE
WHERE product_type_name = @this_producttypeName )
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_addRowProduct
@farmName varchar(50),
@productTypeName varchar(50),
@productName varchar(50),
@productDescription varchar(255),
@current_price money
AS
DECLARE @farm_id int, @producttypeID int
--
EXEC sp_getFarmID
@this_farmName = @farmName,
@this_farmid = @farm_id OUTPUT
--
EXEC sp_getProducttypeID
@this_producttypeName = @productTypeName,
@this_producttypeID = @producttypeID OUTPUT
--
BEGIN TRAN t1
INSERT INTO tblPRODUCT(farm_id, product_type_id,
product_name, product_description, current_price)
VALUES (@farm_id, @producttypeID, @productName,
@productDescription, @current_price)
-- error-handling goes here
IF @@ERROR <> 0
BEGIN
PRINT 'Hello, an error has occurred in the final bits of the transaction; we are rolling back'
ROLLBACK TRAN T1
END
ELSE
COMMIT TRANSACTION T1
-----------------------------------------------------------
EXEC sp_addRowProduct
@farmName = 'Schrute Farm', --existing
@productTypeName = 'Farm Merch', --existing
@productName = 'D-shirt', --new
@productDescription = 'A T-shirt, but with a D', --new
@current_price = '40' --new
-----------------------------------------------------------
/*Creating the stored procedure for tblPRICEHISTORY. tblPRICEHISTORY
has 1 FK, it is product_id.*/
GO
CREATE PROCEDURE sp_getProductID
@this_productName varchar(50),
@this_productid int OUTPUT
AS
SET @this_productid = (SELECT product_id
FROM tblPRODUCT WHERE product_name = @this_productName)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_addRowPriceHistory
@productName varchar(50),
@from_date date,
@to_date date,
@price money
AS
DECLARE @productID int
EXEC sp_getProductID
@this_productName = @productName,
@this_productid = @productID OUTPUT
BEGIN TRAN t1
INSERT INTO tblPRICEHISTORY(product_id, from_date, to_date, price_amount)
VALUES (@productID, @from_date, @to_date, @price)
COMMIT TRAN t1
-----------------------------------------------------------
EXEC sp_addRowPriceHistory
@productName = 'D-shirt',
@from_date = '2021-1-1',
@to_date ='2021-12-31',
@price = '40'
-----------------------------------------------------------
/*Creating the stored procedure for tblORDER. tblORDER
has 4 FKs, they are pruduct_id, order_type_id, customer_id,
and employee_id.
We first write the procedures for each to
get the name based on its id before we created the nested
stored procedure for tblORDER*/
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_getOrderTypeid
@this_ordertypeName varchar(20),
@this_ordertypeID int OUTPUT
AS
SET @this_ordertypeID =
(SELECT order_type_id
FROM tblORDERTYPE
WHERE order_type_name = @this_ordertypeName)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_getCustomerID
@this_cusfname varchar(20),
@this_cuslname varchar(20),
@this_customerid int OUTPUT
AS
SET @this_customerid =
(SELECT customer_id FROM tblCUSTOMER
WHERE customer_first_name = @this_cusfname
AND customer_last_name=@this_cuslname)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_getEmployeeID
@this_empfname varchar(20),
@this_emplname varchar(20),
@this_empid int OUTPUT
AS
SET @this_empid =
(SELECT employee_id FROM tblEMPLOYEE
WHERE employee_first_name = @this_empfname
AND employee_last_name = @this_emplname)
-----------------------------------------------------------
GO
/*Create a function to return the current pricing that is reflected
on tblPRODUCT*/
CREATE FUNCTION fn_getCurrentPrice(@PK int)
RETURNS money
AS
BEGIN
DECLARE @ret money
SELECT @ret = current_price FROM tblPRODUCT WHERE product_id = @PK
RETURN @ret
END
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_addRowOrder
@customerfname varchar(50),
@customerlname varchar(50),
@orderTypeName varchar(20),
@empfname varchar(50),
@emplname varchar(50),
@productname varchar(50),
@quantity int
AS
DECLARE @customerID int, @ordertypeID int,
@empid int, @productID int, @totalPrice money,
@orderDate date
--
EXEC sp_getCustomerID
@this_cusfname = @customerfname,
@this_cuslname = @customerlname,
@this_customerid = @customerID OUTPUT
--
EXEC sp_getOrderTypeid
@this_ordertypeName = @orderTypeName,
@this_ordertypeID = @ordertypeID OUTPUT
--
EXEC sp_getEmployeeID
@this_empfname = @empfname,
@this_emplname = @emplname,
@this_empid = @empid OUTPUT
--
EXEC sp_getProductID
@this_productName = @productname,
@this_productid = @productID OUTPUT
SET @orderDate = GETDATE()
SET @totalPrice = dbo.fn_getCurrentPrice(@productID) * @quantity
BEGIN TRAN t1
INSERT INTO tblORDER(customer_id, order_type_id,
product_id, employee_id, order_date, order_total_price, quantity)
VALUES (@customerID, @ordertypeID, @productID,
@empid , @orderDate, @totalPrice, @quantity)
-- error-handling goes here
IF @@ERROR <> 0
BEGIN
PRINT 'Hello, an error has occurred in the final bits of the transaction; we are rolling back'
ROLLBACK TRAN T1
END
ELSE
COMMIT TRANSACTION T1
-----------------------------------------------------------
EXEC sp_addRowOrder
@customerfname = 'kate',
@customerlname = 'riley',
@orderTypeName = 'delivery',
@empfname = 'Andy',
@emplname = 'bernard',
@productname = 'eggsA',
@quantity = 2
-----------------------------------------------------------
/*Creating the stored procedure for tblEVENT. tblEVENT
has 1 FK, and it is event_type_id*/
GO
CREATE PROCEDURE sp_getEventtypeID
@this_eventtypeName varchar(20),
@this_eventtypeID int OUTPUT
AS
SET @this_eventtypeID =
(SELECT event_type_id
FROM tblEVENTTYPE
WHERE event_type_name = @this_eventtypeName)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_addEvent
@eventtypeName varchar(20),
@eventName varchar(20),
@event_description varchar(255)
AS
DECLARE @eventtypeID int
EXEC sp_getEventtypeID
@this_eventtypeName = @eventtypeName,
@this_eventtypeID = @eventtypeID OUTPUT
BEGIN TRAN t1
INSERT INTO tblEVENT(event_type_id, event_name, event_description)
VALUES (@eventtypeID, @eventName, @event_description)
COMMIT TRAN t1
-----------------------------------------------------------
EXEC sp_addEvent
@eventtypeName = 'maintenance',
@eventName = 'feeding',
@event_description = 'feed them animals'
-----------------------------------------------------------
/*Creating the stored procedure for tblEMP_EVENT. tblEMP_EVENT
has 3 FKs, they are event_id, measurement_id, and employee_id
We first write the procedures for each to
get the name based on its id before we created the nested
stored procedure for tblEMP_EVENT*/
GO
CREATE PROCEDURE sp_getMeasurementID
@this_measurementName varchar(50),
@this_measurementID int OUTPUT
AS
SET @this_measurementID =
(SELECT measurement_id
FROM tblMEASUREMENT
WHERE measurement_name = @this_measurementName)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_getEventID
@this_eventName varchar(50),
@this_eventid int OUTPUT
AS
SET @this_eventid =
(SELECT event_id
FROM tblEVENT
WHERE event_name = @this_eventName)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_addRowEmp_Event
@empfname varchar(20),
@emplname varchar(20),
@measurementName varchar(20),
@eventName varchar(20),
@date date,
@quantity float
AS
DECLARE @empid int, @measurementid int, @eventid int
EXEC sp_getEmployeeID
@this_empfname = @empfname,
@this_emplname = @emplname,
@this_empid = @empid OUTPUT
--
EXEC sp_getMeasurementID
@this_measurementName = @measurementName,
@this_measurementID = @measurementid OUTPUT
--
EXEC sp_getEventID
@this_eventName = @eventName,
@this_eventid = @eventid OUTPUT
BEGIN TRAN t1
INSERT INTO tblEMP_EVENT(measurement_id,
event_id, [date], quantity, employee_id)
VALUES (@measurementid, @eventid, @date,
@quantity, @empid)
COMMIT TRAN t1
-----------------------------------------------------------
EXEC sp_addRowEmp_Event
@empfname = 'Mose',
@emplname = 'Schrute',
@measurementName = 'Gallon',
@eventName = 'cow milking',
@date = '2021-3-4',
@quantity = '5'
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_getEmployeeEventID
@this_date date,
@this_employeefname varchar(50),
@this_employeelname varchar(50),
@this_eventName varchar(50),
@this_employeeEventID int OUTPUT
AS
DECLARE @empid int, @event_id int
SET @empid = (SELECT employee_id
FROM tblEMPLOYEE
WHERE employee_first_name = @this_employeefname
AND employee_last_name = @this_employeelname)
SET @event_id = (SELECT event_id FROM tblEVENT WHERE event_name = @this_eventName)
SET @this_employeeEventID = (SELECT employee_event_id FROM tblEMP_EVENT
WHERE employee_id = @empid
AND [date] = @this_date AND event_id = @event_id)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_addRowEmp_Event_Product
@productName varchar(50),
@date date,
@employeefname varchar(50),
@employeelname varchar(50),
@eventName varchar(50)
AS
DECLARE @employeeEventid int, @productID int
EXEC sp_getProductID
@this_productName = @productName,
@this_productid = @productID OUTPUT
EXEC sp_getEmployeeEventID
@this_date = @date,
@this_employeefname = @employeefname,
@this_employeelname = @employeelname,
@this_eventName = @eventName,
@this_employeeEventID = @employeeEventid OUTPUT
BEGIN TRAN t1
INSERT INTO tblEMP_EVENT_PRODUCT(product_id, employee_event_id)
VALUES (@productID, @employeeEventid)
COMMIT TRAN t1
-----------------------------------------------------------
EXEC sp_addRowEmp_Event_Product
@productName = 'goat milk',
@date = '2021-03-01',
@employeefname = 'Angela' ,
@employeelname = 'Martin',
@eventName = 'goat milking'
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_getLivestockID
@this_livestockName varchar(50),
@this_livestockid int OUTPUT
AS
SET @this_livestockid =
(SELECT livestock_id
FROM tblLIVESTOCK
WHERE livestock_name = @this_livestockName)
-----------------------------------------------------------
GO
CREATE PROCEDURE sp_addRowEmp_Event_Livestock
@livestockName varchar(50),
@date date,
@employeefname varchar(50),
@employeelname varchar(50),
@eventName varchar(50)
AS
DECLARE @employeeEventid int, @livestockID int
EXEC sp_getLivestockID
@this_livestockName = @livestockName,
@this_livestockid = @livestockID OUTPUT
EXEC sp_getEmployeeEventID
@this_date = @date,
@this_employeefname = @employeefname,
@this_employeelname = @employeelname,
@this_eventName = @eventName,
@this_employeeEventID = @employeeEventid OUTPUT
BEGIN TRAN t1
INSERT INTO tblEMP_EVENT_LIVESTOCK(livestock_id, employee_event_id)
VALUES (@livestockID, @employeeEventid)
COMMIT TRAN t1
--------------------------------------------------------
EXEC sp_addRowEmp_Event_Livestock
@livestockName = 'Luana',
@date = '2021-03-01',
@employeefname = 'Angela' ,
@employeelname = 'Martin',
@eventName = 'goat milking'
--------------------------------------------------------